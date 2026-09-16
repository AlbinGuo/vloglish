"""Membership order create / pay success / activate current account."""
from __future__ import annotations

import json
import logging
import secrets
from datetime import datetime
from decimal import Decimal

from fastapi import HTTPException
from sqlalchemy.orm import Session

from ..models import ActivationCode, AlipayNotifyEvent, AlipayRefund, MembershipOrder, User
from .activation_codes import generate_code
from .alipay_pay import (
    amount_equals,
    build_page_pay_form,
    close_trade,
    is_paid_trade_notification,
    notify_app_matches,
    query_refund,
    query_trade,
    refund_trade,
    seller_matches,
    verify_notify,
    yuan_from_cent,
)
from .membership_config import (
    alipay_mock_enabled,
    frontend_url,
    membership_price_cent,
    membership_price_yuan,
    membership_subject,
    public_https_base,
)

logger = logging.getLogger(__name__)


def new_order_no() -> str:
    stamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
    return f"VL{stamp}{secrets.token_hex(3).upper()}"


def _fmt_dt(value: datetime | None) -> str | None:
    if not value:
        return None
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _api_base(notify_base: str) -> str:
    return (notify_base or "").rstrip("/")


def return_url_for(api_base: str, order_no: str = "") -> str:
    url = f"{_api_base(api_base)}/api/membership/alipay/return/"
    if order_no:
        return f"{url}?out_trade_no={order_no}"
    return url


def pay_page_url_for(api_base: str, order_no: str) -> str:
    return f"{_api_base(api_base)}/api/membership/orders/{order_no}/pay/"


def notify_url_for(api_base: str) -> str:
    public = public_https_base()
    if public:
        return f"{public}/api/membership/alipay/notify/"
    # 本地无公网 HTTPS 时省略 notify_url，不传空字符串或占位地址
    del api_base
    return ""


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
        plan="forever",
        pay_client="web",
    )
    db.add(order)
    db.commit()
    db.refresh(order)

    api_base = _api_base(notify_base)
    if not api_base:
        raise HTTPException(status_code=500, detail="无法确定本机 API 地址")
    return_url = return_url_for(api_base, order_no)
    notify_url = notify_url_for(api_base)
    pay_url = pay_page_url_for(api_base, order_no)
    del channel

    try:
        pay_form = build_page_pay_form(
            order_no=order_no,
            amount_yuan=amount_yuan,
            subject=membership_subject(),
            return_url=return_url,
            notify_url=notify_url,
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
        "pay_form": pay_form,
        "mock": alipay_mock_enabled(),
        "return_url": return_url,
        "signup_url": None,
        "activation_code": None,
        "email_is_member": False,
        "membership_activated": False,
        "paid_at": None,
        "created_at": _fmt_dt(order.created_at) or "",
    }


def build_order_pay_form(order: MembershipOrder, api_base: str) -> str:
    return build_page_pay_form(
        order_no=order.order_no,
        amount_yuan=yuan_from_cent(order.amount_cent),
        subject=membership_subject(),
        return_url=return_url_for(api_base, order.order_no),
        notify_url=notify_url_for(api_base),
    )


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
        from .membership import apply_membership

        apply_membership(user, None, plan="forever")
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


def _insert_notify_once(db: Session, params: dict[str, str]) -> bool:
    notify_id = (params.get("notify_id") or "").strip()
    if not notify_id:
        notify_id = f"{params.get('out_trade_no')}|{params.get('trade_no')}|{params.get('trade_status')}"
    exists = db.query(AlipayNotifyEvent.id).filter(AlipayNotifyEvent.notify_id == notify_id).first()
    if exists:
        return False
    db.add(
        AlipayNotifyEvent(
            notify_id=notify_id[:128],
            out_trade_no=(params.get("out_trade_no") or "")[:64],
            trade_no=(params.get("trade_no") or "")[:64],
            trade_status=(params.get("trade_status") or "")[:32],
        )
    )
    db.flush()
    return True


