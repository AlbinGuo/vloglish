"""一次性将「已注册未会员」用户批量开通会员（历史数据迁移）。

用法（必须在 backend 目录、使用项目虚拟环境）:

  Windows（PowerShell）:
    cd D:\\code\\teco-lab\\backend
    .\\.venv\\Scripts\\python.exe scripts\\upgrade_legacy_members.py
    .\\.venv\\Scripts\\python.exe scripts\\upgrade_legacy_members.py --apply

  或在 backend 目录:
    python scripts/upgrade_legacy_members.py
    python scripts/upgrade_legacy_members.py --apply

  若报 No module named 'psycopg'，说明未用 .venv，请先:
    .venv\\Scripts\\activate
    pip install -r requirements.txt

默认只处理 is_active=True、is_member=False、is_staff=False 的普通用户。
"""
from __future__ import annotations

import argparse
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.database import SessionLocal
from app.models import User


def fmt_dt(value: datetime | None) -> str:
    if not value:
        return "-"
    return value.strftime("%Y-%m-%d %H:%M:%S")


def main() -> None:
    parser = argparse.ArgumentParser(description="批量开通历史未会员用户")
    parser.add_argument(
        "--apply",
        action="store_true",
        help="写入数据库（默认仅预览）",
    )
    args = parser.parse_args()

    db = SessionLocal()
    try:
        rows = (
            db.query(User)
            .filter(
                User.is_active.is_(True),
                User.is_member.is_(False),
                User.is_staff.is_(False),
            )
            .order_by(User.id.asc())
            .all()
        )

        if not rows:
            print("没有需要开通的用户。")
            return

        print(f"共 {len(rows)} 个用户待开通会员：")
        for u in rows:
            print(f"  id={u.id}  email={u.email}  created_at={fmt_dt(u.created_at)}")

        if not args.apply:
            print("\n以上为预览。确认后执行：python scripts/upgrade_legacy_members.py --apply")
            return

        now = datetime.utcnow()
        for u in rows:
            u.is_member = True
            if not u.member_activated_at:
                u.member_activated_at = now
        db.commit()
        print(f"\n已开通 {len(rows)} 个用户。")
    finally:
        db.close()


if __name__ == "__main__":
    main()
