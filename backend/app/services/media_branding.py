"""Video delogo / vloglish watermark and cover generation from video frames."""
from __future__ import annotations

import hashlib
import os
import re
import shutil
import subprocess
from pathlib import Path

from .media_transcode import _ffmpeg_bin, ensure_browser_compatible_video


def _ffmpeg_dir() -> Path:
    tools = os.getenv("VLOGISH_TOOLS_DIR", "").strip()
    if tools:
        return Path(tools)
    env = os.getenv("FFMPEG_DIR", "").strip()
    if env:
        return Path(env)
    return Path(__file__).resolve().parents[2] / "tools"


def _int_env(name: str, default: int) -> int:
    raw = os.getenv(name, "").strip()
    if not raw:
        return default
    try:
        return int(raw)
    except ValueError:
        return default


def _escape_drawtext(text: str) -> str:
    s = text.replace("\\", "\\\\")
    s = s.replace(":", "\\:")
    s = s.replace("'", "\\'")
    s = s.replace("%", "\\%")
    return s


BRAND_FONT_NAME = "vloglish-brand.ttf"


def _source_font_path() -> Path | None:
    custom = os.getenv("VLOGISH_FONT_FILE", "").strip()
    if custom and Path(custom).is_file():
        return Path(custom).resolve()
    for path in (
        Path("C:/Windows/Fonts/segoeuib.ttf"),
        Path("C:/Windows/Fonts/arialbd.ttf"),
        Path("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"),
        Path("/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc"),
    ):
        if path.is_file():
            return path.resolve()
    return None


def _ensure_local_font(work_dir: Path) -> str:
    """Copy font into work_dir so ffmpeg drawtext can use a relative path (Windows-safe)."""
    target = work_dir / BRAND_FONT_NAME
    if not target.is_file():
        source = _source_font_path()
        if not source:
            return ""
        shutil.copy2(source, target)
    return BRAND_FONT_NAME


def _font_opt(font_name: str) -> str:
    return f":fontfile={font_name}" if font_name else ""


def _watermark_text() -> str:
    return os.getenv("VLOGISH_WATERMARK_TEXT", "vloglish").strip() or "vloglish"


def _watermark_width() -> int:
    return _int_env("VLOGISH_WATERMARK_W", 237)


def _watermark_height() -> int:
    return _int_env("VLOGISH_WATERMARK_H", 52)


def _watermark_pos() -> tuple[int, int]:
    return _int_env("VLOGISH_WATERMARK_X", 0), _int_env("VLOGISH_WATERMARK_Y", 0)


def _watermark_fontsize() -> int:
    return _int_env("VLOGISH_WATERMARK_FONTSIZE", 28)


def _probe_video_size(path: Path, ffmpeg_dir: Path) -> tuple[int, int]:
    ffprobe = _ffmpeg_bin(ffmpeg_dir, "ffprobe")
    proc = subprocess.run(
        [
            ffprobe,
            "-v",
            "error",
            "-select_streams",
            "v:0",
            "-show_entries",
            "stream=width,height",
            "-of",
            "csv=p=0:s=x",
            str(path),
        ],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=60,
    )
    if proc.returncode == 0 and "x" in proc.stdout:
        w, h = proc.stdout.strip().split("x", 1)
        return int(w), int(h)
    return 1280, 720


def _delogo_filter(width: int = 0, height: int = 0) -> str:
    if os.getenv("VLOGISH_DELOGO_ENABLED", "true").lower() in {"0", "false", "no"}:
        return ""
    wx, wy = _watermark_pos()
    ww = _watermark_width()
    wh = _watermark_height()
    x = _int_env("VLOGISH_DELOGO_X", wx)
    y = _int_env("VLOGISH_DELOGO_Y", wy)
    w = _int_env("VLOGISH_DELOGO_W", ww)
    h = _int_env("VLOGISH_DELOGO_H", wh)
    if width > 0 and height > 0:
        w = min(w, max(width - x - 4, 0))
        h = min(h, max(height - y - 4, 0))
    if w < 8 or h < 8:
        return ""
    return f"delogo=x={x}:y={y}:w={w}:h={h}"


