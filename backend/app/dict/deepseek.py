from __future__ import annotations

import json
import logging
import re
import urllib.error
import urllib.request

from .config import DEEPSEEK_API_KEY, DEEPSEEK_BASE_URL, DEEPSEEK_MODEL

logger = logging.getLogger(__name__)

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
  "exam_tags": []
}

要求：
1. definitions 至少 1 条，examples 每条释义 1-2 个
2. 短语(type=2)时 headword 为完整短语，category 为「短语」
3. pronunciations 至少 1 条美式 IPA；audio_url 留空字符串
4. exam_tags 返回空数组即可
"""


def _extract_json(text: str) -> dict:
    text = text.strip()
    fence = re.search(r"```(?:json)?\s*([\s\S]*?)\s*```", text)
    if fence:
        text = fence.group(1).strip()
    return json.loads(text)


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
        "exam_tags": raw.get("exam_tags") or [],
        "favorite": None,
    }


def lookup_with_deepseek(word: str, token_type: int, context: str, entry_id: int) -> dict:
    if not DEEPSEEK_API_KEY:
        raise RuntimeError("未配置 DEEPSEEK_API_KEY，请在 backend/.env 中设置")

    user_payload = {
        "word": word,
        "type": token_type,
        "sentence": context,
        "hint": "短语" if token_type == 2 else "单词",
    }
    body = {
        "model": DEEPSEEK_MODEL,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": json.dumps(user_payload, ensure_ascii=False)},
        ],
        "response_format": {"type": "json_object"},
        "temperature": 0.3,
    }

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
        with urllib.request.urlopen(req, timeout=60) as resp:
            payload = json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        detail = e.read().decode()
        logger.error("DeepSeek HTTP %s: %s", e.code, detail)
        raise RuntimeError(f"DeepSeek 请求失败 (HTTP {e.code})") from e
    except urllib.error.URLError as e:
        logger.error("DeepSeek network error: %s", e)
        raise RuntimeError("无法连接 DeepSeek API") from e

    content = payload["choices"][0]["message"]["content"]
    raw = _extract_json(content)
    result = _normalize_entry(raw, entry_id)
    if not result["headword"]:
        result["headword"] = word
    if not result["definitions"]:
        raise RuntimeError("DeepSeek 返回的词条格式不完整")
    return result
