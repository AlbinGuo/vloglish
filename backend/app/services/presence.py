from datetime import datetime, timedelta

from sqlalchemy.orm import Session

from ..models import User

# 最近 N 秒内有心跳视为在线
ONLINE_WINDOW_SEC = 90


def touch_presence(db: Session, user: User) -> None:
    if user.is_staff:
        return
    user.last_seen_at = datetime.utcnow()
    db.commit()


def is_user_online(user: User, *, now: datetime | None = None) -> bool:
    if not user.last_seen_at or user.is_staff or not user.is_active:
        return False
    current = now or datetime.utcnow()
    return user.last_seen_at >= current - timedelta(seconds=ONLINE_WINDOW_SEC)


def count_online_users(db: Session) -> int:
    """活跃非管理员用户：最近 ONLINE_WINDOW_SEC 内有心跳视为在线（含非会员）。"""
    since = datetime.utcnow() - timedelta(seconds=ONLINE_WINDOW_SEC)
    return (
        db.query(User)
        .filter(
            User.is_active.is_(True),
            User.is_staff.is_(False),
            User.last_seen_at.isnot(None),
            User.last_seen_at >= since,
        )
        .count()
    )
