"""AI 功能日额度 + 调用计量落库。

普通用户共享每日额度（FREE_AI_DAILY_LIMIT，默认 10）；会员不限但同样记用量。
计量事件写入 ai_usage_events，供管理端看板与对账。
"""

from __future__ import annotations

import json
import logging
import os
from datetime import date, datetime, timedelta
from typing import Any

from fastapi import HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from ..demo_access import user_is_member
from ..models import AiUsageEvent, User
from .daily_visits import visit_date_now

logger = logging.getLogger(__name__)

DEFAULT_FREE_DAILY = 10

# 展示用中文名（管理端）
ACTION_LABELS: dict[str, str] = {
    "explain": "句旁讲解",
    "cloze": "AI 挖空",
    "shadowing_llm": "跟读 LLM 点评",
    "oral_feedback": "口语评测点评",
    "shadowing_text": "文本跟读点评",
    "reading_qa": "读报问答",
    "vocab_review": "生词复习卡",
    "oral_warrant": "口语评测授权",
    "practice_tts": "练习 TTS",
    "lookup_deepseek": "查词 DeepSeek",
    "example_translate": "例句翻译",
}


def free_ai_daily_limit() -> int:
    raw = (os.getenv("FREE_AI_DAILY_LIMIT") or "").strip()
    if not raw:
        return DEFAULT_FREE_DAILY
    try:
        return max(0, int(raw))
    except ValueError:
        return DEFAULT_FREE_DAILY


def _usage_date(*, now_utc: datetime | None = None) -> date:
    return visit_date_now(now_utc=now_utc)


def count_quota_used(db: Session, user_id: int, *, usage_date: date | None = None) -> int:
    day = usage_date or _usage_date()
    return int(
        db.query(func.count(AiUsageEvent.id))
        .filter(
            AiUsageEvent.user_id == user_id,
            AiUsageEvent.usage_date == day,
            AiUsageEvent.counts_quota.is_(True),
        )
        .scalar()
        or 0
    )


def get_quota_status(db: Session, user: User) -> dict:
    """不消耗额度，仅查询今日剩余。"""
    if user_is_member(user):
        return {"is_member": True, "limit": None, "used": 0, "remaining": None}
    limit = free_ai_daily_limit()
    used = count_quota_used(db, user.id)
    return {
        "is_member": False,
        "limit": limit,
        "used": used,
        "remaining": max(0, limit - used),
    }


def record_usage(
    db: Session,
    user: User | None,
    *,
    action: str,
    provider: str = "",
    billed: bool = True,
    cache_hit: bool = False,
    counts_quota: bool = False,
    meta: dict[str, Any] | None = None,
    commit: bool = True,
) -> AiUsageEvent:
    """写入一条用量事件。commit=True 时立即提交，便于多 worker 看到最新计数。"""
    day = _usage_date()
    event = AiUsageEvent(
        user_id=user.id if user else None,
        action=(action or "unknown").strip()[:32] or "unknown",
        provider=(provider or "").strip()[:32],
        billed=bool(billed),
        cache_hit=bool(cache_hit),
        counts_quota=bool(counts_quota),
        usage_date=day,
        meta_json=json.dumps(meta or {}, ensure_ascii=False)[:2000],
        created_at=datetime.utcnow(),
    )
    db.add(event)
    if commit:
        try:
            db.commit()
        except Exception:
            db.rollback()
            logger.exception("ai_usage commit failed action=%s", action)
            raise
    else:
        db.flush()
    return event


def _provider_for_action(action: str) -> str:
    if action in ("oral_feedback",):
        return "rule"
    if action in ("oral_warrant",):
        return "oral_eval"
    if action in ("practice_tts",):
        return "dashscope"
    if action in ("lookup_deepseek",):
        return "deepseek"
    return "deepseek"


def _billed_for_action(action: str) -> bool:
    # oral_feedback 为规则点评，成本在 warrant；其余默认计为外部调用
    return action not in ("oral_feedback",)


def check_and_consume(db: Session, user: User, *, action: str = "ai") -> dict:
    """会员跳过额度校验但仍记用量；普通用户消耗 1 次日额度。"""
    action_key = (action or "ai").strip()[:32] or "ai"
    provider = _provider_for_action(action_key)
    billed = _billed_for_action(action_key)

    if user_is_member(user):
        record_usage(
            db,
            user,
            action=action_key,
            provider=provider,
            billed=billed,
            counts_quota=False,
        )
        return {"is_member": True, "limit": None, "used": 0, "remaining": None}

    limit = free_ai_daily_limit()
    used = count_quota_used(db, user.id)
    if used >= limit:
        raise HTTPException(
            status_code=403,
            detail=f"今日 AI 次数已用完（{limit} 次），开通会员可无限使用",
        )

    record_usage(
        db,
        user,
        action=action_key,
        provider=provider,
        billed=billed,
        counts_quota=True,
    )
    return {
        "is_member": False,
        "limit": limit,
        "used": used + 1,
        "remaining": max(0, limit - used - 1),
    }


