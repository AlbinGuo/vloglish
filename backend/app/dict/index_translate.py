"""Index-Translate 免费公网 API：字幕意译 / 直译 / 专名约束。

接口与官方 call_api.py 对齐：
https://index-translate.bilibili.com/v1/chat/completions
"""
from __future__ import annotations

import json
import logging
import re
import urllib.error
import urllib.request

from .config import (
    INDEX_TRANSLATE_API_KEY,
    INDEX_TRANSLATE_BASE_URL,
    INDEX_TRANSLATE_MODEL,
    INDEX_TRANSLATE_PROXY,
)

logger = logging.getLogger(__name__)

LANG_NAMES = {
    "en": "英语",
    "zh": "中文",
    "de": "德语",
    "fr": "法语",
    "es": "西班牙语",
    "ja": "日语",
    "ko": "韩语",
}

_SUBTITLE_INSTRUCTIONS = (
    "【硬性要求】source 的 value 必须原样保留英文，禁止翻译\n"
    "【硬性要求】chinese 必须是口语意译：像人对白，拒绝翻译腔；字幕宜短，不要括号注释和 emoji\n"
    "【硬性要求】chinese_literal 必须按英文词序直译，例如 "
    "I kinda just wing it when I travel. → 我有点就临场发挥当我旅行\n"
    "【硬性要求】除英文不足 5 个词的短句外，同一条的 chinese 与 chinese_literal 不得相同\n"
    "【硬性要求】items 条数和顺序必须与源文完全一致\n"
    "【注意】若 chinese 已有中文草稿，必须改写得更口语更短，禁止照搬\n"
    "【注意】严格保留合法 JSON 语法格式，key 保持不变"
)


def _urlopen(req: urllib.request.Request, *, timeout: int):
    if INDEX_TRANSLATE_PROXY:
        opener = urllib.request.build_opener(
            urllib.request.ProxyHandler(
                {"http": INDEX_TRANSLATE_PROXY, "https": INDEX_TRANSLATE_PROXY}
            )
        )
        return opener.open(req, timeout=timeout)
    return urllib.request.urlopen(req, timeout=timeout)


def strip_think(text: str) -> str:
    if "</think>" in text:
        text = text.split("</think>", 1)[1]
    text = text.strip()
    if text.startswith("<think>"):
        text = text[len("<think>") :].strip()
    return text


def _extract_json(text: str) -> dict:
    text = strip_think(text or "").strip()
    if not text:
        raise RuntimeError("Index-Translate 返回空内容，无法解析 JSON")

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
        last_error = RuntimeError(
            f"Index-Translate 返回的 JSON 根类型为 {type(data).__name__}，期望 object"
        )

    snippet = text[:400].replace("\n", "\\n")
    detail = str(last_error) if last_error else "未知错误"
    raise RuntimeError(f"Index-Translate 返回的 JSON 无法解析：{detail}；片段：{snippet}")


def format_glossary(items: list[dict] | None) -> str:
    pairs: list[str] = []
    seen: set[str] = set()
    for item in items or []:
        if not isinstance(item, dict):
            continue
        en = str(item.get("en") or "").strip()
        zh = str(item.get("zh") or "").strip()
        key = en.lower()
        if not en or not zh or key in seen:
            continue
        seen.add(key)
        pairs.append(f"{en}→{zh}")
        if len(pairs) >= 24:
            break
    return "、".join(pairs)


def build_prompt(
    text: str,
    *,
    target_lang: str = "zh",
    source_lang: str = "en",
    instruction: str = "",
    glossary: str = "",
    genre: str = "文本",
) -> str:
    """官方 instTrans 提示：glossary + instruction + JSON 保形。"""
    tgt_name = LANG_NAMES.get(target_lang.lower(), target_lang)
    has_source = bool(source_lang) and source_lang.lower() not in ("auto", "")
    src_name = LANG_NAMES.get(source_lang.lower(), source_lang) if has_source else ""

    constraints: list[str] = []
    if glossary:
        constraints.append(f"【硬性要求】专名/术语对照: {glossary}")
    if instruction:
        for line in instruction.strip().splitlines():
            line = line.strip().lstrip("0123456789. ")
            if not line:
                continue
            if line.startswith(("【硬性要求】", "【注意】", "【软性要求】")):
                constraints.append(line)
            else:
                constraints.append(f"【注意】{line}")

    stripped = text.strip()
    if constraints:
        header_src = f"{src_name}{genre}" if src_name else genre
        header = f"请将以下{header_src}翻译成{tgt_name}，并且严格遵循所有约束要求。"
        req_lines = [f"{i + 1}. {c}" for i, c in enumerate(constraints)]
        is_json = False
        if stripped.startswith("{") and stripped.endswith("}"):
            try:
                is_json = isinstance(json.loads(stripped), dict)
            except Exception:
                is_json = False
        if is_json and any("JSON" in c or "json" in c for c in constraints):
            suffix = (
                "请以相同的 JSON 格式输出翻译结果，key 保持不变，value 为对应译文。"
                "只输出 JSON，不要有任何额外说明。"
            )
        else:
            suffix = "只输出译文，不要有任何额外说明。"
        return (
            f"{header}\n\n"
            f"【源文】\n"
            f"{stripped}\n\n"
            f"【约束要求】\n"
            f"{chr(10).join(req_lines)}\n\n"
            f"{suffix}"
        )

    if src_name:
        return (
            f"请将以下{src_name}文本翻译为{tgt_name}，直接输出翻译结果，不要进行任何解释。\n\n"
            f"{stripped}"
        )
    return f"请将以下文本翻译为{tgt_name}，直接输出翻译结果，不要进行任何解释。\n\n{stripped}"


