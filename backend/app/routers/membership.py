"""Public membership purchase APIs (Alipay AI 网页应用收款)."""
from __future__ import annotations

from decimal import Decimal, InvalidOperation

from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import HTMLResponse, PlainTextResponse
from pydantic import BaseModel
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user
from ..models import AppleIapTransaction, MembershipOrder, User
from ..schemas import MembershipOrderCreateIn, MembershipOrderOut, MembershipPricingOut
from ..services.membership_config import (
    alipay_mock_enabled,
    membership_price_cent,
    membership_price_yuan,
    membership_subject,
)
from ..services.membership_orders import (
    build_order_pay_form,
    close_pending_order,
    create_order,
    get_order_by_no,
    handle_alipay_notify,
    lookup_refund,
    mark_order_paid,
    order_public_out,
    request_refund,
    sync_order_from_query,
)

router = APIRouter(prefix="/api/membership", tags=["membership"])


def _api_base(request: Request) -> str:
    return str(request.base_url).rstrip("/")


def _can_manage(user: User, order) -> bool:
    return bool(user.is_staff or (order.user_id and order.user_id == user.id))


class AppleVerifyIn(BaseModel):
    product_id: str = ""
    transaction_id: str = ""
    receipt: str = ""


@router.post("/apple/verify/")
def verify_apple_purchase(
    body: AppleVerifyIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """校验 Apple 内购收据/交易并开通、续期会员。

    链路要点：
    - StoreKit 2：校验 Apple 签名的交易 JWS（无需共享密钥，默认路径）；
    - 旧版 Receipt：verifyReceipt，生产优先、status=21007 自动降级沙盒；
    - 以交易自带到期时间为准（幂等，重复校验不会重复加天数）；
    - 按 transaction_id 去重，防止多账号共享同一笔购买。
    """
    from ..services.apple_iap import (
        apple_iap_enabled,
        expiry_datetime,
        extract_transaction,
        is_storekit2_jws,
        jws_transaction_info,
        resolve_plan,
        status_ok,
        verify_receipt,
        verify_storekit2_jws,
    )
    from ..services.membership import apply_membership, apply_membership_until

    receipt = (body.receipt or "").strip()
    if not receipt and not body.transaction_id:
        raise HTTPException(status_code=400, detail="缺少收据")

    if is_storekit2_jws(receipt):
        # StoreKit 2：验证 Apple 签名的交易 JWS，无需 App 专用共享密钥
        try:
            payload = verify_storekit2_jws(receipt)
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc) or "交易校验失败") from exc
        except Exception as exc:  # noqa: BLE001
            raise HTTPException(status_code=400, detail="交易校验失败") from exc
        info = jws_transaction_info(payload)
    else:
        # 旧版 App Receipt：走 verifyReceipt（需 App 专用共享密钥）
        if not apple_iap_enabled():
            raise HTTPException(status_code=503, detail="Apple 内购校验未配置")
        try:
            res = verify_receipt(receipt)
        except Exception as exc:  # noqa: BLE001
            raise HTTPException(status_code=502, detail="无法校验 Apple 收据") from exc
        status = res.get("status")
        if not status_ok(status):
            raise HTTPException(status_code=400, detail=f"Apple 收据无效（status={status}）")
        info = extract_transaction(res, body.product_id, body.transaction_id)
        if not info:
            raise HTTPException(status_code=400, detail="未找到对应的购买记录")
    plan = resolve_plan(info.get("product_id") or body.product_id)
    if not plan:
        raise HTTPException(status_code=400, detail="未知的会员商品")
    plan_name, days = plan

    txn_id = str(info.get("transaction_id") or body.transaction_id or "").strip()
    expires_ms = info.get("expires_ms")
    product_id = info.get("product_id") or body.product_id or ""

    # 防多账号共享：同一活动交易只能归属一个账号
    existed = None
    if txn_id:
        existed = (
            db.query(AppleIapTransaction)
            .filter(AppleIapTransaction.transaction_id == txn_id)
            .first()
        )
        if existed and existed.user_id != user.id:
            raise HTTPException(status_code=409, detail="该购买记录已绑定其他账号")

    # 应用到账号：订阅以到期时间为准（幂等），永久会员直接置永久
    if plan_name == "forever":
        apply_membership(user, None, plan="forever")
    else:
        exp = expiry_datetime(expires_ms)
        if exp is not None:
            apply_membership_until(user, exp, plan=plan_name)
        else:
            remaining = days
            from ..services.apple_iap import days_until

            remaining = days_until(expires_ms) or remaining
            apply_membership(user, remaining, plan=plan_name)

    # 记录交易（新建才写），并发插入靠唯一约束兜底
    if txn_id and not existed:
        db.add(
            AppleIapTransaction(
                transaction_id=txn_id,
                user_id=user.id,
                product_id=product_id,
                plan=plan_name,
                expires_ms=str(expires_ms or ""),
            )
        )
        try:
            db.commit()
        except IntegrityError:
            db.rollback()
    else:
        db.commit()
    db.refresh(user)
    return {
        "is_member": bool(user.is_member),
        "member_until": user.member_until.isoformat() if user.member_until else None,
        "member_plan": user.member_plan,
    }


