"""页面停留时长：由心跳间隔累加到日聚合表。"""

from __future__ import annotations

from datetime import datetime, timedelta, timezone

from sqlalchemy import func
from sqlalchemy.orm import Session

from ..models import UserPageDwell
from .daily_visits import visit_date_now

# 单次心跳可计入的最大秒数（与在线窗口对齐，避免切回前台时虚高）
MAX_DWELL_DELTA_SEC = 90

PAGE_LABELS: dict[str, str] = {
    "HomePage": "首页",
    "SeriesList": "合集列表",
    "SeriesDetail": "合集详情",
    "AuthorDetail": "作者页",
    "NewsReadingList": "读报列表",
    "NewsReading": "读报详情",
    "EpisodePage": "视频学习",
    "DemoEpisode": "体验视频",
    "SubmitEpisode": "上传视频",
    "SubmitArticle": "上传文章",
    "MySubmissions": "我的语料库",
    "Notifications": "通知",
    "Learning": "学习记录",
    "Vocabulary": "生词本",
    "Pricing": "会员定价",
    "DemoPage": "体验页",
}

ALLOWED_PAGE_KEYS = frozenset(PAGE_LABELS.keys())


def normalize_page_key(raw: str | None) -> str | None:
    key = (raw or "").strip()
    if not key or key not in ALLOWED_PAGE_KEYS:
        return None
    return key


def page_label(page_key: str) -> str:
    return PAGE_LABELS.get(page_key, page_key)


def add_page_dwell(
    db: Session,
    user_id: int,
    page_key: str,
    delta_sec: int,
    *,
    now_utc: datetime | None = None,
) -> None:
    """累加停留秒数；不 commit。"""
    if delta_sec <= 0:
        return
    key = normalize_page_key(page_key)
    if not key:
        return

    current = now_utc or datetime.utcnow()
    if current.tzinfo is not None:
        current = current.astimezone(timezone.utc).replace(tzinfo=None)
    visit_date = visit_date_now(now_utc=current)

    row = (
        db.query(UserPageDwell)
        .filter(
            UserPageDwell.user_id == user_id,
            UserPageDwell.visit_date == visit_date,
            UserPageDwell.page_key == key,
        )
        .first()
    )
    if row:
        row.dwell_seconds = int(row.dwell_seconds or 0) + int(delta_sec)
        row.hit_count = int(row.hit_count or 0) + 1
        row.last_seen_at = current
        return

    db.add(
        UserPageDwell(
            user_id=user_id,
            visit_date=visit_date,
            page_key=key,
            dwell_seconds=int(delta_sec),
            hit_count=1,
            last_seen_at=current,
        )
    )


def dwell_delta_seconds(last_seen_at: datetime | None, now: datetime) -> int:
    if not last_seen_at:
        return 0
    last = last_seen_at
    if last.tzinfo is not None:
        last = last.astimezone(timezone.utc).replace(tzinfo=None)
    current = now
    if current.tzinfo is not None:
        current = current.astimezone(timezone.utc).replace(tzinfo=None)
    raw = (current - last).total_seconds()
    if raw <= 0 or raw > MAX_DWELL_DELTA_SEC:
        return 0
    return int(raw)


def site_page_dwell_stats(db: Session, *, days: int = 7, limit: int = 10) -> dict:
    days = max(1, min(90, int(days or 7)))
    limit = max(1, min(50, int(limit or 10)))
    today = visit_date_now()
    start = today - timedelta(days=days - 1)

    rows = (
        db.query(
            UserPageDwell.page_key,
            func.sum(UserPageDwell.dwell_seconds).label("seconds"),
            func.count(func.distinct(UserPageDwell.user_id)).label("users"),
            func.sum(UserPageDwell.hit_count).label("hits"),
        )
        .filter(UserPageDwell.visit_date >= start)
        .group_by(UserPageDwell.page_key)
        .order_by(func.sum(UserPageDwell.dwell_seconds).desc())
        .limit(limit)
        .all()
    )

    pages = [
        {
            "page_key": key,
            "label": page_label(key),
            "dwell_seconds": int(seconds or 0),
            "users": int(users or 0),
            "hits": int(hits or 0),
        }
        for key, seconds, users, hits in rows
    ]
    total_seconds = sum(p["dwell_seconds"] for p in pages)
    return {
        "days": days,
        "limit": limit,
        "total_dwell_seconds": total_seconds,
        "pages": pages,
    }


def user_page_dwell_top(
    db: Session,
    user_id: int,
    *,
    days: int = 30,
    limit: int = 5,
) -> dict:
    days = max(1, min(90, int(days or 30)))
    limit = max(1, min(20, int(limit or 5)))
    today = visit_date_now()
    start = today - timedelta(days=days - 1)

    rows = (
        db.query(
            UserPageDwell.page_key,
            func.sum(UserPageDwell.dwell_seconds).label("seconds"),
            func.sum(UserPageDwell.hit_count).label("hits"),
        )
        .filter(
            UserPageDwell.user_id == user_id,
            UserPageDwell.visit_date >= start,
        )
        .group_by(UserPageDwell.page_key)
        .order_by(func.sum(UserPageDwell.dwell_seconds).desc())
        .limit(limit)
        .all()
    )
    pages = [
        {
            "page_key": key,
            "label": page_label(key),
            "dwell_seconds": int(seconds or 0),
            "hits": int(hits or 0),
        }
        for key, seconds, hits in rows
    ]
    return {
        "user_id": user_id,
        "days": days,
        "limit": limit,
        "pages": pages,
    }


def top_pages_for_users(
    db: Session,
    user_ids: list[int],
    *,
    days: int = 30,
    limit: int = 3,
) -> dict[int, list[dict]]:
    """批量取每用户停留最长的前 N 个页面（用于用户列表）。"""
    if not user_ids:
        return {}
    days = max(1, min(90, int(days or 30)))
    limit = max(1, min(10, int(limit or 3)))
    today = visit_date_now()
    start = today - timedelta(days=days - 1)

    rows = (
        db.query(
            UserPageDwell.user_id,
            UserPageDwell.page_key,
            func.sum(UserPageDwell.dwell_seconds).label("seconds"),
        )
        .filter(
            UserPageDwell.user_id.in_(user_ids),
            UserPageDwell.visit_date >= start,
        )
        .group_by(UserPageDwell.user_id, UserPageDwell.page_key)
        .all()
    )
    by_user: dict[int, list[tuple[str, int]]] = {}
    for uid, key, seconds in rows:
        by_user.setdefault(int(uid), []).append((key, int(seconds or 0)))

    out: dict[int, list[dict]] = {}
    for uid, items in by_user.items():
        items.sort(key=lambda x: -x[1])
        out[uid] = [
            {
                "page_key": key,
                "label": page_label(key),
                "dwell_seconds": sec,
            }
            for key, sec in items[:limit]
        ]
    return out
