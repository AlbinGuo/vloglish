from datetime import datetime, timedelta

from sqlalchemy import func
from sqlalchemy.orm import Session

from ..models import (
    Episode,
    LearningSession,
    User,
    UserEpisodeProgress,
    UserSubtitleProgress,
    UserVocabularyItem,
    UserWordLookup,
)


def _fmt_dt(value: datetime | None) -> str:
    if not value:
        return ""
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _day_start(dt: datetime | None = None) -> datetime:
    base = dt or datetime.utcnow()
    return base.replace(hour=0, minute=0, second=0, microsecond=0)


def completion_percent(max_index: int, subtitle_count: int, is_completed: bool) -> float:
    if is_completed:
        return 100.0
    if subtitle_count <= 1:
        return 100.0 if max_index > 0 else 0.0
    return round(min(100.0, max(0.0, max_index / (subtitle_count - 1) * 100)), 1)


def get_or_create_progress(db: Session, user_id: int, episode: Episode) -> UserEpisodeProgress:
    row = (
        db.query(UserEpisodeProgress)
        .filter(UserEpisodeProgress.user_id == user_id, UserEpisodeProgress.episode_id == episode.id)
        .first()
    )
    if row:
        return row
    now = datetime.utcnow()
    row = UserEpisodeProgress(
        user_id=user_id,
        episode_id=episode.id,
        first_opened_at=now,
        last_watched_at=now,
    )
    db.add(row)
    db.flush()
    return row


def progress_to_dict(row: UserEpisodeProgress, episode: Episode) -> dict:
    return {
        "video_id": episode.video_id,
        "last_subtitle_index": row.last_subtitle_index,
        "last_position_sec": row.last_position_sec,
        "max_reached_index": row.max_reached_index,
        "watch_time_sec": row.watch_time_sec,
        "completion_percent": row.completion_percent,
        "is_completed": row.is_completed,
        "last_watched_at": _fmt_dt(row.last_watched_at),
        "completed_at": _fmt_dt(row.completed_at) if row.completed_at else None,
    }


def update_episode_progress(
    db: Session,
    user: User,
    episode: Episode,
    data: dict,
) -> UserEpisodeProgress:
    row = get_or_create_progress(db, user.id, episode)
    now = datetime.utcnow()

    if data.get("last_subtitle_index") is not None:
        row.last_subtitle_index = data["last_subtitle_index"]
    if data.get("last_position_sec") is not None:
        row.last_position_sec = data["last_position_sec"]
    if data.get("max_reached_index") is not None:
        row.max_reached_index = max(row.max_reached_index, data["max_reached_index"])
    if data.get("watch_time_delta_sec"):
        row.watch_time_sec += int(data["watch_time_delta_sec"])

    heard_subtitle_id = data.get("heard_subtitle_id")
    if heard_subtitle_id:
        sub_row = (
            db.query(UserSubtitleProgress)
            .filter(
                UserSubtitleProgress.user_id == user.id,
                UserSubtitleProgress.subtitle_id == heard_subtitle_id,
            )
            .first()
        )
        if sub_row:
            sub_row.heard_count += 1
            sub_row.last_heard_at = now
        else:
            db.add(
                UserSubtitleProgress(
                    user_id=user.id,
                    episode_id=episode.id,
                    subtitle_id=heard_subtitle_id,
                    heard_count=1,
                    last_heard_at=now,
                )
            )

    if data.get("is_completed") and not row.is_completed:
        row.is_completed = True
        row.completed_at = now
        row.completion_percent = 100.0
    else:
        row.completion_percent = completion_percent(
            row.max_reached_index,
            episode.subtitle_count,
            row.is_completed,
        )

    row.last_watched_at = now

    session_id = data.get("session_id")
    if session_id:
        session = (
            db.query(LearningSession)
            .filter(LearningSession.id == session_id, LearningSession.user_id == user.id)
            .first()
        )
        if session:
            if data.get("watch_time_delta_sec"):
                session.watch_time_sec += int(data["watch_time_delta_sec"])
            if data.get("session_lookups_delta"):
                session.lookups_count += int(data["session_lookups_delta"])
            if data.get("session_replays_delta"):
                session.sentences_replayed += int(data["session_replays_delta"])
            if data.get("playback_rate") is not None:
                session.playback_rate_avg = float(data["playback_rate"])
            if data.get("subtitle_mode"):
                session.subtitle_mode = data["subtitle_mode"]
            if data.get("loop_mode"):
                session.loop_mode = data["loop_mode"]

    db.commit()
    db.refresh(row)
    return row


