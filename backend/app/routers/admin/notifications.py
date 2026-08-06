from datetime import datetime

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from sqlalchemy import or_
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import AdminBroadcast, Article, Episode, User, UserNotification
from ...qiniu_storage import QiniuConfig
from ...schemas import (
    AdminBroadcastCreateIn,
    AdminBroadcastListOut,
    AdminBroadcastOut,
    AdminEpisodeSubmittedPopupListOut,
    AdminEpisodeSubmittedPopupOut,
    AdminNotificationImageOut,
)
from ...services.admin_broadcast import broadcast_notification_to_all_users
from ...services.notification_image import upload_notification_image

router = APIRouter(prefix="/api/admin/notifications", tags=["admin-notifications"])

_SUBMISSION_POPUP_TYPES = ("episode_submitted", "article_submitted")


def _fmt_dt(value: datetime | None) -> str:
    if not value:
        return ""
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _broadcast_out(row: AdminBroadcast, admin_email: str = "") -> AdminBroadcastOut:
    return AdminBroadcastOut(
        id=row.id,
        title=row.title,
        body=row.body,
        image_url=row.image_url or "",
        recipient_count=row.recipient_count,
        created_by_email=admin_email,
        created_at=_fmt_dt(row.created_at),
    )


@router.get("/broadcasts/", response_model=AdminBroadcastListOut)
def list_broadcasts(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=50),
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    q = db.query(AdminBroadcast)
    total = q.count()
    rows = (
        q.order_by(AdminBroadcast.created_at.desc(), AdminBroadcast.id.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
        .all()
    )
    admin_ids = [r.created_by_user_id for r in rows if r.created_by_user_id]
    email_by_id: dict[int, str] = {}
    if admin_ids:
        for user in db.query(User).filter(User.id.in_(admin_ids)).all():
            email_by_id[user.id] = user.email
    return AdminBroadcastListOut(
        count=total,
        results=[
            _broadcast_out(row, email_by_id.get(row.created_by_user_id or 0, ""))
            for row in rows
        ],
    )


@router.post("/upload-image/", response_model=AdminNotificationImageOut)
async def upload_broadcast_image(
    file: UploadFile = File(...),
    _admin: User = Depends(get_current_admin),
):
    data = await file.read()
    try:
        cfg = QiniuConfig.from_env()
        image_url = upload_notification_image(cfg, data, file.filename)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e)) from e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"图片上传失败: {e}") from e
    return AdminNotificationImageOut(image_url=image_url)


@router.post("/broadcasts/", response_model=AdminBroadcastOut)
def create_broadcast(
    body: AdminBroadcastCreateIn,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    broadcast = broadcast_notification_to_all_users(
        db,
        admin=admin,
        title=body.title,
        body=body.body,
        image_url=body.image_url,
    )
    return _broadcast_out(broadcast, admin.email)


@router.get("/pending-popups/", response_model=AdminEpisodeSubmittedPopupListOut)
def pending_submission_popups(
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    rows = (
        db.query(UserNotification)
        .filter(
            UserNotification.user_id == admin.id,
            UserNotification.type.in_(_SUBMISSION_POPUP_TYPES),
            UserNotification.is_read.is_(False),
            UserNotification.popup_acked_at.is_(None),
        )
        .order_by(UserNotification.created_at.asc(), UserNotification.id.asc())
        .limit(20)
        .all()
    )
    episode_ids = [r.episode_id for r in rows if r.episode_id]
    article_ids = [r.article_id for r in rows if r.article_id]
    episode_by_id: dict[int, Episode] = {}
    article_by_id: dict[int, Article] = {}
    submitter_ids: set[int] = set()
    if episode_ids:
        for ep in db.query(Episode).filter(Episode.id.in_(episode_ids)).all():
            episode_by_id[ep.id] = ep
            if ep.submitted_by_user_id:
                submitter_ids.add(ep.submitted_by_user_id)
    if article_ids:
        for art in db.query(Article).filter(Article.id.in_(article_ids)).all():
            article_by_id[art.id] = art
            if art.submitted_by_user_id:
                submitter_ids.add(art.submitted_by_user_id)
    submitter_by_id: dict[int, User] = {}
    if submitter_ids:
        for u in db.query(User).filter(User.id.in_(submitter_ids)).all():
            submitter_by_id[u.id] = u

    results: list[AdminEpisodeSubmittedPopupOut] = []
    for row in rows:
        if row.type == "article_submitted":
            art = article_by_id.get(row.article_id) if row.article_id else None
            submitter = (
                submitter_by_id.get(art.submitted_by_user_id)
                if art and art.submitted_by_user_id
                else None
            )
            results.append(
                AdminEpisodeSubmittedPopupOut(
                    id=row.id,
                    title=row.title,
                    body=row.body,
                    submission_type="article_submitted",
                    article_id=art.id if art else row.article_id,
                    article_title=((art.title or "").strip() if art else "") or "未命名文章",
                    source_url=(art.source_url or "").strip() if art else "",
                    has_submit_body=bool((art.submit_body or "").strip()) if art else False,
                    submitter_email=(submitter.email if submitter else ""),
                    submitter_nickname=((submitter.nickname or "").strip() if submitter else ""),
                    submitted_at=_fmt_dt(art.created_at) if art else "",
                    created_at=_fmt_dt(row.created_at),
                )
            )
            continue

        ep = episode_by_id.get(row.episode_id) if row.episode_id else None
        submitter = (
            submitter_by_id.get(ep.submitted_by_user_id) if ep and ep.submitted_by_user_id else None
        )
        results.append(
            AdminEpisodeSubmittedPopupOut(
                id=row.id,
                title=row.title,
                body=row.body,
                submission_type="episode_submitted",
                episode_id=row.episode_id,
                episode_title=((ep.short_title or "").strip() if ep else "") or "未命名视频",
                original_video_url=(ep.original_video_url or "").strip() if ep else "",
                submitter_email=(submitter.email if submitter else ""),
                submitter_nickname=((submitter.nickname or "").strip() if submitter else ""),
                submitted_at=_fmt_dt(ep.created_at) if ep else "",
                created_at=_fmt_dt(row.created_at),
            )
        )
    return AdminEpisodeSubmittedPopupListOut(results=results)


@router.post("/{notification_id}/ack-popup/")
def ack_submission_popup(
    notification_id: int,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    row = (
        db.query(UserNotification)
        .filter(
            UserNotification.id == notification_id,
            UserNotification.user_id == admin.id,
            or_(
                UserNotification.type == "episode_submitted",
                UserNotification.type == "article_submitted",
            ),
        )
        .first()
    )
    if not row:
        raise HTTPException(status_code=404, detail="通知不存在")
    row.popup_acked_at = datetime.utcnow()
    row.is_read = True
    db.commit()
    return {"success": True}
