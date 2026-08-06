from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user
from ..models import User
from ..services.presence import touch_presence

router = APIRouter(prefix="/api/presence", tags=["presence"])


class HeartbeatIn(BaseModel):
    page_key: str | None = Field(default=None, max_length=64)


@router.post("/heartbeat/")
def heartbeat(
    body: HeartbeatIn | None = None,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    page_key = body.page_key if body else None
    touch_presence(db, user, page_key=page_key)
    return {"ok": True}
