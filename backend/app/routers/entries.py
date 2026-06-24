import logging

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..dict.deepseek import lookup_with_deepseek
from ..dict.lookup_cache import get_cached_lookup, make_cache_key, make_entry_id, save_lookup_cache
from ..models import Entry
from ..serializers import entry_brief, entry_detail

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api", tags=["entries"])


def _entry_has_detail(entry: Entry) -> bool:
    return bool(entry.detail.get("definitions"))


@router.get("/entry-detail/")
def get_entry_detail(entry_id: int = Query(...), db: Session = Depends(get_db)):
    entry = db.query(Entry).filter(Entry.id == entry_id).first()
    if entry and _entry_has_detail(entry):
        return entry_detail(entry)
    if entry:
        return entry_detail(entry)
    raise HTTPException(status_code=404, detail="Entry not found")


@router.get("/lookup/")
def lookup(
    word: str = Query(..., min_length=1),
    type: int = Query(1, ge=1, le=2),
    context: str = Query(""),
    db: Session = Depends(get_db),
):
    word = word.strip()
    context = context.strip()
    if not word:
        raise HTTPException(status_code=400, detail="word is required")

    cache_key = make_cache_key(word, type, context)
    entry_id = make_entry_id(cache_key)

    cached = get_cached_lookup(db, cache_key)
    if cached:
        return cached

    try:
        result = lookup_with_deepseek(word, type, context, entry_id)
        save_lookup_cache(db, cache_key, word, type, context, entry_id, result)
        return result
    except RuntimeError as e:
        logger.warning("Lookup failed word=%r: %s", word, e)
        raise HTTPException(status_code=502, detail=str(e)) from e
    except Exception as e:
        logger.exception("Lookup error word=%r", word)
        raise HTTPException(status_code=500, detail=f"查词失败: {e}") from e


@router.get("/entries/")
def list_entries(v: str = Query(...), db: Session = Depends(get_db)):
    from ..models import Episode

    episode = db.query(Episode).filter(Episode.video_id == v).first()
    if not episode:
        return {"entries": []}
    entries = db.query(Entry).order_by(Entry.headword).limit(500).all()
    return {"entries": [entry_brief(e) for e in entries]}
