from datetime import datetime, timedelta

from sqlalchemy.orm import Session

from ..models import User
from .daily_visits import record_daily_visit
from .page_dwell import add_page_dwell, dwell_delta_seconds, normalize_page_key

# 最近 N 秒内有心跳视为在线
ONLINE_WINDOW_SEC = 90

ALLOWED_CLIENTS = frozenset({"web", "android", "ios", "weixin"})
ALLOWED_DEVICES = frozenset({"ios", "android", "pc"})


def normalize_client(raw: str | None) -> str | None:
    if not raw:
        return None
    key = str(raw).strip().lower()
    if key in ("app", "native", "capacitor"):
        return "android"  # 未细分平台时归为 android 侧 App
    return key if key in ALLOWED_CLIENTS else None


def normalize_device(raw: str | None) -> str | None:
    if not raw:
        return None
    key = str(raw).strip().lower()
    if key in ("iphone", "ipad", "ipod"):
        key = "ios"
    if key in ("windows", "mac", "devtools", "desktop"):
        key = "pc"
    return key if key in ALLOWED_DEVICES else None


def touch_presence(
    db: Session,
    user: User,
    *,
    page_key: str | None = None,
    client: str | None = None,
    device: str | None = None,
) -> None:
    if user.is_staff:
        return
    now = datetime.utcnow()
    delta = dwell_delta_seconds(user.last_seen_at, now)
    key = normalize_page_key(page_key)
    client_key = normalize_client(client)
    device_key = normalize_device(device)

    user.last_seen_at = now
    if client_key:
        user.last_client = client_key
    if device_key:
        user.last_device = device_key
    record_daily_visit(db, user, now_utc=now)
    if key and delta > 0:
        add_page_dwell(db, user.id, key, delta, now_utc=now)
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
    """在线总数，并拆分会员/普通、浏览器/App。"""
    q = _online_users_query(db)
    online_members = q.filter(User.is_member.is_(True)).count()
    online_free = q.filter(User.is_member.is_(False)).count()
    online_web = q.filter(User.last_client == "web").count()
    online_android = q.filter(User.last_client == "android").count()
    online_ios = q.filter(User.last_client == "ios").count()
    online_app = online_android + online_ios
    online_users = online_members + online_free
    online_unknown = max(0, online_users - online_web - online_app)
    return {
        "online_users": online_users,
        "online_members": online_members,
        "online_free": online_free,
        "online_web": online_web,
        "online_app": online_app,
        "online_android": online_android,
        "online_ios": online_ios,
        "online_unknown": online_unknown,
        "window_sec": ONLINE_WINDOW_SEC,
    }
