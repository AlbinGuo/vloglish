"""运营健康度指标：DAU、注册→首学、会员转化。"""

from __future__ import annotations

from datetime import datetime, timedelta

from sqlalchemy import func
from sqlalchemy.orm import Session

from ..models import User, UserDailyVisit, UserEpisodeProgress
from .daily_visits import visit_date_now


def _pct(num: int, den: int) -> float:
    if den <= 0:
        return 0.0
    return round(num / den * 1000) / 10  # 一位小数百分比数值，如 12.5


def dau_trend(db: Session, *, days: int = 30) -> dict:
    """近 N 天到访 DAU（基于 user_daily_visits，东八区自然日）。"""
    days = max(1, min(int(days), 90))
    today = visit_date_now()
    since = today - timedelta(days=days - 1)

    rows = (
        db.query(UserDailyVisit.visit_date, func.count(UserDailyVisit.id))
        .filter(
            UserDailyVisit.visit_date >= since,
            UserDailyVisit.visit_date <= today,
        )
        .group_by(UserDailyVisit.visit_date)
        .all()
    )
    by_date = {str(d): int(c or 0) for d, c in rows if d is not None}

    trend = []
    cursor = since
    while cursor <= today:
        key = str(cursor)
        trend.append({"date": key, "dau": by_date.get(key, 0)})
        cursor += timedelta(days=1)

    dau_today = by_date.get(str(today), 0)
    return {"dau_today": dau_today, "dau_trend": trend}


def funnel_register_learn(db: Session) -> dict:
    """注册 → 首次学习（有任意视频学习进度即算）。"""
    now = datetime.utcnow()
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    since_30 = now - timedelta(days=30)

    base = db.query(User).filter(User.is_staff.is_(False), User.is_active.is_(True))
    users_total = base.count()

    learned_sq = db.query(UserEpisodeProgress.user_id).distinct()
    users_learned = base.filter(User.id.in_(learned_sq)).count()

    registered_30d = base.filter(User.created_at >= since_30).count()
    learned_among_30d = (
        base.filter(User.created_at >= since_30, User.id.in_(learned_sq)).count()
    )

    # 今日首次打开学习（first_opened_at 落在今日 UTC；与现有仪表盘「今日」口径一致）
    first_learn_today = (
        db.query(UserEpisodeProgress.user_id)
        .join(User, User.id == UserEpisodeProgress.user_id)
        .filter(
            User.is_staff.is_(False),
            User.is_active.is_(True),
            UserEpisodeProgress.first_opened_at >= today_start,
        )
        .distinct()
        .count()
    )

    return {
        "users_total": users_total,
        "users_learned": users_learned,
        "rate": _pct(users_learned, users_total),
        "registered_30d": registered_30d,
        "learned_among_registered_30d": learned_among_30d,
        "rate_30d": _pct(learned_among_30d, registered_30d),
        "first_learn_today": first_learn_today,
    }


def funnel_member(db: Session) -> dict:
    """普通用户 → 会员转化。"""
    now = datetime.utcnow()
    since_7 = now - timedelta(days=7)
    since_30 = now - timedelta(days=30)

    base = db.query(User).filter(User.is_staff.is_(False), User.is_active.is_(True))
    users_total = base.count()
    members_total = base.filter(User.is_member.is_(True)).count()

    activated_7d = base.filter(
        User.is_member.is_(True),
        User.member_activated_at.isnot(None),
        User.member_activated_at >= since_7,
    ).count()
    activated_30d = base.filter(
        User.is_member.is_(True),
        User.member_activated_at.isnot(None),
        User.member_activated_at >= since_30,
    ).count()

    registered_30d = base.filter(User.created_at >= since_30).count()
    members_among_30d = base.filter(
        User.created_at >= since_30,
        User.is_member.is_(True),
    ).count()

    return {
        "users_total": users_total,
        "members_total": members_total,
        "rate": _pct(members_total, users_total),
        "activated_7d": activated_7d,
        "activated_30d": activated_30d,
        "registered_30d": registered_30d,
        "members_among_registered_30d": members_among_30d,
        "rate_among_registered_30d": _pct(members_among_30d, registered_30d),
    }


def ops_health_block(db: Session) -> dict:
    dau = dau_trend(db, days=30)
    return {
        "dau_today": dau["dau_today"],
        "dau_trend": dau["dau_trend"],
        "funnel_register_learn": funnel_register_learn(db),
        "funnel_member": funnel_member(db),
    }
