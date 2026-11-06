"""App 发布配置（当前生效的一条，存 site_settings）。"""

from __future__ import annotations

import json
from typing import Any

from sqlalchemy.orm import Session

from .site_settings import get_setting, set_setting

APP_RELEASE_KEY = "app_release"

DEFAULT_IOS_NOTE = "应用即将上架 App Store，敬请期待。"
DEFAULT_IOS_WECHAT_ID = "vloglish01"
DEFAULT_IOS_LEGACY_MESSAGE = "当前内测版本已停止服务，请更新到最新版本；或加作者微信 {wechat} 开通会员。"
LEGACY_IOS_MODES = {"off", "billing", "full"}


def _default_payload() -> dict[str, Any]:
    return {
        "enabled": True,
        "android_version": "",
        "android_version_code": 0,
        "android_apk_url": "",
        "android_apk_bytes": 0,
        "android_changelog": "",
        "force_update": False,
        "min_supported_version_code": 0,
        "android_download_count": 0,
        "ios_note": DEFAULT_IOS_NOTE,
        "ios_link": "",
        "ios_version": "",
        "ios_version_code": 0,
        "ios_min_supported_version_code": 0,
        "ios_force_update": False,
        "ios_changelog": "",
        "ios_wechat_id": DEFAULT_IOS_WECHAT_ID,
        "legacy_ios_block_mode": "off",
        "legacy_ios_block_message": "",
    }


def _normalize_legacy_mode(value: Any) -> str:
    mode = str(value or "off").strip().lower()
    return mode if mode in LEGACY_IOS_MODES else "off"


def _as_int(value: Any, default: int = 0) -> int:
    try:
        n = int(value)
    except (TypeError, ValueError):
        return default
    return max(0, n)


def _normalize(data: dict[str, Any]) -> dict[str, Any]:
    return {
        "enabled": bool(data.get("enabled", True)),
        "android_version": str(data.get("android_version") or "").strip()[:64],
        "android_version_code": _as_int(data.get("android_version_code"), 0),
        "android_apk_url": str(data.get("android_apk_url") or "").strip()[:1024],
        "android_apk_bytes": _as_int(data.get("android_apk_bytes"), 0),
        "android_changelog": str(data.get("android_changelog") or "").strip()[:4000],
        "force_update": bool(data.get("force_update", False)),
        "min_supported_version_code": _as_int(data.get("min_supported_version_code"), 0),
        "android_download_count": _as_int(data.get("android_download_count"), 0),
        "ios_note": str(data.get("ios_note") or DEFAULT_IOS_NOTE).strip()[:1000] or DEFAULT_IOS_NOTE,
        "ios_link": str(data.get("ios_link") or "").strip()[:1024],
        "ios_version": str(data.get("ios_version") or "").strip()[:64],
        "ios_version_code": _as_int(data.get("ios_version_code"), 0),
        "ios_min_supported_version_code": _as_int(data.get("ios_min_supported_version_code"), 0),
        "ios_force_update": bool(data.get("ios_force_update", False)),
        "ios_changelog": str(data.get("ios_changelog") or "").strip()[:4000],
        "ios_wechat_id": str(data.get("ios_wechat_id") or DEFAULT_IOS_WECHAT_ID).strip()[:64]
        or DEFAULT_IOS_WECHAT_ID,
        "legacy_ios_block_mode": _normalize_legacy_mode(data.get("legacy_ios_block_mode")),
        "legacy_ios_block_message": str(data.get("legacy_ios_block_message") or "").strip()[:4000],
    }


def get_app_release(db: Session) -> dict[str, Any]:
    raw = get_setting(db, APP_RELEASE_KEY, "")
    data = _default_payload()
    if not raw.strip():
        return data
    try:
        parsed = json.loads(raw)
    except json.JSONDecodeError:
        return data
    if not isinstance(parsed, dict):
        return data
    for key in data:
        if key in parsed and parsed[key] is not None:
            data[key] = parsed[key]
    return _normalize(data)


def save_app_release(db: Session, patch: dict[str, Any]) -> dict[str, Any]:
    current = get_app_release(db)
    prev_url = current.get("android_apk_url") or ""
    for key in current:
        if key in patch and patch[key] is not None:
            current[key] = patch[key]
    current = _normalize(current)
    # 手动改安装包地址且未带新体积时，清空体积，避免显示旧包大小
    if (
        "android_apk_url" in patch
        and patch.get("android_apk_url") is not None
        and str(patch.get("android_apk_url") or "").strip() != prev_url
        and "android_apk_bytes" not in patch
    ):
        current["android_apk_bytes"] = 0
    set_setting(db, APP_RELEASE_KEY, json.dumps(current, ensure_ascii=False))
    return current


def increment_android_download(db: Session) -> str | None:
    """计数 +1，返回直链；未开放或无包时返回 None。"""
    data = get_app_release(db)
    url = str(data.get("android_apk_url") or "").strip()
    if not data.get("enabled") or not url:
        return None
    save_app_release(
        db,
        {"android_download_count": _as_int(data.get("android_download_count"), 0) + 1},
    )
    return url


