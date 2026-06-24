from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import User
from ...schemas import AdminUserListItemOut, AdminUserListOut, AdminUserOut, AdminUserUpdateIn

router = APIRouter(prefix="/api/admin/users", tags=["admin-users"])


def _fmt_dt(value: datetime | None) -> str | None:
    if not value:
        return None
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _user_item(user: User) -> AdminUserListItemOut:
    return AdminUserListItemOut(
        id=user.id,
        email=user.email,
        nickname=user.nickname,
        phone=user.phone,
        is_member=user.is_member,
        is_active=user.is_active,
        is_staff=user.is_staff,
        member_activated_at=_fmt_dt(user.member_activated_at),
        created_at=_fmt_dt(user.created_at) or "",
    )


@router.get("/", response_model=AdminUserListOut)
def list_users(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    search: str | None = None,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    q = db.query(User)
    if search and search.strip():
        term = f"%{search.strip()}%"
        q = q.filter(User.email.ilike(term))
    q = q.order_by(User.id.desc())
    total = q.count()
    users = q.offset((page - 1) * page_size).limit(page_size).all()
    return AdminUserListOut(count=total, results=[_user_item(u) for u in users])


@router.get("/{user_id}/", response_model=AdminUserOut)
def get_user(
    user_id: int,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    return AdminUserOut(
        id=user.id,
        email=user.email,
        nickname=user.nickname,
        phone=user.phone,
        is_member=user.is_member,
        is_staff=user.is_staff,
    )


@router.patch("/{user_id}/", response_model=AdminUserOut)
def update_user(
    user_id: int,
    body: AdminUserUpdateIn,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    if user.id == admin.id and body.is_active is False:
        raise HTTPException(status_code=400, detail="不能停用当前登录的管理员")

    if body.is_member is not None:
        user.is_member = body.is_member
        if body.is_member and not user.member_activated_at:
            user.member_activated_at = datetime.utcnow()
        if not body.is_member:
            user.member_activated_at = None
    if body.is_active is not None:
        user.is_active = body.is_active
    if body.nickname is not None:
        user.nickname = body.nickname or None
    if body.phone is not None:
        user.phone = body.phone or None

    db.commit()
    db.refresh(user)
    return AdminUserOut(
        id=user.id,
        email=user.email,
        nickname=user.nickname,
        phone=user.phone,
        is_member=user.is_member,
        is_staff=user.is_staff,
    )
