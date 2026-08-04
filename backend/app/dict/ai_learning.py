"""面向学习者的 AI 能力：句旁讲解、挖空、跟读点评、读报问答。"""

from __future__ import annotations

import json
import re
from collections.abc import Iterator
from typing import Any

from .deepseek import _chat_completion, _chat_completion_stream, _extract_json

EXPLAIN_SYSTEM = """你是 Vloglish 的英语私教，讲解真实 Vlog 字幕句子。
用简洁中文回答，帮助学习者听懂、会用。仅返回合法 JSON，不要 markdown。
字段必须按以下顺序输出（便于流式展示）：plain_chinese → structure → expressions → paraphrase → tip。

JSON：
{
  "plain_chinese": "整句自然中文意译（1句，尽量短）",
  "structure": "句法/时态要点（1句）",
  "expressions": [{"en": "词或短语", "zh": "简短释义"}],
  "paraphrase": "更简单的英文改写（1句）",
  "tip": "记忆或使用小贴士（1句）"
}
expressions 最多 3 条；没有则 []。全文务必简短。"""


CLOZE_SYSTEM = """英语挖空出题。从原句挑 2～4 个实词/短语（优先动词、搭配、难点词）。
仅返回紧凑 JSON：{"blanks":["原词1","原词2"],"hint":"一句中文提示"}
blanks 必须原句真实出现；hint 不泄露答案。"""


SHADOWING_SYSTEM = """你是英语跟读教练。对比「目标句」与「用户跟读识别文本」，给出打分与纠错。
仅返回合法 JSON：
{
  "score": 0到100的整数,
  "level": "优秀"或"良好"或"及格"或"需加强",
  "praise": "一句鼓励",
  "issues": ["具体问题1", "问题2"],
  "tips": ["改进建议1", "建议2"]
}
若用户文本为空或几乎为空，score 给低分并提示未识别到有效语音。"""


READING_QA_SYSTEM = """你是英语新闻阅读助教。根据文章段落回答学习者问题，或在没有问题时出 2 道理解题。
仅返回合法 JSON：
{
  "answer": "对用户问题的回答；若无问题则为空字符串",
  "quiz": [{"q": "理解题", "a": "参考答案"}],
  "key_phrases": [{"en": "...", "zh": "..."}]
}
quiz 最多 2 题；key_phrases 最多 4 条。"""


VOCAB_REVIEW_SYSTEM = """你是英语词汇教练。根据生词列表生成间隔复习题。
仅返回合法 JSON：
{
  "cards": [
    {
      "word": "原词",
      "prompt": "中文提示或英文语境填空（挖空用 ____ ）",
      "answer": "答案词",
      "example": "一句含该词的英文例句",
      "example_zh": "例句中文"
    }
  ]
}
每词一张卡，最多 8 张。"""


def _explain_user_prompt(
    *,
    english: str,
    chinese: str = "",
    context_before: str = "",
    context_after: str = "",
    episode_title: str = "",
) -> str:
    return (
        f"视频标题：{episode_title or '（无）'}\n"
        f"上一句：{context_before or '（无）'}\n"
        f"当前英文：{english}\n"
        f"当前中文参考：{chinese or '（无）'}\n"
        f"下一句：{context_after or '（无）'}\n"
        "请讲解当前句。"
    )


def _normalize_explain(data: dict) -> dict:
    return {
        "plain_chinese": str(data.get("plain_chinese") or "").strip(),
        "structure": str(data.get("structure") or "").strip(),
        "expressions": _normalize_pairs(data.get("expressions")),
        "paraphrase": str(data.get("paraphrase") or "").strip(),
        "tip": str(data.get("tip") or "").strip(),
    }


