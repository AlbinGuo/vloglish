from fastapi import Depends, Header, HTTPException, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from .auth_utils import REMOTE_LOGIN_DETAIL, decode_access_claims
from .database import get_db
from .models import User

_bearer = HTTPBearer(auto_error=False)


def get_device_id(x_device_id: str | None = Header(default=None, alias="X-Device-Id")) -> str:
    if not x_device_id or not x_device_id.strip():
        return "anonymous"
    return x_device_id.strip()[:64]


def get_client_ip(request: Request) -> str | None:
    forwarded = request.headers.get("X-Forwarded-For")
    if forwarded:
        ip = forwarded.split(",")[0].strip()
        if ip:
            return ip[:64]
    real_ip = request.headers.get("X-Real-IP")
    if real_ip and real_ip.strip():
        return real_ip.strip()[:64]
    if request.client and request.client.host:
        return request.client.host[:64]
    return None


def get_current_user_optional(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
    db: Session = Depends(get_db),
) -> User | None:
    if not credentials or credentials.scheme.lower() != "bearer":
        return None

    claims = decode_access_claims(credentials.credentials)
    if claims is None:
        return None

    user = (
        db.query(User)
        .filter(User.id == claims["user_id"], User.is_active.is_(True))
        .first()
    )
    if not user:
        return None
    if user.session_version != claims["session_version"]:
        raise HTTPException(status_code=401, detail=REMOTE_LOGIN_DETAIL)
    return user


def get_current_user(user: User | None = Depends(get_current_user_optional)) -> User:
    if not user:
        raise HTTPException(status_code=401, detail="未登录")
    return user


def get_current_admin(user: User = Depends(get_current_user)) -> User:
    if not user.is_staff:
        raise HTTPException(status_code=403, detail="需要管理员权限")
    return user


def get_current_member(user: User = Depends(get_current_user)) -> User:
    if not user.is_member:
        raise HTTPException(status_code=403, detail="需要激活会员")
    return user
