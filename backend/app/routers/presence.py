from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user
from ..models import User
from ..services.presence import touch_presence

router = APIRouter(prefix="/api/presence", tags=["presence"])


@router.post("/heartbeat/")
def heartbeat(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    touch_presence(db, user)
    return {"ok": True}
