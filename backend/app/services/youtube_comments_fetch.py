"""Fetch YouTube comments via yt-dlp (no media download)."""
from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

from ..database import DATA_DIR
from ..media import extract_youtube_id
from .yt_dlp_fetch import (
    YtDlpTools,
    _assert_local_proxy_ready,
    _format_ytdlp_error,
    _is_youtube_url,
    _yt_dlp_cli_extras,
    _yt_dlp_subprocess_env,
    _youtube_cookies_opt_in,
)


def resolve_youtube_watch_url(*, original_video_url: str = "", video_id: str = "") -> str:
    raw = (original_video_url or "").strip()
    yt_id = extract_youtube_id(raw) or extract_youtube_id(video_id)
    if yt_id:
        return f"https://www.youtube.com/watch?v={yt_id}"
    if raw and _is_youtube_url(raw):
        return raw
    raise RuntimeError("该集没有可用的 YouTube 原链，无法抓取评论")


def fetch_youtube_comments(url: str, *, max_comments: int = 80) -> list[dict]:
    url = url.strip()
    if not _is_youtube_url(url):
        raise RuntimeError("仅支持从 YouTube 链接抓取评论")

    tools = YtDlpTools.from_env()
    _assert_local_proxy_ready()
    limit = max(8, min(200, int(max_comments)))
    work_dir = Path(tempfile.mkdtemp(prefix="vloglish-ytcomments-", dir=DATA_DIR))
    try:
        _run_comment_extract(tools, url, work_dir, max_comments=limit)
        info = _load_info_json(work_dir)
        raw_comments = info.get("comments")
        if not isinstance(raw_comments, list):
            raw_comments = []
        return [_normalize_comment(item) for item in raw_comments if isinstance(item, dict)]
    finally:
        shutil.rmtree(work_dir, ignore_errors=True)


def _run_comment_extract(tools: YtDlpTools, url: str, work_dir: Path, *, max_comments: int) -> None:
    out_template = str(work_dir / "media.%(ext)s")
    cmd = [
        str(tools.yt_dlp),
        "--skip-download",
        "--write-comments",
        "--write-info-json",
        "--no-playlist",
        "--no-warnings",
        "-o",
        out_template,
    ]
    allow_cookies = _youtube_cookies_opt_in()
    if allow_cookies and tools.cookies:
        cmd.extend(["--cookies", str(tools.cookies)])
    extras = _yt_dlp_cli_extras(
        url=url,
        extractor_extra=f"comment_sort=top;max_comments={max_comments}",
        use_browser_cookies=False,
        check_formats=False,
        disable_impersonate=True,
    )
    cmd.extend(extras)
    cmd.append(url)

    timeout_sec = int(os.getenv("YT_DLP_COMMENT_TIMEOUT", "300"))
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=timeout_sec,
            env=_yt_dlp_subprocess_env(),
        )
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError(f"抓取 YouTube 评论超时（已等待 {timeout_sec} 秒）") from exc
    if proc.returncode != 0:
        detail = (proc.stderr or proc.stdout or "").strip()
        raise RuntimeError(_format_ytdlp_error(detail, url))


def _load_info_json(work_dir: Path) -> dict:
    for path in sorted(work_dir.glob("*.info.json")):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            continue
        if isinstance(data, dict):
            return data
    return {}


def _normalize_comment(item: dict) -> dict:
    text = str(item.get("text") or item.get("content") or "").strip()
    text = re.sub(r"https?://\S+", "", text)
    text = re.sub(r"[ \t]+\n", "\n", text)
    text = re.sub(r"\n{3,}", "\n\n", text).strip()
    likes = item.get("like_count") or item.get("likeCount") or 0
    try:
        like_count = int(likes)
    except (TypeError, ValueError):
        like_count = 0
    parent = str(item.get("parent") or "root")
    return {
        "id": str(item.get("id") or "").strip(),
        "text": text,
        "like_count": max(0, like_count),
        "author": str(item.get("author") or "").strip()[:120],
        "parent": parent,
        "is_pinned": bool(item.get("is_pinned")),
        "author_is_uploader": bool(item.get("author_is_uploader")),
    }
