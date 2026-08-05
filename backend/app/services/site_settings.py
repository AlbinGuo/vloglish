"""站点级配置读写。"""

from __future__ import annotations

from datetime import datetime

from sqlalchemy.orm import Session

from ..models import SiteSetting

MEMBERSHIP_GATE_KEY = "membership_gate_enabled"
# 默认启用 Freemium 内容限制
DEFAULT_MEMBERSHIP_GATE_ENABLED = True


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
    raw = get_setting(db, MEMBERSHIP_GATE_KEY, "true" if DEFAULT_MEMBERSHIP_GATE_ENABLED else "false")
    return raw.strip().lower() in ("1", "true", "yes", "on")


def set_membership_gate_enabled(db: Session, enabled: bool) -> bool:
    set_setting(db, MEMBERSHIP_GATE_KEY, "true" if enabled else "false")
    return enabled


def content_access_unlocked(db: Session, user) -> bool:
    """关门槛期间：已登录用户可访问全部视频/合集/文章（AI 仍看 is_member）。"""
    return user is not None and not is_membership_gate_enabled(db)
