"""Import episodes from extra-episodes.json format."""
from __future__ import annotations

import re
from sqlalchemy.orm import Session

from ..media import episode_audio_api_url, is_youtube_episode
from ..models import Episode, Subtitle
from .episode_admin import get_or_create_author, replace_subtitles, resolve_tags, subtitle_stats


def _resolve_tags_from_json(db: Session, tags: list[dict]) -> list:
    names = [t.get("name", "").strip() for t in tags if t.get("name")]
    return resolve_tags(db, names)


def upsert_episode_summary(db: Session, item: dict, *, is_demo: bool, status: str) -> tuple[Episode, bool]:
    author = get_or_create_author(db, item["author"])
    tags = _resolve_tags_from_json(db, item.get("tags", []))

    ep = db.query(Episode).filter(Episode.video_id == item["video_id"]).first()
    created = ep is None
    if not ep:
        ep = Episode(video_id=item["video_id"], status=status)
        db.add(ep)

    ep.short_title = item["short_title"]
    ep.summary = item.get("summary", "")
    ep.remark = item.get("remark", "")
    ep.stars = item.get("stars", 3)
    ep.voca_size = item.get("voca_size", 0)
    ep.subtitle_count = item.get("subtitle_count", 0)
    ep.clip_length = item.get("clip_length", 0)
    ep.cover = item.get("cover", "")
    ep.author_id = author.id
    ep.is_demo = is_demo
    ep.tags = tags
    if item.get("index") is not None:
        ep.index = item["index"]
    else:
        m = re.search(r"clip(\d+)", item.get("cover", ""))
        if m:
            ep.index = int(m.group(1))
    if created:
        ep.status = status
    db.flush()
    return ep, created


def apply_episode_detail_json(db: Session, detail: dict, *, is_demo: bool, status: str) -> tuple[Episode, bool]:
    ep_data = detail["episode"]
    ep = db.query(Episode).filter(Episode.video_id == ep_data["video_id"]).first()
    created = ep is None
    if not ep:
        ep = Episode(video_id=ep_data["video_id"], status=status)
        db.add(ep)

    author = get_or_create_author(db, ep_data["author"])
    tags = _resolve_tags_from_json(db, ep_data.get("tags", []))

    ep.index = ep_data.get("index", ep.index or 0)
    ep.short_title = ep_data["short_title"]
    ep.summary = ep_data.get("summary", "")
    ep.remark = ep_data.get("remark", "")
    ep.stars = ep_data.get("stars", 3)
    ep.voca_size = ep_data.get("voca_size", 0)
    ep.original_video_url = ep_data.get("original_video_url", "")
    ep.author_id = author.id
    ep.tags = tags
    ep.is_demo = is_demo

    media = ep_data.get("media", {})
    ep.video_url = media.get("video_url", "")
    ep.audio_url = media.get("audio_url", "")
    ep.thumbnail_url = media.get("thumbnail_url", "")
    if not ep.cover and ep.thumbnail_url:
        ep.cover = ep.thumbnail_url

    if not ep.audio_url and is_youtube_episode(
        video_id=ep.video_id,
        video_url=ep.video_url,
        original_video_url=ep.original_video_url,
    ):
        ep.audio_url = episode_audio_api_url(ep.video_id)

    subtitles = []
    for s in ep_data.get("subtitles", []):
        subtitles.append(
            {
                "index": s["index"],
                "start": s["start"],
                "end": s["end"],
                "english": s["english"],
                "chinese": s.get("chinese", ""),
                "ipa": s.get("ipa", ""),
                "english_html": s.get("english_html", ""),
            }
        )
    if subtitles:
        replace_subtitles(db, ep.id, subtitles)
        ep.subtitle_count, ep.clip_length = subtitle_stats(subtitles)
    elif ep_data.get("subtitle_count"):
        ep.subtitle_count = ep_data.get("subtitle_count", 0)

    if created:
        ep.status = status
    db.flush()
    return ep, created


