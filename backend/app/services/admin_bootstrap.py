import os
from datetime import datetime

from sqlalchemy.orm import Session

from sqlalchemy import or_

from ..models import ActivationCode, Episode, User


def ensure_admin_user(db: Session) -> None:
    from ..auth_utils import hash_password

    email = os.getenv("ADMIN_EMAIL", "admin@vloglish.com").strip().lower()
    password = os.getenv("ADMIN_PASSWORD", "admin123456")
    if not email or not password:
        return

    user = db.query(User).filter(User.email == email).first()
    if user:
        user.is_staff = True
        user.is_active = True
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
    return {
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
    }
