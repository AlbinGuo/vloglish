"""Apple 应用内购买（StoreKit）收据校验。

使用 Apple 官方 verifyReceipt 接口校验收据（生产优先，status=21007 自动降级沙盒）。
需配置环境变量：
  APPLE_IAP_SHARED_SECRET   App Store Connect 的「App 专用共享密钥」
  APPLE_IAP_PRODUCTS        (可选) JSON，覆盖商品 id → 套餐映射，例如：
      {"cc.vloglish.app.member.year": {"plan": "year", "days": 365}}
"""
from __future__ import annotations

import base64
import json
import os
import urllib.error
import urllib.request
from datetime import datetime, timezone

from cryptography import x509
from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import hashes, padding
from cryptography.hazmat.primitives.asymmetric import ec, rsa
from cryptography.x509.oid import NameOID

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
        "week": ("week", 7),
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
    if "week" in low:
        return ("week", 7)
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
    """从响应里取匹配的购买记录，返回 {product_id, transaction_id, expires_ms, purchase_ms}。"""
    latest = res.get("latest_receipt_info") or []
    inapp = (res.get("receipt") or {}).get("in_app") or []
    candidates: list[dict] = [c for c in latest if isinstance(c, dict)] + [
        c for c in inapp if isinstance(c, dict)
    ]
    # 过滤已退款 / 已撤销的交易，避免用退过的订单发货
    candidates = [
        c
        for c in candidates
        if not (c.get("cancellation_date_ms") or c.get("cancellation_date"))
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
        "transaction_id": chosen.get("transaction_id"),
        "expires_ms": chosen.get("expires_date_ms"),
        "purchase_ms": chosen.get("purchase_date_ms"),
    }


def expiry_datetime(expires_ms: str | int | None) -> datetime | None:
    """把 Apple 的毫秒时间戳转成 naive UTC datetime（与 member_until 存储一致）。"""
    if not expires_ms:
        return None
    try:
        return datetime.fromtimestamp(int(expires_ms) / 1000, tz=timezone.utc).replace(tzinfo=None)
    except (TypeError, ValueError, OSError):
        return None


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


def latest_known_transaction(res: dict, plan_resolver) -> dict | None:
    """恢复购买场景：从整张收据里挑出“最近一笔、属于本应用已知套餐、未退款”的交易。

    plan_resolver 传入 resolve_plan，用来过滤出能映射到本应用套餐的商品，
    避免把 App Store 账号里其它 App 或未知商品的交易误判为本应用购买。
    """
    latest = res.get("latest_receipt_info") or []
    inapp = (res.get("receipt") or {}).get("in_app") or []
    candidates: list[dict] = [c for c in latest if isinstance(c, dict)] + [
        c for c in inapp if isinstance(c, dict)
    ]
    candidates = [
        c
        for c in candidates
        if not (c.get("cancellation_date_ms") or c.get("cancellation_date"))
        and plan_resolver(c.get("product_id") or "")
    ]
    if not candidates:
        return None
    candidates.sort(key=lambda r: int(r.get("purchase_date_ms") or 0), reverse=True)
    chosen = candidates[0]
    return {
        "product_id": chosen.get("product_id"),
        "transaction_id": chosen.get("transaction_id"),
        "expires_ms": chosen.get("expires_date_ms"),
        "purchase_ms": chosen.get("purchase_date_ms"),
    }


# ---------------------------------------------------------------------------
# StoreKit 2：校验 Apple 签名的交易 JWS（无需 App 专用共享密钥）
# ---------------------------------------------------------------------------

def _b64url_decode(data: str) -> bytes:
    pad = "=" * (-len(data) % 4)
    return base64.urlsafe_b64decode(data + pad)


def is_storekit2_jws(receipt: str | None) -> bool:
    """StoreKit2 交易 JWS 形如 header.payload.signature（两个点）。

    旧版 App Receipt 是单个 base64 串（不含点），据此区分两条校验路径。
    """
    return isinstance(receipt, str) and receipt.count(".") == 2 and len(receipt) > 100


def expected_bundle_ids() -> list[str]:
    raw = (
        os.getenv("APPLE_IAP_BUNDLE_IDS")
        or os.getenv("APPLE_BUNDLE_IDS")
        or os.getenv("APPLE_BUNDLE_ID")
        or "cc.vloglish.app"
    )
    ids = [x.strip() for x in raw.split(",") if x.strip()]
    return ids or ["cc.vloglish.app"]


def _load_cert(der_b64: str) -> x509.Certificate:
    pad = "=" * (-len(der_b64) % 4)
    return x509.load_der_x509_certificate(base64.b64decode(der_b64 + pad))


