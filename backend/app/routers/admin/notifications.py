from datetime import datetime

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import AdminBroadcast, User
from ...qiniu_storage import QiniuConfig
from ...schemas import (
    AdminBroadcastCreateIn,
    AdminBroadcastListOut,
    AdminBroadcastOut,
    AdminNotificationImageOut,
)
from ...services.admin_broadcast import broadcast_notification_to_all_users
from ...services.notification_image import upload_notification_image

router = APIRouter(prefix="/api/admin/notifications", tags=["admin-notifications"])


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
