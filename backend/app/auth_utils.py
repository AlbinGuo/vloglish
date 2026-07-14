import hashlib
import os
from datetime import datetime, timedelta, timezone
from secrets import token_urlsafe

import bcrypt
from jose import JWTError, jwt

JWT_SECRET = os.getenv("JWT_SECRET", "dev-secret-change-in-production")
JWT_ALGORITHM = "HS256"
ACCESS_EXPIRE_MINUTES = int(os.getenv("JWT_ACCESS_EXPIRE_MINUTES", "15"))
REFRESH_EXPIRE_DAYS = int(os.getenv("JWT_REFRESH_EXPIRE_DAYS", "30"))

REMOTE_LOGIN_DETAIL = "登录已失效，请重新登录（同一账号最多 3 台设备同时在线）"
MAX_CONCURRENT_SESSIONS = 3


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(password: str, password_hash: str) -> bool:
    try:
        return bcrypt.checkpw(password.encode("utf-8"), password_hash.encode("utf-8"))
    except ValueError:
        return False


def create_access_token(user_id: int, session_version: int, session_key: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_EXPIRE_MINUTES)
    payload = {
        "sub": str(user_id),
        "type": "access",
        "sv": session_version,
        "sid": session_key,
        "exp": expire,
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def decode_access_claims(token: str) -> dict | None:
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        if payload.get("type") != "access":
            return None
        sv = payload.get("sv")
        sid = payload.get("sid")
        if sv is None or not sid:
            return None
        return {
            "user_id": int(payload["sub"]),
            "session_version": int(sv),
            "session_key": str(sid),
        }
    except (JWTError, KeyError, TypeError, ValueError):
        return None


def decode_access_token(token: str) -> int | None:
    claims = decode_access_claims(token)
    if not claims:
        return None
    return claims["user_id"]


def new_refresh_token() -> str:
    return token_urlsafe(48)


def new_session_key() -> str:
    return token_urlsafe(24)


def hash_refresh_token(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def verify_refresh_token(token: str, token_hash: str) -> bool:
    return hash_refresh_token(token) == token_hash


def refresh_token_expires_at() -> datetime:
    return datetime.utcnow() + timedelta(days=REFRESH_EXPIRE_DAYS)


def new_password_reset_token() -> str:
    return token_urlsafe(32)


def hash_password_reset_token(token: str) -> str:
    import hashlib

    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def password_reset_expires_at() -> datetime:
    return datetime.utcnow() + timedelta(hours=1)