def learned_episode_ids(db: Session, user_id: int) -> set[int]:
    rows = (
        db.query(UserEpisodeProgress.episode_id)
        .filter(UserEpisodeProgress.user_id == user_id, UserEpisodeProgress.is_completed.is_(True))
        .all()
    )
    return {r[0] for r in rows}


def progress_map_for_episodes(db: Session, user_id: int, episode_ids: list[int]) -> dict[int, UserEpisodeProgress]:
    if not episode_ids:
        return {}
    rows = (
        db.query(UserEpisodeProgress)
        .filter(UserEpisodeProgress.user_id == user_id, UserEpisodeProgress.episode_id.in_(episode_ids))
        .all()
    )
    return {r.episode_id: r for r in rows}


def log_word_lookup(
    db: Session,
    user: User,
    *,
    entry_id: int,
    word: str,
    token_type: int,
    context: str,
    episode_id: int | None,
    subtitle_id: int | None,
    video_id: str,
) -> UserWordLookup:
    row = UserWordLookup(
        user_id=user.id,
        entry_id=entry_id,
        word=word.strip(),
        token_type=token_type,
        context=context,
        episode_id=episode_id,
        subtitle_id=subtitle_id,
        video_id=video_id or "",
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return row


def is_entry_saved(db: Session, user_id: int, entry_id: int) -> bool:
    return (
        db.query(UserVocabularyItem)
        .filter(UserVocabularyItem.user_id == user_id, UserVocabularyItem.entry_id == entry_id)
        .first()
        is not None
    )


def save_vocabulary(db: Session, user: User, data: dict) -> UserVocabularyItem:
    row = (
        db.query(UserVocabularyItem)
        .filter(UserVocabularyItem.user_id == user.id, UserVocabularyItem.entry_id == data["entry_id"])
        .first()
    )
    if row:
        return row
    row = UserVocabularyItem(
        user_id=user.id,
        entry_id=data["entry_id"],
        word=data["word"].strip(),
        token_type=data.get("token_type", 1),
        source_episode_id=data.get("episode_id"),
        source_subtitle_id=data.get("subtitle_id"),
        source_video_id=data.get("video_id", ""),
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return row


def remove_vocabulary(db: Session, user_id: int, entry_id: int) -> bool:
    deleted = (
        db.query(UserVocabularyItem)
        .filter(UserVocabularyItem.user_id == user_id, UserVocabularyItem.entry_id == entry_id)
        .delete()
    )
    db.commit()
    return deleted > 0


def start_learning_session(db: Session, user: User, episode: Episode, data: dict) -> LearningSession:
    row = LearningSession(
        user_id=user.id,
        episode_id=episode.id,
        video_id=episode.video_id,
        subtitle_mode=data.get("subtitle_mode", "both"),
        loop_mode=data.get("loop_mode", "off"),
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return row


def end_learning_session(db: Session, user_id: int, session_id: int) -> None:
    row = (
        db.query(LearningSession)
        .filter(LearningSession.id == session_id, LearningSession.user_id == user_id)
        .first()
    )
    if row and not row.ended_at:
        row.ended_at = datetime.utcnow()
        db.commit()


def learning_summary(db: Session, user_id: int) -> dict:
    today = _day_start()
    week_start = today - timedelta(days=6)

    progress_rows = db.query(UserEpisodeProgress).filter(UserEpisodeProgress.user_id == user_id).all()
    completed = sum(1 for r in progress_rows if r.is_completed)
    in_progress = sum(1 for r in progress_rows if not r.is_completed and r.max_reached_index > 0)
    total_watch = sum(r.watch_time_sec for r in progress_rows)
    today_watch = sum(r.watch_time_sec for r in progress_rows if r.last_watched_at >= today)
    today_completed = sum(1 for r in progress_rows if r.completed_at and r.completed_at >= today)

    week_watch = (
        db.query(func.coalesce(func.sum(LearningSession.watch_time_sec), 0))
        .filter(LearningSession.user_id == user_id, LearningSession.started_at >= week_start)
        .scalar()
        or 0
    )

    vocab_count = db.query(UserVocabularyItem).filter(UserVocabularyItem.user_id == user_id).count()
    lookup_count = db.query(UserWordLookup).filter(UserWordLookup.user_id == user_id).count()

    active_days = (
        db.query(func.date(UserEpisodeProgress.last_watched_at))
        .filter(UserEpisodeProgress.user_id == user_id)
        .distinct()
        .all()
    )
    day_set = {str(r[0]) for r in active_days if r[0]}
    streak = 0
    cursor = today.date()
    while str(cursor) in day_set:
        streak += 1
        cursor -= timedelta(days=1)

    return {
        "total_watch_time_sec": int(total_watch),
        "completed_episodes": completed,
        "in_progress_episodes": in_progress,
        "vocabulary_count": vocab_count,
        "lookup_count": lookup_count,
        "learning_days": len(day_set),
        "streak_days": streak,
        "today_watch_time_sec": int(today_watch),
        "today_completed": today_completed,
        "week_watch_time_sec": int(week_watch),
    }


def recent_episodes(db: Session, user_id: int, limit: int = 8) -> list[dict]:
    rows = (
        db.query(UserEpisodeProgress, Episode)
        .join(Episode, Episode.id == UserEpisodeProgress.episode_id)
        .filter(
            UserEpisodeProgress.user_id == user_id,
            UserEpisodeProgress.is_completed.is_(False),
            UserEpisodeProgress.max_reached_index > 0,
        )
        .order_by(UserEpisodeProgress.last_watched_at.desc())
        .limit(limit)
        .all()
    )
    return [
        {
            "video_id": ep.video_id,
            "short_title": ep.short_title,
            "cover": ep.thumbnail_url or ep.cover or "",
            "completion_percent": prog.completion_percent,
            "is_completed": prog.is_completed,
            "last_subtitle_index": prog.last_subtitle_index,
            "last_watched_at": _fmt_dt(prog.last_watched_at),
        }
        for prog, ep in rows
    ]


def learning_calendar(db: Session, user_id: int, days: int = 90) -> list[dict]:
    since = _day_start() - timedelta(days=days - 1)
    rows = (
        db.query(
            func.date(UserEpisodeProgress.last_watched_at).label("day"),
            func.sum(UserEpisodeProgress.watch_time_sec).label("watch_sec"),
            func.count(UserEpisodeProgress.id).label("sessions"),
        )
        .filter(UserEpisodeProgress.user_id == user_id, UserEpisodeProgress.last_watched_at >= since)
        .group_by(func.date(UserEpisodeProgress.last_watched_at))
        .all()
    )
    return [
        {"date": str(r.day), "watch_time_sec": int(r.watch_sec or 0), "sessions": int(r.sessions or 0)}
        for r in rows
    ]


def admin_learning_stats(db: Session) -> dict:
    now = datetime.utcnow()
    week_ago = now - timedelta(days=7)
    month_ago = now - timedelta(days=30)

    active_7d = (
        db.query(UserEpisodeProgress.user_id)
        .filter(UserEpisodeProgress.last_watched_at >= week_ago)
        .distinct()
        .count()
    )
    active_30d = (
        db.query(UserEpisodeProgress.user_id)
        .filter(UserEpisodeProgress.last_watched_at >= month_ago)
        .distinct()
        .count()
    )
    total_watch = db.query(func.coalesce(func.sum(UserEpisodeProgress.watch_time_sec), 0)).scalar() or 0
    total_completions = (
        db.query(UserEpisodeProgress).filter(UserEpisodeProgress.is_completed.is_(True)).count()
    )
    total_lookups = db.query(UserWordLookup).count()
    total_vocab = db.query(UserVocabularyItem).count()

    top_eps = (
        db.query(Episode.short_title, Episode.video_id, func.count(UserEpisodeProgress.id).label("cnt"))
        .join(UserEpisodeProgress, UserEpisodeProgress.episode_id == Episode.id)
        .filter(UserEpisodeProgress.is_completed.is_(True))
        .group_by(Episode.id)
        .order_by(func.count(UserEpisodeProgress.id).desc())
        .limit(10)
        .all()
    )

    daily = (
        db.query(
            func.date(UserEpisodeProgress.last_watched_at).label("day"),
            func.count(func.distinct(UserEpisodeProgress.user_id)).label("users"),
            func.sum(UserEpisodeProgress.watch_time_sec).label("watch_sec"),
        )
        .filter(UserEpisodeProgress.last_watched_at >= month_ago)
        .group_by(func.date(UserEpisodeProgress.last_watched_at))
        .order_by(func.date(UserEpisodeProgress.last_watched_at))
        .all()
    )

    return {
        "active_learners_7d": active_7d,
        "active_learners_30d": active_30d,
        "total_watch_hours": round(float(total_watch) / 3600, 1),
        "total_completions": total_completions,
        "total_lookups": total_lookups,
        "total_vocabulary_items": total_vocab,
        "top_episodes": [
            {"short_title": t[0], "video_id": t[1], "completions": int(t[2])} for t in top_eps
        ],
        "daily_activity": [
            {"date": str(r.day), "active_users": int(r.users or 0), "watch_time_sec": int(r.watch_sec or 0)}
            for r in daily
        ],
    }
