from __future__ import annotations

import os
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path

from qiniu import Auth, put_file


@dataclass(frozen=True)
class QiniuConfig:
    access_key: str
    secret_key: str
    bucket: str
    domain: str
    prefix: str = "en"

    @classmethod
    def from_env(cls) -> QiniuConfig:
        access_key = os.getenv("QINIU_ACCESS_KEY", "").strip()
        secret_key = os.getenv("QINIU_SECRET_KEY", "").strip()
        bucket = os.getenv("QINIU_BUCKET", "en").strip()
        domain = os.getenv("QINIU_DOMAIN", "").strip().rstrip("/")
        prefix = os.getenv("QINIU_PREFIX", "en").strip().strip("/")
        if not all([access_key, secret_key, bucket, domain]):
            raise RuntimeError(
                "Missing Qiniu config. Set QINIU_ACCESS_KEY, QINIU_SECRET_KEY, "
                "QINIU_BUCKET, QINIU_DOMAIN in backend/.env"
            )
        return cls(
            access_key=access_key,
            secret_key=secret_key,
            bucket=bucket,
            domain=domain,
            prefix=prefix,
        )

    def object_key(self, *parts: str) -> str:
        cleaned = [self.prefix, *[p.strip("/") for p in parts if p]]
        return "/".join(cleaned)

    def public_url(self, key: str) -> str:
        return f"{self.domain}/{key.lstrip('/')}"


def episode_media_urls(cfg: QiniuConfig, video_id: str) -> dict[str, str]:
    cover = cfg.public_url(cfg.object_key(video_id, "cover.webp"))
    return {
        "video_url": cfg.public_url(cfg.object_key(video_id, "video.mp4")),
        "audio_url": cfg.public_url(cfg.object_key(video_id, "audio.mp3")),
        "cover": cover,
        "thumbnail_url": cover,
    }


def qiniu_object_exists(cfg: QiniuConfig, video_id: str, filename: str, *, timeout: int = 30) -> bool:
    """Check object via Range GET (more reliable than HEAD on some CDNs)."""
    url = cfg.public_url(cfg.object_key(video_id, filename))
    req = urllib.request.Request(
        url,
        method="GET",
        headers={"User-Agent": "Mozilla/5.0", "Range": "bytes=0-0"},
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return resp.status in (200, 206)
    except urllib.error.HTTPError as exc:
        return exc.code in (200, 206)
    except OSError:
        return False


def upload_file(cfg: QiniuConfig, local_path: Path, key: str) -> str:
    if not local_path.is_file():
        raise FileNotFoundError(local_path)

    auth = Auth(cfg.access_key, cfg.secret_key)
    token = auth.upload_token(cfg.bucket, key, 3600)
    ret, info = put_file(token, key, str(local_path), version="v2")
    if info.status_code != 200:
        body = getattr(info, "text_body", "") or str(info)
        hint = ""
        if "no such bucket" in body:
            hint = f" (bucket `{cfg.bucket}` 不存在或 AK/SK 无权限，请在七牛控制台确认)"
        raise RuntimeError(f"Qiniu upload failed ({info.status_code}): {body}{hint}")

    return cfg.public_url(key)
