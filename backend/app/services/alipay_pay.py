"""Alipay AI 网页应用收款：官方 SDK page_execute + 查询/退款/关单/验签。"""

from __future__ import annotations

import json
import logging
import re
from decimal import Decimal, InvalidOperation

from .membership_config import (
    alipay_app_id,
    alipay_app_private_key,
    alipay_mock_enabled,
    alipay_public_key,
    alipay_sandbox,
    alipay_seller_email,
    alipay_seller_id,
    sdk_key_material,
)

logger = logging.getLogger(__name__)

SANDBOX_GATEWAY = "https://openapi-sandbox.dl.alipaydev.com/gateway.do"
PROD_GATEWAY = "https://openapi.alipay.com/gateway.do"


def _gateway() -> str:
    if alipay_sandbox():
        return SANDBOX_GATEWAY
    return PROD_GATEWAY


def format_alipay_timestamp(dt) -> str:
    return dt.strftime("%Y-%m-%d %H:%M:%S")


def normalize_amount_text(value) -> str | None:
    if value is None:
        return None
    match = re.fullmatch(r"(\d+)(?:\.(\d{1,2}))?", str(value).strip())
    if not match:
        return None
    return f"{int(match.group(1))}.{(match.group(2) or '').ljust(2, '0')}"


def amount_equals(expected, actual) -> bool:
    left = normalize_amount_text(expected)
    right = normalize_amount_text(actual)
    return left is not None and left == right


def _sdk_ready() -> bool:
    return bool(alipay_app_id() and sdk_key_material(alipay_app_private_key()) and sdk_key_material(alipay_public_key()))


def _build_client():
    if not _sdk_ready():
        raise RuntimeError("支付宝未配置：请设置 ALIPAY_APP_ID / ALIPAY_APP_PRIVATE_KEY / ALIPAY_PUBLIC_KEY")
    from alipay.aop.api.AlipayClientConfig import AlipayClientConfig
    from alipay.aop.api.DefaultAlipayClient import DefaultAlipayClient

    config = AlipayClientConfig()
    config.server_url = _gateway()
    config.app_id = alipay_app_id()
    config.app_private_key = sdk_key_material(alipay_app_private_key())
    config.alipay_public_key = sdk_key_material(alipay_public_key())
    config.charset = "utf-8"
    config.sign_type = "RSA2"
    return DefaultAlipayClient(alipay_client_config=config)


def _parse_execute(response_content, response_key: str) -> dict:
    if isinstance(response_content, dict):
        payload = response_content
    else:
        payload = json.loads(response_content)
    if response_key in payload:
        return payload.get(response_key) or {}
    return payload


def verify_notify(params: dict[str, str]) -> bool:
    """用官方 SDK SignatureUtils 验签，禁止手写 RSA。本地模拟支付走 mock-pay，不旁路验签。"""
    public_key = sdk_key_material(alipay_public_key())
    if not public_key:
        logger.error("ALIPAY_PUBLIC_KEY missing")
        return False
    sign = params.get("sign") or ""
    sign_type = (params.get("sign_type") or "RSA2").upper()
    if sign_type != "RSA2" or not sign:
        logger.error("unsupported alipay sign_type=%s", sign_type)
        return False
    items = []
    for key in sorted(params.keys()):
        if key in {"sign", "sign_type"}:
            continue
        value = params.get(key)
        if value is None or value == "":
            continue
        items.append(f"{key}={value}")
    content = "&".join(items)
    try:
        from alipay.aop.api.util.SignatureUtils import verify_with_rsa

        return bool(verify_with_rsa(public_key, content.encode("utf-8"), sign))
    except Exception:
        logger.exception("alipay notify verify failed")
        return False


def notify_app_matches(params: dict[str, str]) -> bool:
    app_id = (params.get("app_id") or "").strip()
    return bool(app_id) and app_id == alipay_app_id()


def seller_matches(params: dict[str, str]) -> bool:
    expected_id = alipay_seller_id()
    expected_email = alipay_seller_email()
    if not expected_id and not expected_email:
        return True
    return bool(expected_id and params.get("seller_id") == expected_id) or bool(
        expected_email and params.get("seller_email") == expected_email
    )


def is_paid_trade_notification(params: dict[str, str]) -> bool:
    paid = (params.get("trade_status") or "") in {"TRADE_SUCCESS", "TRADE_FINISHED"}
    return paid and not params.get("out_biz_no") and not params.get("gmt_refund") and not params.get("refund_fee")


def build_page_pay_form(
    *,
    order_no: str,
    amount_yuan: Decimal,
    subject: str,
    return_url: str,
    notify_url: str = "",
) -> str:
    """返回 HTML 表单，必须由浏览器渲染提交，禁止当 URL 跳转。"""
    if alipay_mock_enabled():
        sep = "&" if "?" in return_url else "?"
        return (
            f"<form id='alipay_mock' method='get' action='{return_url}'>"
            f"<input type='hidden' name='out_trade_no' value='{order_no}'/>"
            f"<input type='hidden' name='mock' value='1'/>"
            "</form><script>document.forms[0].submit();</script>"
        )

    from alipay.aop.api.domain.AlipayTradePagePayModel import AlipayTradePagePayModel
    from alipay.aop.api.request.AlipayTradePagePayRequest import AlipayTradePagePayRequest

    client = _build_client()
    request = AlipayTradePagePayRequest()
    if notify_url:
        request.notify_url = notify_url
    request.return_url = return_url
    model = AlipayTradePagePayModel()
    model.out_trade_no = order_no
    model.total_amount = f"{amount_yuan:.2f}"
    model.subject = subject[:256]
    model.product_code = "FAST_INSTANT_TRADE_PAY"
    request.biz_model = model
    try:
        return client.page_execute(request, http_method="POST")
    except TypeError:
        return client.page_execute(request)


