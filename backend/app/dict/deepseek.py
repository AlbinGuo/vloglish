from __future__ import annotations

import json
import logging
import re
import urllib.error
import urllib.request

from .config import DEEPSEEK_API_KEY, DEEPSEEK_BASE_URL, DEEPSEEK_MODEL

logger = logging.getLogger(__name__)

VALID_EXAM_TAGS = frozenset({"CET4", "CET6", "TEM4", "TEM8", "TOEFL", "IELTS", "GRE"})

_EXAM_TAG_ALIASES = {
    "四级": "CET4",
    "大学四级": "CET4",
    "大学英语四级": "CET4",
    "cet4": "CET4",
    "cet-4": "CET4",
    "六级": "CET6",
    "大学六级": "CET6",
    "大学英语六级": "CET6",
    "cet6": "CET6",
    "cet-6": "CET6",
    "专四": "TEM4",
    "专业四级": "TEM4",
    "英语专业四级": "TEM4",
    "tem4": "TEM4",
    "tem-4": "TEM4",
    "专八": "TEM8",
    "专业八级": "TEM8",
    "英语专业八级": "TEM8",
    "tem8": "TEM8",
    "tem-8": "TEM8",
    "托福": "TOEFL",
    "toefl": "TOEFL",
    "雅思": "IELTS",
    "ielts": "IELTS",
    "gre": "GRE",
}


def _canonical_exam_tag(raw: str) -> str | None:
    key = raw.strip()
    if not key:
        return None
    lowered = key.lower()
    if lowered in _EXAM_TAG_ALIASES:
        return _EXAM_TAG_ALIASES[lowered]
    compact = lowered.replace("-", "").replace("_", "").replace(" ", "")
    if compact in _EXAM_TAG_ALIASES:
        return _EXAM_TAG_ALIASES[compact]
    upper = key.upper().replace("-", "").replace("_", "").replace(" ", "")
    if upper in VALID_EXAM_TAGS:
        return upper
    return None


def normalize_exam_tags(raw: object) -> list[str]:
    if not isinstance(raw, list):
        return []
    out: list[str] = []
    seen: set[str] = set()
    for item in raw:
        if not isinstance(item, str):
            continue
        normalized = _canonical_exam_tag(item)
        if normalized and normalized not in seen:
            seen.add(normalized)
            out.append(normalized)
    return out

SYSTEM_PROMPT = """你是英语学习词典助手。仅返回合法 JSON，不要 markdown 代码块，不要额外说明。

JSON 结构：
{
  "headword": "词或短语",
  "category": "单词" 或 "短语",
  "pronunciations": [
    {"ipa": "/音标/", "audio_url": "", "accent_type": "US", "is_primary": true}
  ],
  "definitions": [
    {
      "pos": "词性（英文，如 noun / verb / adjective / phrase）",
      "definition_en": "英文释义",
      "definition_cn": "中文释义",
      "usage_pattern": "常见搭配（可空字符串）",
      "note": "结合上下文的释义说明（必填，说明该词在句中的含义）",
      "examples": [
        {"example_en": "英文例句", "example_cn": "中文例句"}
      ]
    }
  ],
  "exam_tags": ["CET4"]
}

要求：
1. definitions 至少 1 条，examples 每条释义 1-2 个
2. 短语(type=2)时 headword 为完整短语，category 为「短语」
3. pronunciations 至少 1 条美式 IPA；audio_url 留空字符串
4. exam_tags 标注词汇所属考试难度，从以下枚举选 0～3 个（仅选确实符合的）：
   CET4（大学英语四级）、CET6（大学英语六级）、TEM4（英语专业四级）、TEM8（英语专业八级）、TOEFL、IELTS、GRE
   使用英文枚举值：CET4, CET6, TEM4, TEM8, TOEFL, IELTS, GRE；普通基础词或不属于上述考试范围则返回空数组 []
"""


