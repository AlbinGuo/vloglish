from fastapi import Depends, Header, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from .auth_utils import decode_access_token
from .database import get_db
from .models import User

_bearer = HTTPBearer(auto_error=False)


def get_device_id(x_device_id: str | None = Header(default=None, alias="X-Device-Id")) -> str:
    if not x_device_id or not x_device_id.strip():
        return "anonymous"
    return x_device_id.strip()[:64]


def get_current_user_optional(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer),
    db: Session = Depends(get_db),
) -> User | None:
    if not credentials or credentials.scheme.lower() != "bearer":
        return None

    user_id = decode_access_token(credentials.credentials)
    if user_id is None:
        return None

    user = db.query(User).filter(User.id == user_id, User.is_active.is_(True)).first()
    return user


def get_current_user(user: User | None = Depends(get_current_user_optional)) -> User:
    if not user:
        raise HTTPException(status_code=401, detail="未登录")
    return user


def get_current_admin(user: User = Depends(get_current_user)) -> User:
    if not user.is_staff:
        raise HTTPException(status_code=403, detail="需要管理员权限")
    return user
