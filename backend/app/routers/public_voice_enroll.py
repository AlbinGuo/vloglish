"""无鉴权短链：复刻样本拉取、小程序封面中转。"""

import urllib.error
import urllib.request

from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import Response

from ..media import resolve_cover_url
from ..qiniu_storage import is_our_qiniu_url
from ..services import voice_enroll_public as enroll_pub

router = APIRouter(prefix="/api/public", tags=["public"])


@router.api_route("/voice-enroll/{token}", methods=["GET", "HEAD"])
def fetch_voice_enroll_sample(token: str):
    hit = enroll_pub.read_enroll_token(token)
    if not hit:
        raise HTTPException(status_code=404, detail="样本链接无效或已过期")
    data, ctype = hit
    return Response(
        content=data,
        media_type=ctype or "audio/mpeg",
        headers={
            "Cache-Control": "no-store",
            "Access-Control-Allow-Origin": "*",
            "Content-Length": str(len(data)),
        },
    )


@router.get("/cover/")
def public_cover(u: str = Query(..., min_length=8, max_length=2048)):
    """把七牛封面转到本站 HTTPS，避免小程序 Referer 被防盗链拦截。"""
    raw = (u or "").strip()
    if raw.startswith("//"):
        raw = "https:" + raw
    if not is_our_qiniu_url(raw):
        raise HTTPException(status_code=400, detail="不支持的封面地址")
    signed = resolve_cover_url(raw)
    req = urllib.request.Request(
        signed,
        headers={"User-Agent": "VloglishCoverProxy/1.0"},
        method="GET",
    )
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            data = resp.read(2_000_000)
            ctype = (resp.headers.get("Content-Type") or "image/jpeg").split(";")[0]
    except urllib.error.HTTPError as exc:
        raise HTTPException(status_code=502, detail=f"封面拉取失败 ({exc.code})") from exc
    except OSError as exc:
        raise HTTPException(status_code=502, detail="封面拉取失败") from exc
    if not data:
        raise HTTPException(status_code=404, detail="封面为空")
    if ctype not in ("image/jpeg", "image/jpg", "image/png", "image/webp", "image/gif"):
        ctype = "image/jpeg"
    return Response(
        content=data,
        media_type=ctype,
        headers={"Cache-Control": "public, max-age=86400"},
    )
