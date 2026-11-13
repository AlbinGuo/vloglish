"""B 站直连播放代理 + 元信息解析 + 封面代理。

思路：调 B 站 view + playurl 拿 durl 单文件直链（含音视频），后端带
Referer/Origin/UA/Cookie 请求 CDN，并透传 Range 返回 206，前端 <video>
即可秒播并支持拖动时间轴。不下载、不落盘、不存储。高清 DASH 分离流不在此处理。
"""
from __future__ import annotations

import hashlib
import logging
import urllib.error
import urllib.request
from pathlib import Path
from typing import Iterator

from fastapi import APIRouter, HTTPException, Request, Response
from fastapi.responses import FileResponse, StreamingResponse

from ..services.bilibili_meta import (
    extract_bvid,
    fetch_meta,
    host_allowed,
    invalidate_durl,
    resolve_durl,
)
from ..services.yt_dlp_fetch import _BILIBILI_USER_AGENT, _bili_cookie_header

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/bilibili", tags=["bilibili"])

# 封面磁盘缓存：B站图片有防盗链、回源慢，且每个 <img> 都会命中后端；落盘后重复访问秒开
_COVER_CACHE_DIR = Path(__file__).resolve().parents[2] / "data" / "cover_cache"
_COVER_EXT_BY_TYPE = {
    "image/jpeg": ".jpg",
    "image/jpg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
    "image/gif": ".gif",
    "image/avif": ".avif",
}
_COVER_KNOWN_EXTS = (".jpg", ".jpeg", ".png", ".webp", ".gif", ".avif")


@router.get("/resolve")
def resolve(url: str = "", bvid: str = "", page: int | None = None):
    raw = (url or "").strip() or (bvid or "").strip()
    if not raw:
        raise HTTPException(status_code=400, detail="缺少 B 站链接或 BV 号")
    try:
        return fetch_meta(raw, page)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=502, detail=f"解析失败：{exc}") from exc


@router.get("/cover")
def cover(url: str):
    raw = (url or "").strip()
    if not raw or not host_allowed(raw):
        raise HTTPException(status_code=400, detail="非法的封面地址")

    cache_key = hashlib.sha1(raw.encode("utf-8")).hexdigest()
    try:
        _COVER_CACHE_DIR.mkdir(parents=True, exist_ok=True)
        for ext in _COVER_KNOWN_EXTS:
            cached = _COVER_CACHE_DIR / f"{cache_key}{ext}"
            if cached.exists() and cached.stat().st_size > 0:
                return FileResponse(
                    cached,
                    headers={"Cache-Control": "public, max-age=604800, immutable"},
                )
    except Exception:  # noqa: BLE001
        pass

    headers = {
        "User-Agent": _BILIBILI_USER_AGENT,
        "Referer": "https://www.bilibili.com/",
    }
    try:
        with urllib.request.urlopen(
            urllib.request.Request(raw, headers=headers), timeout=30
        ) as resp:
            data = resp.read()
            media_type = resp.headers.get("Content-Type") or "image/jpeg"
    except urllib.error.HTTPError as exc:
        raise HTTPException(status_code=exc.code, detail="封面拉取失败") from exc
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=502, detail=f"封面拉取失败：{exc}") from exc

    try:
        base_type = media_type.split(";")[0].strip().lower()
        ext = _COVER_EXT_BY_TYPE.get(base_type, ".jpg")
        (_COVER_CACHE_DIR / f"{cache_key}{ext}").write_bytes(data)
    except Exception:  # noqa: BLE001
        pass

    return Response(
        content=data,
        media_type=media_type,
        headers={"Cache-Control": "public, max-age=604800, immutable"},
    )


@router.get("/stream/{bvid}")
def bilibili_stream(bvid: str, request: Request, p: int = 1):
    clean = extract_bvid(bvid)
    if not clean:
        raise HTTPException(status_code=400, detail="无效的 BV 号")
    page = max(1, int(p or 1))
    try:
        target = resolve_durl(clean, page)
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=502, detail=f"获取直链失败：{exc}") from exc
    if not host_allowed(target):
        raise HTTPException(status_code=502, detail="解析出的直链域名不在允许列表")

    headers = {
        "User-Agent": _BILIBILI_USER_AGENT,
        "Referer": f"https://www.bilibili.com/video/{clean}",
        "Origin": "https://www.bilibili.com",
        "Accept": "*/*",
    }
    cookie = _bili_cookie_header()
    if cookie:
        headers["Cookie"] = cookie
    range_header = request.headers.get("range")
    if range_header:
        headers["Range"] = range_header

    def _open(target_url: str):
        req_headers = dict(headers)
        if range_header:
            req_headers["Range"] = range_header
        return urllib.request.urlopen(
            urllib.request.Request(target_url, headers=req_headers), timeout=60
        )

    try:
        resp = _open(target)
    except urllib.error.HTTPError as exc:
        if exc.code == 416:
            raise HTTPException(status_code=416, detail="Range 不满足") from exc
        # 直链已过期（403/410）：清缓存重新解析后重试一次，避免用户点开要等很久
        if exc.code in (403, 410):
            invalidate_durl(clean, page)
            try:
                target = resolve_durl(clean, page)
            except Exception:
                detail = ""
                try:
                    detail = exc.read().decode("utf-8", "ignore")[:200]
                except Exception:
                    pass
                raise HTTPException(
                    status_code=502, detail=f"B站 CDN 返回 {exc.code}: {detail}"
                ) from exc
            try:
                resp = _open(target)
            except urllib.error.HTTPError as exc2:
                detail = ""
                try:
                    detail = exc2.read().decode("utf-8", "ignore")[:200]
                except Exception:
                    pass
                raise HTTPException(
                    status_code=502, detail=f"B站 CDN 返回 {exc2.code}: {detail}"
                ) from exc2
            except urllib.error.URLError as exc2:
                raise HTTPException(status_code=502, detail=f"B站 CDN 连接失败：{exc2}") from exc2
        detail = ""
        try:
            detail = exc.read().decode("utf-8", "ignore")[:200]
        except Exception:
            pass
        raise HTTPException(
            status_code=502, detail=f"B站 CDN 返回 {exc.code}: {detail}"
        ) from exc

    content_type = resp.headers.get("Content-Type") or "video/mp4"
    passthrough = {}
    for h in ("Content-Length", "Content-Range", "Accept-Ranges", "Last-Modified", "ETag"):
        v = resp.headers.get(h)
        if v:
            passthrough[h] = v

    def iterator() -> Iterator[bytes]:
        try:
            while True:
                chunk = resp.read(64 * 1024)
                if not chunk:
                    break
                yield chunk
        finally:
            resp.close()

    return StreamingResponse(
        iterator(),
        status_code=resp.status,
        headers=passthrough,
        media_type=content_type,
    )
