"""Migrate data from local SQLite to PostgreSQL.

Usage (from backend/):
  set DATABASE_URL=postgresql+psycopg://postgres:admin@localhost:5432/postgres
  python scripts/migrate_sqlite_to_postgres.py

Options:
  --sqlite PATH   SQLite file path (default: data/teco.db)
  --force         Clear target tables before import
"""
from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine, inspect, select, text
from sqlalchemy.orm import Session

BACKEND_DIR = Path(__file__).resolve().parent.parent
ROOT_DIR = BACKEND_DIR.parent
sys.path.insert(0, str(BACKEND_DIR))

load_dotenv(BACKEND_DIR / ".env")

from app.database import Base, DATA_DIR  # noqa: E402
from app.main import _migrate_schema  # noqa: E402
from app.models import Episode  # noqa: E402

TABLE_ORDER = [
    "tags",
    "authors",
    "users",
    "entries",
    "demo_codes",
    "activation_codes",
    "admin_broadcasts",
    "episodes",
    "subtitles",
    "episode_tags",
    "demo_episodes",
    "token_refs",
    "lookup_cache",
    "episode_favorites",
    "user_episode_favorites",
    "refresh_tokens",
    "password_reset_tokens",
    "user_notifications",
    "user_episode_progress",
    "user_subtitle_progress",
    "user_word_lookups",
    "user_vocabulary_items",
    "learning_sessions",
]

SERIAL_TABLES = [
    "authors",
    "users",
    "episodes",
    "refresh_tokens",
    "password_reset_tokens",
    "activation_codes",
    "demo_codes",
    "admin_broadcasts",
    "user_notifications",
    "user_episode_progress",
    "user_subtitle_progress",
    "user_word_lookups",
    "user_vocabulary_items",
    "learning_sessions",
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Migrate SQLite data to PostgreSQL")
    parser.add_argument(
        "--sqlite",
        default=str(DATA_DIR / "teco.db"),
        help="Path to SQLite database file",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Truncate target tables before import",
    )
    return parser.parse_args()


def require_postgres_url() -> str:
    url = os.getenv("DATABASE_URL", "")
    if not url.startswith("postgresql"):
        print("ERROR: DATABASE_URL must be a PostgreSQL URL, e.g.")
        print("  postgresql+psycopg://postgres:admin@localhost:5432/postgres")
        sys.exit(1)
    return url


def table_count(engine, table_name: str) -> int:
    insp = inspect(engine)
    if table_name not in insp.get_table_names():
        return 0
    with engine.connect() as conn:
        return conn.execute(text(f'SELECT COUNT(*) FROM "{table_name}"')).scalar_one()


def truncate_tables(engine) -> None:
    quoted = ", ".join(f'"{name}"' for name in reversed(TABLE_ORDER))
    with engine.begin() as conn:
        conn.execute(text(f"TRUNCATE TABLE {quoted} RESTART IDENTITY CASCADE"))


def copy_table(sqlite_engine, pg_engine, table_name: str) -> int:
    table = Base.metadata.tables.get(table_name)
    if table is None:
        print(f"  Skip {table_name}: model table not found")
        return 0

    with sqlite_engine.connect() as src:
        rows = src.execute(select(table)).mappings().all()
    if not rows:
        return 0

    payload = [dict(row) for row in rows]
    with pg_engine.begin() as dst:
        dst.execute(table.insert(), payload)
    return len(payload)


def reset_serial_sequences(pg_engine) -> None:
    with pg_engine.begin() as conn:
        for table_name in SERIAL_TABLES:
            seq = conn.execute(
                text("SELECT pg_get_serial_sequence(:table, 'id')"),
                {"table": table_name},
            ).scalar_one_or_none()
            if not seq:
                continue
            max_id = conn.execute(
                text(f'SELECT COALESCE(MAX(id), 0) FROM "{table_name}"')
            ).scalar_one()
            if max_id:
                conn.execute(text("SELECT setval(:seq, :val, true)"), {"seq": seq, "val": max_id})
            else:
                conn.execute(text("SELECT setval(:seq, 1, false)"), {"seq": seq})


def main() -> None:
    args = parse_args()
    pg_url = require_postgres_url()
    sqlite_path = Path(args.sqlite)
    if not sqlite_path.is_file():
        print(f"ERROR: SQLite file not found: {sqlite_path}")
        sys.exit(1)

    sqlite_url = f"sqlite:///{sqlite_path.as_posix()}"
    sqlite_engine = create_engine(sqlite_url, connect_args={"check_same_thread": False})
    pg_engine = create_engine(pg_url, pool_pre_ping=True)

    print(f"Source: {sqlite_path}")
    print(f"Target: {pg_url}")

    existing = table_count(pg_engine, "episodes")
    if existing and not args.force:
        print(f"Target already has {existing} episodes. Use --force to replace.")
        sys.exit(1)

    if args.force or table_count(pg_engine, "tags") > 0:
        print("Recreating PostgreSQL schema...")
        Base.metadata.drop_all(bind=pg_engine)

    Base.metadata.create_all(bind=pg_engine)
    _migrate_schema()

    total = 0
    with pg_engine.begin() as conn:
        if pg_engine.dialect.name == "postgresql":
            conn.execute(text("SET session_replication_role = 'replica'"))

    try:
        for table_name in TABLE_ORDER:
            copied = copy_table(sqlite_engine, pg_engine, table_name)
            if copied:
                print(f"  {table_name}: {copied} rows")
                total += copied
    finally:
        with pg_engine.begin() as conn:
            if pg_engine.dialect.name == "postgresql":
                conn.execute(text("SET session_replication_role = 'origin'"))

    reset_serial_sequences(pg_engine)

    with Session(pg_engine) as db:
        episode_count = db.query(Episode).count()
    print(f"Done. Imported {total} rows, episodes in PostgreSQL: {episode_count}")


if __name__ == "__main__":
    main()
