from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...schemas import AdminAiUsageStatsOut
from ...services.ai_quota import admin_ai_usage_stats

router = APIRouter(prefix="/api/admin/ai-usage", tags=["admin-ai-usage"])


@router.get("/stats/", response_model=AdminAiUsageStatsOut)
def get_ai_usage_stats(
    days: int = Query(7, ge=1, le=90),
    _admin=Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    return AdminAiUsageStatsOut(**admin_ai_usage_stats(db, days=days))
