"""B 站视频 HLS 边转边播：ffmpeg 边拉流边切分片，前端 hls.js/原生 HLS 即点即播。

- 优先用本地 video.mp4（若已存在）；否则直接从 B 站 durl 拉流切分片，不落整片。
- 分片写入 DATA_DIR/hls/<video_id>/，由 episodes 路由对外提供（m3u8 内 ts 会带 token）。
"""
from __future__ import annotations

import logging
import re
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
_uploaders: dict[str, threading.Thread] = {}
_uploaded: dict[str, set[str]] = {}

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
    _start_uploader(video_id)


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


def _seg_sort_key(name: str) -> int:
    match = re.search(r"(\d+)", name)
    return int(match.group(1)) if match else 0


def _start_uploader(video_id: str) -> None:
    existing = _uploaders.get(video_id)
    if existing and existing.is_alive():
        return
    thread = threading.Thread(target=_upload_loop, args=(video_id,), daemon=True)
    _uploaders[video_id] = thread
    thread.start()


def _upload_loop(video_id: str) -> None:
    """把已切好的分片逐个上传七牛（边切边传，前端从 CDN 拉分片）。"""
    from ..qiniu_storage import QiniuConfig, upload_file

    try:
        cfg = QiniuConfig.from_env()
    except RuntimeError:
        return  # 七牛未配置：保持本地分片播放

    d = hls_dir(video_id)
    m3u8 = d / "index.m3u8"
    uploaded = _uploaded.setdefault(video_id, set())
    idle = 0
    while True:
        job = _jobs.get(video_id)
        running = bool(job and job["proc"].poll() is None)
        try:
            text = m3u8.read_text("utf-8", "ignore") if m3u8.is_file() else ""
        except OSError:
            text = ""
        names = _segment_lines(text)
        progressed = False
        for name in names:
            if name in uploaded:
                continue
            seg = d / name
            if not seg.is_file():
                continue
            try:
                size1 = seg.stat().st_size
                if size1 <= 0:
                    continue
                time.sleep(0.2)
                if seg.stat().st_size != size1:
                    continue  # 还在写入，下一轮再传
                upload_file(cfg, seg, cfg.object_key("hls", video_id, name))
                uploaded.add(name)
                progressed = True
            except Exception:  # noqa: BLE001
                logger.warning("HLS 分片上传失败 %s/%s", video_id, name, exc_info=True)

        if not running:
            pending = [n for n in names if n not in uploaded and (d / n).is_file()]
            if not pending:
                break
        idle = 0 if progressed else idle + 1
        if not running and idle >= 10:
            break
        time.sleep(1.0)


def uploaded_segments(video_id: str) -> list[str]:
    return sorted(_uploaded.get(video_id, set()), key=_seg_sort_key)


def hls_done(video_id: str) -> bool:
    job = _jobs.get(video_id)
    if job and job["proc"].poll() is None:
        return False
    m3u8 = m3u8_path(video_id)
    if not m3u8.is_file():
        return False
    try:
        return "#EXT-X-ENDLIST" in m3u8.read_text("utf-8", "ignore")
    except OSError:
        return False


def build_qiniu_m3u8(video_id: str) -> str | None:
    """基于已上传七牛的分片动态生成 m3u8（分片为七牛签名 URL，走 CDN）。

    还没有任何分片上传成功时返回 None，调用方回退到本地分片。
    """
    names = uploaded_segments(video_id)
    if not names:
        return None
    from ..qiniu_storage import QiniuConfig, sign_url

    try:
        cfg = QiniuConfig.from_env()
    except RuntimeError:
        return None

    done = hls_done(video_id)
    out = [
        "#EXTM3U",
        "#EXT-X-VERSION:3",
        "#EXT-X-TARGETDURATION:2",
        "#EXT-X-MEDIA-SEQUENCE:0",
        "#EXT-X-PLAYLIST-TYPE:VOD" if done else "#EXT-X-PLAYLIST-TYPE:EVENT",
    ]
    for name in names:
        key = cfg.object_key("hls", video_id, name)
        out.append("#EXTINF:2.0,")
        out.append(sign_url(cfg.public_url(key), cfg=cfg))
    if done:
        out.append("#EXT-X-ENDLIST")
    return "\n".join(out) + "\n"