def _extract_json_string_field(buf: str, key: str) -> str | None:
    """若 buffer 中该字符串字段已完整闭合，返回解码后的值。"""
    m = re.search(rf'"{re.escape(key)}"\s*:\s*"', buf)
    if not m:
        return None
    i = m.end()
    chars: list[str] = []
    while i < len(buf):
        c = buf[i]
        if c == "\\":
            if i + 1 >= len(buf):
                return None
            chars.append(buf[i : i + 2])
            i += 2
            continue
        if c == '"':
            try:
                return json.loads('"' + "".join(chars) + '"')
            except json.JSONDecodeError:
                return None
        chars.append(c)
        i += 1
    return None


def _extract_json_array_field(buf: str, key: str) -> list | None:
    m = re.search(rf'"{re.escape(key)}"\s*:\s*\[', buf)
    if not m:
        return None
    start = m.end() - 1
    depth = 0
    in_str = False
    escape = False
    for i in range(start, len(buf)):
        c = buf[i]
        if in_str:
            if escape:
                escape = False
            elif c == "\\":
                escape = True
            elif c == '"':
                in_str = False
            continue
        if c == '"':
            in_str = True
        elif c == "[":
            depth += 1
        elif c == "]":
            depth -= 1
            if depth == 0:
                try:
                    val = json.loads(buf[start : i + 1])
                except json.JSONDecodeError:
                    return None
                return val if isinstance(val, list) else None
    return None


def explain_subtitle_sentence(
    *,
    english: str,
    chinese: str = "",
    context_before: str = "",
    context_after: str = "",
    episode_title: str = "",
) -> dict:
    user = _explain_user_prompt(
        english=english,
        chinese=chinese,
        context_before=context_before,
        context_after=context_after,
        episode_title=episode_title,
    )
    raw = _chat_completion(
        system=EXPLAIN_SYSTEM,
        user=user,
        response_format={"type": "json_object"},
        temperature=0.4,
        timeout=90,
        max_tokens=700,
        thinking=False,
    )
    data = _extract_json(raw)
    return _normalize_explain(data)


def explain_subtitle_sentence_stream(
    *,
    english: str,
    chinese: str = "",
    context_before: str = "",
    context_after: str = "",
    episode_title: str = "",
) -> Iterator[dict[str, Any]]:
    """流式讲解：尽早 yield 已完成字段，最后 yield done。"""
    user = _explain_user_prompt(
        english=english,
        chinese=chinese,
        context_before=context_before,
        context_after=context_after,
        episode_title=episode_title,
    )
    buf = ""
    emitted: set[str] = set()
    string_keys = ("plain_chinese", "structure", "paraphrase", "tip")

    for piece in _chat_completion_stream(
        system=EXPLAIN_SYSTEM,
        user=user,
        response_format={"type": "json_object"},
        temperature=0.4,
        timeout=90,
        max_tokens=700,
        thinking=False,
    ):
        buf += piece
        for key in string_keys:
            if key in emitted:
                continue
            val = _extract_json_string_field(buf, key)
            if val is not None and str(val).strip():
                emitted.add(key)
                yield {"type": "field", "key": key, "value": str(val).strip()}
        if "expressions" not in emitted:
            arr = _extract_json_array_field(buf, "expressions")
            if arr is not None:
                pairs = _normalize_pairs(arr)
                emitted.add("expressions")
                yield {"type": "field", "key": "expressions", "value": pairs}

    data = _extract_json(buf) if buf.strip() else {}
    result = _normalize_explain(data if isinstance(data, dict) else {})
    # 补发解析阶段才拿到的字段
    for key in string_keys:
        if key not in emitted and result.get(key):
            yield {"type": "field", "key": key, "value": result[key]}
    if "expressions" not in emitted and result.get("expressions"):
        yield {"type": "field", "key": "expressions", "value": result["expressions"]}
    yield {"type": "done", "result": result}


