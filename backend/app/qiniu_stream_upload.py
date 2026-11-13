"""七牛分片直传：边从源（B 站直链）读取边按 4MB 分片上传，不落整片磁盘。

使用七牛 v2 分片接口（mkblk / bput / mkfile）。上传域名按区域尝试，
失败由调用方回退到“下载后上传”的稳妥路径。
"""
from __future__ import annotations

import base64
import json
import urllib.parse
import urllib.request
from typing import Iterable

from qiniu import Auth

from .qiniu_storage import QiniuConfig

_BLOCK_SIZE = 4 * 1024 * 1024
_UPLOAD_HOSTS = (
    "https://up.qiniup.com",
    "https://up-z2.qiniup.com",
    "https://up-z1.qiniup.com",
    "https://up-na0.qiniup.com",
    "https://up-as0.qiniup.com",
)


def _urlsafe_b64(value: str) -> str:
    return base64.urlsafe_b64encode(value.encode("utf-8")).decode("ascii")


def _post(host: str, path: str, data: bytes, token: str, mime: str = "application/octet-stream"):
    req = urllib.request.Request(
        host + path,
        data=data,
        method="POST",
        headers={
            "Authorization": f"UpToken {token}",
            "Content-Type": mime,
        },
    )
    with urllib.request.urlopen(req, timeout=300) as resp:
        body = resp.read().decode("utf-8", "ignore")
    return json.loads(body) if body else {}


def stream_to_qiniu(
    cfg: QiniuConfig,
    key: str,
    chunks: Iterable[bytes],
    mime: str = "video/mp4",
) -> str:
    """把 chunks 流式分片上传到七牛，返回无签名 public URL。"""
    token = Auth(cfg.access_key, cfg.secret_key).upload_token(cfg.bucket, key, 7200)

    host = ""
    ctxs: list[str] = []
    offset = 0
    buf = b""

    def first_block(block: bytes) -> str:
        nonlocal host
        last_exc: Exception | None = None
        for h in _UPLOAD_HOSTS:
            try:
                resp = _post(h, f"/mkblk/{len(block)}", block, token)
                host = h
                return resp["ctx"]
            except Exception as exc:  # noqa: BLE001
                last_exc = exc
        raise RuntimeError(f"七牛分片首块上传失败：{last_exc}")

    def next_block(block: bytes) -> str:
        resp = _post(host, f"/bput/{ctxs[-1]}/{offset}", block, token)
        return resp["ctx"]

    for piece in chunks:
        if not piece:
            continue
        buf += piece
        while len(buf) >= _BLOCK_SIZE:
            block, buf = buf[:_BLOCK_SIZE], buf[_BLOCK_SIZE:]
            ctx = first_block(block) if not ctxs else next_block(block)
            ctxs.append(ctx)
            offset += len(block)

    if buf:
        ctx = first_block(buf) if not ctxs else next_block(buf)
        ctxs.append(ctx)
        offset += len(buf)

    if not ctxs:
        raise RuntimeError("没有可上传的内容")

    encoded_key = urllib.parse.quote(_urlsafe_b64(key), safe="")
    encoded_mime = urllib.parse.quote(_urlsafe_b64(mime), safe="")
    _post(
        host,
        f"/mkfile/{offset}/key/{encoded_key}/mimeType/{encoded_mime}",
        ",".join(ctxs).encode("utf-8"),
        token,
        mime="text/plain",
    )
    return cfg.public_url(key)