def admin_ai_usage_stats(db: Session, *, days: int = 7) -> dict:
    """管理端用量汇总：今日、按能力、Top 用户、近 N 日趋势。"""
    days = max(1, min(90, int(days or 7)))
    today = _usage_date()
    start = today - timedelta(days=days - 1)

    def _count(*, day: date | None = None, billed_only: bool = False, since: date | None = None) -> int:
        q = db.query(func.count(AiUsageEvent.id))
        if day is not None:
            q = q.filter(AiUsageEvent.usage_date == day)
        if since is not None:
            q = q.filter(AiUsageEvent.usage_date >= since)
        if billed_only:
            q = q.filter(AiUsageEvent.billed.is_(True), AiUsageEvent.cache_hit.is_(False))
        return int(q.scalar() or 0)

    today_total = _count(day=today)
    today_billed = _count(day=today, billed_only=True)
    period_total = _count(since=start)
    period_billed = _count(since=start, billed_only=True)

    by_action_rows = (
        db.query(AiUsageEvent.action, func.count(AiUsageEvent.id))
        .filter(AiUsageEvent.usage_date >= start)
        .group_by(AiUsageEvent.action)
        .all()
    )
    by_action: list[dict] = []
    for action, total in by_action_rows:
        billed = int(
            db.query(func.count(AiUsageEvent.id))
            .filter(
                AiUsageEvent.usage_date >= start,
                AiUsageEvent.action == action,
                AiUsageEvent.billed.is_(True),
                AiUsageEvent.cache_hit.is_(False),
            )
            .scalar()
            or 0
        )
        by_action.append(
            {
                "action": action,
                "label": ACTION_LABELS.get(action, action),
                "total": int(total or 0),
                "billed": billed,
            }
        )
    by_action.sort(key=lambda x: (-x["billed"], -x["total"], x["action"]))

    top_rows = (
        db.query(
            AiUsageEvent.user_id,
            User.email,
            func.count(AiUsageEvent.id).label("total"),
        )
        .outerjoin(User, User.id == AiUsageEvent.user_id)
        .filter(AiUsageEvent.usage_date >= start, AiUsageEvent.user_id.isnot(None))
        .group_by(AiUsageEvent.user_id, User.email)
        .order_by(func.count(AiUsageEvent.id).desc())
        .limit(20)
        .all()
    )
    top_users = []
    for uid, email, total in top_rows:
        billed = int(
            db.query(func.count(AiUsageEvent.id))
            .filter(
                AiUsageEvent.usage_date >= start,
                AiUsageEvent.user_id == uid,
                AiUsageEvent.billed.is_(True),
                AiUsageEvent.cache_hit.is_(False),
            )
            .scalar()
            or 0
        )
        top_users.append(
            {
                "user_id": int(uid),
                "email": email or f"user#{uid}",
                "total": int(total or 0),
                "billed": billed,
            }
        )

    daily_map = {
        str(r[0]): {"date": str(r[0]), "total": int(r[1] or 0), "billed": 0}
        for r in (
            db.query(AiUsageEvent.usage_date, func.count(AiUsageEvent.id))
            .filter(AiUsageEvent.usage_date >= start)
            .group_by(AiUsageEvent.usage_date)
            .all()
        )
    }
    for day, cnt in (
        db.query(AiUsageEvent.usage_date, func.count(AiUsageEvent.id))
        .filter(
            AiUsageEvent.usage_date >= start,
            AiUsageEvent.billed.is_(True),
            AiUsageEvent.cache_hit.is_(False),
        )
        .group_by(AiUsageEvent.usage_date)
        .all()
    ):
        key = str(day)
        if key not in daily_map:
            daily_map[key] = {"date": key, "total": 0, "billed": 0}
        daily_map[key]["billed"] = int(cnt or 0)

    daily = []
    for i in range(days):
        d = start + timedelta(days=i)
        key = str(d)
        daily.append(daily_map.get(key, {"date": key, "total": 0, "billed": 0}))

    free_quota_used_today = int(
        db.query(func.count(AiUsageEvent.id))
        .filter(
            AiUsageEvent.usage_date == today,
            AiUsageEvent.counts_quota.is_(True),
        )
        .scalar()
        or 0
    )

    return {
        "days": days,
        "today": str(today),
        "today_total": today_total,
        "today_billed": today_billed,
        "period_total": period_total,
        "period_billed": period_billed,
        "free_quota_used_today": free_quota_used_today,
        "free_daily_limit": free_ai_daily_limit(),
        "by_action": by_action,
        "top_users": top_users,
        "daily": daily,
    }
