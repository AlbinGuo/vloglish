"""AI 功能日额度：普通用户有限，会员不限。"""

from __future__ import annotations

import os
from datetime import datetime

from fastapi import HTTPException
from sqlalchemy.orm import Session

from ..demo_access import user_is_member
from ..models import User
from .daily_visits import visit_date_now

# 进程内简易计数（多 worker 不共享；生产可换 Redis）。键：user_id:YYYY-MM-DD:action
_USAGE: dict[str, int] = {}

DEFAULT_FREE_DAILY = 3


def free_ai_daily_limit() -> int:
    raw = (os.getenv("FREE_AI_DAILY_LIMIT") or "").strip()
    if not raw:
        return DEFAULT_FREE_DAILY
    try:
        return max(0, int(raw))
    except ValueError:
        return DEFAULT_FREE_DAILY


def _key(user_id: int, action: str) -> str:
    return f"{user_id}:{visit_date_now()}:{action}"


def check_and_consume(db: Session, user: User, *, action: str = "ai") -> dict:
    """会员跳过；普通用户消耗 1 次日额度。返回剩余信息。"""
    _ = db
    if user_is_member(user):
        return {"is_member": True, "limit": None, "used": 0, "remaining": None}

    limit = free_ai_daily_limit()
    key = _key(user.id, action)
    used = int(_USAGE.get(key, 0))
    if used >= limit:
        raise HTTPException(
            status_code=403,
            detail=f"今日 AI 次数已用完（{limit} 次），开通会员可无限使用",
        )
    _USAGE[key] = used + 1
    return {
        "is_member": False,
        "limit": limit,
        "used": used + 1,
        "remaining": max(0, limit - used - 1),
    }
