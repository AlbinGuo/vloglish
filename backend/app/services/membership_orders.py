"""Membership order create / pay success / activate current account."""
from __future__ import annotations

import json
import logging
import secrets
from datetime import datetime
from decimal import Decimal

from fastapi import HTTPException
from sqlalchemy.orm import Session

from ..models import ActivationCode, MembershipOrder, User
from .activation_codes import generate_code
from .alipay_pay import build_pay_url, verify_notify
from .membership_config import (
    alipay_mock_enabled,
    backend_public_url,
    frontend_url,
    membership_price_cent,
    membership_price_yuan,
    membership_subject,
)

logger = logging.getLogger(__name__)


def new_order_no() -> str:
    stamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
    return f"VL{stamp}{secrets.token_hex(3).upper()}"


def _fmt_dt(value: datetime | None) -> str | None:
    if not value:
        return None
    return value.strftime("%Y-%m-%d %H:%M:%S")


def create_order(
    db: Session,
    *,
    user: User,
    channel: str = "page",
    notify_base: str = "",
) -> dict:
    if not user or not user.id:
        raise HTTPException(status_code=401, detail="请先登录后再开通会员")
    if user.is_member:
        raise HTTPException(status_code=400, detail="你已是会员，无需重复购买")

    email_norm = (user.email or "").strip().lower()
    if not email_norm or "@" not in email_norm:
        raise HTTPException(status_code=400, detail="账号邮箱无效，请联系客服")

    amount_cent = membership_price_cent()
    amount_yuan = membership_price_yuan()
    order_no = new_order_no()
    while db.query(MembershipOrder.id).filter(MembershipOrder.order_no == order_no).first():
        order_no = new_order_no()

    order = MembershipOrder(
        order_no=order_no,
        user_id=user.id,
        email=email_norm,
        amount_cent=amount_cent,
        currency="CNY",
        status="pending",
        channel="alipay",
    )
    db.add(order)
    db.commit()
    db.refresh(order)

    return_url = f"{frontend_url()}/pricing/result?order={order_no}"
    base = (notify_base or backend_public_url()).rstrip("/")
    if alipay_mock_enabled():
        notify_url = f"{base or 'http://127.0.0.1:8000'}/api/membership/alipay/notify/"
    else:
        if not base:
            raise HTTPException(
                status_code=500,
                detail="未配置 BACKEND_PUBLIC_URL，无法生成支付宝回调地址",
            )
        notify_url = f"{base}/api/membership/alipay/notify/"

    pay_channel = "wap" if channel == "wap" else "page"
    try:
        pay_url = build_pay_url(
            order_no=order_no,
            amount_yuan=amount_yuan,
            subject=membership_subject(),
            return_url=return_url,
            notify_url=notify_url,
            channel=pay_channel,
        )
    except RuntimeError as exc:
        order.status = "closed"
        db.commit()
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    return {
        "order_no": order.order_no,
        "email": order.email,
        "amount_yuan": f"{amount_yuan:.2f}",
        "amount_cent": order.amount_cent,
        "status": order.status,
        "pay_url": pay_url,
        "mock": alipay_mock_enabled(),
        "return_url": return_url,
        "signup_url": None,
        "activation_code": None,
        "email_is_member": False,
        "membership_activated": False,
        "paid_at": None,
        "created_at": _fmt_dt(order.created_at) or "",
    }


def _issue_activation_code(db: Session, order: MembershipOrder) -> ActivationCode:
    if order.activation_code_id:
        row = db.query(ActivationCode).filter(ActivationCode.id == order.activation_code_id).first()
        if row:
            return row

    for _ in range(50):
        code = generate_code()
        exists = db.query(ActivationCode.id).filter(ActivationCode.code == code).first()
        if not exists:
            row = ActivationCode(code=code)
            db.add(row)
            db.flush()
            order.activation_code_id = row.id
            return row
    raise RuntimeError("无法生成唯一激活码")


def _activate_order_user(db: Session, order: MembershipOrder, code: ActivationCode) -> bool:
    """支付成功后开通当前下单账号；激活码记为已使用。返回是否已开通会员。"""
    user: User | None = None
    if order.user_id:
        user = db.query(User).filter(User.id == order.user_id).first()
    if user is None and order.email:
        user = db.query(User).filter(User.email == order.email.strip().lower()).first()
    if user is None:
        return False

    now = datetime.utcnow()
    if not user.is_member:
        user.is_member = True
        user.member_activated_at = now
        user.member_until = None
    if code.used_by_user_id is None:
        code.used_by_user_id = user.id
        code.used_at = now
    return True


