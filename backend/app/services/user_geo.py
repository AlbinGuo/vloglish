from sqlalchemy.orm import Session

from ..models import User
from .geo_ip import resolve_ip


def apply_signup_geo(user: User, ip: str | None) -> None:
    geo = resolve_ip(ip)
    user.signup_country = geo.country
    user.signup_region = geo.region
    user.signup_city = geo.city


def backfill_signup_geo(user: User, ip: str | None) -> None:
    if user.signup_country or user.signup_region or user.signup_city:
        return
    apply_signup_geo(user, ip)


def _region_label(user: User) -> str:
    if user.signup_region:
        return user.signup_region
    if user.signup_country:
        return user.signup_country
    return "未知"


def user_geo_stats(db: Session) -> dict:
    rows = (
        db.query(User)
        .filter(User.is_staff.is_(False))
        .with_entities(User.signup_country, User.signup_region, User.signup_city)
        .all()
    )
    total_users = len(rows)
    counts: dict[str, int] = {}
    known_users = 0
    for country, region, city in rows:
        if region or country:
            known_users += 1
        label = region or country or "未知"
        counts[label] = counts.get(label, 0) + 1

    by_region = sorted(counts.items(), key=lambda item: (-item[1], item[0]))
    return {
        "total_users": total_users,
        "known_users": known_users,
        "unknown_users": total_users - known_users,
        "by_region": [{"region": name, "count": count} for name, count in by_region[:20]],
    }
