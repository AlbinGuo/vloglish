from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import ActivationCode, User
from ...schemas import (
    AdminUserGeoStatsOut,
    AdminUserListItemOut,
    AdminUserListOut,
    AdminUserOut,
    AdminUserPageDwellOut,
    AdminUserSegmentOut,
    AdminUserSegmentsOut,
    AdminUserUpdateIn,
    AdminVisitHourlyStatsOut,
)
from ...services.daily_visits import visit_hourly_stats, visit_stats_for_users
from ...services.page_dwell import top_pages_for_users, user_page_dwell_top
from ...services.presence import is_user_online
from ...services.user_geo import user_geo_stats
from ...services.user_segments import (
    VALID_SEGMENTS,
    admin_user_list_query,
    row_stats_from_user_query,
    segment_counts,
)

router = APIRouter(prefix="/api/admin/users", tags=["admin-users"])


def _fmt_dt(value: datetime | None) -> str | None:
    if not value:
        return None
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _user_item(
    user: User,
    stats: dict,
    *,
    activation_code: str | None = None,
    top_pages: list | None = None,
) -> AdminUserListItemOut:
    last_active = stats.get("last_active_at")
    return AdminUserListItemOut(
        id=user.id,
        email=user.email,
        nickname=user.nickname,
        phone=user.phone,
        is_member=user.is_member,
        is_active=user.is_active,
        is_staff=user.is_staff,
        is_online=is_user_online(user),
        last_client=(user.last_client or None),
        wx_bound=bool((user.wx_openid or "").strip()),
        member_activated_at=_fmt_dt(user.member_activated_at),
        activation_code=activation_code if user.is_member else None,
        created_at=_fmt_dt(user.created_at) or "",
        last_active_at=_fmt_dt(last_active if isinstance(last_active, datetime) else None),
        watch_time_7d=stats["watch_time_7d"],
        visit_days_7d=int(stats.get("visit_days_7d") or 0),
        visit_days_30d=int(stats.get("visit_days_30d") or 0),
        visit_sessions_today=int(stats.get("visit_sessions_today") or 0),
        visit_sessions_7d=int(stats.get("visit_sessions_7d") or 0),
        visit_sessions_30d=int(stats.get("visit_sessions_30d") or 0),
        completed_episodes=stats["completed_episodes"],
        lookup_count=stats["lookup_count"],
        signup_country=user.signup_country,
        signup_region=user.signup_region,
        signup_city=user.signup_city,
        top_pages=top_pages or [],
    )


def _activation_codes_by_user(db: Session, user_ids: list[int]) -> dict[int, str]:
    if not user_ids:
        return {}
    rows = (
        db.query(ActivationCode)
        .filter(ActivationCode.used_by_user_id.in_(user_ids))
        .order_by(ActivationCode.used_at.desc().nullslast(), ActivationCode.id.desc())
        .all()
    )
    out: dict[int, str] = {}
    for row in rows:
        if row.used_by_user_id is None or row.used_by_user_id in out:
            continue
        out[row.used_by_user_id] = row.code
    return out


@router.get("/geo-stats/", response_model=AdminUserGeoStatsOut)
def get_user_geo_stats(
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    return AdminUserGeoStatsOut(**user_geo_stats(db))


@router.get("/visit-hourly/", response_model=AdminVisitHourlyStatsOut)
def get_visit_hourly_stats(
    days: int = Query(7, ge=1, le=90),
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    """近 N 天到访时段分布（东八区小时，按会话开始时间）。"""
    return AdminVisitHourlyStatsOut(**visit_hourly_stats(db, days=days))


@router.get("/segments/", response_model=AdminUserSegmentsOut)
def list_user_segments(
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    return AdminUserSegmentsOut(
        segments=[AdminUserSegmentOut(**item) for item in segment_counts(db)]
    )


@router.get("/", response_model=AdminUserListOut)
def list_users(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    search: str | None = None,
    segment: str | None = Query(None),
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    if segment and segment not in VALID_SEGMENTS:
        raise HTTPException(status_code=400, detail="无效的分群")

    q = admin_user_list_query(db, search=search, segment=segment)
    total = q.count()
    rows = q.offset((page - 1) * page_size).limit(page_size).all()
    user_ids = [row[0].id for row in rows]
    code_map = _activation_codes_by_user(db, user_ids)
    visit_map = visit_stats_for_users(db, user_ids)
    page_map = top_pages_for_users(db, user_ids, days=30, limit=3)
    results = []
    for row in rows:
        user = row[0]
        stats = row_stats_from_user_query(row)
        stats.update(
            visit_map.get(
                user.id,
                {
                    "visit_days_7d": 0,
                    "visit_days_30d": 0,
                    "visit_sessions_7d": 0,
                    "visit_sessions_30d": 0,
                    "visit_sessions_today": 0,
                },
            )
        )
        results.append(
            _user_item(
                user,
                stats,
                activation_code=code_map.get(user.id),
                top_pages=page_map.get(user.id, []),
            )
        )
    return AdminUserListOut(count=total, results=results)


@router.get("/{user_id}/page-dwell/", response_model=AdminUserPageDwellOut)
def get_user_page_dwell(
    user_id: int,
    days: int = Query(30, ge=1, le=90),
    limit: int = Query(5, ge=1, le=20),
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    return AdminUserPageDwellOut(**user_page_dwell_top(db, user_id, days=days, limit=limit))


@router.get("/{user_id}/", response_model=AdminUserOut)
def get_user(
    user_id: int,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    return AdminUserOut(
        id=user.id,
        email=user.email,
        nickname=user.nickname,
        phone=user.phone,
        is_member=user.is_member,
        is_staff=user.is_staff,
    )


@router.patch("/{user_id}/", response_model=AdminUserOut)
def update_user(
    user_id: int,
    body: AdminUserUpdateIn,
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    if user.id == admin.id and body.is_active is False:
        raise HTTPException(status_code=400, detail="不能停用当前登录的管理员")

    if body.is_member is not None:
        user.is_member = body.is_member
        if body.is_member and not user.member_activated_at:
            user.member_activated_at = datetime.utcnow()
        if not body.is_member:
            user.member_activated_at = None
    if body.is_active is not None:
        user.is_active = body.is_active
    if body.nickname is not None:
        user.nickname = body.nickname or None
    if body.phone is not None:
        user.phone = body.phone or None

    db.commit()
    db.refresh(user)
    return AdminUserOut(
        id=user.id,
        email=user.email,
        nickname=user.nickname,
        phone=user.phone,
        is_member=user.is_member,
        is_staff=user.is_staff,
    )
