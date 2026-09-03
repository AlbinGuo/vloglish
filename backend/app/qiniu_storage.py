from __future__ import annotations

import logging
import os
import urllib.error
import urllib.parse
import urllib.request
from contextlib import contextmanager
from dataclasses import dataclass
from pathlib import Path

from qiniu import Auth, put_file
from qiniu.config import get_default, set_default

logger = logging.getLogger(__name__)


_PROXY_ENV_KEYS = (
    "HTTP_PROXY",
    "HTTPS_PROXY",
    "ALL_PROXY",
    "http_proxy",
    "https_proxy",
    "all_proxy",
)
_QINIU_NO_PROXY_HOSTS = (
    "qiniup.com",
    "qbox.me",
    "qiniuapi.com",
    "qiniu.com",
    "127.0.0.1",
    "localhost",
)


@contextmanager
def _qiniu_upload_context():
    """Bypass local VPN/Clash proxy for Qiniu; large files need a longer timeout."""
    saved_proxy = {key: os.environ.pop(key, None) for key in _PROXY_ENV_KEYS}
    saved_no_proxy = {
        key: os.environ.get(key)
        for key in ("NO_PROXY", "no_proxy")
    }
    merged_no_proxy = set()
    for key in ("NO_PROXY", "no_proxy"):
        raw = saved_no_proxy.get(key) or ""
        merged_no_proxy.update(part.strip() for part in raw.split(",") if part.strip())
    merged_no_proxy.update(_QINIU_NO_PROXY_HOSTS)
    no_proxy_value = ",".join(sorted(merged_no_proxy))
    os.environ["NO_PROXY"] = no_proxy_value
    os.environ["no_proxy"] = no_proxy_value

    old_timeout = get_default("connection_timeout")
    upload_timeout = int(os.getenv("QINIU_UPLOAD_TIMEOUT", "7200"))
    set_default(connection_timeout=upload_timeout)
    try:
        yield
    finally:
        for key, value in saved_proxy.items():
            if value is None:
                os.environ.pop(key, None)
            else:
                os.environ[key] = value
        for key, value in saved_no_proxy.items():
            if value is None:
                os.environ.pop(key, None)
            else:
                os.environ[key] = value
        set_default(connection_timeout=old_timeout)


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
        placeholder_keys = {
            "your_access_key",
            "your_secret_key",
            "changeme",
            "xxx",
            "ak",
            "sk",
        }
        if access_key.lower() in placeholder_keys or secret_key.lower() in placeholder_keys:
            raise RuntimeError(
                "七牛 AK/SK 仍是占位符。请在 backend/.env 填入七牛控制台的 "
                "QINIU_ACCESS_KEY / QINIU_SECRET_KEY 后重启后端"
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
        """库内保存的永久基址（无签名）。对外播放请用 sign_url。"""
        return f"{self.domain}/{key.lstrip('/')}"

    @property
    def domain_host(self) -> str:
        host = urllib.parse.urlparse(self.domain).netloc or self.domain
        return host.lower().split(":")[0]


def qiniu_sign_enabled() -> bool:
    """默认开启签名；设 QINIU_SIGN_URLS=0 可临时关闭（调试用）。"""
    raw = os.getenv("QINIU_SIGN_URLS", "1").strip().lower()
    return raw not in {"0", "false", "no", "off"}


def qiniu_media_expires() -> int:
    """正片音视频签名有效期（秒），默认 4 小时。"""
    try:
        return max(60, int(os.getenv("QINIU_MEDIA_EXPIRES", "14400")))
    except ValueError:
        return 14400


def qiniu_cover_expires() -> int:
    """封面签名有效期（秒），默认 24 小时。"""
    try:
        return max(60, int(os.getenv("QINIU_COVER_EXPIRES", "86400")))
    except ValueError:
        return 86400


def strip_qiniu_download_token(url: str) -> str:
    """去掉已有 e/token，避免重复签名。"""
    raw = (url or "").strip()
    if not raw or "?" not in raw:
        return raw
    parsed = urllib.parse.urlparse(raw)
    query = urllib.parse.parse_qsl(parsed.query, keep_blank_values=True)
    kept = [(k, v) for k, v in query if k.lower() not in {"e", "token"}]
    return urllib.parse.urlunparse(parsed._replace(query=urllib.parse.urlencode(kept)))


def is_our_qiniu_url(url: str, cfg: QiniuConfig | None = None) -> bool:
    raw = (url or "").strip()
    if not raw.startswith(("http://", "https://")):
        return False
    try:
        conf = cfg or QiniuConfig.from_env()
    except RuntimeError:
        return False
    host = (urllib.parse.urlparse(raw).netloc or "").lower().split(":")[0]
    return bool(host) and host == conf.domain_host


def sign_url(url: str, *, expires: int | None = None, cfg: QiniuConfig | None = None) -> str:
    """对自家七牛域名资源签发短时下载 URL；非七牛或关闭签名时原样返回。"""
    raw = (url or "").strip()
    if not raw or not qiniu_sign_enabled():
        return raw
    if not raw.startswith(("http://", "https://")):
        return raw
    try:
        conf = cfg or QiniuConfig.from_env()
    except RuntimeError:
        return raw
    if not is_our_qiniu_url(raw, conf):
        return raw

    base = strip_qiniu_download_token(raw)
    if base.startswith("http://"):
        # 签名必须按最终访问协议；小程序只能拉 HTTPS
        base = "https://" + base[len("http://") :]
    ttl = expires if expires is not None else qiniu_media_expires()
    try:
        auth = Auth(conf.access_key, conf.secret_key)
        return auth.private_download_url(base, expires=ttl)
    except Exception:
        logger.warning("sign qiniu url failed: %s", base[:120], exc_info=True)
        return base


def episode_media_urls(cfg: QiniuConfig, video_id: str) -> dict[str, str]:
    """写入 DB 的永久基址（无签名）。"""
    cover = cfg.public_url(cfg.object_key(video_id, "cover.webp"))
    return {
        "video_url": cfg.public_url(cfg.object_key(video_id, "video.mp4")),
        "audio_url": cfg.public_url(cfg.object_key(video_id, "audio.mp3")),
        "cover": cover,
        "thumbnail_url": cover,
    }


def qiniu_object_exists(cfg: QiniuConfig, video_id: str, filename: str, *, timeout: int = 30) -> bool:
    """Check object via Range GET (more reliable than HEAD on some CDNs)."""
    base = cfg.public_url(cfg.object_key(video_id, filename))
    url = sign_url(base, expires=300, cfg=cfg)
    req = urllib.request.Request(
        url,
        method="GET",
        headers={
            "User-Agent": "Mozilla/5.0",
            "Range": "bytes=0-0",
            # 与网页端一致，避免开启 Referer 防盗链后服务端探测也被拦
            "Referer": (os.getenv("FRONTEND_URL") or "https://en.yunankexun.com").rstrip("/") + "/",
        },
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
    with _qiniu_upload_context():
        ret, info = put_file(token, key, str(local_path), version="v2")
    if info.status_code != 200:
        body = getattr(info, "text_body", "") or str(info)
        hint = ""
        body_l = body.lower()
        if "no such bucket" in body_l:
            hint = f" (bucket `{cfg.bucket}` 不存在或 AK/SK 无权限，请在七牛控制台确认)"
        if "accesskey is not found" in body_l or info.status_code == 612:
            hint += (
                "（七牛 AccessKey 无效或不存在：请核对 backend/.env 的 "
                "QINIU_ACCESS_KEY / QINIU_SECRET_KEY，保存后重启后端）"
            )
        if "127.0.0.1" in body and "timed out" in body.lower():
            hint += "（检测到本机代理，已尝试绕过；若仍失败请关闭 VPN/系统代理或增大 QINIU_UPLOAD_TIMEOUT）"
        raise RuntimeError(f"Qiniu upload failed ({info.status_code}): {body}{hint}")

    # DB / manifest 只存无签名基址
    return cfg.public_url(key)
