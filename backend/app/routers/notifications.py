from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user
from ..models import Episode, User, UserNotification
from ..schemas import NotificationListOut, NotificationOut, UnreadCountOut

router = APIRouter(prefix="/api/notifications", tags=["notifications"])


def _fmt_dt(value: datetime | None) -> str:
    if not value:
        return ""
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _notification_out(row: UserNotification, video_id: str | None) -> NotificationOut:
    return NotificationOut(
        id=row.id,
        type=row.type,
        title=row.title,
        body=row.body,
        episode_id=row.episode_id,
        video_id=video_id,
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
    video_by_episode: dict[int, str] = {}
    if episode_ids:
        for ep in db.query(Episode).filter(Episode.id.in_(episode_ids)).all():
            video_by_episode[ep.id] = ep.video_id
    return NotificationListOut(
        count=total,
        unread_count=unread_count,
        results=[
            _notification_out(row, video_by_episode.get(row.episode_id) if row.episode_id else None)
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
    ).update({"is_read": True})
    db.commit()
    return {"success": True}
