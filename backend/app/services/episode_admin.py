import secrets

from sqlalchemy import func
from sqlalchemy.orm import Session

from ..models import Author, Episode, Subtitle, Tag
from .vtt_import import words_to_html

VALID_STATUSES = {"draft", "published", "archived", "rejected"}


def generate_video_id() -> str:
    return secrets.token_urlsafe(11)[:15]


def get_or_create_author(db: Session, data: dict) -> Author:
    author = (
        db.query(Author)
        .filter(Author.name == data["name"], Author.accent == data.get("accent", ""))
        .first()
    )
    if author:
        return author
    author = Author(
        name=data["name"],
        gender=data.get("gender", "m"),
        nationality=data.get("nationality", ""),
        accent=data.get("accent", ""),
    )
    db.add(author)
    db.flush()
    return author


def resolve_tags(db: Session, tag_names: list[str]) -> list[Tag]:
    tags: list[Tag] = []
    next_id = (db.query(func.max(Tag.id)).scalar() or 0) + 1
    for raw in tag_names:
        name = raw.strip()
        if not name:
            continue
        tag = db.query(Tag).filter(Tag.name == name).first()
        if not tag:
            tag = Tag(id=next_id, name=name)
            next_id += 1
            db.add(tag)
            db.flush()
        tags.append(tag)
    return tags


def subtitle_stats(subtitles: list[dict]) -> tuple[int, float]:
    if not subtitles:
        return 0, 0.0
    return len(subtitles), float(max(s["end"] for s in subtitles))


def replace_subtitles(db: Session, episode_id: int, rows: list[dict]) -> None:
    db.query(Subtitle).filter(Subtitle.episode_id == episode_id).delete()
    db.flush()
    next_id = (db.query(func.max(Subtitle.id)).scalar() or 0) + 1
    for row in rows:
        english = row["english"].strip()
        english_html = row.get("english_html", "").strip() or words_to_html(english)
        db.add(
            Subtitle(
                id=next_id,
                episode_id=episode_id,
                index=row["index"],
                start=row["start"],
                end=row["end"],
                english=english,
                chinese=row.get("chinese", ""),
                ipa=row.get("ipa", ""),
                english_html=english_html,
            )
        )
        next_id += 1


def apply_episode_fields(ep: Episode, data: dict, *, author: Author, tags: list[Tag]) -> None:
    if "short_title" in data:
        ep.short_title = (data["short_title"] or "").strip()
    if "summary" in data:
        ep.summary = data.get("summary", "")
    if "remark" in data:
        ep.remark = data.get("remark", "")
    if "stars" in data:
        ep.stars = data.get("stars", 3)
    if "voca_size" in data:
        ep.voca_size = data.get("voca_size", 0)
    if "cover" in data:
        ep.cover = data.get("cover", "")
    if "video_url" in data:
        ep.video_url = data.get("video_url", "")
    if "audio_url" in data:
        ep.audio_url = data.get("audio_url", "")
    if "thumbnail_url" in data:
        ep.thumbnail_url = data.get("thumbnail_url", "")
    if "original_video_url" in data:
        ep.original_video_url = data.get("original_video_url", "")
    if "is_demo" in data:
        ep.is_demo = data.get("is_demo", False)
    if "status" in data and data.get("status") in VALID_STATUSES:
        ep.status = data["status"]
        if data["status"] != "rejected":
            ep.rejection_reason = None
    if "rejection_reason" in data and ep.status == "rejected":
        reason = (data.get("rejection_reason") or "").strip()
        ep.rejection_reason = reason or None
    if "index" in data:
        ep.index = data.get("index", ep.index)
    ep.author_id = author.id
    ep.tags = tags
    subtitles = data.get("subtitles")
    if subtitles is not None:
        ep.subtitle_count, ep.clip_length = subtitle_stats(subtitles)