def generate_cloze(english: str) -> dict:
    raw = _chat_completion(
        system=CLOZE_SYSTEM,
        user=f"原句：{english}",
        response_format={"type": "json_object"},
        temperature=0.3,
        timeout=45,
        max_tokens=400,
        # V4 默认 thinking 会把小 max_tokens 耗尽，content 变空
        thinking=False,
    )
    data = _extract_json(raw)
    blanks = data.get("blanks") if isinstance(data.get("blanks"), list) else []
    clean = [str(b).strip() for b in blanks if str(b).strip()]
    return {"blanks": clean[:4], "hint": str(data.get("hint") or "").strip()}


def shadowing_feedback(*, target: str, said: str) -> dict:
    raw = _chat_completion(
        system=SHADOWING_SYSTEM,
        user=f"目标句：{target}\n用户跟读识别：{said or '（空）'}",
        response_format={"type": "json_object"},
        temperature=0.35,
        timeout=60,
        thinking=False,
    )
    data = _extract_json(raw)
    try:
        score = int(data.get("score") or 0)
    except (TypeError, ValueError):
        score = 0
    score = max(0, min(100, score))
    issues = data.get("issues") if isinstance(data.get("issues"), list) else []
    tips = data.get("tips") if isinstance(data.get("tips"), list) else []
    return {
        "score": score,
        "level": str(data.get("level") or "").strip() or ("优秀" if score >= 85 else "需加强"),
        "praise": str(data.get("praise") or "").strip(),
        "issues": [str(x).strip() for x in issues if str(x).strip()][:5],
        "tips": [str(x).strip() for x in tips if str(x).strip()][:5],
    }


def reading_qa(*, english: str, chinese: str = "", question: str = "", title: str = "") -> dict:
    user = (
        f"文章：{title or '（无标题）'}\n"
        f"段落英文：{english}\n"
        f"段落中文：{chinese or '（无）'}\n"
        f"用户问题：{question.strip() or '（无，请出理解题）'}"
    )
    raw = _chat_completion(
        system=READING_QA_SYSTEM,
        user=user,
        response_format={"type": "json_object"},
        temperature=0.4,
        timeout=90,
        thinking=False,
    )
    data = _extract_json(raw)
    quiz_raw = data.get("quiz") if isinstance(data.get("quiz"), list) else []
    quiz = []
    for item in quiz_raw[:2]:
        if not isinstance(item, dict):
            continue
        q = str(item.get("q") or "").strip()
        a = str(item.get("a") or "").strip()
        if q:
            quiz.append({"q": q, "a": a})
    return {
        "answer": str(data.get("answer") or "").strip(),
        "quiz": quiz,
        "key_phrases": _normalize_pairs(data.get("key_phrases")),
    }


def vocab_review_cards(words: list[str]) -> dict:
    cleaned = [w.strip() for w in words if w and w.strip()][:8]
    if not cleaned:
        return {"cards": []}
    raw = _chat_completion(
        system=VOCAB_REVIEW_SYSTEM,
        user="生词列表：\n" + "\n".join(f"- {w}" for w in cleaned),
        response_format={"type": "json_object"},
        temperature=0.4,
        timeout=90,
        thinking=False,
    )
    data = _extract_json(raw)
    cards_raw = data.get("cards") if isinstance(data.get("cards"), list) else []
    cards = []
    for item in cards_raw[:8]:
        if not isinstance(item, dict):
            continue
        word = str(item.get("word") or "").strip()
        answer = str(item.get("answer") or word).strip()
        if not word and not answer:
            continue
        cards.append(
            {
                "word": word or answer,
                "prompt": str(item.get("prompt") or "").strip(),
                "answer": answer,
                "example": str(item.get("example") or "").strip(),
                "example_zh": str(item.get("example_zh") or "").strip(),
            }
        )
    return {"cards": cards}


def _normalize_pairs(raw) -> list[dict]:
    if not isinstance(raw, list):
        return []
    out = []
    for item in raw[:4]:
        if not isinstance(item, dict):
            continue
        en = str(item.get("en") or "").strip()
        zh = str(item.get("zh") or "").strip()
        if en or zh:
            out.append({"en": en, "zh": zh})
    return out
