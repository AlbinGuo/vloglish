"""默认头像：一套固定 key，按用户稳定分配并持久化。"""

from __future__ import annotations

import zlib

from sqlalchemy.orm import Session

from ..models import User

DEFAULT_AVATAR_KEYS = (
    "fox",
    "owl",
    "cat",
    "bear",
    "rabbit",
    "whale",
    "panda",
    "deer",
    "penguin",
    "koala",
    "sparrow",
    "otter",
)


def pick_avatar_key(user_id: int | None, email: str = "") -> str:
    seed = int(user_id or 0)
    if seed <= 0:
        seed = zlib.crc32((email or "").encode("utf-8")) & 0x7FFFFFFF
    return DEFAULT_AVATAR_KEYS[seed % len(DEFAULT_AVATAR_KEYS)]


def next_avatar_key(current: str | None) -> str:
    key = (current or "").strip()
    if key not in DEFAULT_AVATAR_KEYS:
        return DEFAULT_AVATAR_KEYS[0]
    idx = DEFAULT_AVATAR_KEYS.index(key)
    return DEFAULT_AVATAR_KEYS[(idx + 1) % len(DEFAULT_AVATAR_KEYS)]


def ensure_user_avatar(user: User) -> bool:
    """若缺失或非法则写入默认头像。返回是否改了字段。"""
    key = (user.avatar_key or "").strip()
    if key in DEFAULT_AVATAR_KEYS:
        if user.avatar_key != key:
            user.avatar_key = key
            return True
        return False
    user.avatar_key = pick_avatar_key(user.id, user.email or "")
    return True


def persist_user_avatar(db: Session, user: User) -> str:
    if ensure_user_avatar(user):
        db.add(user)
        db.commit()
        db.refresh(user)
    return user.avatar_key or pick_avatar_key(user.id, user.email or "")
