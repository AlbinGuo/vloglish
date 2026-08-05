import json

from typing import Any

from fastapi import APIRouter, Depends, Query, Request
from fastapi.responses import Response, StreamingResponse
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_client_ip, get_current_user, get_current_user_optional, get_device_id
from ..models import User
from ..services import ai_coach as coach
from ..services import practice_tts as practice_tts_svc

router = APIRouter(prefix="/api/ai", tags=["ai-coach"])


class ExplainIn(BaseModel):
    video_id: str = Field(min_length=1, max_length=32)
    subtitle_id: int
    force: bool = False


class ClozeIn(BaseModel):
    video_id: str = Field(min_length=1, max_length=32)
    subtitle_id: int
    force: bool = False


class ShadowingIn(BaseModel):
    video_id: str = Field(min_length=1, max_length=32)
    subtitle_id: int
    transcript: str = ""


class OralShadowingIn(BaseModel):
    video_id: str = Field(min_length=1, max_length=32)
    subtitle_id: int
    oral_result: dict[str, Any] = Field(default_factory=dict)


class OralEvalFeedbackIn(BaseModel):
    ref_text: str = Field(min_length=1, max_length=8000)
    oral_result: dict[str, Any] = Field(default_factory=dict)
    core_type: str = Field(default="en.sent.score", max_length=32)


class TextShadowingIn(BaseModel):
    target: str = Field(min_length=1, max_length=8000)
    transcript: str = ""


class PracticeTtsIn(BaseModel):
    text: str = Field(min_length=1, max_length=1200)
    voice: str = Field(min_length=1, max_length=32)
    # word / sentence / passage 长度上限由服务层按 mode 再校验
    mode: str = Field(default="sentence", max_length=16)


class ReadingQaIn(BaseModel):
    article_id: str = Field(min_length=1, max_length=32)
    segment_id: int | None = None
    question: str = ""


@router.post("/explain-subtitle/")
def explain_subtitle(
    body: ExplainIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return coach.explain_subtitle(
        db,
        user,
        video_id=body.video_id,
        subtitle_id=body.subtitle_id,
        force=body.force,
    )


@router.post("/explain-subtitle/stream/")
def explain_subtitle_stream(
    body: ExplainIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """SSE：meta → field* → done（或 error）。命中缓存时几乎瞬时推完。"""

    def event_gen():
        for event in coach.explain_subtitle_stream(
            db,
            user,
            video_id=body.video_id,
            subtitle_id=body.subtitle_id,
            force=body.force,
        ):
            yield f"data: {json.dumps(event, ensure_ascii=False)}\n\n"

    return StreamingResponse(
        event_gen(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )


@router.post("/generate-cloze/")
def generate_cloze(
    body: ClozeIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return coach.cloze_for_subtitle(
        db,
        user,
        video_id=body.video_id,
        subtitle_id=body.subtitle_id,
        force=body.force,
    )


@router.post("/shadowing-feedback/")
def shadowing(
    body: ShadowingIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return coach.shadowing_for_subtitle(
        db,
        user,
        video_id=body.video_id,
        subtitle_id=body.subtitle_id,
        transcript=body.transcript,
    )


@router.get("/oral-eval/status/")
def oral_eval_status(_user: User | None = Depends(get_current_user_optional)):
    """是否启用口语评测引擎（未配置时前端走 ASR+LLM 回退）。无需登录即可探测。"""
    return coach.oral_eval_status()


@router.post("/oral-eval/warrant/")
def oral_eval_warrant(
    request: Request,
    user: User = Depends(get_current_user),
):
    """服务端代理申请 warrant_id，密钥不下发前端。"""
    return coach.oral_eval_warrant_for_user(user, client_ip=get_client_ip(request))


@router.post("/shadowing-oral-feedback/")
def shadowing_oral(
    body: OralShadowingIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """口语评测成功后的统一结果落库/额度与建议生成。"""
    return coach.shadowing_from_oral_result(
        db,
        user,
        video_id=body.video_id,
        subtitle_id=body.subtitle_id,
        oral_payload=body.oral_result,
    )


@router.post("/oral-eval/feedback/")
def oral_eval_feedback(
    body: OralEvalFeedbackIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """通用口语评测反馈（单词 / 句子 / 篇章）。"""
    return coach.oral_eval_feedback(
        db,
        user,
        ref_text=body.ref_text,
        oral_payload=body.oral_result,
        core_type=body.core_type,
    )


@router.post("/shadowing-text-feedback/")
def shadowing_text(
    body: TextShadowingIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """任意文本的 ASR+LLM 跟读点评（无字幕场景回退）。"""
    return coach.shadowing_for_text(
        db,
        user,
        target=body.target,
        transcript=body.transcript,
    )


@router.post("/practice-tts/")
def practice_tts(
    body: PracticeTtsIn,
    _user: User = Depends(get_current_user),
):
    """跟读/单词打分示范音（Ryan / Katerina）。不计入 AI 日额度；本地磁盘缓存。"""
    audio, cache_hit = practice_tts_svc.synthesize_practice_tts(
        text=body.text,
        voice=body.voice,
        mode=body.mode,
    )
    return Response(
        content=audio,
        media_type="audio/mpeg",
        headers={
            "X-Practice-TTS-Cache": "HIT" if cache_hit else "MISS",
            "Cache-Control": "private, max-age=86400",
        },
    )


@router.get("/daily-path/")
def daily_path(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return coach.daily_learning_path(db, user)


@router.post("/reading-qa/")
def reading_qa(
    body: ReadingQaIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    device_id: str = Depends(get_device_id),
):
    return coach.article_qa(
        db,
        user,
        article_id=body.article_id,
        segment_id=body.segment_id,
        question=body.question,
        device_id=device_id,
    )


@router.get("/vocab-review/")
def vocab_review(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
    generate: bool = Query(False),
    force: bool = Query(False),
):
    """错词复习。

    - generate=0：仅查看，返回当日缓存（不耗额度）
    - generate=1：有缓存则复用；无缓存才生成并耗额度
    - force=1：强制重新生成并耗额度（需配合 generate=1）
    """
    if not generate:
        return coach.peek_vocab_review(db, user)
    return coach.build_vocab_review(db, user, force=force)
