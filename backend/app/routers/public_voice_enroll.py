"""无鉴权短链：DashScope 拉取 CosyVoice 复刻样本。"""

from fastapi import APIRouter, HTTPException
from fastapi.responses import Response

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
