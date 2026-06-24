"""Fetch first N episodes from teco-lab.com /english catalog, upload media to Qiniu, import DB."""
from __future__ import annotations

import argparse
import json
import re
import sys
import urllib.request
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parent
ROOT = SCRIPTS.parent
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(SCRIPTS))

from dotenv import load_dotenv

load_dotenv(ROOT / ".env")

from app.database import DATA_DIR, SessionLocal
from app.qiniu_storage import QiniuConfig, upload_file
from app.services.episode_json_import import apply_episode_detail_json, upsert_episode_summary
from teco_remote_client import SESSION_FILE, TecoAuthClient

EXPORT_PATH = ROOT.parent / "analysis" / "imported-english-batch.json"


def download_file(url: str, dest: Path) -> Path:
    dest.parent.mkdir(parents=True, exist_ok=True)
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=600) as resp:
        dest.write_bytes(resp.read())
    return dest


def guess_ext(url: str, default: str) -> str:
    path = url.split("?", 1)[0]
    ext = Path(path).suffix.lower()
    if ext in {".mp4", ".webm", ".mp3", ".m4a", ".webp", ".jpg", ".jpeg", ".png"}:
        return ext
    return default


def upload_episode_media(cfg: QiniuConfig, video_id: str, media_dir: Path) -> dict[str, str]:
    uploads: dict[str, str] = {}

    cover_candidates = sorted(media_dir.glob("cover.*"))
    if cover_candidates:
        cover_local = cover_candidates[0]
        key = cfg.object_key(video_id, cover_local.name)
        url = upload_file(cfg, cover_local, key)
        uploads["cover"] = url
        uploads["thumbnail_url"] = url

    video_local = None
    for p in sorted(media_dir.glob("video.*")):
        video_local = p
        break
    if video_local and video_local.is_file():
        key = cfg.object_key(video_id, video_local.name)
        uploads["video_url"] = upload_file(cfg, video_local, key)

    audio_local = None
    for p in sorted(media_dir.glob("audio.*")):
        audio_local = p
        break
    if audio_local and audio_local.is_file():
        key = cfg.object_key(video_id, audio_local.name)
        uploads["audio_url"] = upload_file(cfg, audio_local, key)

    manifest = media_dir / "qiniu-manifest.json"
    manifest.write_text(json.dumps(uploads, ensure_ascii=False, indent=2), encoding="utf-8")
    return uploads


def apply_manifest_to_detail(detail: dict, manifest: dict, summary: dict) -> None:
    ep = detail["episode"]
    media = ep.setdefault("media", {})
    if manifest.get("video_url"):
        media["video_url"] = manifest["video_url"]
    if manifest.get("audio_url"):
        media["audio_url"] = manifest["audio_url"]
    if manifest.get("thumbnail_url"):
        media["thumbnail_url"] = manifest["thumbnail_url"]
    if manifest.get("cover"):
        ep["cover"] = manifest["cover"]
        summary["cover"] = manifest["cover"]


def extract_index(item: dict) -> int | None:
    if item.get("index") is not None:
        return int(item["index"])
    cover = item.get("cover", "")
    m = re.search(r"clip(\d+)", cover)
    if m:
        return int(m.group(1))
    return None


def import_episode(
    client: TecoAuthClient,
    cfg: QiniuConfig,
    db,
    summary: dict,
    *,
    status: str = "published",
) -> dict:
    video_id = summary["video_id"]
    print(f"\n=== {video_id} · {summary.get('short_title', '')} ===")

    detail = client.episode_detail(video_id)
    ep = detail["episode"]
    media = ep.get("media") or {}

    media_dir = DATA_DIR / "media" / video_id
    media_dir.mkdir(parents=True, exist_ok=True)

    cover_url = summary.get("cover") or media.get("thumbnail_url") or ""
    if cover_url:
        ext = guess_ext(cover_url, ".webp")
        print("  download cover")
        download_file(cover_url, media_dir / f"cover{ext}")

    video_url = media.get("video_url") or ""
    if video_url:
        ext = guess_ext(video_url, ".mp4")
        print(f"  download video ({ext})")
        download_file(video_url, media_dir / f"video{ext}")

    audio_url = media.get("audio_url") or ""
    if audio_url:
        ext = guess_ext(audio_url, ".mp3")
        print(f"  download audio ({ext})")
        download_file(audio_url, media_dir / f"audio{ext}")

    print("  upload qiniu")
    manifest = upload_episode_media(cfg, video_id, media_dir)
    apply_manifest_to_detail(detail, manifest, summary)

    idx = extract_index(summary) or extract_index(ep)
    if idx is not None:
        summary["index"] = idx
        ep["index"] = idx

    upsert_episode_summary(db, summary, is_demo=False, status=status)
    apply_episode_detail_json(db, detail, is_demo=False, status=status)
    db.commit()

    sub_count = len(ep.get("subtitles") or [])
    print(f"  imported · {sub_count} subtitles")
    return detail


def main() -> None:
    parser = argparse.ArgumentParser(description="Import /english catalog episodes from teco-lab.com")
    parser.add_argument("limit", nargs="?", type=int, default=5, help="Number of episodes (default 5)")
    parser.add_argument("--token", help="Bearer access token (overrides env/session file)")
    parser.add_argument("--session", help="Path to teco_session.json exported from browser")
    parser.add_argument("--list-only", action="store_true", help="Only fetch and save episode list")
    args = parser.parse_args()

    if args.token:
        client = TecoAuthClient()
        client.access_token = args.token.strip()
    elif args.session:
        client = TecoAuthClient.from_session_file(Path(args.session))
    else:
        client = TecoAuthClient.from_env()

    print("Fetching /english episode list (no auth required) ...")
    summaries = client.episode_list(page=1, page_size=args.limit)[: args.limit]
    if not summaries:
        raise SystemExit("No episodes returned from /api/episode-list/")

    print(f"Top {len(summaries)} episodes:")
    for s in summaries:
        print(f"  - {s.get('video_id')} · {s.get('short_title', '')[:40]}")

    list_path = ROOT.parent / "analysis" / "imported-english-list.json"
    list_path.write_text(json.dumps({"episodes": summaries}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"List saved: {list_path}")

    if args.list_only:
        return

    print("\nAuthenticating for episode details ...")
    client.ensure_auth()

    cfg = QiniuConfig.from_env()
    db = SessionLocal()
    exported: dict = {"episodes": summaries, "details": []}

    try:
        for summary in summaries:
            detail = import_episode(client, cfg, db, summary, status="published")
            exported["details"].append(detail)
    finally:
        db.close()

    EXPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    EXPORT_PATH.write_text(json.dumps(exported, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"\nBackup saved: {EXPORT_PATH}")
    print("Done.")


if __name__ == "__main__":
    main()
