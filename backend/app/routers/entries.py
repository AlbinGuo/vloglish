import logging

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user_optional
from ..dict.deepseek import lookup_with_deepseek
from ..dict.lookup_cache import get_cached_lookup, make_cache_key, make_entry_id, save_lookup_cache
from ..entry_cache import cache_entry
from ..models import Article, Entry, Episode, User
from ..serializers import entry_brief
from ..services.entry_lookup import build_entry_detail, merged_exam_tags
from ..services.learning import is_entry_saved, log_word_lookup

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["entries"])


@router.get("/entry-detail/")
def get_entry_detail(
    entry_id: int = Query(...),
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    data = build_entry_detail(db, entry_id)
    if not data:
        raise HTTPException(status_code=404, detail="Entry not found")
    data["favorite"] = is_entry_saved(db, user.id, entry_id) if user else False
    return data


@router.get("/lookup/")
def lookup(
    word: str = Query(..., min_length=1),
    type: int = Query(1, ge=1, le=2),
    context: str = Query(""),
    video_id: str = Query(""),
    episode_id: int | None = None,
    subtitle_id: int | None = None,
    article_id: str = Query(""),
    segment_id: int | None = None,
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    word = word.strip()
    context = context.strip()
    if not word:
        raise HTTPException(status_code=400, detail="word is required")

    cache_key = make_cache_key(word, type, context)
    entry_id = make_entry_id(cache_key)

    cached = get_cached_lookup(db, cache_key)
    if cached:
        result = cached
        try:
            cache_entry(db, result)
        except Exception:
            logger.debug("cache_entry skipped on cache hit word=%r", word, exc_info=True)
    else:
        try:
            result = lookup_with_deepseek(word, type, context, entry_id)
            save_lookup_cache(db, cache_key, word, type, context, entry_id, result)
            try:
                cache_entry(db, result)
            except Exception:
                logger.debug("cache_entry skipped for word=%r", word, exc_info=True)
        except RuntimeError as e:
            logger.warning("Lookup failed word=%r: %s", word, e)
            raise HTTPException(status_code=502, detail=str(e)) from e
        except Exception as e:
            logger.exception("Lookup error word=%r", word)
            raise HTTPException(status_code=500, detail=f"查词失败: {e}") from e

    if user:
        ep_id = episode_id
        if video_id and not ep_id:
            ep = db.query(Episode).filter(Episode.video_id == video_id).first()
            ep_id = ep.id if ep else None
        art_id = None
        if article_id:
            art = db.query(Article).filter(Article.article_id == article_id.strip()).first()
            art_id = art.id if art else None
        log_word_lookup(
            db,
            user,
            entry_id=result.get("id", entry_id),
            word=word,
            token_type=type,
            context=context,
            episode_id=ep_id,
            subtitle_id=subtitle_id,
            video_id=video_id,
            article_id=art_id,
            segment_id=segment_id,
        )
        result["favorite"] = is_entry_saved(db, user.id, result.get("id", entry_id))
    else:
        result["favorite"] = False

    eid = result.get("id", entry_id)
    result["exam_tags"] = merged_exam_tags(db, eid)
    return result


@router.get("/entries/")
def list_entries(v: str = Query(...), db: Session = Depends(get_db)):
    episode = db.query(Episode).filter(Episode.video_id == v).first()
    if not episode:
        return {"entries": []}
    entries = db.query(Entry).order_by(Entry.headword).limit(500).all()
    return {"entries": [entry_brief(e) for e in entries]}
