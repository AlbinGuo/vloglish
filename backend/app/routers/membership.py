"""Public membership purchase APIs (Alipay)."""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import PlainTextResponse
from sqlalchemy.orm import Session

from ..database import get_db
from ..schemas import MembershipOrderCreateIn, MembershipOrderOut, MembershipPricingOut
from ..services.membership_config import (
    alipay_mock_enabled,
    backend_public_url,
    membership_price_cent,
    membership_price_yuan,
    membership_subject,
)
from ..services.membership_orders import (
    create_order,
    get_order_by_no,
    handle_alipay_notify,
    mark_order_paid,
    order_public_out,
)

router = APIRouter(prefix="/api/membership", tags=["membership"])


@router.get("/pricing/", response_model=MembershipPricingOut)
def get_pricing():
    yuan = membership_price_yuan()
    return MembershipPricingOut(
        subject=membership_subject(),
        amount_yuan=f"{yuan:.2f}",
        amount_cent=membership_price_cent(),
        mock=alipay_mock_enabled(),
    )


@router.post("/orders/", response_model=MembershipOrderOut)
def create_membership_order(
    body: MembershipOrderCreateIn,
    request: Request,
    db: Session = Depends(get_db),
):
    notify_base = backend_public_url() or str(request.base_url).rstrip("/")
    data = create_order(
        db,
        email=str(body.email),
        channel=body.channel,
        notify_base=notify_base,
    )
    return MembershipOrderOut(**data)


@router.get("/orders/{order_no}/", response_model=MembershipOrderOut)
def get_membership_order(order_no: str, db: Session = Depends(get_db)):
    order = get_order_by_no(db, order_no)
    return MembershipOrderOut(**order_public_out(db, order))


@router.post("/orders/{order_no}/mock-pay/", response_model=MembershipOrderOut)
def mock_pay_order(order_no: str, db: Session = Depends(get_db)):
    if not alipay_mock_enabled():
        raise HTTPException(status_code=403, detail="未开启模拟支付")
    order = get_order_by_no(db, order_no)
    if order.status == "paid":
        return MembershipOrderOut(**order_public_out(db, order))
    mark_order_paid(db, order, alipay_trade_no="MOCK", notify_raw='{"mock":true}')
    return MembershipOrderOut(**order_public_out(db, order))


@router.post("/alipay/notify/")
async def alipay_notify(request: Request, db: Session = Depends(get_db)):
    form = await request.form()
    params = {str(k): str(v) for k, v in form.items()}
    result = handle_alipay_notify(db, params)
    return PlainTextResponse(result)
