"""Sync episode DB records from existing Qiniu media (no re-download/upload)."""
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
from app.qiniu_storage import QiniuConfig
from app.services.teco_client import TecoAuthClient
from app.services.teco_fetch import sync_db_from_qiniu_range


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Write episode rows to DB when video.mp4 already exists on Qiniu"
    )
    parser.add_argument("--index-from", type=int, default=150)
    parser.add_argument("--index-to", type=int, default=190)
    parser.add_argument("--status", default="published", choices=["published", "draft", "archived"])
    parser.add_argument("--force-update", action="store_true", help="Update rows even if already in DB")
    parser.add_argument("--include-existing", action="store_true", help="Do not skip existing DB rows")
    args = parser.parse_args()

    client = TecoAuthClient.from_env()
    cfg = QiniuConfig.from_env()
    db = SessionLocal()

    try:
        result = sync_db_from_qiniu_range(
            db,
            client,
            cfg,
            index_from=args.index_from,
            index_to=args.index_to,
            status=args.status,
            skip_existing=not args.include_existing and not args.force_update,
            force_update=args.force_update,
        )
    finally:
        db.close()

    print(json.dumps(result, ensure_ascii=False, indent=2))
    print(
        f"\nDone: created={result['created']} updated={result['updated']} "
        f"skipped={result['skipped']} failed={result['failed']}"
    )
    if result["errors"]:
        sys.exit(1)


if __name__ == "__main__":
    main()