def handle_alipay_notify(db: Session, params: dict[str, str]) -> str:
    if not verify_notify(params):
        logger.warning("alipay notify bad signature params=%s", params.get("out_trade_no"))
        return "fail"
    if not notify_app_matches(params) or not seller_matches(params):
        logger.warning("alipay notify app/seller mismatch order=%s", params.get("out_trade_no"))
        return "fail"

    order_no = (params.get("out_trade_no") or "").strip()
    trade_no = (params.get("trade_no") or "").strip()
    if not order_no:
        return "fail"

    order = db.query(MembershipOrder).filter(MembershipOrder.order_no == order_no).first()
    if not order:
        logger.warning("alipay notify unknown order %s", order_no)
        return "fail"
    if not amount_equals(yuan_from_cent(order.amount_cent), params.get("total_amount")):
        logger.warning("alipay notify amount mismatch order=%s", order_no)
        return "fail"

    try:
        inserted = _insert_notify_once(db, params)
        if not inserted:
            db.commit()
            return "success"
        if is_paid_trade_notification(params):
            mark_order_paid(
                db,
                order,
                alipay_trade_no=trade_no,
                notify_raw=json.dumps({k: v for k, v in params.items() if k != "sign"}, ensure_ascii=False),
            )
        else:
            db.commit()
    except Exception:
        db.rollback()
        logger.exception("alipay notify mark paid failed order=%s", order_no)
        return "fail"
    return "success"


def sync_order_from_query(db: Session, order: MembershipOrder) -> dict:
    result = query_trade(out_trade_no=order.order_no, trade_no=order.alipay_trade_no)
    if result.get("code") == "10000" and result.get("business_state") == "PAID":
        if amount_equals(yuan_from_cent(order.amount_cent), result.get("total_amount")):
            mark_order_paid(db, order, alipay_trade_no=str(result.get("trade_no") or ""))
            db.refresh(order)
    return result


def request_refund(db: Session, order: MembershipOrder, *, refund_amount: Decimal, out_request_no: str = "") -> dict:
    if order.status != "paid":
        raise HTTPException(status_code=400, detail="未支付订单不能退款")
    max_yuan = yuan_from_cent(order.amount_cent)
    refund_amount = refund_amount.quantize(Decimal("0.01"))
    if refund_amount <= 0 or refund_amount > max_yuan:
        raise HTTPException(status_code=400, detail="退款金额超出原订单")
    spent = Decimal("0.00")
    for row in db.query(AlipayRefund).filter(AlipayRefund.order_no == order.order_no).all():
        if row.status in {"REFUND_SUCCESS", "Y", "created"}:
            spent += Decimal(row.refund_amount or "0")
    if spent + refund_amount > max_yuan:
        raise HTTPException(status_code=400, detail="累计退款不能超过实付金额")
    request_no = (out_request_no or f"RF{order.order_no}{secrets.token_hex(2).upper()}")[:64]
    existing = db.query(AlipayRefund).filter(AlipayRefund.out_request_no == request_no).first()
    if existing:
        request_no = existing.out_request_no
        refund_amount = Decimal(existing.refund_amount)
    else:
        db.add(AlipayRefund(order_no=order.order_no, out_request_no=request_no, refund_amount=f"{refund_amount:.2f}"))
        db.commit()
    result = refund_trade(
        refund_amount=refund_amount,
        out_request_no=request_no,
        out_trade_no=order.order_no,
        trade_no=order.alipay_trade_no,
    )
    row = db.query(AlipayRefund).filter(AlipayRefund.out_request_no == request_no).first()
    if row:
        if result.get("code") == "10000" and result.get("fund_change") == "Y":
            row.status = "REFUND_SUCCESS"
        else:
            row.status = str(result.get("code") or "pending")
        db.commit()
    result["out_request_no"] = request_no
    return result


def lookup_refund(order: MembershipOrder, out_request_no: str) -> dict:
    return query_refund(out_request_no=out_request_no, out_trade_no=order.order_no, trade_no=order.alipay_trade_no)


def close_pending_order(db: Session, order: MembershipOrder) -> dict:
    if order.status == "paid":
        raise HTTPException(status_code=400, detail="已支付订单不能关闭")
    result = close_trade(out_trade_no=order.order_no, trade_no=order.alipay_trade_no)
    if result.get("code") == "10000" and order.status == "pending":
        order.status = "closed"
        db.commit()
    return result


def order_public_out(db: Session, order: MembershipOrder, api_base: str = "") -> dict:
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

    amount_yuan = yuan_from_cent(order.amount_cent)
    base = _api_base(api_base) or frontend_url()
    return {
        "order_no": order.order_no,
        "email": order.email,
        "amount_yuan": f"{amount_yuan:.2f}",
        "amount_cent": order.amount_cent,
        "status": order.status,
        "mock": alipay_mock_enabled(),
        "pay_url": pay_page_url_for(base, order.order_no) if order.status == "pending" else None,
        "pay_form": None,
        "return_url": return_url_for(base, order.order_no),
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
