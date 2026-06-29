import logging

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user_optional
from ..dict.deepseek import lookup_with_deepseek
from ..dict.lookup_cache import get_cached_lookup, make_cache_key, make_entry_id, save_lookup_cache
from ..models import Entry, Episode, User
from ..serializers import entry_brief, entry_detail
from ..services.learning import is_entry_saved, log_word_lookup

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["entries"])


def _entry_has_detail(entry: Entry) -> bool:
    return bool(entry.detail.get("definitions"))


def _entry_detail_for_user(db: Session, entry: Entry, user: User | None) -> dict:
    data = entry_detail(entry)
    data["favorite"] = is_entry_saved(db, user.id, entry.id) if user else False
    return data


@router.get("/entry-detail/")
def get_entry_detail(
    entry_id: int = Query(...),
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    entry = db.query(Entry).filter(Entry.id == entry_id).first()
    if entry and _entry_has_detail(entry):
        return _entry_detail_for_user(db, entry, user)
    if entry:
        return _entry_detail_for_user(db, entry, user)
    raise HTTPException(status_code=404, detail="Entry not found")


@router.get("/lookup/")
def lookup(
    word: str = Query(..., min_length=1),
    type: int = Query(1, ge=1, le=2),
    context: str = Query(""),
    video_id: str = Query(""),
    episode_id: int | None = None,
    subtitle_id: int | None = None,
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
    else:
        try:
            result = lookup_with_deepseek(word, type, context, entry_id)
            save_lookup_cache(db, cache_key, word, type, context, entry_id, result)
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
        )
        result["favorite"] = is_entry_saved(db, user.id, result.get("id", entry_id))
    else:
        result["favorite"] = False

    return result


@router.get("/entries/")
def list_entries(v: str = Query(...), db: Session = Depends(get_db)):
    episode = db.query(Episode).filter(Episode.video_id == v).first()
    if not episode:
        return {"entries": []}
    entries = db.query(Entry).order_by(Entry.headword).limit(500).all()
    return {"entries": [entry_brief(e) for e in entries]}
