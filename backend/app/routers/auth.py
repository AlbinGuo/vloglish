from datetime import datetime
import os

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..auth_utils import (
    REMOTE_LOGIN_DETAIL,
    create_access_token,
    decode_access_claims,
    hash_password,
    hash_password_reset_token,
    hash_refresh_token,
    new_password_reset_token,
    new_refresh_token,
    password_reset_expires_at,
    refresh_token_expires_at,
    verify_password,
)
from ..email_service import build_password_reset_url, send_password_reset_email
from ..demo_access import user_is_member
from ..deps import get_current_user, get_device_id
from ..favorites import merge_device_favorites
from ..models import ActivationCode, PasswordResetToken, RefreshToken, User
from ..database import get_db
from ..schemas import (
    AuthTokensOut,
    ForgotPasswordIn,
    ForgotPasswordOut,
    LoginIn,
    RefreshIn,
    RegisterIn,
    ResetPasswordIn,
    UserOut,
)

router = APIRouter(prefix="/api/auth", tags=["auth"])


def user_out(user: User) -> UserOut:
    return UserOut(
        id=user.id,
        email=user.email,
        nickname=user.nickname,
        phone=user.phone,
        is_member=user.is_member,
    )


def user_can_refresh_session(user: User) -> bool:
    """会员可刷新；管理员（is_staff）共用 refresh 接口，也需允许刷新。"""
    return user_is_member(user) or bool(user.is_staff)


def issue_tokens(db: Session, user: User, device_id: str) -> AuthTokensOut:
    db.query(RefreshToken).filter(RefreshToken.user_id == user.id).delete()
    user.session_version = (user.session_version or 0) + 1
    db.flush()
    access = create_access_token(user.id, user.session_version)
    refresh = new_refresh_token()
    db.add(
        RefreshToken(
            user_id=user.id,
            token_hash=hash_refresh_token(refresh),
            device_id=device_id,
            expires_at=refresh_token_expires_at(),
        )
    )
    db.commit()
    db.refresh(user)
    return AuthTokensOut(access=access, refresh=refresh, user=user_out(user))


def apply_activation_code(db: Session, user: User, code_value: str) -> None:
    activation = db.query(ActivationCode).filter(ActivationCode.code == code_value).first()
    if not activation or activation.used_by_user_id is not None:
        raise HTTPException(status_code=400, detail="无效或已使用的激活码")
    activation.used_by_user_id = user.id
    activation.used_at = datetime.utcnow()
    user.is_member = True
    user.member_activated_at = datetime.utcnow()


@router.post("/register/", response_model=AuthTokensOut)
def register(
    body: RegisterIn,
    db: Session = Depends(get_db),
    device_id: str = Depends(get_device_id),
):
    email = body.email.strip().lower()
    exists = db.query(User).filter(User.email == email).first()
    if exists:
        raise HTTPException(status_code=400, detail="该邮箱已注册")

    code_value = body.activation_code.strip()
    user = User(email=email, password_hash=hash_password(body.password))
    db.add(user)
    db.flush()
    apply_activation_code(db, user, code_value)
    db.commit()
    db.refresh(user)
    merge_device_favorites(db, user.id, device_id)
    return issue_tokens(db, user, device_id)


@router.post("/login/", response_model=AuthTokensOut)
def login(
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
    if not user_is_member(user):
        raise HTTPException(status_code=403, detail="账号未开通会员，请使用激活码注册")

    merge_device_favorites(db, user.id, device_id)
    return issue_tokens(db, user, device_id)


@router.post("/token/refresh/", response_model=AuthTokensOut)
def refresh_token(body: RefreshIn, db: Session = Depends(get_db)):
    token_hash = hash_refresh_token(body.refresh)
    matched = db.query(RefreshToken).filter(RefreshToken.token_hash == token_hash).first()
    if not matched:
        raise HTTPException(status_code=401, detail=REMOTE_LOGIN_DETAIL)
    if matched.expires_at <= datetime.utcnow():
        raise HTTPException(status_code=401, detail="登录已过期，请重新登录")

    user = db.query(User).filter(User.id == matched.user_id, User.is_active.is_(True)).first()
    if not user:
        raise HTTPException(status_code=401, detail="用户不存在")
    if not user_can_refresh_session(user):
        raise HTTPException(status_code=403, detail="账号未开通会员，请使用激活码注册")

    db.delete(matched)
    db.commit()
    return issue_tokens(db, user, matched.device_id)


@router.get("/me/", response_model=UserOut)
def me(user: User = Depends(get_current_user)):
    return user_out(user)


@router.post("/logout/")
def logout(
    body: RefreshIn,
    db: Session = Depends(get_db),
):
    token_hash = hash_refresh_token(body.refresh)
    db.query(RefreshToken).filter(RefreshToken.token_hash == token_hash).delete()
    db.commit()
    return {"success": True}


FORGOT_PASSWORD_MESSAGE = "如果该邮箱已注册，我们已发送密码重置说明"


@router.post("/forgot-password/", response_model=ForgotPasswordOut)
def forgot_password(body: ForgotPasswordIn, db: Session = Depends(get_db)):
    email = body.email.strip().lower()
    user = db.query(User).filter(User.email == email, User.is_active.is_(True)).first()
    reset_url: str | None = None

    if user:
        db.query(PasswordResetToken).filter(PasswordResetToken.user_id == user.id).delete()
        raw_token = new_password_reset_token()
        db.add(
            PasswordResetToken(
                user_id=user.id,
                token_hash=hash_password_reset_token(raw_token),
                expires_at=password_reset_expires_at(),
            )
        )
        db.commit()

        reset_url = build_password_reset_url(raw_token)
        emailed = send_password_reset_email(user.email, reset_url)
        if emailed or os.getenv("APP_DEBUG", "true").lower() not in {"1", "true", "yes"}:
            reset_url = None

    return ForgotPasswordOut(message=FORGOT_PASSWORD_MESSAGE, reset_url=reset_url)


@router.post("/reset-password/")
def reset_password(body: ResetPasswordIn, db: Session = Depends(get_db)):
    token_hash = hash_password_reset_token(body.token.strip())
    row = (
        db.query(PasswordResetToken)
        .filter(
            PasswordResetToken.token_hash == token_hash,
            PasswordResetToken.expires_at > datetime.utcnow(),
        )
        .first()
    )
    if not row:
        raise HTTPException(status_code=400, detail="重置链接无效或已过期")

    user = db.query(User).filter(User.id == row.user_id, User.is_active.is_(True)).first()
    if not user:
        raise HTTPException(status_code=400, detail="用户不存在")

    user.password_hash = hash_password(body.password)
    db.query(PasswordResetToken).filter(PasswordResetToken.user_id == user.id).delete()
    db.query(RefreshToken).filter(RefreshToken.user_id == user.id).delete()
    user.session_version = (user.session_version or 0) + 1
    db.commit()
    return {"success": True, "message": "密码已重置，请使用新密码登录"}
