from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user
from ..models import Article, Episode, User, UserNotification
from ..schemas import (
    AckPopupsIn,
    EpisodePublishedPopupListOut,
    EpisodePublishedPopupOut,
    NotificationListOut,
    NotificationOut,
    UnreadCountOut,
)

router = APIRouter(prefix="/api/notifications", tags=["notifications"])

POPUP_TYPES = ("episode_published", "episode_new_release", "article_new_release")


def _fmt_dt(value: datetime | None) -> str:
    if not value:
        return ""
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _notification_out(
    row: UserNotification,
    *,
    video_id: str | None,
    article_public_id: str | None,
) -> NotificationOut:
    return NotificationOut(
        id=row.id,
        type=row.type,
        title=row.title,
        body=row.body,
        image_url=getattr(row, "image_url", None) or "",
        episode_id=row.episode_id,
        video_id=video_id,
        article_id=article_public_id,
        is_read=row.is_read,
        created_at=_fmt_dt(row.created_at),
    )


@router.get("/", response_model=NotificationListOut)
def list_notifications(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=50),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    q = db.query(UserNotification).filter(UserNotification.user_id == user.id)
    total = q.count()
    unread_count = q.filter(UserNotification.is_read.is_(False)).count()
    rows = (
        q.order_by(UserNotification.created_at.desc(), UserNotification.id.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
        .all()
    )
    episode_ids = [r.episode_id for r in rows if r.episode_id]
    article_ids = [r.article_id for r in rows if getattr(r, "article_id", None)]
    video_by_episode: dict[int, str] = {}
    article_public_by_id: dict[int, str] = {}
    if episode_ids:
        for ep in db.query(Episode).filter(Episode.id.in_(episode_ids)).all():
            video_by_episode[ep.id] = ep.video_id
    if article_ids:
        for art in db.query(Article).filter(Article.id.in_(article_ids)).all():
            article_public_by_id[art.id] = art.article_id
    return NotificationListOut(
        count=total,
        unread_count=unread_count,
        results=[
            _notification_out(
                row,
                video_id=video_by_episode.get(row.episode_id) if row.episode_id else None,
                article_public_id=(
                    article_public_by_id.get(row.article_id)
                    if getattr(row, "article_id", None)
                    else None
                ),
            )
            for row in rows
        ],
    )


@router.get("/unread-count/", response_model=UnreadCountOut)
def unread_count(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    count = (
        db.query(UserNotification)
        .filter(UserNotification.user_id == user.id, UserNotification.is_read.is_(False))
        .count()
    )
    return UnreadCountOut(unread_count=count)


@router.get("/pending-popups/", response_model=EpisodePublishedPopupListOut)
def pending_popups(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = (
        db.query(UserNotification)
        .filter(
            UserNotification.user_id == user.id,
            UserNotification.type.in_(POPUP_TYPES),
            UserNotification.is_read.is_(False),
            UserNotification.popup_acked_at.is_(None),
        )
        .order_by(UserNotification.created_at.asc(), UserNotification.id.asc())
        .limit(20)
        .all()
    )
    episode_ids = [r.episode_id for r in rows if r.episode_id]
    article_ids = [r.article_id for r in rows if getattr(r, "article_id", None)]
    episode_by_id: dict[int, Episode] = {}
    article_by_id: dict[int, Article] = {}
    if episode_ids:
        for ep in db.query(Episode).filter(Episode.id.in_(episode_ids)).all():
            episode_by_id[ep.id] = ep
    if article_ids:
        for art in db.query(Article).filter(Article.id.in_(article_ids)).all():
            article_by_id[art.id] = art

    results: list[EpisodePublishedPopupOut] = []
    for row in rows:
        ep = episode_by_id.get(row.episode_id) if row.episode_id else None
        art = article_by_id.get(row.article_id) if getattr(row, "article_id", None) else None
        episode_title = ""
        submitted_at = ""
        video_id = None
        article_public_id = None
        cover_url = ""
        if ep:
            episode_title = (ep.short_title or "").strip() or "未命名视频"
            submitted_at = _fmt_dt(ep.created_at)
            video_id = ep.video_id
            cover_url = (ep.thumbnail_url or ep.cover or "").strip()
        elif art:
            episode_title = (art.title or "").strip() or "未命名文章"
            submitted_at = _fmt_dt(art.published_at or art.created_at)
            article_public_id = art.article_id
            cover_url = (art.cover or "").strip()
        results.append(
            EpisodePublishedPopupOut(
                id=row.id,
                type=row.type,
                title=row.title,
                body=row.body,
                episode_id=row.episode_id,
                video_id=video_id,
                article_id=article_public_id,
                episode_title=episode_title,
                cover_url=cover_url,
                submitted_at=submitted_at,
                created_at=_fmt_dt(row.created_at),
            )
        )
    return EpisodePublishedPopupListOut(results=results)


@router.post("/ack-popups/")
def ack_popups(
    body: AckPopupsIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    ids = sorted({int(i) for i in body.ids if int(i) > 0})
    if not ids:
        return {"success": True, "acked": 0}
    rows = (
        db.query(UserNotification)
        .filter(UserNotification.id.in_(ids), UserNotification.user_id == user.id)
        .all()
    )
    now = datetime.utcnow()
    for row in rows:
        row.popup_acked_at = now
        row.is_read = True
    db.commit()
    return {"success": True, "acked": len(rows)}


@router.post("/{notification_id}/ack-popup/")
def ack_popup(
    notification_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = (
        db.query(UserNotification)
        .filter(UserNotification.id == notification_id, UserNotification.user_id == user.id)
        .first()
    )
    if not row:
        raise HTTPException(status_code=404, detail="通知不存在")
    row.popup_acked_at = datetime.utcnow()
    row.is_read = True
    db.commit()
    return {"success": True}


@router.post("/{notification_id}/read/")
def mark_read(
    notification_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = (
        db.query(UserNotification)
        .filter(UserNotification.id == notification_id, UserNotification.user_id == user.id)
        .first()
    )
    if not row:
        raise HTTPException(status_code=404, detail="通知不存在")
    row.is_read = True
    db.commit()
    return {"success": True}


@router.post("/read-all/")
def mark_all_read(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    db.query(UserNotification).filter(
        UserNotification.user_id == user.id,
        UserNotification.is_read.is_(False),
    ).update({UserNotification.is_read: True}, synchronize_session=False)
    db.commit()
    return {"success": True}