def _check_cert_time(cert: x509.Certificate) -> None:
    now = datetime.now(timezone.utc)
    nb = getattr(cert, "not_valid_before_utc", None)
    na = getattr(cert, "not_valid_after_utc", None)
    if nb is None:
        nb = cert.not_valid_before.replace(tzinfo=timezone.utc)
    if na is None:
        na = cert.not_valid_after.replace(tzinfo=timezone.utc)
    if now < nb:
        raise ValueError("证书尚未生效")
    if now > na:
        raise ValueError("证书已过期")


def _verify_cert_signed_by(child: x509.Certificate, issuer: x509.Certificate) -> None:
    pub = issuer.public_key()
    data = child.tbs_certificate_bytes
    if isinstance(pub, ec.EllipticCurvePublicKey):
        pub.verify(child.signature, data, ec.ECDSA(child.signature_hash_algorithm))
    elif isinstance(pub, rsa.RSAPublicKey):
        pub.verify(child.signature, data, padding.PKCS1v15(), child.signature_hash_algorithm)
    else:
        raise ValueError("不支持的证书公钥类型")


def _raw_sig_to_der(sig: bytes) -> bytes:
    """JWS 的 ES256 签名是 R||S（64 字节），cryptography 需要 DER 编码。"""
    if len(sig) == 64:
        from cryptography.hazmat.primitives.asymmetric.utils import encode_dss_signature

        r = int.from_bytes(sig[:32], "big")
        s = int.from_bytes(sig[32:], "big")
        return encode_dss_signature(r, s)
    return sig


def verify_storekit2_jws(jws: str) -> dict:
    """校验 Apple 签名的交易 JWS，返回 payload。

    校验：x5c 证书链自洽 → 根为 Apple Root CA 且自签名 → 证书有效期 →
    JWS 签名 → bundleId 属于本应用 → 环境合法 → 未被退款/撤销。
    """
    parts = jws.split(".")
    if len(parts) != 3:
        raise ValueError("交易令牌格式不正确")
    try:
        header = json.loads(_b64url_decode(parts[0]))
        payload = json.loads(_b64url_decode(parts[1]))
        signature = _b64url_decode(parts[2])
    except Exception as exc:  # noqa: BLE001
        raise ValueError("交易令牌解析失败") from exc

    alg = str(header.get("alg") or "")
    x5c = header.get("x5c") or []
    if not x5c:
        raise ValueError("交易令牌缺少证书链")
    try:
        certs = [_load_cert(c) for c in x5c]
    except Exception as exc:  # noqa: BLE001
        raise ValueError("交易证书解析失败") from exc

    for i in range(len(certs) - 1):
        try:
            _verify_cert_signed_by(certs[i], certs[i + 1])
        except InvalidSignature as exc:
            raise ValueError("交易证书链签名无效") from exc

    root = certs[-1]
    try:
        _verify_cert_signed_by(root, root)
    except InvalidSignature as exc:
        raise ValueError("根证书不受信任") from exc
    cn = None
    for attr in root.subject.get_attributes_for_oid(NameOID.COMMON_NAME):
        cn = str(attr.value)
        break
    if not (cn and cn.lower().startswith("apple root ca")):
        raise ValueError("证书根不受信任")

    for cert in certs:
        _check_cert_time(cert)

    leaf_pub = certs[0].public_key()
    signing_input = (parts[0] + "." + parts[1]).encode("ascii")
    try:
        if alg == "ES256" and isinstance(leaf_pub, ec.EllipticCurvePublicKey):
            leaf_pub.verify(_raw_sig_to_der(signature), signing_input, ec.ECDSA(hashes.SHA256()))
        elif alg == "RS256" and isinstance(leaf_pub, rsa.RSAPublicKey):
            leaf_pub.verify(signature, signing_input, padding.PKCS1v15(), hashes.SHA256())
        else:
            raise ValueError(f"不支持的签名算法: {alg}")
    except InvalidSignature as exc:
        raise ValueError("交易签名无效") from exc

    bundle_id = str(payload.get("bundleId") or "")
    if bundle_id and bundle_id not in expected_bundle_ids():
        raise ValueError("交易不属于本应用")
    env = str(payload.get("environment") or "")
    if env and env not in ("Production", "Sandbox"):
        raise ValueError("未知的交易环境")
    if payload.get("revocationDate"):
        raise ValueError("该交易已退款/撤销")
    if not payload.get("productId") or not payload.get("transactionId"):
        raise ValueError("交易信息不完整")
    return payload


def jws_transaction_info(payload: dict) -> dict:
    return {
        "product_id": payload.get("productId"),
        "transaction_id": payload.get("transactionId"),
        "expires_ms": payload.get("expiresDate"),
        "purchase_ms": payload.get("purchaseDate"),
    }
