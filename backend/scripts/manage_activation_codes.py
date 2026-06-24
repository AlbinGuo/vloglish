"""激活码管理：生成、列表、查询、删除未使用的码。

用法（在 backend 目录下）:
  python scripts/manage_activation_codes.py generate --count 5
  python scripts/manage_activation_codes.py list
  python scripts/manage_activation_codes.py list --status available
  python scripts/manage_activation_codes.py show AB3K
  python scripts/manage_activation_codes.py delete AB3K
  python scripts/manage_activation_codes.py import codes.txt
  python scripts/manage_activation_codes.py stats
"""
from __future__ import annotations

import argparse
import secrets
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from app.database import SessionLocal
from app.models import ActivationCode, User


def fmt_dt(value: datetime | None) -> str:
    if not value:
        return "-"
    return value.strftime("%Y-%m-%d %H:%M:%S")


CODE_LENGTH = 4
# 去掉易混淆字符 0/O、1/I/L
CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"


def generate_code() -> str:
    return "".join(secrets.choice(CODE_ALPHABET) for _ in range(CODE_LENGTH))


def unique_code(db, max_attempts: int = 50) -> str:
    for _ in range(max_attempts):
        code = generate_code()
        exists = db.query(ActivationCode.id).filter(ActivationCode.code == code).first()
        if not exists:
            return code
    raise RuntimeError("无法生成唯一激活码，请稍后重试")


def cmd_generate(args: argparse.Namespace) -> None:
    db = SessionLocal()
    created: list[str] = []
    try:
        for _ in range(args.count):
            code = unique_code(db)
            db.add(ActivationCode(code=code))
            created.append(code)
        db.commit()
    finally:
        db.close()

    print(f"已生成 {len(created)} 个激活码:")
    for code in created:
        print(code)

    if args.output:
        out = Path(args.output)
        out.write_text("\n".join(created) + "\n", encoding="utf-8")
        print(f"\n已写入: {out.resolve()}")


def cmd_import(args: argparse.Namespace) -> None:
    path = Path(args.file)
    if not path.is_file():
        raise SystemExit(f"文件不存在: {path}")

    raw_lines = path.read_text(encoding="utf-8").splitlines()
    codes = [line.strip() for line in raw_lines if line.strip() and not line.strip().startswith("#")]
    if not codes:
        raise SystemExit("文件中没有有效激活码")

    db = SessionLocal()
    inserted = 0
    skipped = 0
    try:
        for code in codes:
            exists = db.query(ActivationCode.id).filter(ActivationCode.code == code).first()
            if exists:
                skipped += 1
                continue
            db.add(ActivationCode(code=code))
            inserted += 1
        db.commit()
    finally:
        db.close()

    print(f"导入完成: 新增 {inserted} 个，跳过重复 {skipped} 个")


def cmd_list(args: argparse.Namespace) -> None:
    db = SessionLocal()
    try:
        rows = (
            db.query(ActivationCode, User.email)
            .outerjoin(User, User.id == ActivationCode.used_by_user_id)
            .order_by(ActivationCode.id.desc())
            .all()
        )
    finally:
        db.close()

    if args.status == "available":
        rows = [(code, email) for code, email in rows if code.used_by_user_id is None]
    elif args.status == "used":
        rows = [(code, email) for code, email in rows if code.used_by_user_id is not None]

    if not rows:
        print("没有匹配的激活码")
        return

    print(f"{'CODE':<8} {'STATUS':<10} {'USER':<28} {'USED_AT':<20} {'CREATED_AT'}")
    print("-" * 100)
    for code, email in rows:
        status = "used" if code.used_by_user_id else "available"
        print(
            f"{code.code:<8} {status:<10} {(email or '-'):<28} "
            f"{fmt_dt(code.used_at):<20} {fmt_dt(code.created_at)}"
        )
    print(f"\n共 {len(rows)} 条")


def cmd_show(args: argparse.Namespace) -> None:
    db = SessionLocal()
    try:
        row = (
            db.query(ActivationCode, User.email)
            .outerjoin(User, User.id == ActivationCode.used_by_user_id)
            .filter(ActivationCode.code == args.code.strip())
            .first()
        )
    finally:
        db.close()

    if not row:
        raise SystemExit(f"激活码不存在: {args.code}")

    code, email = row
    print(f"Code:       {code.code}")
    print(f"Status:     {'used' if code.used_by_user_id else 'available'}")
    print(f"User ID:    {code.used_by_user_id or '-'}")
    print(f"User Email: {email or '-'}")
    print(f"Used At:    {fmt_dt(code.used_at)}")
    print(f"Created At: {fmt_dt(code.created_at)}")


def cmd_delete(args: argparse.Namespace) -> None:
    db = SessionLocal()
    try:
        code = db.query(ActivationCode).filter(ActivationCode.code == args.code.strip()).first()
        if not code:
            raise SystemExit(f"激活码不存在: {args.code}")
        if code.used_by_user_id is not None:
            raise SystemExit("已使用的激活码不能删除")
        db.delete(code)
        db.commit()
    finally:
        db.close()
    print(f"已删除: {args.code}")


def cmd_stats(_: argparse.Namespace) -> None:
    db = SessionLocal()
    try:
        total = db.query(ActivationCode).count()
        used = db.query(ActivationCode).filter(ActivationCode.used_by_user_id.isnot(None)).count()
    finally:
        db.close()
    available = total - used
    print(f"Total:     {total}")
    print(f"Available: {available}")
    print(f"Used:      {used}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Vloglish 激活码管理")
    sub = parser.add_subparsers(dest="command", required=True)

    p_generate = sub.add_parser("generate", help="批量生成 4 位激活码")
    p_generate.add_argument("--count", "-n", type=int, default=1, help="生成数量")
    p_generate.add_argument("--output", "-o", help="同时写入文件")
    p_generate.set_defaults(func=cmd_generate)

    p_import = sub.add_parser("import", help="从文本文件导入（每行一个码，# 开头为注释）")
    p_import.add_argument("file", help="文本文件路径")
    p_import.set_defaults(func=cmd_import)

    p_list = sub.add_parser("list", help="列出激活码")
    p_list.add_argument(
        "--status",
        choices=("all", "available", "used"),
        default="all",
        help="筛选状态",
    )
    p_list.set_defaults(func=cmd_list)

    p_show = sub.add_parser("show", help="查看单个激活码")
    p_show.add_argument("code", help="激活码")
    p_show.set_defaults(func=cmd_show)

    p_delete = sub.add_parser("delete", help="删除未使用的激活码")
    p_delete.add_argument("code", help="激活码")
    p_delete.set_defaults(func=cmd_delete)

    p_stats = sub.add_parser("stats", help="统计数量")
    p_stats.set_defaults(func=cmd_stats)

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
