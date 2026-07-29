"""Enrich subtitles with Chinese translation and IPA via DeepSeek."""
from __future__ import annotations

import logging

from ..dict.deepseek import build_subtitle_translation_brief, enrich_subtitle_lines_with_deepseek

logger = logging.getLogger(__name__)

# 每批翻译行数；前后各带若干句作剧情上下文
BATCH_SIZE = 10
_BATCH_SIZE = BATCH_SIZE
_CONTEXT_WINDOW = 6


def enrich_subtitles_with_deepseek(
    subtitles: list[dict],
    *,
    translate_chinese: bool,
    batch_size: int = BATCH_SIZE,
    episode_title: str = "",
    episode_summary: str = "",
    overwrite_chinese: bool = False,
    translation_brief: dict | None = None,
    max_batches: int | None = None,
) -> tuple[int, int, dict, int, bool, int]:
    """Fill chinese/ipa fields.

    Returns (translated_count, ipa_count, translation_brief, remaining_pending, done, batches_run).
    若未传入 translation_brief 且需要翻译，会先生成整集剧情简报。
    max_batches 限制本轮 DeepSeek 批次数（不含 brief），便于分轮续跑。
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

    brief = dict(translation_brief or {})
    if not pending:
        return 0, 0, brief, 0, True, 0

    all_english = [(row.get("english") or "").strip() for row in subtitles]

    if translate_chinese and not brief:
        try:
            brief = build_subtitle_translation_brief(
                [t for t in all_english if t],
                episode_title=episode_title,
                episode_summary=episode_summary,
            )
            if brief:
                logger.info(
                    "subtitle translation brief ready topic=%r tone=%r glossary=%d",
                    brief.get("topic", "")[:40],
                    brief.get("tone", "")[:40],
                    len(brief.get("glossary") or []),
                )
        except Exception:
            logger.warning("subtitle translation brief failed; continue without it", exc_info=True)
            brief = {}

    translated = 0
    ipa_filled = 0
    batches_run = 0
    processed = 0

    for offset in range(0, len(pending), batch_size):
        if max_batches is not None and batches_run >= max_batches:
            break
        chunk_idxs = pending[offset : offset + batch_size]
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
            translation_brief=brief if batch_need_zh else None,
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
        batches_run += 1
        processed += len(chunk_idxs)

    remaining = max(0, len(pending) - processed)
    return translated, ipa_filled, brief, remaining, remaining == 0, batches_run
