from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import User
from ...schemas import AdminLearningStatsOut
from ...services.learning import admin_learning_stats

router = APIRouter(prefix="/api/admin/learning", tags=["admin-learning"])


@router.get("/stats/", response_model=AdminLearningStatsOut)
def get_learning_stats(_admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    return AdminLearningStatsOut(**admin_learning_stats(db))
