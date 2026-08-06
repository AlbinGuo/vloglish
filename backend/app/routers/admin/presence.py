from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import User
from ...schemas import AdminPageDwellStatsOut, AdminPresenceOnlineOut
from ...services.page_dwell import site_page_dwell_stats
from ...services.presence import online_presence_breakdown

router = APIRouter(prefix="/api/admin/presence", tags=["admin-presence"])


@router.get("/online/", response_model=AdminPresenceOnlineOut)
def get_online_users(_admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    return AdminPresenceOnlineOut(**online_presence_breakdown(db))


@router.get("/page-dwell/", response_model=AdminPageDwellStatsOut)
def get_page_dwell_stats(
    days: int = Query(7, ge=1, le=90),
    limit: int = Query(10, ge=1, le=50),
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    """全站页面停留 Top（按累计秒数）。"""
    return AdminPageDwellStatsOut(**site_page_dwell_stats(db, days=days, limit=limit))
