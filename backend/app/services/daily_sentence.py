"""每日一句：按东八区日期分配一句跟读，完成即计入连续天数。"""
from __future__ import annotations

import hashlib
import logging
import re
from datetime import date, datetime, timedelta, timezone

from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ..demo_access import can_access_episode
from ..models import Episode, Subtitle, User, UserDailySentence, UserEpisodeProgress, UserVocabularyItem
from .entry_lookup import lookup_result_by_entry_id
from .learning import dedupe_vocabulary_by_word

logger = logging.getLogger(__name__)

CST = timezone(timedelta(hours=8))
_MIN_CHARS = 12
_MAX_CHARS = 90
_MIN_DUR = 1.2
_MAX_DUR = 8.0
_LETTER_RE = re.compile(r"[A-Za-z]")


def cst_today() -> date:
    return datetime.now(CST).date()


def as_cst_date(dt: datetime | None) -> date | None:
    if not dt:
        return None
    current = dt.replace(tzinfo=timezone.utc) if dt.tzinfo is None else dt
    return current.astimezone(CST).date()


def _qualifies(sub: Subtitle) -> bool:
    english = (sub.english or "").strip()
    if len(english) < _MIN_CHARS or len(english) > _MAX_CHARS:
        return False
    if not _LETTER_RE.search(english):
        return False
    dur = float(sub.end or 0) - float(sub.start or 0)
    return _MIN_DUR <= dur <= _MAX_DUR


def _pick_from_subs(subs: list[Subtitle], seed: str) -> Subtitle | None:
    candidates = [s for s in subs if _qualifies(s)]
    if not candidates:
        return None
    digest = hashlib.md5(seed.encode("utf-8")).hexdigest()
    return candidates[int(digest[:8], 16) % len(candidates)]


def _row_to_payload(row: UserDailySentence, *, streak: int) -> dict:
    done = row.completed_at is not None
    return {
        "day": row.day.isoformat(),
        "video_id": row.video_id,
        "subtitle_id": row.subtitle_id,
        "english": row.english,
        "chinese": row.chinese,
        "cover": row.cover,
        "episode_title": row.episode_title,
        "completed": done,
        "path": f"/english/episode/{row.video_id}?subtitle={row.subtitle_id}&shadow=1",
        "streak_days": streak,
    }


def completed_days(db: Session, user_id: int) -> set[str]:
    rows = (
        db.query(UserDailySentence.day)
        .filter(UserDailySentence.user_id == user_id, UserDailySentence.completed_at.isnot(None))
        .all()
    )
    return {str(r[0]) for r in rows if r[0]}


def streak_for_user(db: Session, user_id: int, extra_days: set[str] | None = None) -> int:
    day_set = completed_days(db, user_id)
    if extra_days:
        day_set |= extra_days
    streak = 0
    cursor = cst_today()
    while str(cursor) in day_set:
        streak += 1
        cursor -= timedelta(days=1)
    return streak


def _save_assignment(db: Session, row: UserDailySentence) -> UserDailySentence:
    db.add(row)
    try:
        db.commit()
        db.refresh(row)
        return row
    except IntegrityError:
        db.rollback()
        existing = (
            db.query(UserDailySentence)
            .filter(UserDailySentence.user_id == row.user_id, UserDailySentence.day == row.day)
            .first()
        )
        if existing:
            return existing
        raise


def _assign_from_episode(db: Session, user: User, ep: Episode, seed: str) -> UserDailySentence | None:
    if not can_access_episode(db, ep, user):
        return None
    subs = (
        db.query(Subtitle)
        .filter(Subtitle.episode_id == ep.id)
        .order_by(Subtitle.index.asc(), Subtitle.id.asc())
        .all()
    )
    if not subs:
        return None

    preferred: list[Subtitle] = []
    prog = (
        db.query(UserEpisodeProgress)
        .filter(UserEpisodeProgress.user_id == user.id, UserEpisodeProgress.episode_id == ep.id)
        .first()
    )
    if prog and subs:
        idx = max(0, min(int(prog.max_reached_index or 0), len(subs) - 1))
        for offset in (0, 1, -1, 2):
            pos = idx + offset
            if 0 <= pos < len(subs) and _qualifies(subs[pos]):
                preferred.append(subs[pos])
                break

    chosen = preferred[0] if preferred else _pick_from_subs(subs, seed)
    if not chosen:
        return None

    today = cst_today()
    row = UserDailySentence(
        user_id=user.id,
        day=today,
        video_id=ep.video_id,
        subtitle_id=chosen.id,
        english=(chosen.english or "").strip(),
        chinese=(chosen.chinese or "").strip(),
        cover=ep.thumbnail_url or ep.cover or "",
        episode_title=(ep.short_title or ep.video_id)[:256],
    )
    return _save_assignment(db, row)


