"""站点级配置读写。"""

from __future__ import annotations

import json
import time
from datetime import datetime

from sqlalchemy.orm import Session

from ..models import SiteSetting

MEMBERSHIP_GATE_KEY = "membership_gate_enabled"
# 默认启用 Freemium 内容限制
DEFAULT_MEMBERSHIP_GATE_ENABLED = True

# 新用户是否需要在登录后选择学习语言（关闭时直接进入英语）
LANGUAGE_SELECTION_KEY = "language_selection_enabled"
DEFAULT_LANGUAGE_SELECTION_ENABLED = True
# 可供用户选择的目标语言（有序，管理端可增删）
AVAILABLE_LANGUAGES_KEY = "available_target_languages"
DEFAULT_AVAILABLE_LANGUAGES = ["en", "de", "fr"]

_gate_enabled: bool | None = None
_gate_expires_at = 0.0


def get_setting(db: Session, key: str, default: str = "") -> str:
    row = db.query(SiteSetting).filter(SiteSetting.key == key).first()
    if not row:
        return default
    return row.value


def set_setting(db: Session, key: str, value: str) -> SiteSetting:
    row = db.query(SiteSetting).filter(SiteSetting.key == key).first()
    if not row:
        row = SiteSetting(key=key, value=value)
        db.add(row)
    else:
        row.value = value
        row.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(row)
    return row


def is_membership_gate_enabled(db: Session) -> bool:
    """是否启用会员内容限制。默认 True（开启 Freemium）。"""
    global _gate_enabled, _gate_expires_at
    now = time.time()
    if _gate_enabled is not None and _gate_expires_at > now:
        return _gate_enabled
    raw = get_setting(db, MEMBERSHIP_GATE_KEY, "true" if DEFAULT_MEMBERSHIP_GATE_ENABLED else "false")
    enabled = raw.strip().lower() in ("1", "true", "yes", "on")
    _gate_enabled = enabled
    _gate_expires_at = now + 8
    return enabled


def set_membership_gate_enabled(db: Session, enabled: bool) -> bool:
    global _gate_enabled, _gate_expires_at
    set_setting(db, MEMBERSHIP_GATE_KEY, "true" if enabled else "false")
    _gate_enabled = enabled
    _gate_expires_at = time.time() + 8
    return enabled


def is_language_selection_enabled(db: Session) -> bool:
    """新用户登录后是否需要选择学习语言。默认 True。"""
    raw = get_setting(db, LANGUAGE_SELECTION_KEY, "true" if DEFAULT_LANGUAGE_SELECTION_ENABLED else "false")
    return raw.strip().lower() in ("1", "true", "yes", "on")


def set_language_selection_enabled(db: Session, enabled: bool) -> bool:
    set_setting(db, LANGUAGE_SELECTION_KEY, "true" if enabled else "false")
    return enabled


def get_available_target_languages(db: Session) -> list[str]:
    raw = get_setting(db, AVAILABLE_LANGUAGES_KEY, "")
    if not raw:
        return list(DEFAULT_AVAILABLE_LANGUAGES)
    try:
        data = json.loads(raw)
        if isinstance(data, list):
            codes = [str(c).strip().lower() for c in data if str(c).strip()]
            return codes or list(DEFAULT_AVAILABLE_LANGUAGES)
    except (ValueError, TypeError):
        pass
    codes = [c.strip().lower() for c in raw.split(",") if c.strip()]
    return codes or list(DEFAULT_AVAILABLE_LANGUAGES)


def set_available_target_languages(db: Session, codes: list[str]) -> list[str]:
    cleaned = [str(c).strip().lower() for c in codes if str(c).strip()]
    set_setting(db, AVAILABLE_LANGUAGES_KEY, json.dumps(cleaned))
    return cleaned


def content_access_unlocked(db: Session, user) -> bool:    """关门槛期间：已登录用户可访问全部视频/合集/文章，并可用上传/语料库等会员工具（AI 仍看 is_member）。"""
    return user is not None and not is_membership_gate_enabled(db)
