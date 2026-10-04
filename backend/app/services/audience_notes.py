"""Curate YouTube comments into episode audience notes."""
from __future__ import annotations

import hashlib
import json
import re

from sqlalchemy.orm import Session

from ..dict.deepseek import curate_audience_notes_with_deepseek
from ..models import Episode, EpisodeAudienceNote
from .youtube_comments_fetch import fetch_youtube_comments, resolve_youtube_watch_url

NOTE_KINDS = ("timestamp", "culture", "opinion", "uploader")

_THANKS_RE = re.compile(
    r"\b(thanks|thank you|thx|tysm|first comment|subscribed?|nice video|great video|"
    r"useful video|love this|love it|good video)\b",
    re.I,
)
_TIMESTAMP_RE = re.compile(r"(?<![\d:])(?:(\d{1,2}):)?(\d{1,2}):(\d{2})(?![\d:])")


def audience_note_dict(note: EpisodeAudienceNote, *, include_author: bool = False) -> dict:
    payload = {
        "id": note.id,
        "english": note.english,
        "chinese": note.chinese or "",
        "kind": note.kind if note.kind in NOTE_KINDS else "opinion",
        "timestamp_sec": note.timestamp_sec,
        "like_count": note.like_count,
        "phrases": note.phrases,
        "is_published": bool(note.is_published),
        "sort_order": note.sort_order,
        "source_comment_id": note.source_comment_id,
    }
    if include_author:
        payload["author_name"] = note.author_name or ""
    return payload


def list_audience_notes(
    db: Session,
    episode_id: int,
    *,
    published_only: bool = False,
    include_author: bool = False,
) -> list[dict]:
    q = db.query(EpisodeAudienceNote).filter(EpisodeAudienceNote.episode_id == episode_id)
    if published_only:
        q = q.filter(EpisodeAudienceNote.is_published.is_(True))
    rows = q.order_by(EpisodeAudienceNote.sort_order.asc(), EpisodeAudienceNote.id.asc()).all()
    return [audience_note_dict(row, include_author=include_author) for row in rows]


def published_audience_notes(episode: Episode) -> list[dict]:
    rows = [
        note
        for note in getattr(episode, "audience_notes", []) or []
        if note.is_published and (note.english or "").strip()
    ]
    rows.sort(key=lambda note: (note.sort_order, note.id))
    return [audience_note_dict(note) for note in rows]


def curate_audience_notes_for_episode(db: Session, episode: Episode) -> dict:
    url = resolve_youtube_watch_url(
        original_video_url=episode.original_video_url or "",
        video_id=episode.video_id,
    )
    comments = fetch_youtube_comments(url, max_comments=80)
    if not comments:
        raise RuntimeError("该视频没有评论，或评论区已关闭")

    candidates = select_comment_candidates(comments)
    if not candidates:
        raise RuntimeError("抓到了评论，但没有适合当学习材料的条目（多为感谢或灌水）")

    curated = curate_audience_notes_with_deepseek(
        [
            {
                "id": item["id"],
                "text": item["text"],
                "like_count": item["like_count"],
                "is_pinned": item["is_pinned"],
                "author_is_uploader": item["author_is_uploader"],
                "timestamp_sec": item.get("timestamp_sec"),
            }
            for item in candidates
        ],
        episode_title=episode.short_title or "",
        episode_summary=episode.summary or "",
    )
    if not curated:
        raise RuntimeError("模型没有选出可用热议，请换一集或稍后重试")

    by_id = {item["id"]: item for item in candidates if item.get("id")}
    saved = replace_audience_notes(db, episode, curated, by_id)
    return {
        "notes": [audience_note_dict(note, include_author=True) for note in saved],
        "fetched": len(comments),
        "candidates": len(candidates),
        "selected": len(saved),
    }


def replace_audience_notes(
    db: Session,
    episode: Episode,
    curated: list[dict],
    comments_by_id: dict[str, dict],
) -> list[EpisodeAudienceNote]:
    db.query(EpisodeAudienceNote).filter(EpisodeAudienceNote.episode_id == episode.id).delete(
        synchronize_session=False
    )
    db.flush()

    saved: list[EpisodeAudienceNote] = []
    seen_ids: set[str] = set()
    for index, item in enumerate(curated):
        source = _resolve_source(item, comments_by_id)
        source_id = str(item.get("source_id") or source.get("id") or "")[:64]
        if not source_id:
            source_id = hashlib.sha1((item.get("english") or "").encode("utf-8")).hexdigest()[:16]
        if source_id in seen_ids:
            source_id = f"{source_id}-{index}"
        seen_ids.add(source_id)
        timestamp = item.get("timestamp_sec")
        if timestamp is None:
            timestamp = source.get("timestamp_sec")
        note = EpisodeAudienceNote(
            episode_id=episode.id,
            source_comment_id=source_id,
            english=str(item.get("english") or "").strip()[:2000],
            chinese=str(item.get("chinese") or "").strip()[:800],
            like_count=int(source.get("like_count") or 0),
            author_name=str(source.get("author") or "")[:128],
            kind=str(item.get("kind") or "opinion"),
            timestamp_sec=timestamp if isinstance(timestamp, (int, float)) else None,
            phrases_json=json.dumps(item.get("phrases") or [], ensure_ascii=False),
            is_published=False,
            sort_order=index,
        )
        db.add(note)
        saved.append(note)
    db.flush()
    return saved