def call_completion(
    prompt: str,
    *,
    max_tokens: int = 1024,
    temperature: float = 0.0,
    timeout: int = 120,
) -> str:
    url = f"{INDEX_TRANSLATE_BASE_URL}/chat/completions"
    payload = {
        "model": INDEX_TRANSLATE_MODEL,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": temperature,
        "max_tokens": int(max_tokens),
        "stream": False,
        "chat_template_kwargs": {"enable_thinking": False},
    }
    headers = {
        "Content-Type": "application/json",
        "User-Agent": "Vloglish-Index-Translate/1.0",
    }
    if INDEX_TRANSLATE_API_KEY:
        headers["Authorization"] = f"Bearer {INDEX_TRANSLATE_API_KEY}"

    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers=headers,
        method="POST",
    )
    try:
        with _urlopen(req, timeout=timeout) as resp:
            raw_body = resp.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", errors="replace")
        logger.error("Index-Translate HTTP %s: %s", e.code, detail)
        hint = ""
        try:
            err = json.loads(detail).get("error") or {}
            msg = str(err.get("message") or "").strip()
            if msg:
                hint = f"：{msg}"
        except Exception:
            if detail.strip():
                hint = f"：{detail.strip()[:240]}"
        raise RuntimeError(f"Index-Translate 请求失败 (HTTP {e.code}){hint}") from e
    except urllib.error.URLError as e:
        reason = getattr(e, "reason", None) or e
        raise RuntimeError(f"无法连接 Index-Translate API（{reason}）") from e

    try:
        data = json.loads(raw_body)
    except json.JSONDecodeError as exc:
        snippet = raw_body[:300].replace("\n", "\\n")
        raise RuntimeError(f"Index-Translate HTTP 响应不是合法 JSON：{exc}；片段：{snippet}") from exc

    try:
        content = data["choices"][0]["message"]["content"]
    except (KeyError, IndexError, TypeError) as exc:
        raise RuntimeError(f"Index-Translate 响应结构异常：{exc}") from exc
    if not isinstance(content, str) or not content.strip():
        raise RuntimeError("Index-Translate 返回空内容")
    return strip_think(content)


def translate_lines(lines: list[str]) -> list[str]:
    if not lines:
        return []
    source = json.dumps({"translations": list(lines)}, ensure_ascii=False)
    prompt = build_prompt(
        source,
        instruction=(
            "【硬性要求】translations 数组长度必须与源文一致，顺序不变\n"
            "【注意】译为自然流畅的简体中文，适合英语学习字幕\n"
            "【注意】不要合并或拆分句子\n"
            "【注意】严格保留合法 JSON 语法格式，仅翻译 value 文本"
        ),
    )
    raw = _extract_json(
        call_completion(prompt, max_tokens=min(8192, 80 * len(lines) + 256), timeout=120)
    )
    translations = raw.get("translations")
    if not isinstance(translations, list):
        raise RuntimeError("Index-Translate 翻译返回格式无效")
    if len(translations) != len(lines):
        raise RuntimeError("Index-Translate 翻译返回条数与输入不一致")
    return [str(t).strip() for t in translations]


def _brief_instruction(brief: dict | None) -> str:
    if not brief:
        return ""
    parts: list[str] = []
    topic = str(brief.get("topic") or "").strip()
    tone = str(brief.get("tone") or "").strip()
    speakers = str(brief.get("speakers") or "").strip()
    if topic:
        parts.append(f"【注意】剧情：{topic[:400]}")
    if tone:
        parts.append(f"【注意】语气贴合：{tone[:200]}")
    if speakers and speakers.lower() != "unknown":
        parts.append(f"【注意】说话人：{speakers[:200]}")
    notes = brief.get("notes")
    if isinstance(notes, list):
        joined = "；".join(str(n).strip() for n in notes if str(n).strip())[:400]
        if joined:
            parts.append(f"【注意】continuity：{joined}")
    return "\n".join(parts)


