"""Sign in with Apple：校验 Apple 下发的 identity token（JWT）。

Apple 的 identity token 由 Apple 用 RS256 私钥签名，公钥在
https://appleid.apple.com/auth/keys（JWKS）公开。这里拉取并缓存公钥，
校验签名、iss、aud、exp 后取出用户唯一标识 sub（及可能的邮箱）。
"""
from __future__ import annotations

import hashlib
import json
import os
import time
import urllib.request
from typing import Any

from jose import jwk, jwt

APPLE_ISSUER = "https://appleid.apple.com"
APPLE_JWKS_URL = "https://appleid.apple.com/auth/keys"
APPLE_EMAIL_SUFFIX = "@apple.vloglish.invalid"
_JWKS_TTL = 3600  # 公钥缓存 1 小时

_jwks_cache: dict[str, Any] = {"at": 0.0, "keys": {}}


def apple_placeholder_email(sub: str) -> str:
    """Apple 隐藏邮箱 / 未提供邮箱时的占位邮箱（基于 sub 稳定生成）。"""
    digest = hashlib.sha256((sub or "").strip().encode("utf-8")).hexdigest()[:24]
    return f"apple_{digest}{APPLE_EMAIL_SUFFIX}"


def is_apple_placeholder_email(email: str | None) -> bool:
    return (email or "").strip().lower().endswith(APPLE_EMAIL_SUFFIX)


def _audiences() -> list[str]:
    """允许的 aud：原生 App 用 bundle id，网页用 Service ID，可逗号分隔多个。"""
    raw = os.getenv("APPLE_BUNDLE_IDS") or os.getenv("APPLE_BUNDLE_ID") or "cc.vloglish.app"
    ids = [x.strip() for x in raw.split(",") if x.strip()]
    return ids or ["cc.vloglish.app"]


def _fetch_jwks(force: bool = False) -> dict[str, Any]:
    now = time.time()
    if not force and now - _jwks_cache["at"] < _JWKS_TTL and _jwks_cache["keys"]:
        return _jwks_cache["keys"]
    req = urllib.request.Request(APPLE_JWKS_URL, headers={"User-Agent": "vloglish-backend"})
    with urllib.request.urlopen(req, timeout=10) as resp:
        data = json.loads(resp.read().decode("utf-8"))
    keys: dict[str, Any] = {}
    for item in data.get("keys", []):
        kid = item.get("kid")
        if kid:
            keys[kid] = item
    _jwks_cache["keys"] = keys
    _jwks_cache["at"] = now
    return keys


def verify_apple_identity_token(identity_token: str) -> dict[str, Any]:
    """校验并返回 Apple identity token 的声明；失败抛 ValueError。"""
    token = (identity_token or "").strip()
    if not token:
        raise ValueError("缺少 identity token")

    try:
        header = jwt.get_unverified_header(token)
    except Exception as exc:  # noqa: BLE001
        raise ValueError("身份令牌格式不正确") from exc

    kid = header.get("kid")
    keys = _fetch_jwks()
    jwk_data = keys.get(kid) if kid else None
    if not jwk_data:
        # kid 未命中缓存（Apple 可能轮换密钥），强制刷新一次
        keys = _fetch_jwks(force=True)
        jwk_data = keys.get(kid) if kid else None
    if not jwk_data:
        raise ValueError("无法获取 Apple 公钥")

    public_key = jwk.construct(jwk_data)
    try:
        claims = jwt.decode(
            token,
            public_key,
            algorithms=["RS256"],
            audience=_audiences(),
            issuer=APPLE_ISSUER,
            options={"verify_aud": True, "verify_iss": True, "verify_exp": True},
        )
    except Exception as exc:  # noqa: BLE001
        raise ValueError("Apple 身份令牌校验失败") from exc

    if not claims.get("sub"):
        raise ValueError("Apple 身份令牌缺少用户标识")
    return claims
