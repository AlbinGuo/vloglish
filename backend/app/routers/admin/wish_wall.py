"""管理端：需求墙回复、隐藏、状态。"""

from __future__ import annotations

from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import User, WishRequest
from ...schemas import AdminWishListOut, AdminWishOut, AdminWishUpdateIn

router = APIRouter(prefix="/api/admin/wish-wall", tags=["admin-wish-wall"])

_ALLOWED_STATUS = {"pending", "replied", "done"}


def _fmt_dt(value: datetime | None) -> str:
    if not value:
        return ""
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _out(row: WishRequest, user: User | None = None) -> AdminWishOut:
    return AdminWishOut(
        id=row.id,
        user_id=row.user_id,
        user_email=(user.email if user else ""),
        user_nickname=(user.nickname or "") if user else "",
        title=row.title,
        body=row.body or "",
        admin_reply=row.admin_reply or "",
        like_count=max(0, row.like_count or 0),
        status=row.status or "pending",
        hidden=bool(row.hidden),
        created_at=_fmt_dt(row.created_at),
        updated_at=_fmt_dt(row.updated_at),
    )


@router.get("/", response_model=AdminWishListOut)
def list_wishes(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=50),
    status: str = Query(""),
    hidden: str = Query(""),
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    q = db.query(WishRequest)
    status = (status or "").strip().lower()
    if status:
        if status not in _ALLOWED_STATUS:
            raise HTTPException(status_code=400, detail="状态无效")
        q = q.filter(WishRequest.status == status)

    hidden_key = (hidden or "").strip().lower()
    if hidden_key in {"1", "true", "yes"}:
        q = q.filter(WishRequest.hidden.is_(True))
    elif hidden_key in {"0", "false", "no"}:
        q = q.filter(WishRequest.hidden.is_(False))

    total = q.count()
    rows = (
        q.order_by(WishRequest.created_at.desc(), WishRequest.id.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
        .all()
    )
    user_ids = list({r.user_id for r in rows})
    users: dict[int, User] = {}
    if user_ids:
        for u in db.query(User).filter(User.id.in_(user_ids)).all():
            users[u.id] = u

    return AdminWishListOut(
        count=total,
        results=[_out(row, users.get(row.user_id)) for row in rows],
    )


@router.patch("/{wish_id}/", response_model=AdminWishOut)
def update_wish(
    wish_id: int,
    body: AdminWishUpdateIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    row = db.query(WishRequest).filter(WishRequest.id == wish_id).first()
    if not row:
        raise HTTPException(status_code=404, detail="需求不存在")

    if body.status is not None:
        status = body.status.strip().lower()
        if status not in _ALLOWED_STATUS:
            raise HTTPException(status_code=400, detail="状态无效")
        row.status = status
    if body.admin_reply is not None:
        row.admin_reply = body.admin_reply.strip()[:2000]
        if row.admin_reply and row.status == "pending":
            row.status = "replied"
    if body.hidden is not None:
        row.hidden = body.hidden
    row.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(row)

    user = db.query(User).filter(User.id == row.user_id).first()
    return _out(row, user)
