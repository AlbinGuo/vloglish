from datetime import datetime
from decimal import Decimal

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import ActivationCode, MembershipOrder, PcPaySession, User
from ...schemas import AdminMembershipOrderListOut, AdminMembershipOrderOut
from ...services.account_merge import is_wechat_only, is_wechat_placeholder_email

router = APIRouter(prefix="/api/admin/membership-orders", tags=["admin-membership-orders"])


def _fmt_dt(value: datetime | None) -> str | None:
    if not value:
        return None
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _email_display(order: MembershipOrder, user: User | None) -> str:
    if user and is_wechat_only(user):
        nick = (user.nickname or "").strip()
        return f"微信用户 · {nick}" if nick else "微信用户"
    if is_wechat_placeholder_email(order.email):
        return "微信用户"
    return order.email or "—"


@router.get("/", response_model=AdminMembershipOrderListOut)
def list_membership_orders(
    status: str = Query("all", pattern="^(all|pending|paid|closed|refunded)$"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    q = (
        db.query(MembershipOrder, ActivationCode.code, User)
        .outerjoin(ActivationCode, ActivationCode.id == MembershipOrder.activation_code_id)
        .outerjoin(User, User.id == MembershipOrder.user_id)
    )
    if status != "all":
        q = q.filter(MembershipOrder.status == status)
    q = q.order_by(MembershipOrder.id.desc())
    total = q.count()
    rows = q.offset((page - 1) * page_size).limit(page_size).all()
    order_nos = [order.order_no for order, _code, _user in rows if order.order_no]
    pc_nos: set[str] = set()
    if order_nos:
        pc_nos = {
            row[0]
            for row in db.query(PcPaySession.order_no).filter(PcPaySession.order_no.in_(order_nos)).all()
            if row[0]
        }
    results = []
    for order, code, user in rows:
        yuan = (Decimal(order.amount_cent) / Decimal(100)).quantize(Decimal("0.01"))
        results.append(
            AdminMembershipOrderOut(
                id=order.id,
                order_no=order.order_no,
                email=order.email,
                email_display=_email_display(order, user),
                wechat_only=bool(user and is_wechat_only(user))
                or is_wechat_placeholder_email(order.email),
                nickname=(user.nickname if user else None),
                amount_yuan=f"{yuan:.2f}",
                amount_cent=order.amount_cent,
                status=order.status,
                channel=order.channel or "",
                plan=order.plan or "forever",
                pay_client=order.pay_client or "",
                via_pc=order.order_no in pc_nos,
                alipay_trade_no=order.alipay_trade_no or "",
                wx_order_id=order.wx_order_id or "",
                activation_code=code,
                paid_at=_fmt_dt(order.paid_at),
                created_at=_fmt_dt(order.created_at) or "",
            )
        )
    return AdminMembershipOrderListOut(count=total, results=results)