def _extract_json(text: str) -> dict:
    """Parse model JSON; tolerate markdown fences and surrounding prose."""
    text = (text or "").strip()
    if not text:
        raise RuntimeError("DeepSeek 返回空内容，无法解析 JSON")

    fence = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", text)
    if fence:
        text = fence.group(1).strip()

    candidates = [text]
    start = text.find("{")
    end = text.rfind("}")
    if start >= 0 and end > start:
        sliced = text[start : end + 1]
        if sliced not in candidates:
            candidates.append(sliced)

    last_error: Exception | None = None
    for candidate in candidates:
        try:
            data = json.loads(candidate)
        except json.JSONDecodeError as exc:
            last_error = exc
            # 常见：尾逗号导致解析失败
            repaired = re.sub(r",\s*([}\]])", r"\1", candidate)
            if repaired != candidate:
                try:
                    data = json.loads(repaired)
                except json.JSONDecodeError as repair_exc:
                    last_error = repair_exc
                    continue
            else:
                continue
        if isinstance(data, dict):
            return data
        last_error = RuntimeError(f"DeepSeek 返回的 JSON 根类型为 {type(data).__name__}，期望 object")

    snippet = text[:400].replace("\n", "\\n")
    detail = str(last_error) if last_error else "未知错误"
    raise RuntimeError(f"DeepSeek 返回的 JSON 无法解析：{detail}；片段：{snippet}")


def _normalize_entry(raw: dict, entry_id: int) -> dict:
    definitions = []
    for i, d in enumerate(raw.get("definitions") or [], start=1):
        examples = []
        for j, ex in enumerate(d.get("examples") or [], start=1):
            examples.append(
                {
                    "example_en": ex.get("example_en", ""),
                    "example_cn": ex.get("example_cn", ""),
                    "order": j,
                }
            )
        definitions.append(
            {
                "id": i,
                "pos": d.get("pos", ""),
                "definition_en": d.get("definition_en", ""),
                "definition_cn": d.get("definition_cn", ""),
                "usage_pattern": d.get("usage_pattern", ""),
                "note": d.get("note", ""),
                "order": i,
                "examples": examples,
            }
        )

    pronunciations = []
    for i, p in enumerate(raw.get("pronunciations") or []):
        pronunciations.append(
            {
                "ipa": p.get("ipa", ""),
                "audio_url": p.get("audio_url", "") or "",
                "accent_type": p.get("accent_type", "US"),
                "is_primary": bool(p.get("is_primary", i == 0)),
            }
        )
    if not pronunciations:
        pronunciations = [{"ipa": "", "audio_url": "", "accent_type": "US", "is_primary": True}]

    return {
        "id": entry_id,
        "eid": entry_id,
        "headword": raw.get("headword", ""),
        "category": raw.get("category", "单词"),
        "pronunciations": pronunciations,
        "definitions": definitions,
        "exam_tags": normalize_exam_tags(raw.get("exam_tags")),
        "favorite": None,
    }


