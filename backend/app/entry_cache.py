import json

from sqlalchemy.orm import Session

from .dict.deepseek import normalize_exam_tags
from .models import Entry, TokenRef


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
    entry.exam_tags_json = json.dumps(normalize_exam_tags(data.get("exam_tags")))
    entry.data_json = json.dumps(payload)
    db.commit()
    db.refresh(entry)
    return entry


def save_token_ref(db: Session, token_id: int, token_type: int, entry_id: int) -> None:
    ref = (
        db.query(TokenRef)
        .filter(TokenRef.token_id == token_id, TokenRef.token_type == token_type)
        .first()
    )
    if not ref:
        ref = TokenRef(token_id=token_id, token_type=token_type, entry_id=entry_id)
        db.add(ref)
    else:
        ref.entry_id = entry_id
    db.commit()


def entry_for_token(db: Session, token_id: int, token_type: int) -> Entry | None:
    ref = (
        db.query(TokenRef)
        .filter(TokenRef.token_id == token_id, TokenRef.token_type == token_type)
        .first()
    )
    if not ref:
        return None
    return db.query(Entry).filter(Entry.id == ref.entry_id).first()
