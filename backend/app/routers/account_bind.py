from __future__ import annotations

import secrets
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import Response
from pydantic import BaseModel, EmailStr, Field
from sqlalchemy.orm import Session

from ..auth_utils import verify_password
from ..database import get_db
from ..deps import get_current_user, get_device_id
from ..models import AccountBindToken, User
from ..routers.auth import issue_tokens, user_out
from ..schemas import AuthTokensOut, UserOut
from ..services.account_merge import is_wechat_only, merge_users
from ..services import wechat_mini as wechat_mini_svc

router = APIRouter(prefix="/api/auth", tags=["auth-bind"])

BIND_TTL_MINUTES = 10


class BindEmailIn(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


class BindTokenOut(BaseModel):
    token: str
    expires_in: int


class BindStatusOut(BaseModel):
    status: str
    user: UserOut | None = None


def _ensure_wx(user: User) -> None:
    if not (user.wx_openid or "").strip():
        raise HTTPException(status_code=400, detail="当前不是微信登录，无法关联")


@router.post("/bind-email/", response_model=AuthTokensOut)
def bind_email(
    body: BindEmailIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
    device_id: str = Depends(get_device_id),
):
    """小程序：用邮箱密码把微信影子账号并入网页账号。"""
    _ensure_wx(user)
    email = body.email.strip().lower()
    target = db.query(User).filter(User.email == email).first()
    if not target or not verify_password(body.password, target.password_hash):
        raise HTTPException(status_code=401, detail="邮箱或密码错误")
    if not target.is_active:
        raise HTTPException(status_code=403, detail="账号已停用")
    if is_wechat_only(target):
        raise HTTPException(status_code=400, detail="请填写网页/App 注册的邮箱")
    if user.id == target.id:
        raise HTTPException(status_code=400, detail="已经是这个账号")
    if target.wx_openid and target.wx_openid != user.wx_openid:
        raise HTTPException(status_code=400, detail="该邮箱已绑定其他微信")
    if not is_wechat_only(user) and user.email != target.email:
        raise HTTPException(status_code=400, detail="当前账号已关联其他邮箱")

    try:
        merge_users(db, source=user, target=target)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    db.commit()
    db.refresh(target)
    return issue_tokens(db, target, device_id)


@router.post("/bind-wechat/prepare/", response_model=BindTokenOut)
def prepare_bind_wechat(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """网页：生成短时绑定码，供小程序扫码。"""
    if is_wechat_only(user):
        raise HTTPException(status_code=400, detail="请先在网页用邮箱登录")
    if user.wx_openid:
        raise HTTPException(status_code=400, detail="已经绑定微信")
    db.query(AccountBindToken).filter(
        AccountBindToken.user_id == user.id,
        AccountBindToken.consumed_at.is_(None),
    ).delete(synchronize_session=False)
    token = secrets.token_hex(8)
    row = AccountBindToken(
        token=token,
        user_id=user.id,
        expires_at=datetime.utcnow() + timedelta(minutes=BIND_TTL_MINUTES),
    )
    db.add(row)
    db.commit()
    return BindTokenOut(token=token, expires_in=BIND_TTL_MINUTES * 60)


@router.get("/bind-wechat/qrcode/")
def bind_wechat_qrcode(token: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    row = (
        db.query(AccountBindToken)
        .filter(AccountBindToken.token == (token or "").strip(), AccountBindToken.user_id == user.id)
        .first()
    )
    if not row or row.consumed_at or row.expires_at <= datetime.utcnow():
        raise HTTPException(status_code=404, detail="绑定码无效或已过期")
    try:
        png = wechat_mini_svc.get_bind_wxacode(row.token)
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    return Response(content=png, media_type="image/png")


@router.get("/bind-wechat/status/", response_model=BindStatusOut)
def bind_wechat_status(
    token: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    row = (
        db.query(AccountBindToken)
        .filter(AccountBindToken.token == (token or "").strip(), AccountBindToken.user_id == user.id)
        .first()
    )
    if not row:
        return BindStatusOut(status="missing")
    if row.expires_at <= datetime.utcnow() and not row.consumed_at:
        return BindStatusOut(status="expired")
    if row.consumed_at:
        db.refresh(user)
        return BindStatusOut(status="bound", user=user_out(user))
    return BindStatusOut(status="pending")


class BindWechatConfirmIn(BaseModel):
    token: str = Field(min_length=8, max_length=32)


@router.post("/bind-wechat/confirm/", response_model=AuthTokensOut)
def confirm_bind_wechat(
    body: BindWechatConfirmIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
    device_id: str = Depends(get_device_id),
):
    """小程序：确认把当前微信并入扫码对应的网页账号。"""
    _ensure_wx(user)
    row = db.query(AccountBindToken).filter(AccountBindToken.token == body.token.strip()).first()
    if not row or row.consumed_at or row.expires_at <= datetime.utcnow():
        raise HTTPException(status_code=400, detail="绑定码无效或已过期，请在网页重新打开")
    target = db.query(User).filter(User.id == row.user_id).first()
    if not target or not target.is_active:
        raise HTTPException(status_code=400, detail="网页账号不存在")
    if target.wx_openid and target.wx_openid != user.wx_openid:
        raise HTTPException(status_code=400, detail="该网页账号已绑定其他微信")
    if user.id != target.id:
        if not is_wechat_only(user) and user.email != target.email:
            raise HTTPException(status_code=400, detail="当前微信已关联其他邮箱")
        try:
            merge_users(db, source=user, target=target)
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
    else:
        if not target.wx_openid:
            target.wx_openid = user.wx_openid
    row.consumed_at = datetime.utcnow()
    db.commit()
    db.refresh(target)
    return issue_tokens(db, target, device_id)