def _chat_completion(
    *,
    system: str,
    user: str,
    response_format: dict | None = None,
    temperature: float = 0.3,
    timeout: int = 60,
) -> str:
    if not DEEPSEEK_API_KEY:
        raise RuntimeError("未配置 DEEPSEEK_API_KEY，请在 backend/.env 中设置")

    body: dict = {
        "model": DEEPSEEK_MODEL,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        "temperature": temperature,
    }
    if response_format:
        body["response_format"] = response_format

    req = urllib.request.Request(
        f"{DEEPSEEK_BASE_URL}/chat/completions",
        data=json.dumps(body).encode(),
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {DEEPSEEK_API_KEY}",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            raw_body = resp.read().decode()
            try:
                payload = json.loads(raw_body)
            except json.JSONDecodeError as exc:
                snippet = raw_body[:300].replace("\n", "\\n")
                raise RuntimeError(f"DeepSeek HTTP 响应不是合法 JSON：{exc}；片段：{snippet}") from exc
    except urllib.error.HTTPError as e:
        detail = e.read().decode()
        logger.error("DeepSeek HTTP %s: %s", e.code, detail)
        raise RuntimeError(f"DeepSeek 请求失败 (HTTP {e.code})") from e
    except urllib.error.URLError as e:
        logger.error("DeepSeek network error: %s", e)
        raise RuntimeError("无法连接 DeepSeek API") from e

    try:
        return payload["choices"][0]["message"]["content"]
    except (KeyError, IndexError, TypeError) as exc:
        raise RuntimeError(f"DeepSeek 响应结构异常：{exc}") from exc


TRANSLATE_SYSTEM_PROMPT = """你是专业英中字幕翻译。将用户提供的英文字幕行逐条翻译成自然、准确的中文，适合英语学习场景。
要求：
1. 严格保持与输入相同的行数和顺序，一行英文对应一行中文
2. 只翻译，不要解释、不要合并或拆分句子
3. 仅返回合法 JSON，不要 markdown 代码块

JSON 结构：{"translations": ["中文1", "中文2", ...]}"""


ENRICH_SYSTEM_PROMPT = """你是影视/Vlog 英中字幕翻译，同时负责美式 IPA。用户每次给出一段待译字幕（lines），以及可选的剧情上下文。

## 上下文（只作理解，不要翻译这些字段）
- episode.title / episode.summary：视频标题与简介
- before：本批之前的英文字幕（剧情 continuity）
- after：本批之后的英文字幕
- lines：【需要处理】的条目；每项含 english（必填），以及可选的 draft_chinese（文件里已有的草稿中文，往往偏机械）

## 翻译风格（chinese）
1. 以 english 为准，按剧情与说话场景意译，像人口语对白，不要逐词机械直译
2. 若有 draft_chinese：可参考其大致含义，但必须改写成更自然、口语、简洁的中文字幕，不要照搬草稿
3. 语气、人称、省略主语要与前后文一致（it/that/this、口语省略等）
4. 习语、俚语、玩笑按中文观众能懂的方式表达，可意译，勿生硬直译
5. 字幕宜短：一句中文尽量简洁上口，避免书面腔、翻译腔（如「正在进行…」「被…所…」）
6. 专有名词可保留英文或用通行译名；不要擅自剧透或补全原文没有的信息
7. 不要解释、不要加括号注释、不要合并/拆分行

## 音标（ipa）
整句美式 IPA，用斜杠包裹，如 /həˈloʊ wɜːrld/

仅返回合法 JSON，不要 markdown。
JSON：{"items": [{"chinese": "中文", "ipa": "/音标/"}, ...]}
条目数必须与 lines 完全一致。"""


IPA_ONLY_SYSTEM_PROMPT = """你是英语语音学助手。对用户提供的每行英文字幕，输出对应的美式英语整句 IPA 音标。
要求：
1. 严格保持与输入相同的行数和顺序
2. ipa：整句美式 IPA，用斜杠包裹，如 /həˈloʊ wɜːrld/
3. 仅返回合法 JSON，不要 markdown 代码块

JSON 结构：{"items": [{"ipa": "/音标/"}, ...]}"""


EPISODE_METRICS_SYSTEM_PROMPT = """你是英语教学数据分析助手。根据英文字幕全文及附带的统计元数据，评估整期 Vlog 精听难度并统计词汇量。

## 难度 stars（1-5 整数）
综合以下维度加权判断（面向真实 Vlog 口语，不仅看单词生僻度）：

1. 词汇难度（权重约 30%）
   - 词频与 CEFR 层级：A1-A2 为主 vs B2+ 学术/书面/领域词
   - 抽象词、多义词、专有名词密度

2. 句法与信息结构（权重约 20%）
   - 平均句长、从句嵌套、并列与插入语
   - 口语省略、话题跳跃、指代是否清晰

3. 语速与口语密度（权重约 25%）
   - 参考 meta.words_per_minute（若提供）：<110 偏慢，110-150 正常，>150 偏快，>180 很快
   - 参考 meta.avg_words_per_sentence：句越长信息负荷越高
   - 缩略形式（gonna/wanna/'ve）、填充词（like/you know）密度——对初学者增加听辨负担

4. 习语与搭配密度（权重约 15%）
   - 短语动词、固定搭配、习语俚语、口语惯用表达的出现频率
   - 可结合字幕中难学表达的大致比例推断

5. 主题与认知负荷（权重约 10%）
   - 话题是否生活化 vs 需要背景知识（财经、文化梗、专业领域）
   - 信息密度：同样时长内观点/事实是否密集

## 星级锚点（典型特征）
- 1 星入门：短句慢速、高频词、生活化主题、结构清晰
- 2 星初级：日常口语、少量短语、语速中等
- 3 星中级：正常 Vlog 语速、有搭配习语、句子略长
- 4 星中高级：较快语速、抽象/领域词、从句多、听辨有挑战
- 5 星高级：快而密、习语俚语多、需背景知识、口语省略与风格化表达强

注意：voca_size（词汇量）高不等于 stars 高；语速慢但词汇专深的内容可适当降低星级。

## voca_size（整数，去重计数）
值得学习的词/短语数量：
- 计入：中高级单词、短语动词、习语、固定搭配、主题/domain 词汇
- 不计入：冠词、代词、be/have/do 等超高频动词、基础介词连词、数词、月份、极常见副词(very/really/just/also)、基础形容词(good/bad/big/small/new/old)等

仅返回合法 JSON，不要 markdown 代码块。
JSON 结构：{"stars": 3, "voca_size": 42}"""


SUBTITLE_ANNOTATE_SYSTEM_PROMPT = """你是英语学习字幕标注助手。对每行英文字幕分词并标注有学习价值的 token。
要求：
1. 严格保持与输入相同的行数和顺序
2. tokens 按顺序拼接后应还原为原句（标点附着在对应 token 上，如 "failure."）
3. phrase=true 表示多词短语；phrase=false 表示单词
4. highlight 仅对有学习难度的词/短语设置，简单功能词必须为 null
5. highlight 类型：
   - "a"：核心词汇（中高级单词）
   - "d"：短语动词、动词搭配
   - "i"：习语、惯用表达
   - "c"：固定搭配、介词短语
   - "l"：较难的从句片段或多词表达
6. 仅返回合法 JSON，不要 markdown 代码块

JSON 结构：
{"items": [{"tokens": [{"text": "You", "phrase": false, "highlight": null}, {"text": "look for", "phrase": true, "highlight": "d"}]}, ...]}"""


METADATA_LOCALIZE_PROMPT = """你是视频内容本地化助手。用户提供已从社交平台抓取并去除 #话题 和 @用户 后的视频标题与简介（可能为英文或其他语言）。

1. title：译为简洁明了的简体中文剧集标题
   - 概括核心主题，去掉 emoji、平台口号、多余修饰
   - 尽量控制在 40 字以内，适合作为学习视频短标题

2. summary：将简介忠实翻译为自然流畅的简体中文
   - 保留原文段落结构（换行用 \\n）
   - 不要添加原文没有的信息或评论
   - 若简介为空、极短或仅有链接/无关模板文字，summary 返回空字符串 ""

仅返回合法 JSON，不要 markdown 代码块。
JSON 结构：{"title": "...", "summary": "..."}"""


def translate_lines_with_deepseek(lines: list[str]) -> list[str]:
    if not lines:
        return []
    user_payload = {"lines": lines}
    content = _chat_completion(
        system=TRANSLATE_SYSTEM_PROMPT,
        user=json.dumps(user_payload, ensure_ascii=False),
        response_format={"type": "json_object"},
        temperature=0.2,
        timeout=120,
    )
    raw = _extract_json(content)
    translations = raw.get("translations")
    if not isinstance(translations, list):
        raise RuntimeError("DeepSeek 翻译返回格式无效")
    return [str(t) for t in translations]


def _normalize_enrich_lines(lines: list[str] | list[dict]) -> list[dict[str, str]]:
    items: list[dict[str, str]] = []
    for line in lines:
        if isinstance(line, dict):
            english = str(line.get("english", "")).strip()
            draft = str(line.get("draft_chinese", "")).strip()
            item: dict[str, str] = {"english": english}
            if draft:
                item["draft_chinese"] = draft
            items.append(item)
        else:
            items.append({"english": str(line).strip()})
    return items


def _line_englishs(lines: list[str] | list[dict]) -> list[str]:
    return [
        str(line.get("english", "")).strip() if isinstance(line, dict) else str(line).strip()
        for line in lines
    ]


def _enrich_subtitle_lines_batch(
    lines: list[str] | list[dict],
    *,
    translate_chinese: bool,
    before: list[str] | None = None,
    after: list[str] | None = None,
    episode_title: str = "",
    episode_summary: str = "",
) -> list[dict[str, str]]:
    if translate_chinese:
        line_items = _normalize_enrich_lines(lines)
        user_payload: dict = {"lines": line_items}
        episode: dict[str, str] = {}
        if episode_title.strip():
            episode["title"] = episode_title.strip()
        if episode_summary.strip():
            episode["summary"] = episode_summary.strip()[:800]
        if episode:
            user_payload["episode"] = episode
        if before:
            user_payload["before"] = before
        if after:
            user_payload["after"] = after
        line_count = len(line_items)
    else:
        english_lines = _line_englishs(lines)
        user_payload = {"lines": english_lines}
        line_count = len(english_lines)

    content = _chat_completion(
        system=ENRICH_SYSTEM_PROMPT if translate_chinese else IPA_ONLY_SYSTEM_PROMPT,
        user=json.dumps(user_payload, ensure_ascii=False),
        response_format={"type": "json_object"},
        # 翻译略提高温度，减少机械直译；仅 IPA 仍偏低温
        temperature=0.35 if translate_chinese else 0.2,
        timeout=180,
    )
    raw = _extract_json(content)
    items = raw.get("items")
    if not isinstance(items, list):
        raise RuntimeError("DeepSeek 字幕增强返回格式无效")
    if len(items) != line_count:
        raise RuntimeError("DeepSeek 返回条数与输入不一致")
    result: list[dict[str, str]] = []
    for item in items:
        if not isinstance(item, dict):
            raise RuntimeError("DeepSeek 字幕增强返回格式无效")
        result.append(
            {
                "chinese": str(item.get("chinese", "")).strip(),
                "ipa": str(item.get("ipa", "")).strip(),
            }
        )
    return result


def enrich_subtitle_lines_with_deepseek(
    lines: list[str] | list[dict],
    *,
    translate_chinese: bool,
    before: list[str] | None = None,
    after: list[str] | None = None,
    episode_title: str = "",
    episode_summary: str = "",
) -> list[dict[str, str]]:
    if not lines:
        return []
    kwargs = dict(
        translate_chinese=translate_chinese,
        before=before,
        after=after,
        episode_title=episode_title,
        episode_summary=episode_summary,
    )
    if len(lines) == 1:
        try:
            return _enrich_subtitle_lines_batch(lines, **kwargs)
        except Exception:
            return [{"chinese": "", "ipa": ""}]

    try:
        return _enrich_subtitle_lines_batch(lines, **kwargs)
    except Exception:
        mid = len(lines) // 2
        englishs = _line_englishs(lines)
        left_after = englishs[mid:] + list(after or [])
        right_before = list(before or []) + englishs[:mid]
        return enrich_subtitle_lines_with_deepseek(
            lines[:mid],
            before=before,
            after=left_after[:6],
            episode_title=episode_title,
            episode_summary=episode_summary,
            translate_chinese=translate_chinese,
        ) + enrich_subtitle_lines_with_deepseek(
            lines[mid:],
            before=right_before[-6:],
            after=after,
            episode_title=episode_title,
            episode_summary=episode_summary,
            translate_chinese=translate_chinese,
        )


def localize_video_metadata_with_deepseek(title: str, summary: str) -> dict[str, str]:
    title = title.strip()
    summary = summary.strip()
    if not title and not summary:
        return {"title": "", "summary": ""}

    user_payload = {"title": title, "summary": summary}
    content = _chat_completion(
        system=METADATA_LOCALIZE_PROMPT,
        user=json.dumps(user_payload, ensure_ascii=False),
        response_format={"type": "json_object"},
        temperature=0.2,
        timeout=120,
    )
    raw = _extract_json(content)
    out_title = str(raw.get("title", "")).strip() or title
    out_summary = str(raw.get("summary", "")).strip()
    return {"title": out_title, "summary": out_summary}


def analyze_episode_metrics_with_deepseek(
    lines: list[str],
    *,
    clip_length: float | None = None,
) -> dict[str, int]:
    if not lines:
        return {"stars": 3, "voca_size": 0}

    word_count = sum(len(re.findall(r"[A-Za-z']+", line)) for line in lines)
    sentence_count = len(lines)
    meta: dict[str, float | int] = {
        "sentence_count": sentence_count,
        "word_count": word_count,
        "avg_words_per_sentence": round(word_count / sentence_count, 1) if sentence_count else 0,
    }
    if clip_length and clip_length > 0:
        meta["clip_length_seconds"] = round(clip_length, 1)
        meta["words_per_minute"] = round(word_count / (clip_length / 60), 1)

    user_payload = {"lines": lines, "meta": meta}
    content = _chat_completion(
        system=EPISODE_METRICS_SYSTEM_PROMPT,
        user=json.dumps(user_payload, ensure_ascii=False),
        response_format={"type": "json_object"},
        temperature=0.2,
        timeout=180,
    )
    raw = _extract_json(content)
    stars = int(raw.get("stars", 3))
    voca_size = int(raw.get("voca_size", 0))
    return {
        "stars": max(1, min(5, stars)),
        "voca_size": max(0, voca_size),
    }


def _annotate_subtitle_lines_batch(lines: list[str]) -> list[dict]:
    user_payload = {"lines": lines}
    content = _chat_completion(
        system=SUBTITLE_ANNOTATE_SYSTEM_PROMPT,
        user=json.dumps(user_payload, ensure_ascii=False),
        response_format={"type": "json_object"},
        temperature=0.2,
        timeout=240,
    )
    raw = _extract_json(content)
    items = raw.get("items")
    if not isinstance(items, list):
        raise RuntimeError("DeepSeek 字幕标注返回格式无效")
    if len(items) != len(lines):
        raise RuntimeError("DeepSeek 字幕标注返回条数与输入不一致")
    result: list[dict] = []
    for item in items:
        if not isinstance(item, dict):
            raise RuntimeError("DeepSeek 字幕标注返回格式无效")
        tokens = item.get("tokens")
        if not isinstance(tokens, list):
            raise RuntimeError("DeepSeek 字幕标注 tokens 格式无效")
        result.append({"tokens": tokens})
    return result


def annotate_subtitle_lines_with_deepseek(lines: list[str]) -> list[dict]:
    if not lines:
        return []
    if len(lines) == 1:
        try:
            return _annotate_subtitle_lines_batch(lines)
        except Exception:
            return [{"tokens": []}]

    try:
        return _annotate_subtitle_lines_batch(lines)
    except Exception:
        mid = len(lines) // 2
        return annotate_subtitle_lines_with_deepseek(lines[:mid]) + annotate_subtitle_lines_with_deepseek(
            lines[mid:]
        )


def lookup_with_deepseek(word: str, token_type: int, context: str, entry_id: int) -> dict:
    user_payload = {
        "word": word,
        "type": token_type,
        "sentence": context,
        "hint": "短语" if token_type == 2 else "单词",
    }
    content = _chat_completion(
        system=SYSTEM_PROMPT,
        user=json.dumps(user_payload, ensure_ascii=False),
        response_format={"type": "json_object"},
        temperature=0.3,
    )
    raw = _extract_json(content)
    result = _normalize_entry(raw, entry_id)
    if not result["headword"]:
        result["headword"] = word
    if not result["definitions"]:
        raise RuntimeError("DeepSeek 返回的词条格式不完整")
    return result
