"""文章封面：从外链下载并上传七牛。"""

from __future__ import annotations

import mimetypes
import tempfile
import urllib.error
import urllib.request
from pathlib import Path
from urllib.parse import urlparse

from ..qiniu_storage import QiniuConfig, upload_file


def normalize_image_url(url: str) -> str:
    cleaned = url.strip()
    if not cleaned:
        raise ValueError("图片链接不能为空")
    if cleaned.startswith("//"):
        return f"https:{cleaned}"
    if not cleaned.startswith(("http://", "https://")):
        raise ValueError("无效图片链接，需以 http://、https:// 或 // 开头")
    return cleaned


def _suffix_from_url(url: str) -> str:
    path = urlparse(url).path.lower()
    for ext in (".jpg", ".jpeg", ".png", ".webp", ".gif"):
        if path.endswith(ext):
            return ext if ext != ".jpeg" else ".jpg"
    return ""


def _suffix_from_bytes(data: bytes) -> str:
    if data.startswith(b"\xff\xd8\xff"):
        return ".jpg"
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return ".png"
    if data.startswith(b"GIF87a") or data.startswith(b"GIF89a"):
        return ".gif"
    if len(data) >= 12 and data[:4] == b"RIFF" and data[8:12] == b"WEBP":
        return ".webp"
    return ".jpg"


def _suffix_from_content_type(content_type: str | None) -> str:
    if not content_type:
        return ""
    ext = mimetypes.guess_extension(content_type.split(";", 1)[0].strip().lower())
    if ext == ".jpe":
        return ".jpg"
    return ext or ""


def upload_article_cover_from_url(
    cfg: QiniuConfig,
    article_public_id: str,
    source_url: str,
) -> str:
    url = normalize_image_url(source_url)
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 (compatible; Vloglish/1.0)",
            "Accept": "image/avif,image/webp,image/apng,image/*,*/*;q=0.8",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            content_type = resp.headers.get("Content-Type")
            data = resp.read()
    except urllib.error.HTTPError as exc:
        raise RuntimeError(f"封面下载失败 ({exc.code})") from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(f"封面下载失败: {exc.reason}") from exc

    if not data:
        raise RuntimeError("封面下载为空")

    suffix = _suffix_from_url(url) or _suffix_from_content_type(content_type) or _suffix_from_bytes(data)
    key = cfg.object_key("reading", article_public_id, f"cover{suffix}")

    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
        tmp.write(data)
        tmp_path = Path(tmp.name)
    try:
        return upload_file(cfg, tmp_path, key)
    finally:
        tmp_path.unlink(missing_ok=True)
