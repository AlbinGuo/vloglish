"""本集专名表：入库 JSON，按当前句英文做命中。"""

from __future__ import annotations

import json
import re

from ..models import Episode


def parse_glossary(raw: str | None) -> list[dict[str, str]]:
    try:
        data = json.loads(raw or "[]")
    except json.JSONDecodeError:
        return []
    if not isinstance(data, list):
        return []
    out: list[dict[str, str]] = []
    seen: set[str] = set()
    for item in data:
        if not isinstance(item, dict):
            continue
        en = str(item.get("en") or "").strip()
        zh = str(item.get("zh") or "").strip()
        key = en.lower()
        if not en or key in seen:
            continue
        seen.add(key)
        out.append({"en": en[:80], "zh": zh[:40]})
        if len(out) >= 24:
            break
    return out


def dump_glossary(items: list[dict] | None) -> str:
    return json.dumps(parse_glossary(json.dumps(items or [], ensure_ascii=False)), ensure_ascii=False)


def merge_glossary(existing: list[dict] | None, incoming: list[dict] | None) -> list[dict[str, str]]:
    merged = parse_glossary(json.dumps(existing or [], ensure_ascii=False))
    seen = {row["en"].lower() for row in merged}
    for item in incoming or []:
        if not isinstance(item, dict):
            continue
        en = str(item.get("en") or "").strip()
        zh = str(item.get("zh") or "").strip()
        key = en.lower()
        if not en or key in seen:
            continue
        seen.add(key)
        merged.append({"en": en[:80], "zh": zh[:40]})
        if len(merged) >= 24:
            break
    return merged


def set_episode_glossary(episode: Episode, items: list[dict] | None) -> list[dict[str, str]]:
    parsed = parse_glossary(json.dumps(items or [], ensure_ascii=False))
    episode.glossary_json = json.dumps(parsed, ensure_ascii=False)
    return parsed


def merge_episode_glossary(episode: Episode, incoming: list[dict] | None) -> list[dict[str, str]]:
    merged = merge_glossary(parse_glossary(getattr(episode, "glossary_json", None)), incoming)
    episode.glossary_json = json.dumps(merged, ensure_ascii=False)
    return merged


def glossary_hits(english: str, items: list[dict[str, str]] | None) -> list[dict[str, str]]:
    text = (english or "").strip()
    if not text or not items:
        return []
    hits: list[dict[str, str]] = []
    for item in items:
        en = (item.get("en") or "").strip()
        if not en:
            continue
        if re.search(rf"(?<![A-Za-z]){re.escape(en)}(?![A-Za-z])", text, flags=re.I):
            hits.append(item)
    return hits
