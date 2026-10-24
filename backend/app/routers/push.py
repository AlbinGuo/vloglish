from datetime import datetime

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user
from ..models import PushDevice, User
from ..schemas import PushRegisterIn

router = APIRouter(prefix="/api/push", tags=["push"])


@router.post("/register/")
def register_push(
    body: PushRegisterIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    token = (body.token or "").strip()
    if body.error:
        # 客户端获取 token 失败时回传的错误，打到日志便于排查（如缺 entitlement）
        print(f"[push] ❌ 客户端注册失败 (platform={body.platform}, env={body.env}): {body.error}")
        return {"success": False}
    if not token:
        return {"success": False}
    row = db.query(PushDevice).filter(PushDevice.token == token).first()
    if row:
        row.user_id = user.id
        row.platform = body.platform or row.platform
        row.env = body.env or row.env
        row.is_active = True
        row.last_seen_at = datetime.utcnow()
    else:
        db.add(
            PushDevice(
                user_id=user.id,
                token=token,
                platform=body.platform or "",
                env=body.env or "",
            )
        )
    db.commit()
    return {"success": True}


@router.post("/unregister/")
def unregister_push(
    body: PushRegisterIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    token = (body.token or "").strip()
    if token:
        db.query(PushDevice).filter(
            PushDevice.token == token, PushDevice.user_id == user.id
        ).update({PushDevice.is_active: False}, synchronize_session=False)
        db.commit()
    return {"success": True}
