"""整句字幕收藏：列表 / 收藏 / 取消（含文本快照）。"""
from __future__ import annotations

from datetime import datetime

from sqlalchemy.orm import Session

from ..demo_access import can_access_episode
from ..models import Episode, Subtitle, User, UserSubtitleFavorite


def favorite_to_dict(row: UserSubtitleFavorite, *, already_saved: bool = False) -> dict:
    return {
        "id": row.id,
        "video_id": row.video_id or "",
        "subtitle_id": row.subtitle_id,
        "subtitle_index": int(row.subtitle_index or 0),
        "start_sec": float(row.start_sec or 0),
        "end_sec": float(row.end_sec or 0),
        "english": row.english or "",
        "chinese": row.chinese or "",
        "ipa": row.ipa or "",
        "english_html": row.english_html or "",
        "episode_title": row.episode_title or "",
        "cover_url": row.cover_url or "",
        "created_at": row.created_at.isoformat() if row.created_at else "",
        "already_saved": already_saved,
    }


def list_favorites(
    db: Session,
    user: User,
    *,
    video_id: str | None = None,
    limit: int = 200,
    offset: int = 0,
) -> list[dict]:
    q = db.query(UserSubtitleFavorite).filter(UserSubtitleFavorite.user_id == user.id)
    if video_id:
        q = q.filter(UserSubtitleFavorite.video_id == video_id)
    rows = (
        q.order_by(UserSubtitleFavorite.created_at.desc())
        .offset(max(0, offset))
        .limit(max(1, min(limit, 500)))
        .all()
    )
    return [favorite_to_dict(r) for r in rows]


def save_favorite(db: Session, user: User, subtitle_id: int) -> tuple[UserSubtitleFavorite, bool]:
    sub = db.query(Subtitle).filter(Subtitle.id == int(subtitle_id)).first()
    if not sub:
        raise LookupError("字幕不存在")
    episode = db.query(Episode).filter(Episode.id == sub.episode_id).first()
    if not episode:
        raise LookupError("剧集不存在")
    if not can_access_episode(db, episode, user):
        raise PermissionError("无权访问该内容")

    existing = (
        db.query(UserSubtitleFavorite)
        .filter(
            UserSubtitleFavorite.user_id == user.id,
            UserSubtitleFavorite.video_id == episode.video_id,
            UserSubtitleFavorite.subtitle_index == sub.index,
        )
        .first()
    )
    if existing:
        return existing, True

    now = datetime.utcnow()
    row = UserSubtitleFavorite(
        user_id=user.id,
        episode_id=episode.id,
        subtitle_id=sub.id,
        video_id=episode.video_id,
        subtitle_index=sub.index,
        start_sec=sub.start,
        end_sec=sub.end,
        english=sub.english or "",
        chinese=sub.chinese or "",
        ipa=sub.ipa or "",
        english_html=sub.english_html or "",
        episode_title=episode.short_title or "",
        cover_url=episode.thumbnail_url or episode.cover or "",
        created_at=now,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return row, False


def remove_favorite(db: Session, user: User, favorite_id: int) -> bool:
    row = (
        db.query(UserSubtitleFavorite)
        .filter(
            UserSubtitleFavorite.id == int(favorite_id),
            UserSubtitleFavorite.user_id == user.id,
        )
        .first()
    )
    if not row:
        return False
    db.delete(row)
    db.commit()
    return True


def remove_by_subtitle(db: Session, user: User, subtitle_id: int) -> bool:
    rows = (
        db.query(UserSubtitleFavorite)
        .filter(
            UserSubtitleFavorite.user_id == user.id,
            UserSubtitleFavorite.subtitle_id == int(subtitle_id),
        )
        .all()
    )
    if not rows:
        return False
    for r in rows:
        db.delete(r)
    db.commit()
    return True
