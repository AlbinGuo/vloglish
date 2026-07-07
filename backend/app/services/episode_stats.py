from datetime import datetime, timedelta

from sqlalchemy import case, func
from sqlalchemy.orm import Query, Session, joinedload

from ..models import Author, Episode, LearningSession, UserEpisodeProgress

EPISODE_LIST_SORT_FIELDS = frozenset(
    {
        "id",
        "index",
        "play_count",
        "unique_learners",
        "completions",
        "completion_rate",
        "plays_7d",
        "plays_30d",
    }
)


def _stats_subqueries(db: Session):
    now = datetime.utcnow()
    week_ago = now - timedelta(days=7)
    month_ago = now - timedelta(days=30)

    session_sq = (
        db.query(
            LearningSession.episode_id.label("episode_id"),
            func.count(LearningSession.id).label("play_count"),
            func.count(case((LearningSession.started_at >= week_ago, 1))).label("plays_7d"),
            func.count(case((LearningSession.started_at >= month_ago, 1))).label("plays_30d"),
        )
        .group_by(LearningSession.episode_id)
        .subquery()
    )
    progress_sq = (
        db.query(
            UserEpisodeProgress.episode_id.label("episode_id"),
            func.count(UserEpisodeProgress.id).label("unique_learners"),
            func.sum(case((UserEpisodeProgress.is_completed.is_(True), 1), else_=0)).label("completions"),
        )
        .group_by(UserEpisodeProgress.episode_id)
        .subquery()
    )
    return session_sq, progress_sq


def admin_episode_list_query(
    db: Session,
    *,
    search: str | None = None,
    status: str | None = None,
    stars: int | None = None,
    sort_by: str = "index",
    sort_dir: str = "desc",
) -> Query:
    session_sq, progress_sq = _stats_subqueries(db)

    play_count_col = func.coalesce(session_sq.c.play_count, 0).label("play_count")
    plays_7d_col = func.coalesce(session_sq.c.plays_7d, 0).label("plays_7d")
    plays_30d_col = func.coalesce(session_sq.c.plays_30d, 0).label("plays_30d")
    unique_learners_col = func.coalesce(progress_sq.c.unique_learners, 0).label("unique_learners")
    completions_col = func.coalesce(progress_sq.c.completions, 0).label("completions")
    completion_rate_col = func.coalesce(
        completions_col * 100.0 / func.nullif(unique_learners_col, 0),
        0,
    ).label("completion_rate")

    q = (
        db.query(
            Episode,
            play_count_col,
            unique_learners_col,
            completions_col,
            completion_rate_col,
            plays_7d_col,
            plays_30d_col,
        )
        .options(joinedload(Episode.author), joinedload(Episode.tags))
        .join(Author)
        .outerjoin(session_sq, Episode.id == session_sq.c.episode_id)
        .outerjoin(progress_sq, Episode.id == progress_sq.c.episode_id)
    )

    if search and search.strip():
        term = f"%{search.strip()}%"
        q = q.filter(
            Episode.short_title.ilike(term)
            | Episode.video_id.ilike(term)
            | Author.name.ilike(term)
        )
    if status:
        q = q.filter(Episode.status == status)
    if stars is not None:
        q = q.filter(Episode.stars == stars)

    sort_key = sort_by if sort_by in EPISODE_LIST_SORT_FIELDS else "id"
    direction = sort_dir if sort_dir in {"asc", "desc"} else "desc"
    order_map = {
        "id": Episode.id,
        "index": Episode.index,
        "play_count": play_count_col,
        "unique_learners": unique_learners_col,
        "completions": completions_col,
        "completion_rate": completion_rate_col,
        "plays_7d": plays_7d_col,
        "plays_30d": plays_30d_col,
    }
    order_col = order_map[sort_key]
    if direction == "asc":
        q = q.order_by(order_col.asc(), Episode.id.desc())
    else:
        q = q.order_by(order_col.desc(), Episode.id.desc())

    return q


def row_stats_from_query(row) -> dict:
    _, play_count, unique_learners, completions, completion_rate, plays_7d, plays_30d = row
    return {
        "play_count": int(play_count or 0),
        "unique_learners": int(unique_learners or 0),
        "completions": int(completions or 0),
        "completion_rate": round(float(completion_rate or 0), 1),
        "plays_7d": int(plays_7d or 0),
        "plays_30d": int(plays_30d or 0),
    }
