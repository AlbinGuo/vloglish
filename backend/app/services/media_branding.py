"""Video delogo / vloglish watermark and cover generation from video frames."""
from __future__ import annotations

import hashlib
import os
import re
import shutil
import subprocess
from pathlib import Path

from .media_transcode import _ffmpeg_bin, ensure_browser_compatible_video, get_ffmpeg_dir


def _int_env(name: str, default: int) -> int:
    raw = os.getenv(name, "").strip()
    if not raw:
        return default
    try:
        return int(raw)
    except ValueError:
        return default


def _boxblur_for_crop(lr: int, lp: int, crop_w: int, crop_h: int) -> str:
    """Build boxblur filter; chroma radius must be < 9 (ffmpeg limit on small crops)."""
    dim_cap = max(1, min(crop_w, crop_h) // 2 - 1) if crop_w > 0 and crop_h > 0 else 8
    luma_lr = max(1, min(lr, dim_cap))
    chroma_lr = max(1, min(lr, 8, dim_cap))
    return f"boxblur={luma_lr}:{lp}:{chroma_lr}:{lp}"


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


def _watermark_bar_width(*, frame_width: int = 0) -> int:
    """Full frosted-glass strip (covers vloglish + trailing 'at TECO Lab' / subtitle leak)."""
    explicit = _int_env("VLOGISH_WATERMARK_BAR_W", 0)
    if explicit > 0:
        return explicit
    base = _int_env("VLOGISH_WATERMARK_W", 455)
    if frame_width > 0 and frame_width != 1280:
        base = max(base, int(base * frame_width / 1280))
    return base


def _watermark_text_zone_width() -> int:
    """Left zone width for centering the vloglish label inside the wider bar."""
    return _int_env("VLOGISH_WATERMARK_TEXT_W", 140)


def _watermark_width(*, frame_width: int = 0) -> int:
    """Alias for bar width (backward compatible)."""
    return _watermark_bar_width(frame_width=frame_width)


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


def _delogo_enabled() -> bool:
    return os.getenv("VLOGISH_DELOGO_ENABLED", "true").lower() not in {"0", "false", "no"}


def _bottom_left_patch_enabled() -> bool:
    return os.getenv("VLOGISH_DELOGO_BL_ENABLED", "true").lower() not in {"0", "false", "no"}


def _clamp_rect(x: int, y: int, w: int, h: int, frame_w: int, frame_h: int) -> tuple[int, int, int, int]:
    if frame_w > 0:
        w = min(w, max(frame_w - x - 4, 0))
    if frame_h > 0:
        h = min(h, max(frame_h - y - 4, 0))
    return x, y, w, h


def _top_left_delogo_rect(width: int, height: int) -> tuple[int, int, int, int]:
    wx, wy = _watermark_pos()
    x = _int_env("VLOGISH_DELOGO_X", wx)
    y = _int_env("VLOGISH_DELOGO_Y", wy)
    w = _int_env("VLOGISH_DELOGO_W", _watermark_bar_width(frame_width=width))
    h = _int_env("VLOGISH_DELOGO_H", _watermark_height())
    return _clamp_rect(x, y, w, h, width, height)


def _bottom_left_badge_rect(width: int, height: int) -> tuple[int, int, int, int]:
    """Bottom-left 'Ep.NNN' badge (e.g. Ep.180); width covers 3-digit episode numbers."""
    base_w = _int_env("VLOGISH_DELOGO_BL_W", 175)
    if width > 0 and width != 1280:
        w = max(base_w, int(base_w * width / 1280))
    else:
        w = base_w
    h = _int_env("VLOGISH_DELOGO_BL_H", 38)
    margin = _int_env("VLOGISH_DELOGO_BL_MARGIN", 10)
    x = _int_env("VLOGISH_DELOGO_BL_X", 0)
    y_env = os.getenv("VLOGISH_DELOGO_BL_Y", "").strip()
    if y_env:
        y = int(y_env)
    elif height > 0:
        y = max(0, height - h - margin)
    else:
        y = 0
    return _clamp_rect(x, y, w, h, width, height)


def _delogo_chain(width: int, height: int, *, include_top: bool, include_bottom: bool) -> str:
    filters: list[str] = []
    if include_top:
        x, y, w, h = _top_left_delogo_rect(width, height)
        if w >= 8 and h >= 8:
            filters.append(f"delogo=x={x}:y={y}:w={w}:h={h}")
    if include_bottom:
        x, y, w, h = _bottom_left_badge_rect(width, height)
        if w >= 8 and h >= 8:
            filters.append(f"delogo=x={x}:y={y}:w={w}:h={h}")
    return ",".join(filters)


def build_watermark_filter_complex(*, font_name: str, width: int, height: int, use_delogo: bool) -> str:
    """Top-left vloglish bar + bottom-left Ep.NNN removal."""
    wx, wy = _watermark_pos()
    ww = min(_watermark_bar_width(frame_width=width), width) if width > 0 else _watermark_bar_width(frame_width=width)
    wh = min(_watermark_height(), height) if height > 0 else _watermark_height()
    if ww < 16 or wh < 12:
        ww = min(455, width or 455)
        wh = min(52, height or 52)

    bl_x, bl_y, bl_w, bl_h = _bottom_left_badge_rect(width, height)
    use_bl_patch = _bottom_left_patch_enabled() and bl_w >= 16 and bl_h >= 12

    blur_lr = _int_env("VLOGISH_WATERMARK_BLUR_LR", 12)
    blur_lp = _int_env("VLOGISH_WATERMARK_BLUR_LP", 2)
    top_blur = _boxblur_for_crop(blur_lr, blur_lp, ww, wh)
    bl_blur = _boxblur_for_crop(blur_lr, blur_lp, bl_w, bl_h)
    tint = os.getenv("VLOGISH_WATERMARK_TINT", "0.22").strip() or "0.22"
    text = _escape_drawtext(_watermark_text())
    font = _font_opt(font_name)
    fs = _watermark_fontsize()
    text_zone = min(_watermark_text_zone_width(), ww)
    text_x = f"({wx}+({text_zone}-text_w)/2)"
    text_y = f"({wy}+({wh}-text_h)/2)"

    delogos = ""
    if use_delogo and _delogo_enabled():
        delogos = _delogo_chain(width, height, include_top=True, include_bottom=use_bl_patch)
    head = f"[0:v]{delogos}," if delogos else "[0:v]"

    if use_bl_patch:
        return (
            f"{head}split=3[main][wm_src][bl_src];"
            f"[wm_src]crop={ww}:{wh}:{wx}:{wy},{top_blur}[wm_blur];"
            f"[bl_src]crop={bl_w}:{bl_h}:{bl_x}:{bl_y},{bl_blur}[bl_blur];"
            f"[main][wm_blur]overlay={wx}:{wy}[wm_base];"
            f"[wm_base][bl_blur]overlay={bl_x}:{bl_y}[bl_base];"
            f"[bl_base]drawbox=x={wx}:y={wy}:w={ww}:h={wh}:color=black@{tint}:t=fill[wm_tint_tl];"
            f"[wm_tint_tl]drawbox=x={bl_x}:y={bl_y}:w={bl_w}:h={bl_h}:color=black@{tint}:t=fill[wm_tint];"
            f"[wm_tint]drawtext=text='{text}'{font}:fontsize={fs}:fontcolor=white@0.96:"
            f"x={text_x}:y={text_y}[vout]"
        )

    return (
        f"{head}split=2[main][wm_src];"
        f"[wm_src]crop={ww}:{wh}:{wx}:{wy},{top_blur}[wm_blur];"
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
    ffmpeg_dir = get_ffmpeg_dir()
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
    ffmpeg_dir = get_ffmpeg_dir()
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
    ffmpeg_dir = get_ffmpeg_dir()
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
    ffmpeg_dir = get_ffmpeg_dir()
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
    path, _ = ensure_browser_compatible_video(branded, get_ffmpeg_dir())
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
    duration = probe_duration(video_path, get_ffmpeg_dir())
    ts = cover_sample_offset_sec(video_id, duration, clip_length_hint)
    raw = dest_path.with_suffix(".jpg")
    extract_cover_frame(video_path, raw, ts)
    return brand_cover_image(
        raw,
        episode_index=episode_index,
        short_title=short_title,
        output_path=dest_path.with_suffix(".webp"),
    )