def translate_subtitle_items(
    lines: list[dict[str, str]],
    *,
    before: list[str] | None = None,
    after: list[str] | None = None,
    episode_title: str = "",
    episode_summary: str = "",
    translation_brief: dict | None = None,
) -> list[dict[str, str]]:
    if not lines:
        return []

    items = []
    for line in lines:
        english = str(line.get("english") or "").strip()
        draft = str(line.get("draft_chinese") or "").strip()
        items.append(
            {
                "source": english,
                "chinese": draft or english,
                "chinese_literal": english,
            }
        )
    source = json.dumps({"items": items}, ensure_ascii=False)

    extra: list[str] = [_SUBTITLE_INSTRUCTIONS]
    title = episode_title.strip()
    if title:
        extra.append(f"【注意】视频标题：{title[:80]}")
    summary = episode_summary.strip()
    if summary:
        extra.append(f"【注意】视频简介：{summary[:400]}")
    brief_text = _brief_instruction(translation_brief)
    if brief_text:
        extra.append(brief_text)
    if before:
        extra.append("【注意】上文只作连贯参考，不要写入 items：" + " / ".join(before[:8]))
    if after:
        extra.append("【注意】下文只作连贯参考，不要写入 items：" + " / ".join(after[:8]))

    glossary = format_glossary((translation_brief or {}).get("glossary"))
    prompt = build_prompt(
        source,
        instruction="\n".join(extra),
        glossary=glossary,
        genre="字幕",
    )
    max_tokens = min(8192, 160 * len(lines) + 512)
    raw = _extract_json(call_completion(prompt, max_tokens=max_tokens, timeout=180, temperature=0.2))
    out_items = raw.get("items")
    if not isinstance(out_items, list):
        raise RuntimeError("Index-Translate 字幕翻译返回格式无效")
    if len(out_items) != len(lines):
        raise RuntimeError("Index-Translate 字幕翻译返回条数与输入不一致")

    result: list[dict[str, str]] = []
    for item in out_items:
        if not isinstance(item, dict):
            raise RuntimeError("Index-Translate 字幕翻译返回格式无效")
        result.append(
            {
                "chinese": str(item.get("chinese") or "").strip(),
                "chinese_literal": str(item.get("chinese_literal") or "").strip(),
            }
        )
    return result


def translate_literal(
    english: str,
    *,
    sense_chinese: str = "",
    glossary: list[dict] | None = None,
) -> dict:
    source = json.dumps(
        {
            "chinese_literal": (english or "").strip(),
            "glossary_hits": [],
        },
        ensure_ascii=False,
    )
    notes = [
        "【硬性要求】chinese_literal 必须按英文词序直译，例如 "
        "That was the first time I really heard it. → 那是第一次我真正听见它",
        "【硬性要求】不要照抄意译；意译只用来核对意思",
        "【硬性要求】glossary_hits 只列出本句实际出现的专名/梗，没有则 []；每项 {en, zh}",
        "【注意】不要解释、括号注释、emoji",
        "【注意】严格保留合法 JSON 语法格式，key 保持不变",
    ]
    sense = (sense_chinese or "").strip()
    if sense:
        notes.append(f"【注意】本句意译仅供对照，禁止输出成 chinese_literal：{sense[:200]}")
    prompt = build_prompt(
        source,
        instruction="\n".join(notes),
        glossary=format_glossary(glossary),
    )
    raw = _extract_json(call_completion(prompt, max_tokens=400, timeout=60))
    literal = str(raw.get("chinese_literal") or raw.get("chinese") or "").strip()
    hits: list[dict[str, str]] = []
    raw_hits = raw.get("glossary_hits")
    if isinstance(raw_hits, list):
        for item in raw_hits[:8]:
            if not isinstance(item, dict):
                continue
            en = str(item.get("en") or "").strip()
            zh = str(item.get("zh") or "").strip()
            if en:
                hits.append({"en": en, "zh": zh})
    return {"chinese_literal": literal, "glossary_hits": hits}


def localize_metadata(title: str, summary: str) -> dict[str, str]:
    title = title.strip()
    summary = summary.strip()
    if not title and not summary:
        return {"title": "", "summary": ""}
    source = json.dumps({"title": title, "summary": summary}, ensure_ascii=False)
    prompt = build_prompt(
        source,
        instruction=(
            "【硬性要求】title 译为简洁明了的简体中文短标题，去掉 emoji、平台口号，尽量 40 字以内\n"
            "【硬性要求】summary 忠实翻译为自然流畅的简体中文，保留段落（换行用 \\n）\n"
            "【注意】不要添加原文没有的信息或评论\n"
            "【注意】若简介为空、极短或仅有链接/无关模板，summary 返回空字符串\n"
            "【注意】严格保留合法 JSON 语法格式，key 保持不变"
        ),
    )
    raw = _extract_json(call_completion(prompt, max_tokens=2048, timeout=120))
    out_title = str(raw.get("title") or "").strip() or title
    out_summary = str(raw.get("summary") or "").strip()
    return {"title": out_title, "summary": out_summary}