def update_audience_note(note: EpisodeAudienceNote, data: dict) -> EpisodeAudienceNote:
    if "english" in data and data["english"] is not None:
        note.english = str(data["english"]).strip()[:2000]
    if "chinese" in data and data["chinese"] is not None:
        note.chinese = str(data["chinese"]).strip()[:800]
    if "kind" in data and data["kind"] in NOTE_KINDS:
        note.kind = data["kind"]
    if "timestamp_sec" in data:
        raw = data["timestamp_sec"]
        if raw is None or raw == "":
            note.timestamp_sec = None
        else:
            note.timestamp_sec = float(raw)
    if "is_published" in data and data["is_published"] is not None:
        note.is_published = bool(data["is_published"])
    if "sort_order" in data and data["sort_order"] is not None:
        note.sort_order = int(data["sort_order"])
    if "phrases" in data and data["phrases"] is not None:
        cleaned: list[dict[str, str]] = []
        for item in data["phrases"]:
            if not isinstance(item, dict):
                continue
            en = str(item.get("en") or "").strip()
            zh = str(item.get("zh") or "").strip()
            if en:
                cleaned.append({"en": en, "zh": zh})
        note.phrases_json = json.dumps(cleaned[:3], ensure_ascii=False)
    return note


def publish_all_audience_notes(db: Session, episode_id: int) -> int:
    rows = (
        db.query(EpisodeAudienceNote)
        .filter(EpisodeAudienceNote.episode_id == episode_id)
        .all()
    )
    for note in rows:
        if (note.english or "").strip():
            note.is_published = True
    return len(rows)


def select_comment_candidates(comments: list[dict], *, limit: int = 40) -> list[dict]:
    scored: list[tuple[int, dict]] = []
    for raw in comments:
        text = str(raw.get("text") or "").strip()
        if not text:
            continue
        parent = str(raw.get("parent") or "root")
        is_uploader = bool(raw.get("author_is_uploader"))
        if parent not in {"", "root"} and not is_uploader:
            continue
        words = re.findall(r"[A-Za-z']+", text)
        timestamp_sec = parse_video_timestamp(text)
        pinned = bool(raw.get("is_pinned"))
        if not _looks_useful(text, words, timestamp_sec, pinned=pinned, uploader=is_uploader):
            continue
        item = {**raw, "text": text[:800], "timestamp_sec": timestamp_sec}
        score = int(raw.get("like_count") or 0)
        if pinned:
            score += 500
        if is_uploader:
            score += 400
        if timestamp_sec is not None:
            score += 200
        if len(words) >= 16:
            score += 40
        scored.append((score, item))
    scored.sort(key=lambda pair: pair[0], reverse=True)
    return [item for _, item in scored[:limit]]


def parse_video_timestamp(text: str) -> float | None:
    match = _TIMESTAMP_RE.search(text or "")
    if not match:
        return None
    hours = int(match.group(1) or 0)
    minutes = int(match.group(2))
    seconds = int(match.group(3))
    if minutes > 59 or seconds > 59:
        return None
    total = hours * 3600 + minutes * 60 + seconds
    if total <= 0:
        return None
    return float(total)


def _looks_useful(
    text: str,
    words: list[str],
    timestamp_sec: float | None,
    *,
    pinned: bool,
    uploader: bool,
) -> bool:
    if pinned or uploader:
        return len(words) >= 4
    if timestamp_sec is not None and len(words) >= 5:
        return True
    if len(words) < 8:
        return False
    letters = len(re.findall(r"[A-Za-z]", text))
    if letters < 20:
        return False
    compact = _THANKS_RE.sub("", text)
    leftover = re.findall(r"[A-Za-z']+", compact)
    if len(leftover) < 6:
        return False
    return True


def _resolve_source(item: dict, comments_by_id: dict[str, dict]) -> dict:
    source_id = str(item.get("source_id") or "").strip()
    if source_id and source_id in comments_by_id:
        return comments_by_id[source_id]
    needle = re.sub(r"\s+", " ", str(item.get("english") or "").lower())
    if not needle:
        return {}
    for comment in comments_by_id.values():
        hay = re.sub(r"\s+", " ", str(comment.get("text") or "").lower())
        if needle[:40] and needle[:40] in hay:
            return comment
    return {}
