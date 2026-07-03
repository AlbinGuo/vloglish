"""Enrich subtitles with Chinese translation and IPA via DeepSeek."""
from __future__ import annotations

from ..dict.deepseek import enrich_subtitle_lines_with_deepseek


def enrich_subtitles_with_deepseek(
    subtitles: list[dict],
    *,
    translate_chinese: bool,
    batch_size: int = 8,
) -> tuple[int, int]:
    """Fill missing chinese/ipa fields. Returns (translated_count, ipa_count)."""
    pending: list[tuple[int, str]] = []
    for i, row in enumerate(subtitles):
        english = (row.get("english") or "").strip()
        if not english:
            continue
        need_zh = translate_chinese and not (row.get("chinese") or "").strip()
        need_ipa = not (row.get("ipa") or "").strip()
        if need_zh or need_ipa:
            pending.append((i, english))

    if not pending:
        return 0, 0

    translated = 0
    ipa_filled = 0
    for offset in range(0, len(pending), batch_size):
        chunk = pending[offset : offset + batch_size]
        lines = [text for _, text in chunk]
        items = enrich_subtitle_lines_with_deepseek(lines, translate_chinese=translate_chinese)
        for (idx, _), item in zip(chunk, items):
            row = subtitles[idx]
            if translate_chinese and not (row.get("chinese") or "").strip():
                zh = item.get("chinese", "").strip()
                if zh:
                    row["chinese"] = zh
                    translated += 1
            if not (row.get("ipa") or "").strip():
                ipa = item.get("ipa", "").strip()
                if ipa:
                    row["ipa"] = ipa
                    ipa_filled += 1
    return translated, ipa_filled
