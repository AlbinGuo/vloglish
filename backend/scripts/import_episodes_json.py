"""Import episodes JSON into current DATABASE_URL / db_switch (upsert by video_id)."""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from dotenv import load_dotenv

load_dotenv(ROOT / ".env")

from app.database import SessionLocal
from app.db_url import database_host_label, resolve_database_url
from app.services.episode_json_import import import_episodes_json


def main() -> None:
    parser = argparse.ArgumentParser(description="Import episodes JSON into DB")
    parser.add_argument("json_file", type=Path, help="Path to episodes export JSON")
    parser.add_argument(
        "--status",
        default="published",
        choices=["published", "draft", "archived"],
        help="Status for new/updated episodes",
    )
    parser.add_argument("--mark-demo", action="store_true", help="Mark imported episodes as demo")
    args = parser.parse_args()

    if not args.json_file.is_file():
        raise SystemExit(f"File not found: {args.json_file}")

    db_url = resolve_database_url("sqlite")
    print(f"[import] database → {database_host_label(db_url)}")

    payload = json.loads(args.json_file.read_text(encoding="utf-8"))
    db = SessionLocal()
    try:
        result = import_episodes_json(
            db,
            payload,
            default_status=args.status,
            mark_demo=args.mark_demo,
        )
    finally:
        db.close()

    print(json.dumps(result, ensure_ascii=False, indent=2))
    print(
        f"\nDone: created={result['created']} updated={result['updated']} "
        f"total={result['total']} errors={len(result['errors'])}"
    )
    if result["errors"]:
        sys.exit(1)


if __name__ == "__main__":
    main()
