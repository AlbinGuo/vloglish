"""开通 / 取消会员。支付发货与管理端赠送共用。"""

from __future__ import annotations

from datetime import datetime, timedelta

from ..models import User

PLAN_WEEK = "week"
PLAN_QUARTER = "quarter"
PLAN_YEAR = "year"
PLAN_FOREVER = "forever"
PLAN_CUSTOM = "custom"
PLAN_FILTERS = frozenset({"none", PLAN_WEEK, PLAN_QUARTER, PLAN_YEAR, PLAN_FOREVER, PLAN_CUSTOM, "expired"})


def apply_membership(user: User, days: int | None, *, plan: str | None = None) -> None:
    """开通会员。days 为空表示永久；未过期再开限期则从原到期日叠加。"""
    now = datetime.utcnow()
    user.is_member = True
    if user.member_activated_at is None:
        user.member_activated_at = now
    if days is None:
        user.member_until = None
        user.member_plan = PLAN_FOREVER
        return
    n = int(days)
    if n < 1:
        raise ValueError("days must be >= 1")
    base = now
    if user.member_until and user.member_until > now:
        base = user.member_until
    user.member_until = base + timedelta(days=n)
    if plan in (PLAN_WEEK, PLAN_QUARTER, PLAN_YEAR, PLAN_CUSTOM):
        user.member_plan = plan
    else:
        user.member_plan = PLAN_CUSTOM


def revoke_membership(user: User) -> None:
    user.is_member = False
    user.member_activated_at = None
    user.member_until = None
    user.member_plan = None


def apply_membership_until(user: User, until: datetime | None, *, plan: str | None = None) -> None:
    """按「绝对到期时间」开通/延长会员，幂等（重复调用不会叠加）。

    until 为空表示永久。适用于订阅类购买：以交易自带的到期时间为准，
    重复校验同一笔交易不会重复加天数。
    """
    now = datetime.utcnow()
    user.is_member = True
    if user.member_activated_at is None:
        user.member_activated_at = now
    if until is None:
        user.member_until = None
        user.member_plan = PLAN_FOREVER
        return
    # 已经是永久会员，不因限期订阅而降级
    if user.member_until is None and user.member_plan == PLAN_FOREVER:
        return
    target = until
    if user.member_until and user.member_until > target:
        target = user.member_until
    user.member_until = target
    if plan in (PLAN_WEEK, PLAN_QUARTER, PLAN_YEAR, PLAN_CUSTOM):
        user.member_plan = plan
    elif user.member_plan is None:
        user.member_plan = PLAN_CUSTOM
