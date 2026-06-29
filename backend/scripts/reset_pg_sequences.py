"""Reset PostgreSQL serial sequences after manual data import (pg_dump / copy).

Usage (from backend/):
  set DATABASE_URL=postgresql+psycopg://postgres:pass@127.0.0.1:15432/postgres
  python scripts/reset_pg_sequences.py

On server:
  docker compose --env-file .env.prod exec backend python scripts/reset_pg_sequences.py
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine, text

BACKEND_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BACKEND_DIR))

load_dotenv(BACKEND_DIR / ".env")

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


def require_postgres_url() -> str:
    url = os.getenv("DATABASE_URL", "")
    if not url.startswith("postgresql"):
        print("ERROR: DATABASE_URL must be a PostgreSQL URL")
        sys.exit(1)
    return url


def reset_serial_sequences(engine) -> None:
    with engine.begin() as conn:
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
                next_val = conn.execute(
                    text("SELECT setval(:seq, :val, true)"),
                    {"seq": seq, "val": max_id},
                ).scalar_one()
            else:
                next_val = conn.execute(
                    text("SELECT setval(:seq, 1, false)"),
                    {"seq": seq},
                ).scalar_one()
            print(f"  {table_name}: max_id={max_id}, sequence next={next_val}")


def main() -> None:
    url = require_postgres_url()
    engine = create_engine(url, pool_pre_ping=True)
    print(f"Resetting sequences on {url.split('@')[-1]}")
    reset_serial_sequences(engine)
    print("Done.")


if __name__ == "__main__":
    main()