def ensure_today_sentence(db: Session, user: User) -> UserDailySentence | None:
    today = cst_today()
    existing = (
        db.query(UserDailySentence)
        .filter(UserDailySentence.user_id == user.id, UserDailySentence.day == today)
        .first()
    )
    if existing:
        return existing

    seed = f"{user.id}:{today.isoformat()}"
    prog = (
        db.query(UserEpisodeProgress, Episode)
        .join(Episode, Episode.id == UserEpisodeProgress.episode_id)
        .filter(
            UserEpisodeProgress.user_id == user.id,
            UserEpisodeProgress.is_completed.is_(False),
            UserEpisodeProgress.max_reached_index > 0,
            Episode.status == "published",
        )
        .order_by(UserEpisodeProgress.last_watched_at.desc())
        .first()
    )
    if prog:
        row = _assign_from_episode(db, user, prog[1], seed)
        if row:
            return row

    episodes = (
        db.query(Episode)
        .filter(Episode.status == "published")
        .order_by(Episode.created_at.desc())
        .limit(60)
        .all()
    )
    pool: list[tuple[Episode, Subtitle]] = []
    for ep in episodes:
        if not can_access_episode(db, ep, user):
            continue
        subs = (
            db.query(Subtitle)
            .filter(Subtitle.episode_id == ep.id)
            .order_by(Subtitle.index.asc())
            .all()
        )
        picked = _pick_from_subs(subs, f"{seed}:{ep.video_id}")
        if picked:
            pool.append((ep, picked))
        if len(pool) >= 12:
            break
    if not pool:
        return None
    digest = hashlib.md5(seed.encode("utf-8")).hexdigest()
    ep, sub = pool[int(digest[:8], 16) % len(pool)]
    row = UserDailySentence(
        user_id=user.id,
        day=today,
        video_id=ep.video_id,
        subtitle_id=sub.id,
        english=(sub.english or "").strip(),
        chinese=(sub.chinese or "").strip(),
        cover=ep.thumbnail_url or ep.cover or "",
        episode_title=(ep.short_title or ep.video_id)[:256],
    )
    return _save_assignment(db, row)


def complete_if_matches(
    db: Session,
    user: User,
    *,
    video_id: str = "",
    subtitle_id: int | None = None,
) -> bool:
    if subtitle_id is None:
        return False
    today = cst_today()
    row = (
        db.query(UserDailySentence)
        .filter(UserDailySentence.user_id == user.id, UserDailySentence.day == today)
        .first()
    )
    vid = (video_id or "").strip()[:32]
    if not row:
        row = _adopt_as_today(db, user, video_id=vid, subtitle_id=subtitle_id)
        return row is not None
    if row.completed_at:
        return True
    if row.subtitle_id != subtitle_id:
        return False
    if vid and row.video_id != vid:
        return False
    row.completed_at = datetime.utcnow()
    db.add(row)
    db.commit()
    return True


def _adopt_as_today(
    db: Session,
    user: User,
    *,
    video_id: str,
    subtitle_id: int,
) -> UserDailySentence | None:
    sub = db.query(Subtitle).filter(Subtitle.id == subtitle_id).first()
    if not sub or not _qualifies(sub):
        return None
    ep = db.query(Episode).filter(Episode.id == sub.episode_id).first()
    if not ep or ep.status != "published":
        return None
    if video_id and ep.video_id != video_id:
        return None
    if not can_access_episode(db, ep, user):
        return None
    row = UserDailySentence(
        user_id=user.id,
        day=cst_today(),
        video_id=ep.video_id,
        subtitle_id=sub.id,
        english=(sub.english or "").strip(),
        chinese=(sub.chinese or "").strip(),
        cover=ep.thumbnail_url or ep.cover or "",
        episode_title=(ep.short_title or ep.video_id)[:256],
        completed_at=datetime.utcnow(),
    )
    saved = _save_assignment(db, row)
    if saved.subtitle_id != subtitle_id:
        return None
    if not saved.completed_at:
        saved.completed_at = datetime.utcnow()
        db.add(saved)
        db.commit()
        db.refresh(saved)
    return saved


def vocab_preview(db: Session, user: User, limit: int = 3) -> list[dict]:
    rows = (
        db.query(UserVocabularyItem)
        .filter(UserVocabularyItem.user_id == user.id)
        .order_by(UserVocabularyItem.created_at.desc())
        .all()
    )
    items = dedupe_vocabulary_by_word(rows)[: max(1, limit)]
    out: list[dict] = []
    for item in items:
        meaning = ""
        try:
            detail = lookup_result_by_entry_id(db, item.entry_id) or {}
            defs = detail.get("definitions") or []
            first = defs[0] if defs else None
            if isinstance(first, dict):
                meaning = (first.get("definition_cn") or first.get("definition") or "").strip()
        except Exception:
            meaning = ""
        out.append(
            {
                "word": item.word,
                "meaning": meaning[:48],
                "path": "/english/vocabulary?review=1",
            }
        )
    return out


def daily_sentence_payload(db: Session, user: User) -> dict | None:
    row = ensure_today_sentence(db, user)
    if not row:
        return None
    extra = completed_days(db, user.id)
    if row.completed_at:
        extra.add(str(row.day))
    return _row_to_payload(row, streak=streak_for_user(db, user.id, extra))