@router.get("/pricing/", response_model=MembershipPricingOut)
def get_pricing():
    yuan = membership_price_yuan()
    return MembershipPricingOut(
        subject=membership_subject(),
        amount_yuan=f"{yuan:.2f}",
        amount_cent=membership_price_cent(),
        mock=alipay_mock_enabled(),
        description="登录账号付款成功后立即开通永久会员",
    )


@router.post("/orders/", response_model=MembershipOrderOut)
def create_membership_order(
    body: MembershipOrderCreateIn,
    request: Request,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    data = create_order(
        db,
        user=user,
        channel=body.channel,
        notify_base=_api_base(request),
    )
    return MembershipOrderOut(**data)


@router.get("/orders/{order_no}/", response_model=MembershipOrderOut)
def get_membership_order(order_no: str, request: Request, db: Session = Depends(get_db)):
    order = get_order_by_no(db, order_no)
    return MembershipOrderOut(**order_public_out(db, order, api_base=_api_base(request)))


def _pay_html(form: str) -> HTMLResponse:
    return HTMLResponse(
        "<!doctype html><html><head><meta charset='utf-8'><title>正在前往支付宝</title></head>"
        "<body style='font-family:sans-serif;padding:24px'>"
        "<p>正在前往支付宝收银台…</p>"
        f"{form}"
        "</body></html>"
    )


@router.get("/pay/", response_class=HTMLResponse)
def start_membership_pay(
    request: Request,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    pending = (
        db.query(MembershipOrder)
        .filter(
            MembershipOrder.user_id == user.id,
            MembershipOrder.status == "pending",
            MembershipOrder.channel == "alipay",
        )
        .order_by(MembershipOrder.id.desc())
        .first()
    )
    if pending:
        return _pay_html(build_order_pay_form(pending, _api_base(request)))
    data = create_order(db, user=user, notify_base=_api_base(request))
    form = data.get("pay_form") or ""
    if not form:
        raise HTTPException(status_code=502, detail="无法生成支付表单")
    return _pay_html(form)


@router.get("/orders/{order_no}/pay/", response_class=HTMLResponse)
def pay_membership_order(
    order_no: str,
    request: Request,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    order = get_order_by_no(db, order_no)
    if not _can_manage(user, order):
        raise HTTPException(status_code=403, detail="无权操作该订单")
    if order.status != "pending":
        raise HTTPException(status_code=400, detail="订单已结束")
    return _pay_html(build_order_pay_form(order, _api_base(request)))


@router.get("/orders/{order_no}/trade/")
def query_membership_trade(
    order_no: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    order = get_order_by_no(db, order_no)
    if not _can_manage(user, order):
        raise HTTPException(status_code=403, detail="无权操作该订单")
    result = sync_order_from_query(db, order)
    return {"order": order_public_out(db, order), "trade": result}


@router.post("/orders/{order_no}/refund/")
def refund_membership_order(
    order_no: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
    amount: str = "",
    out_request_no: str = "",
):
    order = get_order_by_no(db, order_no)
    if not _can_manage(user, order):
        raise HTTPException(status_code=403, detail="无权操作该订单")
    raw = (amount or "").strip()
    try:
        refund_amount = Decimal(raw) if raw else (Decimal(order.amount_cent) / Decimal(100))
    except InvalidOperation as exc:
        raise HTTPException(status_code=400, detail="退款金额无效") from exc
    return request_refund(db, order, refund_amount=refund_amount, out_request_no=out_request_no)


@router.get("/orders/{order_no}/refunds/{out_request_no}/")
def query_membership_refund(
    order_no: str,
    out_request_no: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    order = get_order_by_no(db, order_no)
    if not _can_manage(user, order):
        raise HTTPException(status_code=403, detail="无权操作该订单")
    return lookup_refund(order, out_request_no)


@router.post("/orders/{order_no}/close/")
def close_membership_order(
    order_no: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    order = get_order_by_no(db, order_no)
    if not _can_manage(user, order):
        raise HTTPException(status_code=403, detail="无权操作该订单")
    return close_pending_order(db, order)


@router.post("/orders/{order_no}/mock-pay/", response_model=MembershipOrderOut)
def mock_pay_order(
    order_no: str,
    request: Request,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    if not alipay_mock_enabled():
        raise HTTPException(status_code=403, detail="未开启模拟支付")
    order = get_order_by_no(db, order_no)
    if order.user_id and order.user_id != user.id and not user.is_staff:
        raise HTTPException(status_code=403, detail="无权操作该订单")
    if order.status == "paid":
        return MembershipOrderOut(**order_public_out(db, order, api_base=_api_base(request)))
    mark_order_paid(db, order, alipay_trade_no="MOCK", notify_raw='{"mock":true}')
    return MembershipOrderOut(**order_public_out(db, order, api_base=_api_base(request)))


@router.get("/alipay/return/", response_class=HTMLResponse)
def alipay_return(request: Request, db: Session = Depends(get_db), out_trade_no: str = ""):
    order_no = (out_trade_no or request.query_params.get("out_trade_no") or "").strip()
    status_text = "支付结果页"
    detail = "没有订单上下文。若你刚从支付宝返回，请从购买页重新进入。"
    if order_no:
        try:
            order = get_order_by_no(db, order_no)
            if order.status != "paid" and not alipay_mock_enabled():
                sync_order_from_query(db, order)
                db.refresh(order)
            if order.status == "paid":
                status_text = "支付已确认"
                detail = "正在确认支付结果：会员已开通。"
            else:
                status_text = "正在确认支付结果"
                detail = "同步回跳不能作为付款成功依据，已向支付宝查询交易。"
        except HTTPException:
            status_text = "正在确认支付结果"
            detail = "未找到对应订单，请稍后在购买页查看。"
    mock_note = ""
    if alipay_mock_enabled() and request.query_params.get("mock") == "1" and order_no:
        mock_note = (
            f"<p><a href='/api/membership/orders/{order_no}/'>查看订单</a> "
            "（模拟支付请登录后调用 mock-pay）</p>"
        )
    return HTMLResponse(
        "<!doctype html><html><head><meta charset='utf-8'><title>支付结果</title></head>"
        "<body style='font-family:sans-serif;max-width:40rem;margin:3rem auto;line-height:1.6'>"
        f"<h1>{status_text}</h1><p>{detail}</p>"
        f"<p>订单号 {order_no or '—'}</p>{mock_note}"
        "</body></html>"
    )


@router.post("/alipay/notify/")
async def alipay_notify(request: Request, db: Session = Depends(get_db)):
    form = await request.form()
    params = {str(k): str(v) for k, v in form.items()}
    result = handle_alipay_notify(db, params)
    return PlainTextResponse(result)
