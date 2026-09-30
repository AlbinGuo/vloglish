"""用户每日到访：按东八区自然日落库，供管理端统计上站天数、次数与时段分布。"""

from __future__ import annotations

from datetime import date, datetime, timedelta, timezone

from sqlalchemy import case, func
from sqlalchemy.orm import Session

from ..models import User, UserDailyVisit, UserVisitSession

# 业务日切：中国时区（固定 UTC+8，不依赖系统 tzdata）
CST = timezone(timedelta(hours=8))

# 距上次心跳超过该间隔，视为新的一次到访会话
SESSION_GAP = timedelta(minutes=30)


def visit_date_now(*, now_utc: datetime | None = None) -> date:
    current = now_utc or datetime.utcnow()
    if current.tzinfo is None:
        current = current.replace(tzinfo=timezone.utc)
    return current.astimezone(CST).date()


def fmt_cst(value: datetime | None) -> str | None:
    """库内 naive UTC → 东八区墙钟，格式 YYYY-MM-DD HH:MM:SS。"""
    if not value:
        return None
    current = value.replace(tzinfo=timezone.utc) if value.tzinfo is None else value
    return current.astimezone(CST).strftime("%Y-%m-%d %H:%M:%S")


def _as_naive_utc(now_utc: datetime | None = None) -> datetime:
    current = now_utc or datetime.utcnow()
    if current.tzinfo is not None:
        return current.astimezone(timezone.utc).replace(tzinfo=None)
    return current


def _cst_hour(started_at: datetime) -> int:
    current = _as_naive_utc(started_at).replace(tzinfo=timezone.utc)
    return current.astimezone(CST).hour


def _start_visit_session(
    db: Session,
    *,
    user_id: int,
    visit_date: date,
    started_at: datetime,
) -> None:
    db.add(
        UserVisitSession(
            user_id=user_id,
            visit_date=visit_date,
            started_at=started_at,
        )
    )


def record_daily_visit(db: Session, user: User, *, now_utc: datetime | None = None) -> None:
    """记录用户当日到访。管理员不计；不 commit，由调用方提交事务。"""
    if user.is_staff or not user.is_active:
        return
    current = _as_naive_utc(now_utc)
    visit_date = visit_date_now(now_utc=current)

    row = (
        db.query(UserDailyVisit)
        .filter(UserDailyVisit.user_id == user.id, UserDailyVisit.visit_date == visit_date)
        .first()
    )
    if row:
        last = row.last_seen_at or current
        if last.tzinfo is not None:
            last = last.astimezone(timezone.utc).replace(tzinfo=None)
        if current - last > SESSION_GAP:
            row.session_count = int(row.session_count or 0) + 1
            _start_visit_session(
                db, user_id=user.id, visit_date=visit_date, started_at=current
            )
        row.last_seen_at = current
        row.hit_count = int(row.hit_count or 0) + 1
        return

    db.add(
        UserDailyVisit(
            user_id=user.id,
            visit_date=visit_date,
            first_seen_at=current,
            last_seen_at=current,
            hit_count=1,
            session_count=1,
        )
    )
    _start_visit_session(db, user_id=user.id, visit_date=visit_date, started_at=current)


def visit_stats_for_users(
    db: Session,
    user_ids: list[int],
    *,
    days_7: int = 7,
    days_30: int = 30,
) -> dict[int, dict[str, int]]:
    """返回每用户近 7/30 日到访天数与会话次数合计。"""
    if not user_ids:
        return {}
    today = visit_date_now()
    since_30 = today - timedelta(days=days_30 - 1)
    since_7 = today - timedelta(days=days_7 - 1)

    rows = (
        db.query(
            UserDailyVisit.user_id,
            func.coalesce(
                func.sum(case((UserDailyVisit.visit_date >= since_7, 1), else_=0)),
                0,
            ).label("days_7"),
            func.count(UserDailyVisit.id).label("days_30"),
            func.coalesce(
                func.sum(
                    case(
                        (UserDailyVisit.visit_date >= since_7, UserDailyVisit.session_count),
                        else_=0,
                    )
                ),
                0,
            ).label("sessions_7"),
            func.coalesce(func.sum(UserDailyVisit.session_count), 0).label("sessions_30"),
            func.coalesce(
                func.sum(case((UserDailyVisit.visit_date == today, UserDailyVisit.session_count), else_=0)),
                0,
            ).label("sessions_today"),
        )
        .filter(
            UserDailyVisit.user_id.in_(user_ids),
            UserDailyVisit.visit_date >= since_30,
            UserDailyVisit.visit_date <= today,
        )
        .group_by(UserDailyVisit.user_id)
        .all()
    )
    out: dict[int, dict[str, int]] = {
        uid: {
            "visit_days_7d": 0,
            "visit_days_30d": 0,
            "visit_sessions_7d": 0,
            "visit_sessions_30d": 0,
            "visit_sessions_today": 0,
        }
        for uid in user_ids
    }
    for user_id, d7, d30, s7, s30, st in rows:
        out[int(user_id)] = {
            "visit_days_7d": int(d7 or 0),
            "visit_days_30d": int(d30 or 0),
            "visit_sessions_7d": int(s7 or 0),
            "visit_sessions_30d": int(s30 or 0),
            "visit_sessions_today": int(st or 0),
        }
    return out


def visit_hourly_stats(db: Session, *, days: int = 7) -> dict:
    """近 N 天按东八区小时聚合到访人数（去重）与会话次数。"""
    days = max(1, min(int(days), 90))
    today = visit_date_now()
    since = today - timedelta(days=days - 1)

    rows = (
        db.query(UserVisitSession.user_id, UserVisitSession.started_at)
        .filter(
            UserVisitSession.visit_date >= since,
            UserVisitSession.visit_date <= today,
        )
        .all()
    )

    users_by_hour: list[set[int]] = [set() for _ in range(24)]
    sessions_by_hour = [0] * 24
    for user_id, started_at in rows:
        if not started_at:
            continue
        hour = _cst_hour(started_at)
        users_by_hour[hour].add(int(user_id))
        sessions_by_hour[hour] += 1

    hours = [
        {
            "hour": h,
            "label": f"{h:02d}:00",
            "users": len(users_by_hour[h]),
            "sessions": sessions_by_hour[h],
        }
        for h in range(24)
    ]

    if any(item["users"] or item["sessions"] for item in hours):
        peak = max(hours, key=lambda item: (item["users"], item["sessions"], -item["hour"]))
        low = min(hours, key=lambda item: (item["users"], item["sessions"], item["hour"]))
    else:
        peak = None
        low = None

    return {
        "days": days,
        "timezone": "Asia/Shanghai",
        "total_sessions": sum(item["sessions"] for item in hours),
        "total_users": len({uid for bucket in users_by_hour for uid in bucket}),
        "peak_hour": peak["hour"] if peak else None,
        "peak_label": peak["label"] if peak else None,
        "peak_users": peak["users"] if peak else 0,
        "low_hour": low["hour"] if low else None,
        "low_label": low["label"] if low else None,
        "low_users": low["users"] if low else 0,
        "hours": hours,
    }


# 兼容旧调用名
def visit_day_counts_for_users(
    db: Session,
    user_ids: list[int],
    *,
    days_7: int = 7,
    days_30: int = 30,
) -> dict[int, tuple[int, int]]:
    stats = visit_stats_for_users(db, user_ids, days_7=days_7, days_30=days_30)
    return {
        uid: (item["visit_days_7d"], item["visit_days_30d"]) for uid, item in stats.items()
    }
