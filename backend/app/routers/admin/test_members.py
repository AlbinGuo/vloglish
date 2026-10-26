"""管理后台：外部测试（TestFlight）试用会员的查看与一键清理。"""
from __future__ import annotations

from datetime import datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import User
from ...schemas import (
    AdminPurgeTestMembersOut,
    AdminTestMemberListOut,
    AdminTestMemberOut,
)
from ...services.membership_config import external_test_mode_enabled

router = APIRouter(prefix="/api/admin/test-members", tags=["admin-test-members"])

# 视为「测试/沙盒」会员的来源
TEST_SOURCES = ("test_trial", "apple_iap_sandbox")


def _fmt_dt(value: datetime | None) -> str | None:
    if not value:
        return None
    return value.strftime("%Y-%m-%d %H:%M:%S")


@router.get("/", response_model=AdminTestMemberListOut)
def list_test_members(
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    q = db.query(User).filter(User.member_source.in_(TEST_SOURCES))
    total = q.count()
    rows = (
        q.order_by(User.member_until.desc().nullslast(), User.id.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
        .all()
    )
    results = [
        AdminTestMemberOut(
            id=u.id,
            email=u.email,
            nickname=u.nickname,
            member_source=u.member_source,
            member_plan=u.member_plan,
            member_until=_fmt_dt(u.member_until),
            is_member=bool(u.is_member),
        )
        for u in rows
    ]
    return AdminTestMemberListOut(count=total, results=results)


@router.post("/purge/", response_model=AdminPurgeTestMembersOut)
def purge_test_members(
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    """一键撤销所有测试/沙盒会员。

    与 scripts/revoke_test_memberships.py --apply 等价：
    - 清空 is_member / member_until / member_plan；
    - member_source 追加 '_revoked' 便于审计。
    """
    rows = db.query(User).filter(User.member_source.in_(TEST_SOURCES)).all()
    for u in rows:
        u.is_member = False
        u.member_until = None
        u.member_plan = None
        src = u.member_source or ""
        if src and not src.endswith("_revoked"):
            u.member_source = f"{src}_revoked"
    if rows:
        db.commit()
    return AdminPurgeTestMembersOut(
        revoked=len(rows),
        test_mode_enabled=external_test_mode_enabled(),
    )
