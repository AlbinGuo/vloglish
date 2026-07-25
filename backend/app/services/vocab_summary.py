"""解析剧集「词汇与表达汇总」粘贴文本。

支持两种格式：

1) 简单两列（兼容）：
   分类名
   english<TAB>中文释义

2) 多行词条（管理端常用）：
   分类名

   english headword
   剧中含义：...
   例句：...
   释义：...
"""

from __future__ import annotations

import re

_SPLIT_RE = re.compile(r"(?:\t+|\|+|／+|/+|[ \u00a0\u3000]{2,}|[ ]*[-–—][ ]*)")
_FIELD_PREFIXES = (
    ("剧中含义：", "note"),
    ("剧中含义:", "note"),
    ("例句：", "example"),
    ("例句:", "example"),
    ("释义：", "zh"),
    ("释义:", "zh"),
    ("中文：", "zh"),
    ("中文:", "zh"),
    ("难度：", "level"),
    ("难度:", "level"),
)
_LATIN_RE = re.compile(r"[A-Za-z]")


def _match_field(line: str) -> tuple[str, str] | None:
    for prefix, key in _FIELD_PREFIXES:
        if line.startswith(prefix):
            return key, line[len(prefix) :].strip()
    return None


def _split_simple_entry(line: str) -> tuple[str, str] | None:
    parts = _SPLIT_RE.split(line, maxsplit=1)
    if len(parts) != 2:
        return None
    en, zh = parts[0].strip(), parts[1].strip()
    if not en or not _LATIN_RE.search(en):
        return None
    # 避免把「固定搭配 / 惯用表达」一类标题误判为词条
    if not zh:
        return None
    return en, zh


def _item_dict(
    *,
    en: str,
    zh: str = "",
    note: str = "",
    example: str = "",
    level: str = "",
) -> dict:
    return {
        "en": en,
        "zh": zh,
        "note": note,
        "example": example,
        "level": level,
    }


def parse_vocab_summary(text: str) -> list[dict]:
    """返回 [{title, items:[{en, zh, note, example, level}]}]。无有效内容时返回 []。"""
    raw = (text or "").replace("\r\n", "\n").replace("\r", "\n")
    groups: list[dict] = []
    current: dict | None = None
    current_entry: dict | None = None

    def ensure_group(title: str) -> dict:
        nonlocal current
        title = (title or "").strip() or "汇总"
        if current and current["title"] == title:
            return current
        current = {"title": title, "items": []}
        groups.append(current)
        return current

    def flush_entry() -> None:
        nonlocal current_entry
        if not current_entry:
            return
        en = (current_entry.get("en") or "").strip()
        if not en:
            current_entry = None
            return
        g = current or ensure_group("汇总")
        g["items"].append(
            _item_dict(
                en=en,
                zh=(current_entry.get("zh") or "").strip(),
                note=(current_entry.get("note") or "").strip(),
                example=(current_entry.get("example") or "").strip(),
                level=(current_entry.get("level") or "").strip(),
            )
        )
        current_entry = None

    for line in raw.split("\n"):
        line = line.strip()
        if not line:
            flush_entry()
            continue

        field = _match_field(line)
        if field:
            key, value = field
            if current_entry is None:
                # 无头词的字段行忽略
                continue
            current_entry[key] = value
            continue

        simple = _split_simple_entry(line)
        if simple:
            flush_entry()
            en, zh = simple
            g = current or ensure_group("汇总")
            g["items"].append(_item_dict(en=en, zh=zh))
            continue

        if not _LATIN_RE.search(line):
            flush_entry()
            ensure_group(line)
            continue

        # 新的英文头词，开启多行词条
        flush_entry()
        current_entry = {"en": line, "zh": "", "note": "", "example": "", "level": ""}

    flush_entry()
    return [g for g in groups if g["items"]]


def vocab_summary_item_count(groups: list[dict]) -> int:
    return sum(len(g.get("items") or []) for g in groups)
