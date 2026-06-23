from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..entry_cache import cache_entry
from ..models import Entry
from ..remote import remote_entry_detail, remote_lookup
from ..serializers import entry_brief, entry_detail

router = APIRouter(prefix="/api", tags=["entries"])


def _entry_has_detail(entry: Entry) -> bool:
    return bool(entry.detail.get("definitions"))


@router.get("/entry-detail/")
def get_entry_detail(entry_id: int = Query(...), db: Session = Depends(get_db)):
    entry = db.query(Entry).filter(Entry.id == entry_id).first()
    if entry and _entry_has_detail(entry):
        return entry_detail(entry)

    remote = remote_entry_detail(entry_id)
    if remote:
        entry = cache_entry(db, remote)
        return entry_detail(entry)

    if entry:
        return entry_detail(entry)
    raise HTTPException(status_code=404, detail="Entry not found")


@router.get("/lookup/")
def lookup(id: int = Query(...), type: int = Query(1), db: Session = Depends(get_db)):
    entry = db.query(Entry).filter(Entry.id == id).first()
    if entry and _entry_has_detail(entry):
        data = entry_detail(entry)
        data["eid"] = entry.id
        return data

    remote = remote_lookup(id, type)
    if remote:
        entry = cache_entry(db, remote)
        data = entry_detail(entry)
        data["eid"] = entry.id
        return data

    raise HTTPException(status_code=404, detail="Entry not found")


@router.get("/entries/")
def list_entries(v: str = Query(...), db: Session = Depends(get_db)):
    from ..models import Episode

    episode = db.query(Episode).filter(Episode.video_id == v).first()
    if not episode:
        return {"entries": []}
    entries = db.query(Entry).order_by(Entry.headword).limit(500).all()
    return {"entries": [entry_brief(e) for e in entries]}
