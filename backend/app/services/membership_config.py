"""Membership purchase / Alipay configuration from env."""
from __future__ import annotations

import os
from decimal import Decimal, InvalidOperation


def membership_price_yuan() -> Decimal:
    raw = (os.getenv("MEMBERSHIP_PRICE_YUAN") or "99").strip()
    try:
        value = Decimal(raw)
    except InvalidOperation as exc:
        raise RuntimeError("MEMBERSHIP_PRICE_YUAN 配置无效") from exc
    if value <= 0:
        raise RuntimeError("MEMBERSHIP_PRICE_YUAN 必须大于 0")
    return value.quantize(Decimal("0.01"))


def membership_price_cent() -> int:
    return int(membership_price_yuan() * 100)


def membership_subject() -> str:
    return (os.getenv("MEMBERSHIP_SUBJECT") or "Vloglish 永久会员").strip() or "Vloglish 永久会员"


def frontend_url() -> str:
    return (os.getenv("FRONTEND_URL") or "http://127.0.0.1:5173").rstrip("/")


def backend_public_url() -> str:
    return (os.getenv("BACKEND_PUBLIC_URL") or "").rstrip("/")


def alipay_mock_enabled() -> bool:
    flag = (os.getenv("ALIPAY_MOCK") or "").strip().lower()
    if flag in {"1", "true", "yes", "on"}:
        return True
    if flag in {"0", "false", "no", "off"}:
        return False
    # 未配置 AppId 时默认走本地模拟支付，便于开发联调
    return not (os.getenv("ALIPAY_APP_ID") or "").strip()


def alipay_sandbox() -> bool:
    return (os.getenv("ALIPAY_SANDBOX") or "").strip().lower() in {"1", "true", "yes", "on"}


def alipay_app_id() -> str:
    return (os.getenv("ALIPAY_APP_ID") or "").strip()


def alipay_app_private_key() -> str:
    return _normalize_pem(os.getenv("ALIPAY_APP_PRIVATE_KEY") or "")


def alipay_public_key() -> str:
    return _normalize_pem(os.getenv("ALIPAY_PUBLIC_KEY") or "")


def _normalize_pem(raw: str) -> str:
    text = raw.strip()
    if not text:
        return ""
    # 支持 .env 里用 \n 写成一行
    text = text.replace("\\n", "\n")
    if "BEGIN" in text:
        return text
    # 无头尾时按 PKCS8 私钥 / 公钥常见格式补齐（调用方应尽量给完整 PEM）
    return text
