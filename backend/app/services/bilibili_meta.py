"""B 站元信息与直链解析，供代理与“一键导入”接口复用。"""
from __future__ import annotations

import re
import time
import urllib.parse

from .yt_dlp_fetch import _bili_cookie_header, _bili_get_json, resolve_bilibili_short_url

_BV_RE = re.compile(r"(BV[0-9A-Za-z]{10})")
_PAGE_RE = re.compile(r"[?&]p=(\d+)")
_SHORT_HOSTS = ("b23.tv", "bili2233", "b23.wtf")

# 直链/封面只来自 B 站官方接口，这里再加一层域名白名单防误用
ALLOWED_HOST_SUFFIXES = (
    ".bilivideo.com",
    ".bilivideo.cn",
    ".akamaized.net",
    ".szbdyd.com",
    ".hdslb.com",
)

_durl_cache: dict[str, tuple[float, str]] = {}
_DURL_TTL = 300


def extract_bvid(raw: str) -> str:
    m = _BV_RE.search((raw or "").strip())
    return m.group(1) if m else ""


def page_from(raw: str) -> int:
    m = _PAGE_RE.search(raw or "")
    try:
        return int(m.group(1)) if m else 1
    except ValueError:
        return 1


def host_allowed(url: str) -> bool:
    try:
        host = (urllib.parse.urlparse(url).netloc or "").lower().split(":")[0]
    except Exception:
        return False
    return bool(host) and any(host.endswith(sfx) for sfx in ALLOWED_HOST_SUFFIXES)


def canonical_url(bvid: str, page: int) -> str:
    base = f"https://www.bilibili.com/video/{bvid}"
    return f"{base}?p={page}" if page and page > 1 else base


def proxy_cover_url(cover: str) -> str:
    raw = (cover or "").strip()
    if not raw:
        return ""
    return f"/api/bilibili/cover?url={urllib.parse.quote(raw, safe='')}"


def _view(bvid: str) -> tuple[dict, str]:
    cookie = _bili_cookie_header()
    payload = _bili_get_json(
        f"https://api.bilibili.com/x/web-interface/view?bvid={bvid}", cookie
    )
    if payload.get("code") != 0:
        raise RuntimeError(
            f"B站接口返回 {payload.get('code')}: {payload.get('message')}"
        )
    return payload.get("data") or {}, cookie


def _pick_page(data: dict, page: int) -> tuple[object, float]:
    cid = data.get("cid")
    duration = float(data.get("duration") or 0)
    pages = data.get("pages") or []
    if pages and 1 <= page <= len(pages):
        cid = pages[page - 1].get("cid") or cid
        duration = float(pages[page - 1].get("duration") or duration)
    return cid, duration


def fetch_meta(raw: str, page_override: int | None = None) -> dict:
    """解析 B 站链接/BV 号，返回标题、封面、作者、时长、cid 等。"""
    text = (raw or "").strip()
    if any(h in text for h in _SHORT_HOSTS):
        text = resolve_bilibili_short_url(text) or text
    bvid = extract_bvid(text)
    if not bvid:
        raise ValueError("无法识别 B 站链接或 BV 号")
    page = int(page_override) if page_override else page_from(text)
    page = max(1, page)

    data, _ = _view(bvid)
    cid, duration = _pick_page(data, page)
    if not cid:
        raise RuntimeError("B站未返回 cid")
    owner = data.get("owner") or {}
    cover = str(data.get("pic") or "")
    return {
        "bvid": bvid,
        "page": page,
        "cid": cid,
        "title": str(data.get("title") or ""),
        "summary": str(data.get("desc") or "")[:2000],
        "cover": cover,
        "cover_proxy": proxy_cover_url(cover),
        "author_name": str(owner.get("name") or ""),
        "author_avatar": str(owner.get("face") or ""),
        "duration": duration,
        "canonical_url": canonical_url(bvid, page),
    }


def resolve_durl(bvid: str, page: int) -> str:
    """返回 durl 单文件直链（含音视频），进程内缓存 5 分钟。"""
    key = f"{bvid}#{page}"
    now = time.time()
    cached = _durl_cache.get(key)
    if cached and cached[0] > now:
        return cached[1]

    data, cookie = _view(bvid)
    cid, _ = _pick_page(data, page)
    if not cid:
        raise RuntimeError("B站未返回 cid")

    play = _bili_get_json(
        "https://api.bilibili.com/x/player/playurl"
        f"?bvid={bvid}&cid={cid}&qn=64&fnval=1&platform=html5&high_quality=1",
        cookie,
    )
    if play.get("code") != 0:
        raise RuntimeError(
            f"B站播放接口返回 {play.get('code')}: {play.get('message')}"
        )
    durl = (play.get("data") or {}).get("durl") or []
    url = str(durl[0].get("url") or "") if durl else ""
    if not url:
        raise RuntimeError(
            "B站未返回 durl 单文件（可能需要登录 Cookie，或该视频仅支持 DASH）"
        )
    _durl_cache[key] = (now + _DURL_TTL, url)
    return url
