from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import User
from ...schemas import AdminPresenceOnlineOut
from ...services.presence import online_presence_breakdown

router = APIRouter(prefix="/api/admin/presence", tags=["admin-presence"])


@router.get("/online/", response_model=AdminPresenceOnlineOut)
def get_online_users(_admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    return AdminPresenceOnlineOut(**online_presence_breakdown(db))
