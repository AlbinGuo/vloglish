from datetime import datetime, timedelta

from sqlalchemy.orm import Session

from ..models import User
from .daily_visits import record_daily_visit

# 最近 N 秒内有心跳视为在线
ONLINE_WINDOW_SEC = 90


def touch_presence(db: Session, user: User) -> None:
    if user.is_staff:
        return
    now = datetime.utcnow()
    user.last_seen_at = now
    record_daily_visit(db, user, now_utc=now)
    db.commit()


def is_user_online(user: User, *, now: datetime | None = None) -> bool:
    if not user.last_seen_at or user.is_staff or not user.is_active:
        return False
    current = now or datetime.utcnow()
    return user.last_seen_at >= current - timedelta(seconds=ONLINE_WINDOW_SEC)


def _online_users_query(db: Session):
    since = datetime.utcnow() - timedelta(seconds=ONLINE_WINDOW_SEC)
    return db.query(User).filter(
        User.is_active.is_(True),
        User.is_staff.is_(False),
        User.last_seen_at.isnot(None),
        User.last_seen_at >= since,
    )


def count_online_users(db: Session) -> int:
    """活跃非管理员用户：最近 ONLINE_WINDOW_SEC 内有心跳视为在线（含非会员）。"""
    return _online_users_query(db).count()


def online_presence_breakdown(db: Session) -> dict:
    """在线总数，并拆分会员 / 普通用户。"""
    q = _online_users_query(db)
    online_members = q.filter(User.is_member.is_(True)).count()
    online_free = q.filter(User.is_member.is_(False)).count()
    return {
        "online_users": online_members + online_free,
        "online_members": online_members,
        "online_free": online_free,
        "window_sec": ONLINE_WINDOW_SEC,
    }