def build_watermark_filter_complex(*, font_name: str, width: int, height: int, use_delogo: bool) -> str:
    """237px frosted bar: crop → blur → overlay → light tint → centered text."""
    wx, wy = _watermark_pos()
    ww = min(_watermark_width(), width) if width > 0 else _watermark_width()
    wh = min(_watermark_height(), height) if height > 0 else _watermark_height()
    if ww < 16 or wh < 12:
        ww = min(237, width or 237)
        wh = min(52, height or 52)

    blur_lr = _int_env("VLOGISH_WATERMARK_BLUR_LR", 12)
    blur_lp = _int_env("VLOGISH_WATERMARK_BLUR_LP", 2)
    tint = os.getenv("VLOGISH_WATERMARK_TINT", "0.22").strip() or "0.22"
    text = _escape_drawtext(_watermark_text())
    font = _font_opt(font_name)
    fs = _watermark_fontsize()
    text_x = f"({wx}+({ww}-text_w)/2)"
    text_y = f"({wy}+({wh}-text_h)/2)"

    delogo = _delogo_filter(width, height) if use_delogo else ""
    head = f"[0:v]{delogo}," if delogo else "[0:v]"
    return (
        f"{head}split=2[main][wm_src];"
        f"[wm_src]crop={ww}:{wh}:{wx}:{wy},boxblur={blur_lr}:{blur_lp}[wm_blur];"
        f"[main][wm_blur]overlay={wx}:{wy}[wm_base];"
        f"[wm_base]drawbox=x={wx}:y={wy}:w={ww}:h={wh}:color=black@{tint}:t=fill[wm_tint];"
        f"[wm_tint]drawtext=text='{text}'{font}:fontsize={fs}:fontcolor=white@0.96:"
        f"x={text_x}:y={text_y}[vout]"
    )


def probe_duration(path: Path, ffmpeg_dir: Path) -> float:
    ffprobe = _ffmpeg_bin(ffmpeg_dir, "ffprobe")
    proc = subprocess.run(
        [
            ffprobe,
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=nw=1:nk=1",
            str(path),
        ],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=60,
    )
    if proc.returncode != 0:
        return 0.0
    try:
        return float(proc.stdout.strip())
    except ValueError:
        return 0.0


def cover_sample_offset_sec(video_id: str, duration: float, clip_length_hint: float = 0) -> float:
    dur = duration or clip_length_hint or 120.0
    digest = hashlib.md5(video_id.encode("utf-8")).hexdigest()
    bucket = int(digest[:8], 16) % 35
    pct = 0.10 + bucket / 100.0
    offset = dur * pct
    return max(1.0, min(offset, max(dur - 2.0, 1.0)))


def brand_video(input_path: Path, output_path: Path | None = None) -> Path:
    ffmpeg_dir = _ffmpeg_dir()
    vw, vh = _probe_video_size(input_path, ffmpeg_dir)
    try:
        return _run_brand_video(input_path, output_path, vw, vh, use_delogo=True)
    except RuntimeError as exc:
        msg = str(exc)
        if "delogo" in msg.lower() or "logo area" in msg.lower():
            return _run_brand_video(input_path, output_path, vw, vh, use_delogo=False)
        raise


def _run_brand_video(
    input_path: Path,
    output_path: Path | None,
    width: int,
    height: int,
    *,
    use_delogo: bool,
) -> Path:
    ffmpeg_dir = _ffmpeg_dir()
    ffmpeg = _ffmpeg_bin(ffmpeg_dir, "ffmpeg")
    work_dir = input_path.parent
    font_name = _ensure_local_font(work_dir)
    fc = build_watermark_filter_complex(
        font_name=font_name,
        width=width,
        height=height,
        use_delogo=use_delogo,
    )
    dest = output_path or input_path.with_name(f"{input_path.stem}.branded{input_path.suffix}")
    timeout = int(os.getenv("FFMPEG_BRAND_TIMEOUT", "1800"))

    cmd = [
        ffmpeg,
        "-y",
        "-i",
        input_path.name,
        "-filter_complex",
        fc,
        "-map",
        "[vout]",
        "-map",
        "0:a?",
        "-c:v",
        "libx264",
        "-preset",
        "fast",
        "-crf",
        "23",
        "-c:a",
        "copy",
        "-movflags",
        "+faststart",
        dest.name,
    ]
    proc = subprocess.run(
        cmd,
        cwd=work_dir,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=timeout,
    )
    if proc.returncode != 0:
        detail = (proc.stderr or proc.stdout or "").strip()
        raise RuntimeError(detail[-2000:] if detail else "视频去水印/加水印失败")

    if dest.resolve() != input_path.resolve():
        branded = work_dir / dest.name
        branded.replace(input_path)
    return input_path


