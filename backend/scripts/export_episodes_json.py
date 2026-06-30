"""Export episodes (+ subtitles) from current DATABASE_URL / db_switch to JSON."""
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
from app.services.episode_json_import import export_episodes_json


def main() -> None:
    parser = argparse.ArgumentParser(description="Export episodes from DB to JSON")
    parser.add_argument("--index-from", type=int, help="Export from episode index (inclusive)")
    parser.add_argument("--index-to", type=int, help="Export to episode index (inclusive)")
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=ROOT.parent / "analysis" / "episodes-export.json",
        help="Output JSON path",
    )
    args = parser.parse_args()

    db_url = resolve_database_url("sqlite")
    print(f"[export] database → {database_host_label(db_url)}")

    db = SessionLocal()
    try:
        data = export_episodes_json(
            db,
            index_from=args.index_from,
            index_to=args.index_to,
        )
    finally:
        db.close()

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Exported {len(data.get('episodes', []))} episodes → {args.output}")


if __name__ == "__main__":
    main()
