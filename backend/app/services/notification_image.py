"""通知配图：本地文件上传七牛。"""

from __future__ import annotations

import tempfile
import uuid
from pathlib import Path

from ..qiniu_storage import QiniuConfig, upload_file

ALLOWED_SUFFIXES = {".jpg", ".jpeg", ".png", ".webp", ".gif"}
MAX_IMAGE_BYTES = 8 * 1024 * 1024


def _suffix_from_bytes(data: bytes) -> str:
    if data.startswith(b"\xff\xd8\xff"):
        return ".jpg"
    if data.startswith(b"\x89PNG\r\n\x1a\n"):
        return ".png"
    if data.startswith(b"GIF87a") or data.startswith(b"GIF89a"):
        return ".gif"
    if len(data) >= 12 and data[:4] == b"RIFF" and data[8:12] == b"WEBP":
        return ".webp"
    return ""


def _normalize_suffix(filename: str | None, data: bytes) -> str:
    raw = (filename or "").lower()
    for ext in ALLOWED_SUFFIXES:
        if raw.endswith(ext):
            return ".jpg" if ext == ".jpeg" else ext
    detected = _suffix_from_bytes(data)
    if not detected:
        raise ValueError("仅支持 JPG / PNG / WEBP / GIF 图片")
    return detected


def upload_notification_image(
    cfg: QiniuConfig,
    data: bytes,
    filename: str | None = None,
    *,
    folder: str = "notifications",
) -> str:
    if not data:
        raise ValueError("图片内容为空")
    if len(data) > MAX_IMAGE_BYTES:
        raise ValueError("图片不能超过 8MB")

    suffix = _normalize_suffix(filename, data)
    folder_name = (folder or "notifications").strip().strip("/") or "notifications"
    key = cfg.object_key(folder_name, f"{uuid.uuid4().hex}{suffix}")
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
        tmp.write(data)
        tmp_path = Path(tmp.name)
    try:
        return upload_file(cfg, tmp_path, key)
    finally:
        tmp_path.unlink(missing_ok=True)
