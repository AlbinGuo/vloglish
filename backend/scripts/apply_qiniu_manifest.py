"""Apply qiniu-manifest.json URLs to extra-episodes.json and re-seed."""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EXTRA = ROOT.parent / "analysis" / "extra-episodes.json"


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: python scripts/apply_qiniu_manifest.py <video_id>")
        sys.exit(1)

    video_id = sys.argv[1].strip()
    manifest_path = ROOT / "data" / "media" / video_id / "qiniu-manifest.json"
    if not manifest_path.is_file():
        raise SystemExit(f"Missing manifest: {manifest_path}\nRun upload_episode_to_qiniu.py first.")

    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    extra = json.loads(EXTRA.read_text(encoding="utf-8"))

    for item in extra.get("episodes", []):
        if item.get("video_id") == video_id:
            if manifest.get("cover"):
                item["cover"] = manifest["cover"]

    for detail in extra.get("details", []):
        if detail.get("episode", {}).get("video_id") != video_id:
            continue
        media = detail["episode"].setdefault("media", {})
        for key in ("video_url", "audio_url", "thumbnail_url"):
            if manifest.get(key):
                media[key] = manifest[key]
        if manifest.get("cover"):
            detail["episode"]["cover"] = manifest["cover"]

    EXTRA.write_text(json.dumps(extra, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Updated {EXTRA}")

    subprocess.run([sys.executable, str(ROOT / "seed.py")], check=True)


if __name__ == "__main__":
    main()
