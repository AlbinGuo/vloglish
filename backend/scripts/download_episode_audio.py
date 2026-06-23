"""Download episode audio into backend/data/media/{video_id}/audio.*"""
from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA_MEDIA = ROOT / "data" / "media"


def has_ffmpeg() -> bool:
    return shutil.which("ffmpeg") is not None and shutil.which("ffprobe") is not None


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: python scripts/download_episode_audio.py <video_id_or_youtube_url>")
        sys.exit(1)

    target = sys.argv[1].strip()
    if target.startswith("http"):
        video_id = target.rstrip("/").split("/")[-1].split("?")[0]
        url = target
    else:
        video_id = target
        url = f"https://youtu.be/{video_id}"

    out_dir = DATA_MEDIA / video_id
    out_dir.mkdir(parents=True, exist_ok=True)
    out_template = str(out_dir / "audio.%(ext)s")

    cmd = [sys.executable, "-m", "yt_dlp", "-o", out_template, url]
    if has_ffmpeg():
        cmd[3:3] = ["-x", "--audio-format", "mp3"]
    else:
        cmd.extend(["-f", "ba"])
        print("ffmpeg not found, saving best audio without MP3 conversion")

    print("Running:", " ".join(cmd))
    subprocess.run(cmd, check=True)

    candidates = sorted(out_dir.glob("audio.*"))
    if not candidates:
        raise SystemExit("Download finished but audio file was not found")

    print(f"Saved: {candidates[0]}")


if __name__ == "__main__":
    main()
