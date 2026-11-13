"""B 站视频 HLS 边转边播：ffmpeg 边拉流边切分片，前端 hls.js/原生 HLS 即点即播。

- 优先用本地 video.mp4（若已存在）；否则直接从 B 站 durl 拉流切分片，不落整片。
- 分片写入 DATA_DIR/hls/<video_id>/，由 episodes 路由对外提供（m3u8 内 ts 会带 token）。
"""
from __future__ import annotations

import logging
import subprocess
import threading
import time
from pathlib import Path
from urllib.parse import parse_qs, urlparse

from ..database import DATA_DIR
from .bilibili_meta import _BILIBILI_USER_AGENT, _bili_cookie_header, resolve_durl

logger = logging.getLogger(__name__)

HLS_ROOT = DATA_DIR / "hls"
_lock = threading.Lock()
_jobs: dict[str, dict] = {}

HLS_MIME = "application/vnd.apple.mpegurl"
TS_MIME = "video/mp2t"


def hls_dir(video_id: str) -> Path:
    return HLS_ROOT / video_id


def _bili_parts(video_url: str) -> tuple[str, int] | None:
    if "/api/bilibili/stream/" not in (video_url or ""):
        return None
    parsed = urlparse(video_url)
    bvid = parsed.path.rstrip("/").rsplit("/", 1)[-1]
    if not bvid:
        return None
    try:
        page = int((parse_qs(parsed.query).get("p") or ["1"])[0] or 1)
    except (TypeError, ValueError):
        page = 1
    return bvid, max(1, page)


def _start(video_id: str, video_url: str, local_video: Path | None) -> None:
    d = hls_dir(video_id)
    d.mkdir(parents=True, exist_ok=True)
    for old in d.glob("*"):
        try:
            old.unlink()
        except OSError:
            pass

    cmd = ["ffmpeg", "-y", "-loglevel", "warning"]
    if local_video and local_video.is_file():
        cmd += ["-i", str(local_video)]
    else:
        parts = _bili_parts(video_url)
        if not parts:
            raise RuntimeError("无可用视频源")
        bvid, page = parts
        url = resolve_durl(bvid, page)
        headers = (
            f"Referer: https://www.bilibili.com/video/{bvid}\r\n"
            f"User-Agent: {_BILIBILI_USER_AGENT}\r\n"
            "Origin: https://www.bilibili.com\r\n"
        )
        cookie = _bili_cookie_header()
        if cookie:
            headers += f"Cookie: {cookie}\r\n"
        cmd += [
            "-rw_timeout",
            "15000000",
            "-reconnect",
            "1",
            "-reconnect_streamed",
            "1",
            "-reconnect_delay_max",
            "5",
            "-headers",
            headers,
            "-i",
            url,
        ]

    cmd += [
        "-c",
        "copy",
        "-f",
        "hls",
        "-hls_time",
        "2",
        "-hls_list_size",
        "0",
        "-hls_segment_type",
        "mpegts",
        "-hls_flags",
        "independent_segments",
        str(d / "index.m3u8"),
    ]
    log = open(d / "ffmpeg.log", "wb")
    proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=log)
    _jobs[video_id] = {"proc": proc, "started": time.time(), "log": log}
    logger.info("HLS 转封装启动 %s (pid=%s)", video_id, proc.pid)


def ensure_hls(video_id: str, video_url: str, local_video: Path | None) -> None:
    d = hls_dir(video_id)
    with _lock:
        job = _jobs.get(video_id)
        if job and job["proc"].poll() is None:
            return
        if job:
            try:
                job.get("log") and job["log"].close()
            except Exception:  # noqa: BLE001
                pass
            _jobs.pop(video_id, None)
        if (d / "index.m3u8").is_file() and any(d.glob("*.ts")):
            # 已生成过（进程结束但文件在）——若 m3u8 有 ENDLIST 视为完成
            try:
                if "#EXT-X-ENDLIST" in (d / "index.m3u8").read_text("utf-8", "ignore"):
                    return
            except OSError:
                pass
        _start(video_id, video_url, local_video)


def m3u8_path(video_id: str) -> Path:
    return hls_dir(video_id) / "index.m3u8"


def segment_path(video_id: str, name: str) -> Path | None:
    safe = Path(name).name
    if not safe.endswith(".ts"):
        return None
    p = hls_dir(video_id) / safe
    return p if p.is_file() else None


def _segment_lines(text: str) -> list[str]:
    return [line.strip() for line in text.splitlines() if line.strip().endswith(".ts")]


def wait_first_segment(video_id: str, timeout: float = 25.0) -> bool:
    d = hls_dir(video_id)
    deadline = time.time() + timeout
    m3u8 = d / "index.m3u8"
    while time.time() < deadline:
        if m3u8.is_file():
            try:
                text = m3u8.read_text("utf-8", "ignore")
                if _segment_lines(text) and any(d.glob("*.ts")):
                    return True
            except OSError:
                pass
        time.sleep(0.3)
    return False
