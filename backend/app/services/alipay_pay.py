"""Alipay page/wap pay helpers (RSA2) + mock mode."""
from __future__ import annotations

import base64
import json
import logging
from decimal import Decimal
from urllib.parse import quote_plus, urlencode

from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import padding

from .membership_config import (
    alipay_app_id,
    alipay_app_private_key,
    alipay_mock_enabled,
    alipay_public_key,
    alipay_sandbox,
)

logger = logging.getLogger(__name__)


def _gateway() -> str:
    if alipay_sandbox():
        return "https://openapi-sandbox.dl.alipaydev.com/gateway.do"
    return "https://openapi.alipay.com/gateway.do"


def _load_private_key(pem: str):
    data = pem.encode() if "BEGIN" in pem else pem.encode()
    try:
        return serialization.load_pem_private_key(data, password=None)
    except ValueError:
        # 纯 base64 体：尝试包成 PKCS#8
        body = "".join(pem.split())
        wrapped = (
            "-----BEGIN PRIVATE KEY-----\n"
            + "\n".join(body[i : i + 64] for i in range(0, len(body), 64))
            + "\n-----END PRIVATE KEY-----\n"
        )
        return serialization.load_pem_private_key(wrapped.encode(), password=None)


def _load_public_key(pem: str):
    data = pem.encode()
    try:
        return serialization.load_pem_public_key(data)
    except ValueError:
        body = "".join(pem.split())
        wrapped = (
            "-----BEGIN PUBLIC KEY-----\n"
            + "\n".join(body[i : i + 64] for i in range(0, len(body), 64))
            + "\n-----END PUBLIC KEY-----\n"
        )
        return serialization.load_pem_public_key(wrapped.encode())


def _sign(content: str, private_key_pem: str) -> str:
    key = _load_private_key(private_key_pem)
    signature = key.sign(content.encode("utf-8"), padding.PKCS1v15(), hashes.SHA256())
    return base64.b64encode(signature).decode("utf-8")


def verify_notify(params: dict[str, str]) -> bool:
    """校验支付宝异步通知签名。"""
    if alipay_mock_enabled():
        return params.get("sign") == "MOCK" or params.get("trade_status") == "TRADE_SUCCESS"

    public_pem = alipay_public_key()
    if not public_pem:
        logger.error("ALIPAY_PUBLIC_KEY missing")
        return False

    sign = params.get("sign") or ""
    sign_type = (params.get("sign_type") or "RSA2").upper()
    if sign_type != "RSA2":
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
        key = _load_public_key(public_pem)
        key.verify(
            base64.b64decode(sign),
            content.encode("utf-8"),
            padding.PKCS1v15(),
            hashes.SHA256(),
        )
        return True
    except Exception:
        logger.exception("alipay notify verify failed")
        return False


def build_pay_url(
    *,
    order_no: str,
    amount_yuan: Decimal,
    subject: str,
    return_url: str,
    notify_url: str,
    channel: str = "page",
) -> str:
    """返回可跳转的支付宝收银台 URL。mock 模式下返回站内模拟支付页。"""
    if alipay_mock_enabled():
        # 前端结果页可调 mock-pay；这里直接给结果页并带 mock=1
        sep = "&" if "?" in return_url else "?"
        return f"{return_url}{sep}mock=1"

    app_id = alipay_app_id()
    private_key = alipay_app_private_key()
    if not app_id or not private_key:
        raise RuntimeError("支付宝未配置：请设置 ALIPAY_APP_ID / ALIPAY_APP_PRIVATE_KEY，或开启 ALIPAY_MOCK")

    method = "alipay.trade.wap.pay" if channel == "wap" else "alipay.trade.page.pay"
    biz: dict = {
        "out_trade_no": order_no,
        "total_amount": f"{amount_yuan:.2f}",
        "subject": subject[:256],
        "product_code": "QUICK_WAP_WAY" if channel == "wap" else "FAST_INSTANT_TRADE_PAY",
    }
    params = {
        "app_id": app_id,
        "method": method,
        "format": "JSON",
        "charset": "utf-8",
        "sign_type": "RSA2",
        "timestamp": __import__("datetime").datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "version": "1.0",
        "notify_url": notify_url,
        "return_url": return_url,
        "biz_content": json.dumps(biz, ensure_ascii=False, separators=(",", ":")),
    }
    unsigned = "&".join(f"{k}={params[k]}" for k in sorted(params.keys()))
    params["sign"] = _sign(unsigned, private_key)
    # 对 value 做 URL 编码
    query = urlencode(params, quote_via=quote_plus)
    return f"{_gateway()}?{query}"
