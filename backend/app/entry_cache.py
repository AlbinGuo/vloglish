import json

from sqlalchemy.orm import Session

from .models import Entry


def cache_entry(db: Session, data: dict) -> Entry:
    entry_id = data.get("eid") or data.get("id")
    if not entry_id:
        raise ValueError("entry id missing")

    payload = {
        "pronunciations": data.get("pronunciations", []),
        "definitions": data.get("definitions", []),
    }
    entry = db.query(Entry).filter(Entry.id == entry_id).first()
    if not entry:
        entry = Entry(id=entry_id)
        db.add(entry)
    entry.headword = data["headword"]
    entry.category = data.get("category", "单词")
    entry.exam_tags_json = json.dumps(data.get("exam_tags", []))
    entry.data_json = json.dumps(payload)
    db.commit()
    db.refresh(entry)
    return entry
