"""App 发布配置（当前生效的一条，存 site_settings）。"""

from __future__ import annotations

import json
from typing import Any

from sqlalchemy.orm import Session

from .site_settings import get_setting, set_setting

APP_RELEASE_KEY = "app_release"

DEFAULT_IOS_NOTE = "iOS 版尚未上架 App Store，敬请期待。"


def _default_payload() -> dict[str, Any]:
    return {
        "enabled": True,
        "android_version": "",
        "android_version_code": 0,
        "android_apk_url": "",
        "android_changelog": "",
        "force_update": False,
        "min_supported_version_code": 0,
        "ios_note": DEFAULT_IOS_NOTE,
        "ios_link": "",
    }


def _as_int(value: Any, default: int = 0) -> int:
    try:
        n = int(value)
    except (TypeError, ValueError):
        return default
    return max(0, n)


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
    data["enabled"] = bool(data.get("enabled", True))
    data["android_version"] = str(data.get("android_version") or "").strip()[:64]
    data["android_version_code"] = _as_int(data.get("android_version_code"), 0)
    data["android_apk_url"] = str(data.get("android_apk_url") or "").strip()[:1024]
    data["android_changelog"] = str(data.get("android_changelog") or "").strip()[:4000]
    data["force_update"] = bool(data.get("force_update", False))
    data["min_supported_version_code"] = _as_int(data.get("min_supported_version_code"), 0)
    data["ios_note"] = str(data.get("ios_note") or DEFAULT_IOS_NOTE).strip()[:1000] or DEFAULT_IOS_NOTE
    data["ios_link"] = str(data.get("ios_link") or "").strip()[:1024]
    return data


def save_app_release(db: Session, patch: dict[str, Any]) -> dict[str, Any]:
    current = get_app_release(db)
    for key in current:
        if key in patch and patch[key] is not None:
            current[key] = patch[key]
    current = {
        "enabled": bool(current.get("enabled", True)),
        "android_version": str(current.get("android_version") or "").strip()[:64],
        "android_version_code": _as_int(current.get("android_version_code"), 0),
        "android_apk_url": str(current.get("android_apk_url") or "").strip()[:1024],
        "android_changelog": str(current.get("android_changelog") or "").strip()[:4000],
        "force_update": bool(current.get("force_update", False)),
        "min_supported_version_code": _as_int(current.get("min_supported_version_code"), 0),
        "ios_note": str(current.get("ios_note") or DEFAULT_IOS_NOTE).strip()[:1000] or DEFAULT_IOS_NOTE,
        "ios_link": str(current.get("ios_link") or "").strip()[:1024],
    }
    set_setting(db, APP_RELEASE_KEY, json.dumps(current, ensure_ascii=False))
    return current


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
        "android_changelog": data.get("android_changelog") or "" if enabled else "",
        "force_update": bool(data.get("force_update")) if enabled else False,
        "min_supported_version_code": int(data.get("min_supported_version_code") or 0) if enabled else 0,
        "ios_note": data.get("ios_note") or DEFAULT_IOS_NOTE,
        "ios_link": data.get("ios_link") or "" if enabled else "",
        "has_android": bool(apk),
    }


def check_app_version(db: Session, *, current_version_code: int) -> dict[str, Any]:
    """App 内检查更新。"""
    data = get_app_release(db)
    enabled = bool(data.get("enabled"))
    latest_code = _as_int(data.get("android_version_code"), 0)
    min_code = _as_int(data.get("min_supported_version_code"), 0)
    apk = str(data.get("android_apk_url") or "").strip()
    current = max(0, int(current_version_code or 0))

    has_update = bool(enabled and apk and latest_code > current)
    force = False
    if has_update:
        force = bool(data.get("force_update")) or (min_code > 0 and current < min_code)

    return {
        "has_update": has_update,
        "force_update": force,
        "latest_version": data.get("android_version") or "" if has_update else "",
        "latest_version_code": latest_code if has_update else 0,
        "android_apk_url": apk if has_update else "",
        "android_changelog": (data.get("android_changelog") or "") if has_update else "",
        "download_page_path": "/download",
    }
