"""管理端：用户意见反馈列表与处理。"""

from __future__ import annotations

from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import User, UserFeedback
from ...schemas import AdminFeedbackListOut, AdminFeedbackOut, AdminFeedbackUpdateIn

router = APIRouter(prefix="/api/admin/feedback", tags=["admin-feedback"])

_ALLOWED_STATUS = {"pending", "reviewing", "done", "closed"}


def _fmt_dt(value: datetime | None) -> str:
    if not value:
        return ""
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _out(row: UserFeedback, user: User | None = None) -> AdminFeedbackOut:
    return AdminFeedbackOut(
        id=row.id,
        user_id=row.user_id,
        user_email=(user.email if user else ""),
        user_nickname=(user.nickname or "") if user else "",
        title=row.title,
        body=row.body,
        image_urls=row.image_urls,
        status=row.status,
        admin_note=row.admin_note or "",
        created_at=_fmt_dt(row.created_at),
        updated_at=_fmt_dt(row.updated_at),
    )


@router.get("/", response_model=AdminFeedbackListOut)
def list_feedback(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=50),
    status: str = Query(""),
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    q = db.query(UserFeedback)
    status = (status or "").strip().lower()
    if status:
        if status not in _ALLOWED_STATUS:
            raise HTTPException(status_code=400, detail="状态无效")
        q = q.filter(UserFeedback.status == status)

    total = q.count()
    rows = (
        q.order_by(UserFeedback.created_at.desc(), UserFeedback.id.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
        .all()
    )
    user_ids = list({r.user_id for r in rows})
    users: dict[int, User] = {}
    if user_ids:
        for u in db.query(User).filter(User.id.in_(user_ids)).all():
            users[u.id] = u

    return AdminFeedbackListOut(
        count=total,
        results=[_out(row, users.get(row.user_id)) for row in rows],
    )


@router.patch("/{feedback_id}/", response_model=AdminFeedbackOut)
def update_feedback(
    feedback_id: int,
    body: AdminFeedbackUpdateIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    row = db.query(UserFeedback).filter(UserFeedback.id == feedback_id).first()
    if not row:
        raise HTTPException(status_code=404, detail="反馈不存在")

    if body.status is not None:
        status = body.status.strip().lower()
        if status not in _ALLOWED_STATUS:
            raise HTTPException(status_code=400, detail="状态无效")
        row.status = status
    if body.admin_note is not None:
        row.admin_note = body.admin_note.strip()[:2000]
    row.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(row)

    user = db.query(User).filter(User.id == row.user_id).first()
    return _out(row, user)