def mark_order_paid(
    db: Session,
    order: MembershipOrder,
    *,
    alipay_trade_no: str = "",
    notify_raw: str = "",
) -> MembershipOrder:
    """幂等：已支付则直接返回。"""
    if order.status == "paid":
        if alipay_trade_no and not order.alipay_trade_no:
            order.alipay_trade_no = alipay_trade_no[:64]
            db.commit()
        return order
    if order.status not in {"pending"}:
        raise HTTPException(status_code=400, detail=f"订单状态不可支付：{order.status}")

    code = _issue_activation_code(db, order)
    _activate_order_user(db, order, code)
    order.status = "paid"
    order.paid_at = datetime.utcnow()
    if alipay_trade_no:
        order.alipay_trade_no = alipay_trade_no[:64]
    if notify_raw:
        order.notify_raw = notify_raw[:8000]
    db.commit()
    db.refresh(order)
    return order


def handle_alipay_notify(db: Session, params: dict[str, str]) -> str:
    if not verify_notify(params):
        logger.warning("alipay notify bad signature params=%s", params.get("out_trade_no"))
        return "fail"

    order_no = (params.get("out_trade_no") or "").strip()
    trade_status = (params.get("trade_status") or "").strip()
    trade_no = (params.get("trade_no") or "").strip()
    total_amount = (params.get("total_amount") or "").strip()

    if not order_no:
        return "fail"

    order = db.query(MembershipOrder).filter(MembershipOrder.order_no == order_no).first()
    if not order:
        logger.warning("alipay notify unknown order %s", order_no)
        return "fail"

    if trade_status not in {"TRADE_SUCCESS", "TRADE_FINISHED"}:
        return "success"

    try:
        paid_yuan = Decimal(total_amount)
    except Exception:
        logger.warning("alipay notify bad amount %s", total_amount)
        return "fail"

    expected = (Decimal(order.amount_cent) / Decimal(100)).quantize(Decimal("0.01"))
    if paid_yuan != expected:
        logger.warning(
            "alipay notify amount mismatch order=%s got=%s expect=%s",
            order_no,
            paid_yuan,
            expected,
        )
        return "fail"

    try:
        mark_order_paid(
            db,
            order,
            alipay_trade_no=trade_no,
            notify_raw=json.dumps(params, ensure_ascii=False),
        )
    except Exception:
        logger.exception("alipay notify mark paid failed order=%s", order_no)
        return "fail"
    return "success"


def order_public_out(db: Session, order: MembershipOrder) -> dict:
    code_value = None
    membership_activated = False
    if order.activation_code_id:
        row = db.query(ActivationCode).filter(ActivationCode.id == order.activation_code_id).first()
        if row:
            code_value = row.code
            membership_activated = row.used_by_user_id is not None

    if order.status == "paid" and order.user_id:
        user = db.query(User).filter(User.id == order.user_id).first()
        if user and user.is_member:
            membership_activated = True

    amount_yuan = (Decimal(order.amount_cent) / Decimal(100)).quantize(Decimal("0.01"))
    return {
        "order_no": order.order_no,
        "email": order.email,
        "amount_yuan": f"{amount_yuan:.2f}",
        "amount_cent": order.amount_cent,
        "status": order.status,
        "mock": alipay_mock_enabled(),
        "pay_url": None,
        "return_url": f"{frontend_url()}/pricing/result?order={order.order_no}",
        "signup_url": None,
        "activation_code": code_value if order.status == "paid" else None,
        "email_is_member": membership_activated,
        "membership_activated": membership_activated,
        "paid_at": _fmt_dt(order.paid_at),
        "created_at": _fmt_dt(order.created_at) or "",
    }


def get_order_by_no(db: Session, order_no: str) -> MembershipOrder:
    order = db.query(MembershipOrder).filter(MembershipOrder.order_no == order_no.strip()).first()
    if not order:
        raise HTTPException(status_code=404, detail="订单不存在")
    return order
