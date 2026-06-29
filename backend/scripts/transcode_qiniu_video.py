"""Download a remote mp4, transcode to H.264 if needed, re-upload to Qiniu.

Run with the backend venv (system python has no qiniu):

  cd backend
  .venv\\Scripts\\activate
  python scripts/transcode_qiniu_video.py <url> <slug/filename>

Or without activate:

  .venv\\Scripts\\python scripts/transcode_qiniu_video.py <url> <slug/filename>
"""
from __future__ import annotations

import sys
import tempfile
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

try:
    from dotenv import load_dotenv
except ImportError as exc:
    raise SystemExit(
        "缺少依赖。请在 backend 目录激活虚拟环境后运行：\n"
        "  .venv\\Scripts\\activate\n"
        "  pip install -r requirements.txt"
    ) from exc

load_dotenv(ROOT / ".env")

try:
    from app.qiniu_storage import QiniuConfig, upload_file
    from app.services.media_transcode import ensure_browser_compatible_video, probe_video_codec
    from app.services.yt_dlp_fetch import YtDlpTools
except ModuleNotFoundError as exc:
    if exc.name == "qiniu":
        raise SystemExit(
            "未找到 qiniu 模块。请使用 backend/.venv 中的 Python，不要直接用系统 python：\n"
            "  cd backend\n"
            "  .venv\\Scripts\\python scripts/transcode_qiniu_video.py <url> <slug/filename>"
        ) from exc
    raise


def main() -> None:
    if len(sys.argv) < 3:
        print("Usage: python scripts/transcode_qiniu_video.py <remote_mp4_url> <qiniu_slug/filename>")
        print("Example: python scripts/transcode_qiniu_video.py http://oss.sxakgs.com/en/tk01/tk-01.mp4 tk01/tk-01.mp4")
        raise SystemExit(1)

    remote_url = sys.argv[1].strip()
    key_suffix = sys.argv[2].strip().lstrip("/")
    tools = YtDlpTools.from_env()
    cfg = QiniuConfig.from_env()

    with tempfile.TemporaryDirectory(prefix="transcode-") as tmp:
        local = Path(tmp) / "video.mp4"
        print(f"Downloading {remote_url} ...")
        with urllib.request.urlopen(remote_url, timeout=600) as resp:
            local.write_bytes(resp.read())

        codec = probe_video_codec(local, tools.ffmpeg_dir)
        print(f"Current codec: {codec or 'unknown'}")
        local, changed = ensure_browser_compatible_video(local, tools.ffmpeg_dir)
        print("Transcoded to H.264" if changed else "Already browser-compatible")

        key = cfg.object_key(*key_suffix.split("/", 1)) if "/" in key_suffix else cfg.object_key(key_suffix, "video.mp4")
        url = upload_file(cfg, local, key)
        print(f"Uploaded: {url}")


if __name__ == "__main__":
    main()
