from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import ActivationCode, User
from ...schemas import (
    AdminActivationCodeListOut,
    AdminActivationCodeOut,
    AdminGenerateCodesIn,
    AdminGenerateCodesOut,
)
from ...services.activation_codes import generate_unique_codes

router = APIRouter(prefix="/api/admin/activation-codes", tags=["admin-activation-codes"])


def _fmt_dt(value: datetime | None) -> str | None:
    if not value:
        return None
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _code_out(code: ActivationCode, email: str | None = None) -> AdminActivationCodeOut:
    return AdminActivationCodeOut(
        id=code.id,
        code=code.code,
        used_by_user_id=code.used_by_user_id,
        used_by_email=email,
        used_at=_fmt_dt(code.used_at),
        created_at=_fmt_dt(code.created_at) or "",
    )


@router.get("/", response_model=AdminActivationCodeListOut)
def list_activation_codes(
    status: str = Query("all", pattern="^(all|available|used)$"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    q = db.query(ActivationCode, User.email).outerjoin(User, User.id == ActivationCode.used_by_user_id)
    if status == "available":
        q = q.filter(ActivationCode.used_by_user_id.is_(None))
    elif status == "used":
        q = q.filter(ActivationCode.used_by_user_id.isnot(None))
    q = q.order_by(ActivationCode.id.desc())
    total = q.count()
    rows = q.offset((page - 1) * page_size).limit(page_size).all()
    return AdminActivationCodeListOut(
        count=total,
        results=[_code_out(code, email) for code, email in rows],
    )


@router.post("/generate/", response_model=AdminGenerateCodesOut)
def generate_codes(
    body: AdminGenerateCodesIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    try:
        codes = generate_unique_codes(db, body.count)
    except RuntimeError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
    return AdminGenerateCodesOut(codes=codes)


@router.delete("/{code}/")
def delete_activation_code(
    code: str,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    row = db.query(ActivationCode).filter(ActivationCode.code == code.strip()).first()
    if not row:
        raise HTTPException(status_code=404, detail="激活码不存在")
    if row.used_by_user_id is not None:
        raise HTTPException(status_code=400, detail="已使用的激活码不能删除")
    db.delete(row)
    db.commit()
    return {"success": True}
