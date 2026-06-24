from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ...auth_utils import verify_password
from ...database import get_db
from ...deps import get_current_admin, get_device_id
from ...models import User
from ...routers.auth import issue_tokens
from ...schemas import AdminAuthTokensOut, AdminUserOut, LoginIn

router = APIRouter(prefix="/api/admin/auth", tags=["admin-auth"])


def admin_user_out(user: User) -> AdminUserOut:
    return AdminUserOut(
        id=user.id,
        email=user.email,
        nickname=user.nickname,
        phone=user.phone,
        is_member=user.is_member,
        is_staff=user.is_staff,
    )


@router.post("/login/", response_model=AdminAuthTokensOut)
def admin_login(
    body: LoginIn,
    db: Session = Depends(get_db),
    device_id: str = Depends(get_device_id),
):
    email = body.email.strip().lower()
    user = db.query(User).filter(User.email == email).first()
    if not user or not verify_password(body.password, user.password_hash):
        raise HTTPException(status_code=401, detail="邮箱或密码错误")
    if not user.is_active:
        raise HTTPException(status_code=403, detail="账号已停用")
    if not user.is_staff:
        raise HTTPException(status_code=403, detail="非管理员账号")

    tokens = issue_tokens(db, user, device_id)
    return AdminAuthTokensOut(
        access=tokens.access,
        refresh=tokens.refresh,
        user=admin_user_out(user),
    )


@router.get("/me/", response_model=AdminUserOut)
def admin_me(admin: User = Depends(get_current_admin)):
    return admin_user_out(admin)