def extract_cover_frame(video_path: Path, out_path: Path, timestamp_sec: float) -> Path:
    ffmpeg_dir = _ffmpeg_dir()
    ffmpeg = _ffmpeg_bin(ffmpeg_dir, "ffmpeg")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run(
        [
            ffmpeg,
            "-y",
            "-ss",
            f"{timestamp_sec:.3f}",
            "-i",
            str(video_path),
            "-vframes",
            "1",
            "-q:v",
            "2",
            str(out_path),
        ],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=120,
    )
    if proc.returncode != 0 or not out_path.is_file():
        detail = (proc.stderr or proc.stdout or "").strip()
        raise RuntimeError(detail[-1500:] if detail else "封面截帧失败")
    return out_path


def _short_title_for_cover(title: str, max_len: int = 28) -> str:
    cleaned = re.sub(r"\s+", " ", title.strip())
    if len(cleaned) <= max_len:
        return cleaned
    return cleaned[: max_len - 1] + "…"


def brand_cover_image(
    cover_path: Path,
    *,
    episode_index: int,
    short_title: str,
    output_path: Path | None = None,
) -> Path:
    ffmpeg_dir = _ffmpeg_dir()
    ffmpeg = _ffmpeg_bin(ffmpeg_dir, "ffmpeg")
    work_dir = cover_path.parent
    font_name = _ensure_local_font(work_dir)
    font = _font_opt(font_name)
    title = _escape_drawtext(_short_title_for_cover(short_title))
    brand = _escape_drawtext(_watermark_text())
    dest = output_path or cover_path.with_suffix(".webp")

    vf = ",".join(
        [
            "scale=1280:-2",
            (
                f"drawbox=x=0:y=ih-96:w=iw:h=96:color=black@0.55:t=fill,"
                f"drawtext=text='{brand}'{font}:fontsize=34:fontcolor=white@0.95:"
                f"box=1:boxcolor=black@0.35:boxborderw=8:x=28:y=28,"
                f"drawtext=text='Ep.{episode_index}'{font}:fontsize=30:fontcolor=white@0.95:x=28:y=h-78,"
                f"drawtext=text='{title}'{font}:fontsize=24:fontcolor=white@0.92:x=140:y=h-74"
            ),
        ]
    )

    proc = subprocess.run(
        [
            ffmpeg,
            "-y",
            "-i",
            cover_path.name,
            "-vf",
            vf,
            dest.name,
        ],
        cwd=work_dir,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=120,
    )
    if proc.returncode != 0 or not dest.is_file():
        detail = (proc.stderr or proc.stdout or "").strip()
        raise RuntimeError(detail[-1500:] if detail else "封面品牌化失败")

    final = work_dir / dest.name
    if final.suffix.lower() != cover_path.suffix.lower():
        cover_path.unlink(missing_ok=True)
    return final


def process_imported_video(video_path: Path) -> Path:
    branded = brand_video(video_path)
    path, _ = ensure_browser_compatible_video(branded, _ffmpeg_dir())
    return path


def generate_episode_cover(
    video_path: Path,
    *,
    video_id: str,
    episode_index: int,
    short_title: str,
    clip_length_hint: float = 0,
    dest_path: Path,
) -> Path:
    duration = probe_duration(video_path, _ffmpeg_dir())
    ts = cover_sample_offset_sec(video_id, duration, clip_length_hint)
    raw = dest_path.with_suffix(".jpg")
    extract_cover_frame(video_path, raw, ts)
    return brand_cover_image(
        raw,
        episode_index=episode_index,
        short_title=short_title,
        output_path=dest_path.with_suffix(".webp"),
    )
