"""TTS 通用工具（时长估算、音频格式转换）。"""

from __future__ import annotations

import re
import subprocess
import tempfile
from pathlib import Path

from .media_transcode import get_ffmpeg_dir, _ffmpeg_bin


def normalize_tts_text(text: str) -> str:
    cleaned = re.sub(r"\s+", " ", text.strip())
    if not cleaned:
        raise ValueError("朗读文本为空")
    return cleaned


def estimate_duration_ms(text: str) -> int:
    words = len(re.findall(r"[A-Za-z']+", text))
    if words <= 0:
        return 500
    # ~150 wpm
    return max(500, int(words / 2.5 * 1000))


def _is_mp3(data: bytes) -> bool:
    return data.startswith(b"ID3") or data[:2] == b"\xff\xfb"


def _is_wav(data: bytes) -> bool:
    return len(data) >= 12 and data[:4] == b"RIFF" and data[8:12] == b"WAVE"


def ensure_mp3_bytes(audio_data: bytes) -> bytes:
    if _is_mp3(audio_data):
        return audio_data
    if not _is_wav(audio_data):
        return audio_data

    ffmpeg_dir = get_ffmpeg_dir()
    try:
        ffmpeg = _ffmpeg_bin(ffmpeg_dir, "ffmpeg")
    except RuntimeError:
        return audio_data

    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as src:
        src.write(audio_data)
        src_path = Path(src.name)
    out_path = src_path.with_suffix(".mp3")
    try:
        proc = subprocess.run(
            [
                ffmpeg,
                "-y",
                "-i",
                str(src_path),
                "-codec:a",
                "libmp3lame",
                "-qscale:a",
                "4",
                str(out_path),
            ],
            capture_output=True,
            text=True,
            check=False,
        )
        if proc.returncode != 0 or not out_path.is_file():
            detail = (proc.stderr or proc.stdout or "").strip()
            raise RuntimeError(detail[-500:] if detail else "ffmpeg 转 mp3 失败")
        return out_path.read_bytes()
    finally:
        src_path.unlink(missing_ok=True)
        out_path.unlink(missing_ok=True)


def audio_file_suffix(data: bytes) -> str:
    if _is_mp3(data):
        return ".mp3"
    if _is_wav(data):
        return ".wav"
    return ".bin"
