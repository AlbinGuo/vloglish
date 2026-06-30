"""Fetch episodes from teco-lab.com /english catalog (CLI; prefer admin UI import)."""
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
from app.services.teco_fetch import fetch_catalog_in_index_range, import_teco_episode

EXPORT_PATH = ROOT.parent / "analysis" / "imported-english-batch.json"


def main() -> None:
    parser = argparse.ArgumentParser(description="Import /english catalog episodes from teco-lab.com")
    parser.add_argument("limit", nargs="?", type=int, default=5, help="Number of episodes (default 5)")
    parser.add_argument("--index-from", type=int, help="Import from episode index (inclusive)")
    parser.add_argument("--index-to", type=int, help="Import to episode index (inclusive)")
    parser.add_argument("--token", help="Bearer access token (overrides env/session file)")
    parser.add_argument("--session", help="Path to teco_session.json exported from browser")
    parser.add_argument("--list-only", action="store_true", help="Only fetch and save episode list")
    parser.add_argument("--no-branding", action="store_true", help="Skip delogo/watermark/custom cover")
    args = parser.parse_args()

    if args.token:
        client = TecoAuthClient()
        client.access_token = args.token.strip()
    elif args.session:
        client = TecoAuthClient.from_session_file(Path(args.session))
    else:
        client = TecoAuthClient.from_env()

    if args.index_from is not None and args.index_to is not None:
        summaries = fetch_catalog_in_index_range(
            client, index_from=args.index_from, index_to=args.index_to
        )
    else:
        summaries = client.episode_list(page=1, page_size=args.limit)[: args.limit]

    if not summaries:
        raise SystemExit("No episodes returned from /api/episode-list/")

    print(f"Selected {len(summaries)} episodes:")
    for s in summaries:
        print(f"  - {s.get('video_id')} · {s.get('short_title', '')[:40]}")

    list_path = ROOT.parent / "analysis" / "imported-english-list.json"
    list_path.write_text(json.dumps({"episodes": summaries}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"List saved: {list_path}")

    if args.list_only:
        return

    cfg = QiniuConfig.from_env()
    db = SessionLocal()
    exported: dict = {"episodes": summaries, "details": []}

    try:
        for summary in summaries:
            detail_row = import_teco_episode(
                db,
                client,
                cfg,
                summary,
                status="published",
                apply_branding=not args.no_branding,
            )
            print(f"  {summary['video_id']}: {detail_row.get('message')}")
    finally:
        db.close()

    EXPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    EXPORT_PATH.write_text(json.dumps(exported, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"\nBackup path (legacy): {EXPORT_PATH}")
    print("Done.")


if __name__ == "__main__":
    main()
