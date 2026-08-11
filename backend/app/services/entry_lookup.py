"""从 Entry / LookupCache 读取词条详情与音标、释义等附加信息。"""

from __future__ import annotations

import json

from sqlalchemy.orm import Session

from ..dict.deepseek import normalize_exam_tags
from ..models import Entry, LookupCache
from ..serializers import entry_detail


def _ipa_and_definition_from_detail(detail: dict) -> tuple[str, str]:
    pronunciations = detail.get("pronunciations") or []
    ipa = ""
    for p in pronunciations:
        if not isinstance(p, dict):
            continue
        candidate = (p.get("ipa") or "").strip()
        if p.get("is_primary") and candidate:
            ipa = candidate
            break
        if candidate and not ipa:
            ipa = candidate
    definitions = detail.get("definitions") or []
    first = definitions[0] if definitions else None
    definition_cn = (
        (first.get("definition_cn") or "").strip() if isinstance(first, dict) else ""
    )
    return ipa, definition_cn


def lookup_result_by_entry_id(db: Session, entry_id: int) -> dict | None:
    cache_row = (
        db.query(LookupCache)
        .filter(LookupCache.entry_id == entry_id)
        .order_by(LookupCache.updated_at.desc())
        .first()
    )
    if not cache_row:
        return None
    try:
        data = json.loads(cache_row.response_json)
    except json.JSONDecodeError:
        return None
    data["id"] = cache_row.entry_id
    data["eid"] = cache_row.entry_id
    data["exam_tags"] = normalize_exam_tags(data.get("exam_tags"))
    return data


def merged_exam_tags(db: Session, entry_id: int) -> list[str]:
    entry = db.query(Entry).filter(Entry.id == entry_id).first()
    cached = lookup_result_by_entry_id(db, entry_id)
    cached_tags = cached.get("exam_tags", []) if cached else []
    entry_tags = normalize_exam_tags(entry.exam_tags) if entry else []
    return cached_tags or entry_tags


def _extras_from_entry_and_cache(
    entry: Entry | None, cached: dict | None
) -> tuple[list[str], str, str]:
    cached_tags = cached.get("exam_tags", []) if cached else []
    entry_tags = normalize_exam_tags(entry.exam_tags) if entry else []
    exam_tags = cached_tags or entry_tags
    ipa = ""
    definition_cn = ""
    if entry:
        detail = entry.detail
        if detail.get("definitions"):
            ipa, definition_cn = _ipa_and_definition_from_detail(detail)
    if cached:
        cached_ipa, cached_def = _ipa_and_definition_from_detail(cached)
        if not ipa:
            ipa = cached_ipa
        if not definition_cn:
            definition_cn = cached_def
    return exam_tags, ipa, definition_cn


def entry_vocab_extras(db: Session, entry_id: int) -> tuple[list[str], str, str]:
    entry = db.query(Entry).filter(Entry.id == entry_id).first()
    cached = lookup_result_by_entry_id(db, entry_id)
    return _extras_from_entry_and_cache(entry, cached)


def entry_vocab_extras_many(
    db: Session, entry_ids: list[int]
) -> dict[int, tuple[list[str], str, str]]:
    """批量取生词本展示附加信息，避免列表接口 N+1。"""
    ids = sorted({int(i) for i in entry_ids if i})
    if not ids:
        return {}

    entries = {
        e.id: e for e in db.query(Entry).filter(Entry.id.in_(ids)).all()
    }
    cache_rows = (
        db.query(LookupCache)
        .filter(LookupCache.entry_id.in_(ids))
        .order_by(LookupCache.entry_id.asc(), LookupCache.updated_at.desc())
        .all()
    )
    caches: dict[int, dict] = {}
    for row in cache_rows:
        if row.entry_id in caches:
            continue
        try:
            data = json.loads(row.response_json)
        except json.JSONDecodeError:
            continue
        if not isinstance(data, dict):
            continue
        data["id"] = row.entry_id
        data["eid"] = row.entry_id
        data["exam_tags"] = normalize_exam_tags(data.get("exam_tags"))
        caches[row.entry_id] = data

    return {
        eid: _extras_from_entry_and_cache(entries.get(eid), caches.get(eid))
        for eid in ids
    }


def entry_has_detail(entry: Entry) -> bool:
    return bool(entry.detail.get("definitions"))


def build_entry_detail(db: Session, entry_id: int) -> dict | None:
    entry = db.query(Entry).filter(Entry.id == entry_id).first()
    cached = lookup_result_by_entry_id(db, entry_id)

    if entry and entry_has_detail(entry):
        data = entry_detail(entry)
    elif cached:
        data = {
            "id": entry_id,
            "headword": cached.get("headword", ""),
            "category": cached.get("category", "单词"),
            "pronunciations": cached.get("pronunciations") or [],
            "definitions": cached.get("definitions") or [],
            "exam_tags": cached.get("exam_tags") or [],
            "favorite": None,
        }
    elif entry:
        data = entry_detail(entry)
    else:
        return None

    data["exam_tags"] = merged_exam_tags(db, entry_id)
    return data
