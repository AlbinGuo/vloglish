from datetime import datetime, timedelta

from sqlalchemy import case, func, or_
from sqlalchemy.orm import Query, Session

from ..models import LearningSession, User, UserEpisodeProgress, UserWordLookup
from .presence import ONLINE_WINDOW_SEC

SEGMENT_LABELS: dict[str, str] = {
    "active_7d": "7 日活跃",
    "churn_risk": "流失风险",
    "new_inactive": "新注册未学",
    "deep_learners": "深度用户",
    "members": "会员",
    "non_members": "非会员",
}

VALID_SEGMENTS = frozenset(SEGMENT_LABELS.keys())

DEEP_LEARNER_MIN_WATCH_SEC = 3600
DEEP_LEARNER_MIN_LOOKUPS = 15


def _learning_subqueries(db: Session):
    week_ago = datetime.utcnow() - timedelta(days=7)

    progress_sq = (
        db.query(
            UserEpisodeProgress.user_id.label("user_id"),
            func.max(UserEpisodeProgress.last_watched_at).label("last_watched_at"),
            func.sum(case((UserEpisodeProgress.is_completed.is_(True), 1), else_=0)).label("completions"),
        )
        .group_by(UserEpisodeProgress.user_id)
        .subquery()
    )
    session_7d_sq = (
        db.query(
            LearningSession.user_id.label("user_id"),
            func.coalesce(func.sum(LearningSession.watch_time_sec), 0).label("watch_time_7d"),
        )
        .filter(LearningSession.started_at >= week_ago)
        .group_by(LearningSession.user_id)
        .subquery()
    )
    lookup_sq = (
        db.query(
            UserWordLookup.user_id.label("user_id"),
            func.count(UserWordLookup.id).label("lookup_count"),
        )
        .group_by(UserWordLookup.user_id)
        .subquery()
    )
    return progress_sq, session_7d_sq, lookup_sq


def _apply_segment_filter(q: Query, segment: str, db: Session) -> Query:
    if segment not in VALID_SEGMENTS:
        return q

    now = datetime.utcnow()
    week_ago = now - timedelta(days=7)
    two_weeks_ago = now - timedelta(days=14)
    three_days_ago = now - timedelta(days=3)

    if segment == "members":
        return q.filter(User.is_member.is_(True))
    if segment == "non_members":
        return q.filter(User.is_member.is_(False))

    q = q.filter(User.is_staff.is_(False))

    if segment == "active_7d":
        progress_active = (
            db.query(UserEpisodeProgress.user_id)
            .filter(UserEpisodeProgress.last_watched_at >= week_ago)
            .distinct()
        )
        session_active = (
            db.query(LearningSession.user_id)
            .filter(LearningSession.started_at >= week_ago)
            .distinct()
        )
        return q.filter(or_(User.id.in_(progress_active), User.id.in_(session_active)))

    if segment == "churn_risk":
        latest_sq = (
            db.query(
                UserEpisodeProgress.user_id.label("user_id"),
                func.max(UserEpisodeProgress.last_watched_at).label("last_at"),
            )
            .group_by(UserEpisodeProgress.user_id)
            .subquery()
        )
        return q.join(latest_sq, User.id == latest_sq.c.user_id).filter(latest_sq.c.last_at < two_weeks_ago)

    if segment == "new_inactive":
        has_progress = db.query(UserEpisodeProgress.user_id).distinct()
        return q.filter(User.created_at < three_days_ago, ~User.id.in_(has_progress))

    if segment == "deep_learners":
        heavy_watch = (
            db.query(LearningSession.user_id)
            .filter(LearningSession.started_at >= week_ago)
            .group_by(LearningSession.user_id)
            .having(func.sum(LearningSession.watch_time_sec) >= DEEP_LEARNER_MIN_WATCH_SEC)
        )
        heavy_lookup = (
            db.query(UserWordLookup.user_id)
            .filter(UserWordLookup.looked_up_at >= week_ago)
            .group_by(UserWordLookup.user_id)
            .having(func.count(UserWordLookup.id) >= DEEP_LEARNER_MIN_LOOKUPS)
        )
        return q.filter(or_(User.id.in_(heavy_watch), User.id.in_(heavy_lookup)))

    return q


def admin_user_list_query(
    db: Session,
    *,
    search: str | None = None,
    segment: str | None = None,
) -> Query:
    progress_sq, session_7d_sq, lookup_sq = _learning_subqueries(db)

    watch_7d_col = func.coalesce(session_7d_sq.c.watch_time_7d, 0).label("watch_time_7d")
    completions_col = func.coalesce(progress_sq.c.completions, 0).label("completed_episodes")
    lookup_col = func.coalesce(lookup_sq.c.lookup_count, 0).label("lookup_count")
    last_watched_col = progress_sq.c.last_watched_at.label("last_watched_at")

    q = (
        db.query(User, last_watched_col, watch_7d_col, completions_col, lookup_col)
        .outerjoin(progress_sq, User.id == progress_sq.c.user_id)
        .outerjoin(session_7d_sq, User.id == session_7d_sq.c.user_id)
        .outerjoin(lookup_sq, User.id == lookup_sq.c.user_id)
    )

    if search and search.strip():
        term = f"%{search.strip()}%"
        q = q.filter(User.email.ilike(term))

    if segment and segment in VALID_SEGMENTS:
        q = _apply_segment_filter(q, segment, db)

    online_since = datetime.utcnow() - timedelta(seconds=ONLINE_WINDOW_SEC)
    online_first = case(
        (
            User.is_active.is_(True)
            & User.is_staff.is_(False)
            & User.last_seen_at.isnot(None)
            & (User.last_seen_at >= online_since),
            0,
        ),
        else_=1,
    )
    return q.order_by(online_first.asc(), User.id.desc())


def row_stats_from_user_query(row) -> dict:
    user, last_watched_at, watch_time_7d, completed_episodes, lookup_count = row
    last_active_at = None
    if user.last_seen_at and last_watched_at:
        last_active_at = max(user.last_seen_at, last_watched_at)
    elif user.last_seen_at:
        last_active_at = user.last_seen_at
    else:
        last_active_at = last_watched_at
    return {
        "last_active_at": last_active_at,
        "watch_time_7d": int(watch_time_7d or 0),
        "completed_episodes": int(completed_episodes or 0),
        "lookup_count": int(lookup_count or 0),
    }


def segment_counts(db: Session) -> list[dict]:
    return [
        {
            "key": key,
            "label": label,
            "count": _apply_segment_filter(db.query(User), key, db).count(),
        }
        for key, label in SEGMENT_LABELS.items()
    ]
