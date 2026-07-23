"""Enrich subtitles with Chinese translation and IPA via DeepSeek."""
from __future__ import annotations

from ..dict.deepseek import enrich_subtitle_lines_with_deepseek

# 每批翻译行数；前后各带若干句作剧情上下文
_BATCH_SIZE = 8
_CONTEXT_WINDOW = 4


def enrich_subtitles_with_deepseek(
    subtitles: list[dict],
    *,
    translate_chinese: bool,
    batch_size: int = _BATCH_SIZE,
    episode_title: str = "",
    episode_summary: str = "",
    overwrite_chinese: bool = False,
) -> tuple[int, int]:
    """Fill chinese/ipa fields. Returns (translated_count, ipa_count).

    overwrite_chinese=True 时：即使已有中文也会按剧情重译覆盖（导入双语 SRT 用）。
    """
    pending: list[int] = []
    for i, row in enumerate(subtitles):
        english = (row.get("english") or "").strip()
        if not english:
            continue
        has_zh = bool((row.get("chinese") or "").strip())
        need_zh = translate_chinese and (overwrite_chinese or not has_zh)
        need_ipa = not (row.get("ipa") or "").strip()
        if need_zh or need_ipa:
            pending.append(i)

    if not pending:
        return 0, 0

    # 全量英文轴，用于取前后文
    all_english = [(row.get("english") or "").strip() for row in subtitles]

    translated = 0
    ipa_filled = 0
    for offset in range(0, len(pending), batch_size):
        chunk_idxs = pending[offset : offset + batch_size]
        # 本批是否需要出中文：只要其中有一行需要翻译，整批走翻译 prompt
        batch_need_zh = False
        line_items: list[dict[str, str]] = []
        for idx in chunk_idxs:
            row = subtitles[idx]
            english = (row.get("english") or "").strip()
            draft = (row.get("chinese") or "").strip()
            has_zh = bool(draft)
            need_zh = translate_chinese and (overwrite_chinese or not has_zh)
            if need_zh:
                batch_need_zh = True
            item: dict[str, str] = {"english": english}
            if need_zh and draft:
                item["draft_chinese"] = draft
            line_items.append(item)

        first_idx = chunk_idxs[0]
        last_idx = chunk_idxs[-1]
        before = [
            t for t in all_english[max(0, first_idx - _CONTEXT_WINDOW) : first_idx] if t
        ]
        after = [
            t
            for t in all_english[last_idx + 1 : last_idx + 1 + _CONTEXT_WINDOW]
            if t
        ]

        items = enrich_subtitle_lines_with_deepseek(
            line_items if batch_need_zh else [it["english"] for it in line_items],
            translate_chinese=batch_need_zh,
            before=before if batch_need_zh else None,
            after=after if batch_need_zh else None,
            episode_title=episode_title if batch_need_zh else "",
            episode_summary=episode_summary if batch_need_zh else "",
        )
        for idx, item in zip(chunk_idxs, items):
            row = subtitles[idx]
            has_zh = bool((row.get("chinese") or "").strip())
            need_zh = translate_chinese and (overwrite_chinese or not has_zh)
            if need_zh:
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
