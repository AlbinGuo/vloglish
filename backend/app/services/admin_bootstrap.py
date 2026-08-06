import os
from datetime import datetime, timedelta

from sqlalchemy import func, or_
from sqlalchemy.orm import Session

from ..models import ActivationCode, AiUsageEvent, Episode, User, UserEpisodeProgress, UserWordLookup
from .daily_visits import visit_date_now
from .ops_metrics import ops_health_block
from .presence import online_presence_breakdown


def ensure_admin_user(db: Session) -> None:
    from ..auth_utils import hash_password, verify_password

    email = os.getenv("ADMIN_EMAIL", "admin@vloglish.com").strip().lower()
    password = os.getenv("ADMIN_PASSWORD", "admin123456")
    if not email or not password:
        return

    user = db.query(User).filter(User.email == email).first()
    if user:
        user.is_staff = True
        user.is_active = True
        # 与环境变量密码对齐，避免库中旧哈希导致默认账号登不上
        if not verify_password(password, user.password_hash):
            user.password_hash = hash_password(password)
    else:
        db.add(
            User(
                email=email,
                password_hash=hash_password(password),
                is_staff=True,
                is_active=True,
            )
        )
    db.commit()


def dashboard_stats(db: Session) -> dict:
    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    total_codes = db.query(ActivationCode).count()
    used_codes = db.query(ActivationCode).filter(ActivationCode.used_by_user_id.isnot(None)).count()
    missing_media = (
        db.query(Episode)
        .filter(
            or_(
                Episode.video_url == "",
                Episode.audio_url == "",
                Episode.cover == "",
            )
        )
        .count()
    )
    stats = {
        "users_total": db.query(User).count(),
        "users_today": db.query(User).filter(User.created_at >= today_start).count(),
        "members_total": db.query(User).filter(User.is_member.is_(True)).count(),
        "episodes_total": db.query(Episode).count(),
        "episodes_published": db.query(Episode).filter(Episode.status == "published").count(),
        "episodes_draft": db.query(Episode).filter(Episode.status == "draft").count(),
        "episodes_missing_media": missing_media,
        "activation_codes_total": total_codes,
        "activation_codes_available": total_codes - used_codes,
        "activation_codes_used": used_codes,
        "learning_active_7d": _active_learners_7d(db),
        "learning_completions_total": db.query(UserEpisodeProgress)
        .filter(UserEpisodeProgress.is_completed.is_(True))
        .count(),
        "learning_lookups_total": db.query(UserWordLookup).count(),
        "ai_calls_today": 0,
        "ai_billed_today": 0,
    }
    try:
        today = visit_date_now()
        stats["ai_calls_today"] = int(
            db.query(func.count(AiUsageEvent.id)).filter(AiUsageEvent.usage_date == today).scalar()
            or 0
        )
        stats["ai_billed_today"] = int(
            db.query(func.count(AiUsageEvent.id))
            .filter(
                AiUsageEvent.usage_date == today,
                AiUsageEvent.billed.is_(True),
                AiUsageEvent.cache_hit.is_(False),
            )
            .scalar()
            or 0
        )
    except Exception:
        pass
    presence = online_presence_breakdown(db)
    stats["online_users_now"] = presence["online_users"]
    stats["online_members_now"] = presence["online_members"]
    stats["online_free_now"] = presence["online_free"]
    stats.update(ops_health_block(db))
    return stats


def _active_learners_7d(db: Session) -> int:
    since = datetime.utcnow() - timedelta(days=7)
    return (
        db.query(UserEpisodeProgress.user_id)
        .filter(UserEpisodeProgress.last_watched_at >= since)
        .distinct()
        .count()
    )