def build_pay_url(
    *,
    order_no: str,
    amount_yuan: Decimal,
    subject: str,
    return_url: str,
    notify_url: str,
    channel: str = "page",
) -> str:
    """兼容旧调用：返回支付页地址由路由层生成；此处仅校验配置。"""
    del order_no, amount_yuan, subject, return_url, notify_url, channel
    if alipay_mock_enabled():
        return ""
    if not _sdk_ready():
        raise RuntimeError("支付宝未配置：请设置 ALIPAY_APP_ID / ALIPAY_APP_PRIVATE_KEY / ALIPAY_PUBLIC_KEY")
    return ""


def query_trade(*, out_trade_no: str = "", trade_no: str = "") -> dict:
    if alipay_mock_enabled():
        return {"code": "10000", "trade_status": "WAIT_BUYER_PAY", "mock": True}
    from alipay.aop.api.domain.AlipayTradeQueryModel import AlipayTradeQueryModel
    from alipay.aop.api.request.AlipayTradeQueryRequest import AlipayTradeQueryRequest

    client = _build_client()
    request = AlipayTradeQueryRequest()
    model = AlipayTradeQueryModel()
    if trade_no:
        model.trade_no = trade_no
    elif out_trade_no:
        model.out_trade_no = out_trade_no
    else:
        raise ValueError("缺少 out_trade_no 或 trade_no")
    request.biz_model = model
    result = _parse_execute(client.execute(request), "alipay_trade_query_response")
    status = result.get("trade_status")
    result["business_state"] = {
        "TRADE_SUCCESS": "PAID",
        "TRADE_FINISHED": "PAID",
        "WAIT_BUYER_PAY": "PENDING_PAYMENT",
        "TRADE_CLOSED": "CLOSED",
    }.get(status, "UNKNOWN")
    return result


def refund_trade(
    *,
    refund_amount: Decimal,
    out_request_no: str,
    out_trade_no: str = "",
    trade_no: str = "",
    refund_reason: str = "",
) -> dict:
    if alipay_mock_enabled():
        return {"code": "10000", "fund_change": "Y", "mock": True, "out_request_no": out_request_no}
    from alipay.aop.api.domain.AlipayTradeRefundModel import AlipayTradeRefundModel
    from alipay.aop.api.request.AlipayTradeRefundRequest import AlipayTradeRefundRequest

    client = _build_client()
    request = AlipayTradeRefundRequest()
    model = AlipayTradeRefundModel()
    if trade_no:
        model.trade_no = trade_no
    elif out_trade_no:
        model.out_trade_no = out_trade_no
    else:
        raise ValueError("缺少 out_trade_no 或 trade_no")
    model.refund_amount = f"{refund_amount:.2f}"
    model.out_request_no = out_request_no
    if refund_reason:
        model.refund_reason = refund_reason[:256]
    request.biz_model = model
    return _parse_execute(client.execute(request), "alipay_trade_refund_response")


def query_refund(*, out_request_no: str, out_trade_no: str = "", trade_no: str = "") -> dict:
    if alipay_mock_enabled():
        return {"code": "10000", "refund_status": "REFUND_SUCCESS", "mock": True}
    from alipay.aop.api.domain.AlipayTradeFastpayRefundQueryModel import AlipayTradeFastpayRefundQueryModel
    from alipay.aop.api.request.AlipayTradeFastpayRefundQueryRequest import AlipayTradeFastpayRefundQueryRequest

    client = _build_client()
    request = AlipayTradeFastpayRefundQueryRequest()
    model = AlipayTradeFastpayRefundQueryModel()
    model.out_request_no = out_request_no
    if trade_no:
        model.trade_no = trade_no
    elif out_trade_no:
        model.out_trade_no = out_trade_no
    else:
        raise ValueError("缺少 out_trade_no 或 trade_no")
    request.biz_model = model
    return _parse_execute(client.execute(request), "alipay_trade_fastpay_refund_query_response")


def close_trade(*, out_trade_no: str = "", trade_no: str = "") -> dict:
    if alipay_mock_enabled():
        return {"code": "10000", "mock": True}
    from alipay.aop.api.domain.AlipayTradeCloseModel import AlipayTradeCloseModel
    from alipay.aop.api.request.AlipayTradeCloseRequest import AlipayTradeCloseRequest

    client = _build_client()
    request = AlipayTradeCloseRequest()
    model = AlipayTradeCloseModel()
    if trade_no:
        model.trade_no = trade_no
    elif out_trade_no:
        model.out_trade_no = out_trade_no
    else:
        raise ValueError("缺少 out_trade_no 或 trade_no")
    request.biz_model = model
    return _parse_execute(client.execute(request), "alipay_trade_close_response")


def yuan_from_cent(amount_cent: int) -> Decimal:
    try:
        return (Decimal(amount_cent) / Decimal(100)).quantize(Decimal("0.01"))
    except (InvalidOperation, TypeError) as exc:
        raise ValueError("金额无效") from exc
