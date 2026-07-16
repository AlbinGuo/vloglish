"""统一查词：LookupCache → DeepSeek → 物化 Entry。"""

from __future__ import annotations

import logging

from sqlalchemy.orm import Session

from ..dict.deepseek import lookup_with_deepseek
from ..dict.lookup_cache import get_cached_lookup, make_cache_key, make_entry_id, save_lookup_cache
from ..entry_cache import cache_entry
from .entry_lookup import merged_exam_tags

logger = logging.getLogger(__name__)


def resolve_word_lookup(db: Session, word: str, token_type: int, context: str) -> dict:
    """返回词条详情 dict（含 exam_tags）。优先读共享 LookupCache，未命中再调 DeepSeek。"""
    word = word.strip()
    context = (context or "").strip()
    if not word:
        raise ValueError("word is required")

    cache_key = make_cache_key(word, token_type, context)
    entry_id = make_entry_id(cache_key)

    cached = get_cached_lookup(db, cache_key)
    if cached:
        try:
            cache_entry(db, cached)
        except Exception:
            logger.debug("cache_entry skipped on cache hit word=%r", word, exc_info=True)
        cached["exam_tags"] = merged_exam_tags(db, cached.get("id", entry_id))
        cached["favorite"] = False
        return cached

    result = lookup_with_deepseek(word, token_type, context, entry_id)
    save_lookup_cache(db, cache_key, word, token_type, context, entry_id, result)
    try:
        cache_entry(db, result)
    except Exception:
        logger.debug("cache_entry skipped for word=%r", word, exc_info=True)

    eid = result.get("id", entry_id)
    result["exam_tags"] = merged_exam_tags(db, eid)
    result["favorite"] = False
    return result
