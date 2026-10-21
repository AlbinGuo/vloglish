"""Apple 应用内购买（StoreKit）收据校验。

使用 Apple 官方 verifyReceipt 接口校验收据（生产优先，status=21007 自动降级沙盒）。
需配置环境变量：
  APPLE_IAP_SHARED_SECRET   App Store Connect 的「App 专用共享密钥」
  APPLE_IAP_PRODUCTS        (可选) JSON，覆盖商品 id → 套餐映射，例如：
      {"cc.vloglish.app.member.year": {"plan": "year", "days": 365}}
"""
from __future__ import annotations

import json
import os
import urllib.error
import urllib.request
from datetime import datetime, timezone

PROD_URL = "https://buy.itunes.apple.com/verifyReceipt"
SANDBOX_URL = "https://sandbox.itunes.apple.com/verifyReceipt"

# verifyReceipt 状态码：0 成功；21006 收据有效但订阅已过期（仍可解析）
_OK_STATUSES = {0, 21006}


def apple_shared_secret() -> str:
    return (os.getenv("APPLE_IAP_SHARED_SECRET") or "").strip()


def apple_iap_enabled() -> bool:
    return bool(apple_shared_secret())


def _default_plan_map() -> dict[str, tuple[str, int | None]]:
    return {
        "quarter": ("quarter", 90),
        "year": ("year", 365),
        "forever": ("forever", None),
    }


def _plan_map() -> dict[str, tuple[str, int | None]]:
    raw = (os.getenv("APPLE_IAP_PRODUCTS") or "").strip()
    if not raw:
        return _default_plan_map()
    try:
        data = json.loads(raw)
    except json.JSONDecodeError:
        return _default_plan_map()
    if not isinstance(data, dict):
        return _default_plan_map()
    out: dict[str, tuple[str, int | None]] = {}
    for pid, spec in data.items():
        if not isinstance(spec, dict):
            continue
        plan = str(spec.get("plan") or "").strip()
        days = spec.get("days")
        if not plan:
            continue
        out[str(pid)] = (plan, None if days in (None, "", 0) else int(days))
    return out or _default_plan_map()


def resolve_plan(product_id: str) -> tuple[str, int | None] | None:
    """把商品 id 映射为 (套餐名, 天数)；天数 None 表示永久。"""
    pid = (product_id or "").strip()
    if not pid:
        return None
    mapping = _plan_map()
    if pid in mapping:
        return mapping[pid]
    low = pid.lower()
    for key, val in mapping.items():
        if key and key.lower() in low:
            return val
    if any(k in low for k in ("forever", "lifetime", "permanent")):
        return ("forever", None)
    if "year" in low:
        return ("year", 365)
    if "quarter" in low:
        return ("quarter", 90)
    return None


def _post_json(url: str, payload: dict) -> dict:
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url, data=body, headers={"Content-Type": "application/json"}, method="POST"
    )
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:  # noqa: S310 - 固定 Apple 官方域名
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:  # type: ignore[name-defined]
        raw = exc.read().decode("utf-8", "ignore")
        try:
            return json.loads(raw)
        except json.JSONDecodeError as err:
            raise RuntimeError(f"Apple 校验失败: HTTP {exc.code}") from err


def verify_receipt(receipt: str) -> dict:
    """校验收据，返回 Apple 响应 dict。"""
    secret = apple_shared_secret()
    if not secret:
        raise RuntimeError("APPLE_IAP_SHARED_SECRET 未配置")
    payload = {
        "receipt-data": receipt,
        "password": secret,
        "exclude-old-transactions": False,
    }
    res = _post_json(PROD_URL, payload)
    if res.get("status") == 21007:
        res = _post_json(SANDBOX_URL, payload)
    return res


def extract_transaction(
    res: dict, product_id: str, transaction_id: str = ""
) -> dict | None:
    """从响应里取匹配的购买记录，返回 {product_id, expires_ms}。"""
    latest = res.get("latest_receipt_info") or []
    inapp = (res.get("receipt") or {}).get("in_app") or []
    candidates: list[dict] = [c for c in latest if isinstance(c, dict)] + [
        c for c in inapp if isinstance(c, dict)
    ]

    def _find(pred) -> dict | None:
        for row in candidates:
            if pred(row):
                return row
        return None

    chosen = None
    if transaction_id:
        chosen = _find(lambda r: str(r.get("transaction_id")) == str(transaction_id))
    if chosen is None and product_id:
        rows = [r for r in candidates if r.get("product_id") == product_id]
        if rows:
            rows.sort(key=lambda r: int(r.get("purchase_date_ms") or 0), reverse=True)
            chosen = rows[0]
    if chosen is None:
        return None
    return {
        "product_id": chosen.get("product_id"),
        "expires_ms": chosen.get("expires_date_ms"),
    }


def days_until(expires_ms: str | int | None) -> int | None:
    if not expires_ms:
        return None
    try:
        exp = datetime.fromtimestamp(int(expires_ms) / 1000, tz=timezone.utc)
    except (TypeError, ValueError):
        return None
    remaining = int((exp - datetime.now(timezone.utc)).total_seconds() // 86400)
    return max(1, remaining)


def status_ok(status: int | None) -> bool:
    return status in _OK_STATUSES
