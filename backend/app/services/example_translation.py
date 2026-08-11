"""例句英→中：共享缓存（DB + Redis），命中不调 AI、不扣额度。"""

from __future__ import annotations

import hashlib
import logging
import re

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ..dict.deepseek import translate_lines_with_deepseek
from ..models import ArticleSegment, ExampleTranslationCache, Subtitle, User
from .ai_quota import check_and_consume, record_usage
from .ai_result_cache import get_ai_result, set_ai_result

logger = logging.getLogger(__name__)

_CACHE_KIND = "example_zh"
_WS_RE = re.compile(r"\s+")


def normalize_example_en(text: str) -> str:
    return _WS_RE.sub(" ", (text or "").strip())


def example_content_hash(english: str) -> str:
    raw = normalize_example_en(english)
    return hashlib.sha1(raw.encode("utf-8")).hexdigest()[:40]


def lookup_cached_example_zh(db: Session, english: str) -> str:
    """只读缓存（DB → Redis），不调 AI。"""
    en = normalize_example_en(english)
    if not en:
        return ""
    digest = example_content_hash(en)

    row = (
        db.query(ExampleTranslationCache)
        .filter(ExampleTranslationCache.content_hash == digest)
        .first()
    )
    if row and (row.chinese or "").strip():
        zh = (row.chinese or "").strip()
        set_ai_result(_CACHE_KIND, 0, digest[:20], {"chinese": zh, "english": en})
        return zh

    cached = get_ai_result(_CACHE_KIND, 0, digest[:20])
    if cached:
        zh = str(cached.get("chinese") or "").strip()
        if zh:
            _persist_db(db, digest=digest, english=en, chinese=zh)
            return zh
    return ""


def _persist_db(db: Session, *, digest: str, english: str, chinese: str) -> None:
    zh = (chinese or "").strip()
    en = normalize_example_en(english)
    if not digest or not en or not zh:
        return
    existing = (
        db.query(ExampleTranslationCache)
        .filter(ExampleTranslationCache.content_hash == digest)
        .first()
    )
    if existing:
        if not (existing.chinese or "").strip():
            existing.chinese = zh
            existing.english = en
            try:
                db.commit()
            except Exception:
                db.rollback()
        return
    db.add(
        ExampleTranslationCache(
            content_hash=digest,
            english=en[:2000],
            chinese=zh[:2000],
        )
    )
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
    except Exception:
        db.rollback()
        logger.exception("example translation cache persist failed")


def _write_back_source(
    db: Session,
    *,
    chinese: str,
    source_subtitle_id: int | None,
    source_segment_id: int | None,
) -> None:
    zh = (chinese or "").strip()
    if not zh:
        return
    try:
        if source_subtitle_id:
            sub = db.query(Subtitle).filter(Subtitle.id == int(source_subtitle_id)).first()
            if sub and not (sub.chinese or "").strip():
                sub.chinese = zh[:2000]
                db.commit()
                return
        if source_segment_id:
            seg = db.query(ArticleSegment).filter(ArticleSegment.id == int(source_segment_id)).first()
            if seg and not (seg.chinese or "").strip():
                seg.chinese = zh[:2000]
                db.commit()
    except Exception:
        db.rollback()
        logger.debug("example zh write-back failed", exc_info=True)


def resolve_example_zh(
    db: Session,
    user: User,
    *,
    english: str,
    source_subtitle_id: int | None = None,
    source_segment_id: int | None = None,
) -> dict:
    """
    返回 { chinese, from_cache, quota? }。
    缓存命中不扣额度；未命中调 DeepSeek 并写入共享缓存。
    """
    en = normalize_example_en(english)
    if not en:
        raise ValueError("例句英文为空")

    cached = lookup_cached_example_zh(db, en)
    if cached:
        record_usage(
            db,
            user,
            action="example_translate",
            provider="cache",
            billed=False,
            cache_hit=True,
            counts_quota=False,
            meta={"len": len(en)},
        )
        _write_back_source(
            db,
            chinese=cached,
            source_subtitle_id=source_subtitle_id,
            source_segment_id=source_segment_id,
        )
        return {"chinese": cached, "from_cache": True}

    quota = check_and_consume(db, user, action="example_translate")
    digest = example_content_hash(en)

    try:
        translations = translate_lines_with_deepseek([en])
        zh = (translations[0] if translations else "").strip()
    except Exception as e:
        logger.exception("example translate failed")
        raise ValueError("AI 翻译失败，请稍后重试") from e

    if not zh:
        raise ValueError("AI 未返回有效翻译")

    _persist_db(db, digest=digest, english=en, chinese=zh)
    set_ai_result(_CACHE_KIND, 0, digest[:20], {"chinese": zh, "english": en})
    _write_back_source(
        db,
        chinese=zh,
        source_subtitle_id=source_subtitle_id,
        source_segment_id=source_segment_id,
    )
    return {"chinese": zh, "from_cache": False, "quota": quota}
