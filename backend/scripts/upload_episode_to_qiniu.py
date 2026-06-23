"""Upload episode media (cover / video / audio) to Qiniu OSS and print public URLs."""
from __future__ import annotations

import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from dotenv import load_dotenv

load_dotenv(ROOT / ".env")

from app.database import DATA_DIR
from app.qiniu_storage import QiniuConfig, upload_file


def download_cover(video_id: str, dest: Path) -> Path:
    url = f"https://i.ytimg.com/vi/{video_id}/hqdefault.jpg"
    dest.parent.mkdir(parents=True, exist_ok=True)
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=60) as resp:
        dest.write_bytes(resp.read())
    return dest


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: python scripts/upload_episode_to_qiniu.py <video_id>")
        sys.exit(1)

    video_id = sys.argv[1].strip()
    cfg = QiniuConfig.from_env()
    media_dir = DATA_DIR / "media" / video_id
    media_dir.mkdir(parents=True, exist_ok=True)

    uploads: dict[str, str] = {}

    cover_local = media_dir / "cover.jpg"
    if not cover_local.is_file():
        print(f"Downloading cover -> {cover_local}")
        download_cover(video_id, cover_local)
    cover_key = cfg.object_key(video_id, "cover.jpg")
    uploads["cover"] = upload_file(cfg, cover_local, cover_key)
    uploads["thumbnail_url"] = uploads["cover"]
    print(f"cover: {uploads['cover']}")

    for name, filename in (("video_url", "video.mp4"), ("audio_url", "audio.webm")):
        local = media_dir / filename
        if not local.is_file():
            print(f"Skip {name}: missing {local}")
            continue
        key = cfg.object_key(video_id, filename)
        uploads[name] = upload_file(cfg, local, key)
        print(f"{name}: {uploads[name]}")

    manifest = media_dir / "qiniu-manifest.json"
    manifest.write_text(json.dumps(uploads, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\nManifest: {manifest}")
    print(json.dumps(uploads, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
