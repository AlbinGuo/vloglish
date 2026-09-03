from __future__ import annotations

import secrets
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import PlainTextResponse, Response
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user
from ..models import MembershipOrder, PcPaySession, User
from ..routers.auth import user_out
from ..schemas import UserOut
from ..services import wechat_mini as wechat_mini_svc
from ..services import wx_virtual_pay as xpay

router = APIRouter(prefix="/api/wxpay", tags=["wxpay"])

PC_PAY_TTL_MINUTES = 15


class WxPayCreateIn(BaseModel):
    plan: str
    code: str = Field(min_length=4, max_length=128)
    pc_token: str = ""


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


class PcPayCreateIn(BaseModel):
    plan: str


class PcPayCreateOut(BaseModel):
    token: str
    plan: str
    plan_name: str
    amount_cent: int
    expires_in: int


class PcPayStatusOut(BaseModel):
    status: str
    plan: str
    plan_name: str
    amount_cent: int
    paid: bool
    user: UserOut | None = None


def _plan_public(plan: str) -> tuple[str, int]:
    meta = xpay.PLANS.get(plan)
    if not meta:
        raise HTTPException(status_code=400, detail="无效套餐")
    return str(meta["name"]), int(meta["price_cent"])


def _refresh_pc_session(db: Session, sess: PcPaySession) -> PcPaySession:
    if sess.status == "paid":
        return sess
    if sess.order_no:
        order = db.query(MembershipOrder).filter(MembershipOrder.order_no == sess.order_no).first()
        if order and order.status == "paid":
            sess.status = "paid"
            sess.paid_at = order.paid_at or datetime.utcnow()
            db.commit()
            db.refresh(sess)
    if sess.status != "paid" and sess.expires_at <= datetime.utcnow():
        sess.status = "expired"
        db.commit()
        db.refresh(sess)
    return sess


@router.post("/orders/", response_model=WxPayCreateOut)
def create_wx_order(
    body: WxPayCreateIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    data = xpay.create_pay_order(
        db, user=user, plan=body.plan, login_code=body.code, pc_token=body.pc_token
    )
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


@router.post("/pc-sessions/", response_model=PcPayCreateOut)
def create_pc_session(
    body: PcPayCreateIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    if not (user.wx_openid or "").strip():
        raise HTTPException(status_code=400, detail="请先关联小程序，再用微信扫码支付")
    from ..demo_access import user_is_member

    if user_is_member(user) and user.member_until is None:
        raise HTTPException(status_code=400, detail="你已是永久会员，无需重复购买")
    if body.plan not in xpay.PLANS:
        raise HTTPException(status_code=400, detail="无效套餐")
    db.query(PcPaySession).filter(
        PcPaySession.user_id == user.id,
        PcPaySession.status == "pending",
    ).delete(synchronize_session=False)
    token = secrets.token_hex(8)
    name, amount = _plan_public(body.plan)
    row = PcPaySession(
        token=token,
        user_id=user.id,
        plan=body.plan,
        status="pending",
        expires_at=datetime.utcnow() + timedelta(minutes=PC_PAY_TTL_MINUTES),
    )
    db.add(row)
    db.commit()
    return PcPayCreateOut(
        token=token,
        plan=body.plan,
        plan_name=name,
        amount_cent=amount,
        expires_in=PC_PAY_TTL_MINUTES * 60,
    )


@router.get("/pc-sessions/{token}/", response_model=PcPayStatusOut)
def get_pc_session(
    token: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    sess = db.query(PcPaySession).filter(PcPaySession.token == (token or "").strip()).first()
    if not sess or (sess.user_id != user.id and not user.is_staff):
        raise HTTPException(status_code=404, detail="支付会话不存在")
    sess = _refresh_pc_session(db, sess)
    name, amount = _plan_public(sess.plan)
    owner = db.query(User).filter(User.id == sess.user_id).first() or user
    return PcPayStatusOut(
        status=sess.status,
        plan=sess.plan,
        plan_name=name,
        amount_cent=amount,
        paid=sess.status == "paid",
        user=user_out(owner) if sess.status == "paid" else None,
    )


@router.get("/pc-sessions/{token}/qrcode/")
def pc_session_qrcode(
    token: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    sess = db.query(PcPaySession).filter(PcPaySession.token == (token or "").strip()).first()
    if not sess or sess.user_id != user.id:
        raise HTTPException(status_code=404, detail="支付会话不存在")
    if sess.expires_at <= datetime.utcnow() and sess.status != "paid":
        raise HTTPException(status_code=400, detail="支付码已过期")
    try:
        png = wechat_mini_svc.get_wxacode(sess.token, "pages/pc-pay/pc-pay")
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    return Response(content=png, media_type="image/png")


@router.post("/deliver/")
async def wx_deliver(request: Request, db: Session = Depends(get_db)):
    raw = (await request.body()).decode("utf-8", errors="replace")
    xml = xpay.handle_deliver_notify(db, raw, request.headers.get("content-type") or "")
    return PlainTextResponse(xml, media_type="application/xml")
