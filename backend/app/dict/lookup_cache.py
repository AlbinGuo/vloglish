from __future__ import annotations

import hashlib
import json
from datetime import datetime, timedelta

from sqlalchemy.orm import Session

from .config import LOOKUP_CACHE_TTL_DAYS
from ..models import LookupCache


def make_cache_key(word: str, token_type: int, context: str) -> str:
    normalized = f"{word.strip().lower()}|{token_type}|{context.strip()}"
    return hashlib.sha256(normalized.encode()).hexdigest()


def make_entry_id(cache_key: str) -> int:
    return int(cache_key[:12], 16) % 2_000_000_000 or 1


def get_cached_lookup(db: Session, cache_key: str) -> dict | None:
    row = db.query(LookupCache).filter(LookupCache.cache_key == cache_key).first()
    if not row:
        return None
    expires = row.updated_at + timedelta(days=LOOKUP_CACHE_TTL_DAYS)
    if datetime.utcnow() > expires:
        return None
    data = json.loads(row.response_json)
    data["id"] = row.entry_id
    data["eid"] = row.entry_id
    return data


def save_lookup_cache(
    db: Session,
    cache_key: str,
    word: str,
    token_type: int,
    context: str,
    entry_id: int,
    response: dict,
) -> None:
    payload = json.dumps(response, ensure_ascii=False)
    row = db.query(LookupCache).filter(LookupCache.cache_key == cache_key).first()
    now = datetime.utcnow()
    if row:
        row.word = word
        row.token_type = token_type
        row.context = context
        row.entry_id = entry_id
        row.response_json = payload
        row.updated_at = now
    else:
        db.add(
            LookupCache(
                cache_key=cache_key,
                word=word,
                token_type=token_type,
                context=context,
                entry_id=entry_id,
                response_json=payload,
                created_at=now,
                updated_at=now,
            )
        )
    db.commit()
