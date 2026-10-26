"""发布正式版前撤销所有「沙盒 / 外部测试试用」会员。

用法（在 backend 目录、已配置好 DATABASE_URL 的环境执行）：
    python scripts/revoke_test_memberships.py           # 默认只预览，不写库
    python scripts/revoke_test_memberships.py --apply    # 真正执行撤销

撤销范围：
    users.member_source in ('apple_iap_sandbox', 'test_trial')
撤销后：
    is_member=False, member_until=None, member_plan=None,
    member_source 追加 '_revoked' 便于审计（保留原值痕迹）。

可选：同时删除 apple_iap_transactions 中 is_sandbox=True 的流水（--purge-tx）。
"""
from __future__ import annotations

import sys

from app.database import SessionLocal
from app.models import AppleIapTransaction, User

TEST_SOURCES = ("apple_iap_sandbox", "test_trial")


def main() -> int:
    apply = "--apply" in sys.argv
    purge_tx = "--purge-tx" in sys.argv

    db = SessionLocal()
    try:
        rows = db.query(User).filter(User.member_source.in_(TEST_SOURCES)).all()
        print(f"待处理用户：{len(rows)} 个（来源 {TEST_SOURCES}）")
        for u in rows:
            print(f"  - id={u.id} email={u.email} source={u.member_source} until={u.member_until}")
        if not apply:
            print("\n预览模式：未写入。加 --apply 才会真正撤销。")
            return 0

        for u in rows:
            u.is_member = False
            u.member_until = None
            u.member_plan = None
            src = u.member_source or ""
            u.member_source = f"{src}_revoked" if src and not src.endswith("_revoked") else src
        db.commit()
        print(f"\n已撤销 {len(rows)} 个测试/沙盒会员。")

        if purge_tx:
            tx_rows = (
                db.query(AppleIapTransaction)
                .filter(AppleIapTransaction.is_sandbox.is_(True))
                .all()
            )
            for tx in tx_rows:
                db.delete(tx)
            db.commit()
            print(f"已删除 {len(tx_rows)} 条沙盒交易流水。")
        return 0
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