def import_episodes_json(
    db: Session,
    payload: dict,
    *,
    default_status: str = "draft",
    mark_demo: bool = False,
) -> dict:
    episodes_data = payload.get("episodes") or []
    details_data = payload.get("details") or []

    created_ids: set[str] = set()
    updated_ids: set[str] = set()
    errors: list[str] = []

    def track(vid: str, was_created: bool) -> None:
        if was_created:
            created_ids.add(vid)
            updated_ids.discard(vid)
        elif vid not in created_ids:
            updated_ids.add(vid)

    for item in episodes_data:
        vid = item.get("video_id")
        if not vid:
            errors.append("episodes 条目缺少 video_id")
            continue
        try:
            _, was_created = upsert_episode_summary(db, item, is_demo=mark_demo, status=default_status)
            track(vid, was_created)
        except Exception as exc:
            errors.append(f"{vid}: {exc}")

    summary_vids = {item.get("video_id") for item in episodes_data if item.get("video_id")}

    for detail in details_data:
        vid = detail.get("episode", {}).get("video_id")
        if not vid:
            errors.append("details 条目缺少 video_id")
            continue
        try:
            _, was_created = apply_episode_detail_json(db, detail, is_demo=mark_demo, status=default_status)
            track(vid, was_created)
        except Exception as exc:
            errors.append(f"{vid} detail: {exc}")

    db.commit()
    all_vids = summary_vids | created_ids | updated_ids
    for detail in details_data:
        vid = detail.get("episode", {}).get("video_id")
        if vid:
            all_vids.add(vid)

    return {
        "created": len(created_ids),
        "updated": len(updated_ids),
        "total": len(all_vids),
        "video_ids": sorted(all_vids),
        "errors": errors,
    }


def export_episodes_json(db: Session) -> dict:
    from sqlalchemy.orm import joinedload

    episodes = (
        db.query(Episode)
        .options(joinedload(Episode.author), joinedload(Episode.tags), joinedload(Episode.subtitles))
        .order_by(Episode.id)
        .all()
    )

    summaries = []
    details = []
    for ep in episodes:
        summaries.append(
            {
                "video_id": ep.video_id,
                "index": ep.index,
                "tags": [{"id": t.id, "name": t.name} for t in ep.tags],
                "cover": ep.cover,
                "short_title": ep.short_title,
                "summary": ep.summary,
                "remark": ep.remark or "",
                "stars": ep.stars,
                "voca_size": ep.voca_size,
                "subtitle_count": ep.subtitle_count,
                "author": {
                    "name": ep.author.name,
                    "gender": ep.author.gender,
                    "nationality": ep.author.nationality,
                    "accent": ep.author.accent,
                },
                "created_at": ep.created_at.isoformat() + "Z" if ep.created_at else "",
                "clip_length": ep.clip_length,
                "is_learned": False,
                "is_favorite": False,
            }
        )
        details.append(
            {
                "episode": {
                    "index": ep.index,
                    "video_id": ep.video_id,
                    "short_title": ep.short_title,
                    "summary": ep.summary,
                    "remark": ep.remark or "",
                    "stars": ep.stars,
                    "voca_size": ep.voca_size,
                    "subtitle_count": ep.subtitle_count,
                    "original_video_url": ep.original_video_url,
                    "author": {
                        "name": ep.author.name,
                        "gender": ep.author.gender,
                        "nationality": ep.author.nationality,
                        "accent": ep.author.accent,
                    },
                    "tags": [{"id": t.id, "name": t.name} for t in ep.tags],
                    "media": {
                        "video_url": ep.video_url,
                        "audio_url": ep.audio_url,
                        "thumbnail_url": ep.thumbnail_url,
                    },
                    "subtitles": [
                        {
                            "id": s.id,
                            "index": s.index,
                            "start": s.start,
                            "end": s.end,
                            "english": s.english,
                            "chinese": s.chinese,
                            "ipa": s.ipa,
                            "english_html": s.english_html,
                        }
                        for s in sorted(ep.subtitles, key=lambda x: x.index)
                    ],
                }
            }
        )

    return {"episodes": summaries, "details": details}
