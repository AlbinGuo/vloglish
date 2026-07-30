from datetime import datetime
from decimal import Decimal

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import ActivationCode, MembershipOrder, User
from ...schemas import AdminMembershipOrderListOut, AdminMembershipOrderOut

router = APIRouter(prefix="/api/admin/membership-orders", tags=["admin-membership-orders"])


def _fmt_dt(value: datetime | None) -> str | None:
    if not value:
        return None
    return value.strftime("%Y-%m-%d %H:%M:%S")


@router.get("/", response_model=AdminMembershipOrderListOut)
def list_membership_orders(
    status: str = Query("all", pattern="^(all|pending|paid|closed|refunded)$"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    q = db.query(MembershipOrder, ActivationCode.code).outerjoin(
        ActivationCode, ActivationCode.id == MembershipOrder.activation_code_id
    )
    if status != "all":
        q = q.filter(MembershipOrder.status == status)
    q = q.order_by(MembershipOrder.id.desc())
    total = q.count()
    rows = q.offset((page - 1) * page_size).limit(page_size).all()
    results = []
    for order, code in rows:
        yuan = (Decimal(order.amount_cent) / Decimal(100)).quantize(Decimal("0.01"))
        results.append(
            AdminMembershipOrderOut(
                id=order.id,
                order_no=order.order_no,
                email=order.email,
                amount_yuan=f"{yuan:.2f}",
                amount_cent=order.amount_cent,
                status=order.status,
                channel=order.channel,
                alipay_trade_no=order.alipay_trade_no or "",
                activation_code=code,
                paid_at=_fmt_dt(order.paid_at),
                created_at=_fmt_dt(order.created_at) or "",
            )
        )
    return AdminMembershipOrderListOut(count=total, results=results)
