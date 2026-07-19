from collections import defaultdict

from sqlalchemy.orm import Session

from ..models import User
from .geo_ip import resolve_ip
from .geo_normalize import (
    country_for_stats,
    is_china_location,
    resolve_china_province_city,
)


def apply_signup_geo(user: User, ip: str | None) -> None:
    geo = resolve_ip(ip)
    user.signup_country = geo.country
    user.signup_region = geo.region
    user.signup_city = geo.city


def backfill_signup_geo(user: User, ip: str | None) -> None:
    if user.signup_country or user.signup_region or user.signup_city:
        return
    apply_signup_geo(user, ip)


def _sorted_items(counts: dict[str, int], *, limit: int | None = None) -> list[tuple[str, int]]:
    items = sorted(counts.items(), key=lambda item: (-item[1], item[0]))
    if limit is not None:
        return items[:limit]
    return items


def user_geo_stats(db: Session) -> dict:
    rows = (
        db.query(User)
        .filter(User.is_staff.is_(False))
        .with_entities(User.signup_country, User.signup_region, User.signup_city)
        .all()
    )
    total_users = len(rows)
    known_users = 0
    china_users = 0
    overseas_users = 0

    region_counts: dict[str, int] = defaultdict(int)
    country_counts: dict[tuple[str, str], int] = defaultdict(int)
    province_counts: dict[str, int] = defaultdict(int)
    city_counts: dict[tuple[str, str], int] = defaultdict(int)

    for country, region, city in rows:
        has_geo = bool(region or country or city)
        if has_geo:
            known_users += 1

        # 排行榜：优先展示可识别的省，其次原始 region/country
        province, city_name = resolve_china_province_city(country, region, city)
        label = province or region or country or "未知"
        region_counts[label] += 1

        if not has_geo:
            continue

        in_china = is_china_location(country, region, city)
        if in_china:
            china_users += 1
            country_counts[("中国", "China")] += 1
            if province:
                province_counts[province] += 1
                if city_name and city_name not in (province, f"{province}市"):
                    city_counts[(province, city_name)] += 1
        else:
            overseas_users += 1
            mapped = country_for_stats(country, region, city)
            if mapped:
                country_counts[mapped] += 1
            elif country:
                country_counts[(country, country)] += 1

    by_region = [
        {"region": name, "count": count}
        for name, count in _sorted_items(dict(region_counts), limit=20)
    ]
    by_country = [
        {"name": name, "map_name": map_name, "count": count}
        for (name, map_name), count in sorted(
            country_counts.items(), key=lambda item: (-item[1], item[0][0])
        )
    ]
    by_province = [
        {"name": name, "map_name": name, "count": count}
        for name, count in _sorted_items(dict(province_counts))
    ]
    by_city = [
        {"name": city, "province": province, "count": count}
        for (province, city), count in sorted(
            city_counts.items(), key=lambda item: (-item[1], item[0][0], item[0][1])
        )
    ]

    return {
        "total_users": total_users,
        "known_users": known_users,
        "unknown_users": total_users - known_users,
        "china_users": china_users,
        "overseas_users": overseas_users,
        "by_region": by_region,
        "by_country": by_country,
        "by_province": by_province,
        "by_city": by_city,
    }
