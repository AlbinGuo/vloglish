from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import PlainTextResponse
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user
from ..models import MembershipOrder, User
from ..routers.auth import user_out
from ..schemas import UserOut
from ..services import wx_virtual_pay as xpay

router = APIRouter(prefix="/api/wxpay", tags=["wxpay"])


class WxPayCreateIn(BaseModel):
    plan: str = Field(pattern="^(quarter|year|forever)$")
    code: str = Field(min_length=4, max_length=128)


class WxPayCreateOut(BaseModel):
    out_trade_no: str
    plan: str
    plan_name: str
    amount_cent: int
    mode: str
    sign_data: str
    pay_sig: str
    signature: str


class WxPayOrderOut(BaseModel):
    out_trade_no: str
    status: str
    plan: str
    amount_cent: int
    paid: bool
    user: UserOut | None = None


@router.post("/orders/", response_model=WxPayCreateOut)
def create_wx_order(
    body: WxPayCreateIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    data = xpay.create_pay_order(db, user=user, plan=body.plan, login_code=body.code)
    return WxPayCreateOut(**data)


@router.get("/orders/{out_trade_no}/", response_model=WxPayOrderOut)
def get_wx_order(
    out_trade_no: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    order = db.query(MembershipOrder).filter(MembershipOrder.order_no == out_trade_no).first()
    if not order or (order.user_id and order.user_id != user.id and not user.is_staff):
        raise HTTPException(status_code=404, detail="订单不存在")
    return WxPayOrderOut(
        out_trade_no=order.order_no,
        status=order.status,
        plan=order.plan or "",
        amount_cent=order.amount_cent,
        paid=order.status == "paid",
        user=user_out(user) if order.status == "paid" else None,
    )


@router.post("/orders/{out_trade_no}/query/", response_model=WxPayOrderOut)
def query_wx_order(
    out_trade_no: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    order = db.query(MembershipOrder).filter(MembershipOrder.order_no == out_trade_no).first()
    if not order or (order.user_id and order.user_id != user.id and not user.is_staff):
        raise HTTPException(status_code=404, detail="订单不存在")
    if order.status != "paid":
        try:
            order = xpay.sync_order_from_wechat(db, order)
        except HTTPException:
            raise
        except Exception as exc:
            raise HTTPException(status_code=502, detail=str(exc) or "查单失败") from exc
    fresh = db.query(User).filter(User.id == user.id).first() or user
    return WxPayOrderOut(
        out_trade_no=order.order_no,
        status=order.status,
        plan=order.plan or "",
        amount_cent=order.amount_cent,
        paid=order.status == "paid",
        user=user_out(fresh) if order.status == "paid" else None,
    )


@router.post("/deliver/")
async def wx_deliver(request: Request, db: Session = Depends(get_db)):
    raw = (await request.body()).decode("utf-8", errors="replace")
    xml = xpay.handle_deliver_notify(db, raw, request.headers.get("content-type") or "")
    return PlainTextResponse(xml, media_type="application/xml")
