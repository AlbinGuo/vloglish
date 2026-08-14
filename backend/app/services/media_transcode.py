"""Ensure video files use browser-friendly codecs (H.264)."""
from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path

BROWSER_VIDEO_CODECS = frozenset({"h264", "avc1", "vp8", "vp9", "av1"})


def get_ffmpeg_dir() -> Path:
    tools = os.getenv("VLOGISH_TOOLS_DIR", "").strip()
    if tools:
        return Path(tools)
    env = os.getenv("FFMPEG_DIR", "").strip()
    if env:
        return Path(env)
    return Path(__file__).resolve().parents[2] / "tools"


def ffmpeg_tools_status() -> dict:
    ffmpeg_dir = get_ffmpeg_dir()
    has_ffmpeg = (ffmpeg_dir / "ffmpeg.exe").is_file() or shutil.which("ffmpeg") is not None
    has_ffprobe = (ffmpeg_dir / "ffprobe.exe").is_file() or shutil.which("ffprobe") is not None
    return {
        "configured": has_ffmpeg and has_ffprobe,
        "ffmpeg_dir": str(ffmpeg_dir),
        "has_ffmpeg": has_ffmpeg,
        "has_ffprobe": has_ffprobe,
    }


def _ffmpeg_bin(ffmpeg_dir: Path, name: str) -> str:
    local = ffmpeg_dir / f"{name}.exe"
    if local.is_file():
        return str(local)
    found = shutil.which(name)
    if found:
        return found
    raise RuntimeError(
        f"未找到 {name}，请在 backend/.env 配置 VLOGISH_TOOLS_DIR 或 FFMPEG_DIR（当前目录：{ffmpeg_dir}）"
    )


def probe_video_codec(path: Path, ffmpeg_dir: Path) -> str:
    ffprobe = _ffmpeg_bin(ffmpeg_dir, "ffprobe")
    proc = subprocess.run(
        [
            ffprobe,
            "-v",
            "error",
            "-select_streams",
            "v:0",
            "-show_entries",
            "stream=codec_name",
            "-of",
            "default=nw=1",
            str(path),
        ],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=60,
    )
    if proc.returncode != 0:
        return ""
    for line in proc.stdout.splitlines():
        if line.startswith("codec_name="):
            return line.split("=", 1)[1].strip().lower()
    return ""


def is_browser_compatible_codec(codec: str) -> bool:
    if not codec:
        return True
    if codec in BROWSER_VIDEO_CODECS:
        return True
    return codec.startswith("avc1")


def transcode_to_h264(input_path: Path, ffmpeg_dir: Path) -> Path:
    ffmpeg = _ffmpeg_bin(ffmpeg_dir, "ffmpeg")
    output = input_path.with_name(f"{input_path.stem}.h264{input_path.suffix}")
    timeout = int(os.getenv("FFMPEG_TRANSCODE_TIMEOUT", "14400"))
    proc = subprocess.run(
        [
            ffmpeg,
            "-y",
            "-i",
            str(input_path),
            "-c:v",
            "libx264",
            "-preset",
            "fast",
            "-crf",
            "23",
            "-c:a",
            "aac",
            "-b:a",
            "128k",
            "-movflags",
            "+faststart",
            str(output),
        ],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=timeout,
    )
    if proc.returncode != 0:
        detail = (proc.stderr or proc.stdout or "").strip()
        raise RuntimeError(detail[-2000:] if detail else "ffmpeg 转码失败")
    input_path.unlink(missing_ok=True)
    final = input_path
    output.replace(final)
    return final


def ensure_browser_compatible_video(path: Path, ffmpeg_dir: Path) -> tuple[Path, bool]:
    """Return (path, was_transcoded)."""
    codec = probe_video_codec(path, ffmpeg_dir)
    if is_browser_compatible_codec(codec):
        return path, False
    if codec in {"hevc", "h265"}:
        return transcode_to_h264(path, ffmpeg_dir), True
    raise RuntimeError(f"不支持的视频编码 {codec or 'unknown'}，请用 H.264 重新导出")
