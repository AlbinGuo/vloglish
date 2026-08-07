"""App APK：上传安装包到七牛。"""

from __future__ import annotations

import tempfile
import uuid
from pathlib import Path

from ..qiniu_storage import QiniuConfig, upload_file

ALLOWED_SUFFIXES = {".apk"}
# 调试/正式包体积不一，放宽到 300MB
MAX_APK_BYTES = 300 * 1024 * 1024


def _looks_like_zip_apk(data: bytes) -> bool:
    # APK 为 ZIP 容器
    return len(data) >= 4 and data[:2] == b"PK"


def upload_app_apk(
    cfg: QiniuConfig,
    data: bytes,
    filename: str | None = None,
) -> str:
    if not data:
        raise ValueError("安装包内容为空")
    if len(data) > MAX_APK_BYTES:
        raise ValueError("安装包不能超过 300MB")

    raw = (filename or "").lower()
    if not any(raw.endswith(ext) for ext in ALLOWED_SUFFIXES):
        raise ValueError("仅支持 .apk 文件")
    if not _looks_like_zip_apk(data):
        raise ValueError("文件内容不像有效的 APK（ZIP）")

    key = cfg.object_key("apk", f"vloglish-{uuid.uuid4().hex}.apk")
    with tempfile.NamedTemporaryFile(suffix=".apk", delete=False) as tmp:
        tmp.write(data)
        tmp_path = Path(tmp.name)
    try:
        return upload_file(cfg, tmp_path, key)
    finally:
        tmp_path.unlink(missing_ok=True)
