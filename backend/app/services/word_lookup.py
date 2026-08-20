"""统一查词：LookupCache → DeepSeek → 物化 Entry。"""

from __future__ import annotations

import logging
import threading

from sqlalchemy import func
from sqlalchemy.orm import Session

from ..database import SessionLocal
from ..dict.deepseek import lookup_with_deepseek
from ..dict.lookup_cache import get_cached_lookup, make_cache_key, make_entry_id, save_lookup_cache
from ..entry_cache import cache_entry
from ..models import Entry, LookupCache
from .entry_lookup import merged_exam_tags

logger = logging.getLogger(__name__)


def _finalize_cached_lookup(db: Session, cached: dict, fallback_id: int) -> tuple[dict, bool]:
    try:
        cache_entry(db, cached)
    except Exception:
        logger.debug("cache_entry skipped on cache hit id=%s", cached.get("id"), exc_info=True)
    eid = int(cached.get("id") or fallback_id or 0)
    cached["exam_tags"] = merged_exam_tags(db, eid)
    cached["favorite"] = False
    return cached, True


def _reuse_word_level_cache(db: Session, word: str, token_type: int) -> dict | None:
    """同一单词在其它句子查过时，先复用释义，避免每次都等 DeepSeek。"""
    generic = get_cached_lookup(db, make_cache_key(word, token_type, ""))
    if generic:
        return generic
    row = (
        db.query(LookupCache)
        .filter(func.lower(LookupCache.word) == word.lower())
        .filter(LookupCache.token_type == token_type)
        .order_by(LookupCache.updated_at.desc())
        .first()
    )
    if row:
        reused = get_cached_lookup(db, row.cache_key)
        if reused:
            return reused
    entry = (
        db.query(Entry)
        .filter(func.lower(Entry.headword) == word.lower())
        .order_by(Entry.id.asc())
        .first()
    )
    if not entry:
        return None
    from .entry_lookup import build_entry_detail

    detail = build_entry_detail(db, entry.id)
    if detail and detail.get("definitions"):
        return detail
    return None


def resolve_word_lookup(
    db: Session, word: str, token_type: int, context: str
) -> tuple[dict, bool]:
    """返回 (词条详情 dict, from_cache)。优先读共享 LookupCache，未命中再调 DeepSeek。"""
    word = word.strip()
    context = (context or "").strip()
    if not word:
        raise ValueError("word is required")

    cache_key = make_cache_key(word, token_type, context)
    entry_id = make_entry_id(cache_key)

    cached = get_cached_lookup(db, cache_key)
    if cached:
        return _finalize_cached_lookup(db, cached, entry_id)

    reused = _reuse_word_level_cache(db, word, token_type)
    if reused:
        reused_id = int(reused.get("id") or entry_id)
        try:
            save_lookup_cache(db, cache_key, word, token_type, context, reused_id, reused)
        except Exception:
            logger.debug("reuse cache write skipped word=%r", word, exc_info=True)
        return _finalize_cached_lookup(db, reused, reused_id)

    result = lookup_with_deepseek(word, token_type, context, entry_id)
    save_lookup_cache(db, cache_key, word, token_type, context, entry_id, result)
    if context:
        generic_key = make_cache_key(word, token_type, "")
        if not get_cached_lookup(db, generic_key):
            save_lookup_cache(db, generic_key, word, token_type, "", entry_id, result)
    try:
        cache_entry(db, result)
    except Exception:
        logger.debug("cache_entry skipped for word=%r", word, exc_info=True)

    eid = result.get("id", entry_id)
    result["exam_tags"] = merged_exam_tags(db, eid)
    result["favorite"] = False
    return result, False


def _schedule_background_lookup(word: str, token_type: int) -> None:
    """后台补全释义，不阻塞「加入生词本」。"""

    def _run() -> None:
        db = SessionLocal()
        try:
            resolve_word_lookup(db, word, token_type, "")
        except Exception:
            logger.warning("background lookup failed word=%r", word, exc_info=True)
        finally:
            db.close()

    threading.Thread(target=_run, name=f"vocab-lookup-{word[:24]}", daemon=True).start()


def resolve_entry_id_for_vocab_save(
    db: Session, word: str, token_type: int
) -> int:
    """为收藏解析 entry_id：优先复用缓存/已有词条，避免同步调用 DeepSeek。"""
    word = (word or "").strip()
    if not word:
        raise ValueError("word is required")
    token_type = 2 if int(token_type or 1) == 2 else 1

    # 1) 空语境稳定 key（汇总/快捷收藏统一走这里，命中率更高）
    stable_key = make_cache_key(word, token_type, "")
    cached = get_cached_lookup(db, stable_key)
    if cached and cached.get("id"):
        return int(cached["id"])

    # 2) 任意语境下该词的查词缓存
    row = (
        db.query(LookupCache)
        .filter(func.lower(LookupCache.word) == word.lower())
        .order_by(LookupCache.updated_at.desc())
        .first()
    )
    if row and row.entry_id:
        return int(row.entry_id)

    # 3) 已物化的 Entry
    entry = (
        db.query(Entry)
        .filter(func.lower(Entry.headword) == word.lower())
        .order_by(Entry.id.asc())
        .first()
    )
    if entry:
        return int(entry.id)

    # 4) 分配稳定 id + stub，释义后台补全
    entry_id = make_entry_id(stable_key)
    stub = db.query(Entry).filter(Entry.id == entry_id).first()
    if not stub:
        db.add(
            Entry(
                id=entry_id,
                headword=word,
                category="短语" if token_type == 2 else "单词",
                exam_tags_json="[]",
                data_json="{}",
            )
        )
        db.commit()
    _schedule_background_lookup(word, token_type)
    return entry_id
