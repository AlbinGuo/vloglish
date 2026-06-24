from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import User
from ...schemas import AdminDashboardOut
from ...services.admin_bootstrap import dashboard_stats

router = APIRouter(prefix="/api/admin", tags=["admin-dashboard"])


@router.get("/dashboard/", response_model=AdminDashboardOut)
def get_dashboard(_admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    return dashboard_stats(db)
