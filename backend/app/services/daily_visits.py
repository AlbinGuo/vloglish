"""用户每日到访：按东八区自然日落库，供管理端统计上站天数。"""

from __future__ import annotations

from datetime import date, datetime, timedelta, timezone

from sqlalchemy import case, func
from sqlalchemy.orm import Session

from ..models import User, UserDailyVisit

# 业务日切：中国时区（固定 UTC+8，不依赖系统 tzdata）
CST = timezone(timedelta(hours=8))


def visit_date_now(*, now_utc: datetime | None = None) -> date:
    current = now_utc or datetime.utcnow()
    if current.tzinfo is None:
        current = current.replace(tzinfo=timezone.utc)
    return current.astimezone(CST).date()


def record_daily_visit(db: Session, user: User, *, now_utc: datetime | None = None) -> None:
    """记录用户当日到访。管理员不计；不 commit，由调用方提交事务。"""
    if user.is_staff or not user.is_active:
        return
    current = now_utc or datetime.utcnow()
    if current.tzinfo is not None:
        current = current.astimezone(timezone.utc).replace(tzinfo=None)
    visit_date = visit_date_now(now_utc=current)

    row = (
        db.query(UserDailyVisit)
        .filter(UserDailyVisit.user_id == user.id, UserDailyVisit.visit_date == visit_date)
        .first()
    )
    if row:
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
        )
    )


def visit_day_counts_for_users(
    db: Session,
    user_ids: list[int],
    *,
    days_7: int = 7,
    days_30: int = 30,
) -> dict[int, tuple[int, int]]:
    """返回 {user_id: (visit_days_7d, visit_days_30d)}。"""
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
            ).label("d7"),
            func.count(UserDailyVisit.id).label("d30"),
        )
        .filter(
            UserDailyVisit.user_id.in_(user_ids),
            UserDailyVisit.visit_date >= since_30,
            UserDailyVisit.visit_date <= today,
        )
        .group_by(UserDailyVisit.user_id)
        .all()
    )
    out: dict[int, tuple[int, int]] = {uid: (0, 0) for uid in user_ids}
    for user_id, d7, d30 in rows:
        out[int(user_id)] = (int(d7 or 0), int(d30 or 0))
    return out
