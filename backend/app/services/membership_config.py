"""Membership purchase / Alipay configuration from env or local sandbox file."""
from __future__ import annotations

import json
import os
from decimal import Decimal, InvalidOperation
from functools import lru_cache
from pathlib import Path


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


def _project_root() -> Path:
    return Path(__file__).resolve().parents[2]


def sandbox_config_path() -> Path:
    return _project_root() / ".alipay-sandbox.json"


@lru_cache(maxsize=1)
def _sandbox_local() -> dict:
    path = sandbox_config_path()
    if not path.is_file():
        return {}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RuntimeError("沙箱本地配置无法读取") from exc
    if not isinstance(data, dict):
        raise RuntimeError("沙箱本地配置无效")
    return data


def _sandbox_value(*keys: str) -> str:
    data = _sandbox_local()
    for key in keys:
        value = data.get(key)
        if isinstance(value, str) and value.strip():
            return value.strip()
    return ""


def _sandbox_ready() -> bool:
    return bool(
        _sandbox_value("appId")
        and _sandbox_value("appPrivatePkcsKey")
        and _sandbox_value("alipayPublicKey")
        and _sandbox_value("appPublicKey")
        and _sandbox_value("sellerEmail", "sellerUserId")
        and _sandbox_value("buyerUserId")
        and _sandbox_value("buyerEmail")
        and _sandbox_value("buyerLogonPassword")
        and _sandbox_value("buyerPayPassword")
    )


def alipay_mock_enabled() -> bool:
    flag = (os.getenv("ALIPAY_MOCK") or "").strip().lower()
    if flag in {"1", "true", "yes", "on"}:
        return True
    if flag in {"0", "false", "no", "off"}:
        return False
    if _sandbox_ready():
        return False
    return not alipay_app_id()


def alipay_sandbox() -> bool:
    flag = (os.getenv("ALIPAY_SANDBOX") or "").strip().lower()
    if flag in {"0", "false", "no", "off"}:
        return False
    if flag in {"1", "true", "yes", "on"}:
        return True
    return _sandbox_ready()


def alipay_app_id() -> str:
    if _sandbox_ready():
        return _sandbox_value("appId")
    return (os.getenv("ALIPAY_APP_ID") or "").strip()


def alipay_app_private_key() -> str:
    raw = _sandbox_value("appPrivatePkcsKey") if _sandbox_ready() else (os.getenv("ALIPAY_APP_PRIVATE_KEY") or "")
    return _normalize_pem(raw)


def alipay_public_key() -> str:
    raw = _sandbox_value("alipayPublicKey") if _sandbox_ready() else (os.getenv("ALIPAY_PUBLIC_KEY") or "")
    return _normalize_pem(raw)


def alipay_seller_id() -> str:
    if _sandbox_ready():
        return _sandbox_value("sellerUserId")
    return (os.getenv("ALIPAY_SELLER_ID") or "").strip()


def alipay_seller_email() -> str:
    if _sandbox_ready():
        return _sandbox_value("sellerEmail")
    return (os.getenv("ALIPAY_SELLER_EMAIL") or "").strip()


def public_https_base() -> str:
    """仅公网 HTTPS 才可作为 notify_url；本地验收省略该字段。"""
    base = backend_public_url()
    if base.startswith("https://"):
        return base
    return ""


def sdk_key_material(raw: str) -> str:
    """SDK 配置使用原始密钥字符串，不添加 PEM 头尾或改写换行。"""
    text = (raw or "").strip()
    if not text:
        return ""
    text = text.replace("\\n", "\n")
    lines = [line.strip() for line in text.splitlines() if line.strip() and "BEGIN" not in line and "END" not in line]
    return "".join(lines)


def _normalize_pem(raw: str) -> str:
    text = raw.strip()
    if not text:
        return ""
    text = text.replace("\\n", "\n")
    if "BEGIN" in text:
        return text
    return text