def public_app_download(db: Session) -> dict[str, Any]:
    """公开落地页数据；未启用时仍返回说明，但不给下载地址。"""
    data = get_app_release(db)
    enabled = bool(data.get("enabled"))
    apk = data.get("android_apk_url") or "" if enabled else ""
    return {
        "enabled": enabled,
        "android_version": data.get("android_version") or "",
        "android_version_code": int(data.get("android_version_code") or 0) if enabled else 0,
        "android_apk_url": apk,
        "android_apk_bytes": int(data.get("android_apk_bytes") or 0) if enabled and apk else 0,
        "android_changelog": data.get("android_changelog") or "" if enabled else "",
        "force_update": bool(data.get("force_update")) if enabled else False,
        "min_supported_version_code": int(data.get("min_supported_version_code") or 0) if enabled else 0,
        "ios_note": data.get("ios_note") or DEFAULT_IOS_NOTE,
        "ios_link": data.get("ios_link") or "" if enabled else "",
        "ios_version": data.get("ios_version") or "",
        "ios_version_code": int(data.get("ios_version_code") or 0) if enabled else 0,
        "ios_min_supported_version_code": int(data.get("ios_min_supported_version_code") or 0)
        if enabled
        else 0,
        "ios_force_update": bool(data.get("ios_force_update")) if enabled else False,
        "ios_changelog": data.get("ios_changelog") or "" if enabled else "",
        "ios_wechat_id": data.get("ios_wechat_id") or DEFAULT_IOS_WECHAT_ID,
        "legacy_ios_block_mode": _normalize_legacy_mode(data.get("legacy_ios_block_mode")),
        "legacy_ios_block_message": data.get("legacy_ios_block_message") or "",
        "has_android": bool(apk),
    }


def _check_android(data: dict[str, Any], enabled: bool, current: int) -> dict[str, Any]:
    latest_code = _as_int(data.get("android_version_code"), 0)
    min_code = _as_int(data.get("min_supported_version_code"), 0)
    apk = str(data.get("android_apk_url") or "").strip()

    has_update = bool(enabled and apk and latest_code > current)
    force = False
    if has_update:
        force = bool(data.get("force_update")) or (min_code > 0 and current < min_code)

    return {
        "platform": "android",
        "has_update": has_update,
        "force_update": force,
        "latest_version": data.get("android_version") or "" if has_update else "",
        "latest_version_code": latest_code if has_update else 0,
        "android_apk_url": apk if has_update else "",
        "android_apk_bytes": int(data.get("android_apk_bytes") or 0) if has_update else 0,
        "android_changelog": (data.get("android_changelog") or "") if has_update else "",
        "changelog": (data.get("android_changelog") or "") if has_update else "",
        "download_page_path": "/download",
        "store_url": "",
        "blocked": False,
        "block_mode": "off",
        "block_message": "",
        "wechat_id": "",
    }


def _check_ios(data: dict[str, Any], enabled: bool, current: int) -> dict[str, Any]:
    latest_code = _as_int(data.get("ios_version_code"), 0)
    min_code = _as_int(data.get("ios_min_supported_version_code"), 0)
    store_url = str(data.get("ios_link") or "").strip()
    wechat = str(data.get("ios_wechat_id") or DEFAULT_IOS_WECHAT_ID).strip() or DEFAULT_IOS_WECHAT_ID

    has_update = bool(enabled and latest_code > current)
    force = bool(has_update and (bool(data.get("ios_force_update")) or (min_code > 0 and current < min_code)))

    block_mode = _normalize_legacy_mode(data.get("legacy_ios_block_mode"))
    # 内测版停服：开了 legacy 拦截且当前版本落后于最新 iOS 版本时，强制提示更新/加微信
    blocked = bool(enabled and block_mode != "off" and latest_code > current)
    block_message = ""
    if blocked:
        tmpl = str(data.get("legacy_ios_block_message") or "").strip() or DEFAULT_IOS_LEGACY_MESSAGE
        block_message = tmpl.replace("{wechat}", wechat)

    return {
        "platform": "ios",
        "has_update": has_update,
        "force_update": force,
        "latest_version": (data.get("ios_version") or "") if has_update else "",
        "latest_version_code": latest_code if has_update else 0,
        "android_apk_url": "",
        "android_apk_bytes": 0,
        "android_changelog": "",
        "changelog": (data.get("ios_changelog") or "") if has_update else "",
        "download_page_path": "/download",
        "store_url": store_url if (has_update or blocked) else "",
        "blocked": blocked,
        "block_mode": block_mode if blocked else "off",
        "block_message": block_message,
        "wechat_id": wechat if (blocked or has_update) else "",
    }


def check_app_version(
    db: Session, *, current_version_code: int, platform: str = "android"
) -> dict[str, Any]:
    """App 内检查更新。platform: android / ios。"""
    data = get_app_release(db)
    enabled = bool(data.get("enabled"))
    current = max(0, int(current_version_code or 0))
    if str(platform or "").strip().lower() == "ios":
        return _check_ios(data, enabled, current)
    return _check_android(data, enabled, current)
