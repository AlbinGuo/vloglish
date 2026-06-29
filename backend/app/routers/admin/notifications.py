from datetime import datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import AdminBroadcast, User
from ...schemas import AdminBroadcastCreateIn, AdminBroadcastListOut, AdminBroadcastOut
from ...services.admin_broadcast import broadcast_notification_to_all_users

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
    )
    return _broadcast_out(broadcast, admin.email)
