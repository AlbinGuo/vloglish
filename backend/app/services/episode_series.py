"""Episode series (合集) helpers."""
from __future__ import annotations

import re

from sqlalchemy import func
from sqlalchemy.orm import Session, joinedload

from ..models import Episode, EpisodeSeries

SERIES_STATUSES = {"draft", "published", "archived"}


def sanitize_series_slug(value: str) -> str:
    slug = re.sub(r"[^\w\-]+", "-", value.strip().lower(), flags=re.UNICODE)
    slug = re.sub(r"-{2,}", "-", slug).strip("-")
    return slug[:64] or "series"


def series_episode_count(db: Session, series_id: int, *, published_only: bool = False) -> int:
    q = db.query(func.count(Episode.id)).filter(Episode.series_id == series_id)
    if published_only:
        q = q.filter(Episode.status == "published")
    return int(q.scalar() or 0)


def get_series_or_none(db: Session, series_id: int | None) -> EpisodeSeries | None:
    if not series_id:
        return None
    return db.query(EpisodeSeries).filter(EpisodeSeries.id == series_id).first()


def list_series_episodes(
    db: Session,
    series_id: int,
    *,
    published_only: bool = True,
) -> list[Episode]:
    q = (
        db.query(Episode)
        .options(joinedload(Episode.author), joinedload(Episode.tags), joinedload(Episode.series))
        .filter(Episode.series_id == series_id)
    )
    if published_only:
        q = q.filter(Episode.status == "published")
    return (
        q.order_by(Episode.series_index.asc().nulls_last(), Episode.index.asc())
        .all()
    )


def series_nav_for_episode(db: Session, episode: Episode) -> dict | None:
    if not episode.series_id:
        return None
    series = episode.series or get_series_or_none(db, episode.series_id)
    if not series or series.status != "published":
        return None

    siblings = list_series_episodes(db, series.id, published_only=True)
    if not siblings:
        return None

    current_pos = next((i for i, ep in enumerate(siblings) if ep.id == episode.id), None)
    if current_pos is None:
        return None

    prev_ep = siblings[current_pos - 1] if current_pos > 0 else None
    next_ep = siblings[current_pos + 1] if current_pos + 1 < len(siblings) else None
    series_index = episode.series_index if episode.series_index is not None else current_pos + 1

    return {
        "id": series.id,
        "slug": series.slug,
        "title": series.title,
        "series_index": series_index,
        "episode_count": len(siblings),
        "prev_video_id": prev_ep.video_id if prev_ep else None,
        "next_video_id": next_ep.video_id if next_ep else None,
    }
