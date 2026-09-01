import json

from typing import Any

from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, Request, UploadFile
from fastapi.responses import Response, StreamingResponse
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_client_ip, get_current_user, get_current_user_optional, get_device_id
from ..models import User
from ..services import ai_coach as coach
from ..services import practice_records as practice_records_svc
from ..services import practice_tts as practice_tts_svc
from ..services import oral_eval as oral_eval_svc
from ..services import voice_clone as voice_clone_svc

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
    title: str = Field(default="", max_length=256)


class OralEvalFeedbackIn(BaseModel):
    ref_text: str = Field(min_length=1, max_length=8000)
    oral_result: dict[str, Any] = Field(default_factory=dict)
    core_type: str = Field(default="en.sent.score", max_length=32)
    source_type: str = Field(default="other", max_length=16)
    video_id: str = Field(default="", max_length=32)
    subtitle_id: int | None = None
    article_id: str = Field(default="", max_length=32)
    segment_id: int | None = None
    title: str = Field(default="", max_length=256)


class TextShadowingIn(BaseModel):
    target: str = Field(min_length=1, max_length=8000)
    transcript: str = ""
    mode: str = Field(default="sentence", max_length=16)
    source_type: str = Field(default="other", max_length=16)
    video_id: str = Field(default="", max_length=32)
    subtitle_id: int | None = None
    article_id: str = Field(default="", max_length=32)
    segment_id: int | None = None
    title: str = Field(default="", max_length=256)


class PracticeTtsIn(BaseModel):
    text: str = Field(min_length=1, max_length=1200)
    voice: str = Field(min_length=1, max_length=32)
    # word / sentence / passage 长度上限由服务层按 mode 再校验
    mode: str = Field(default="sentence", max_length=16)


class VoiceCloneSpeakIn(BaseModel):
    text: str = Field(min_length=1, max_length=500)
    duration_ms: int | None = Field(default=None, ge=1, le=120_000)


class VoiceClonePreferIn(BaseModel):
    prefer_playback: bool = True


class ShadowTrackUpsertIn(BaseModel):
    video_id: str = Field(min_length=1, max_length=32)
    subtitle_id: int
    title: str = Field(default="", max_length=256)
    ref_text: str = Field(default="", max_length=8000)


class ReadingQaIn(BaseModel):
    article_id: str = Field(min_length=1, max_length=32)
    segment_id: int | None = None
    question: str = ""


@router.get("/quota/")
def ai_quota(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """今日 AI 免费额度剩余（不消耗）。"""
    from ..services.ai_quota import get_quota_status

    return get_quota_status(db, user)


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
    db: Session = Depends(get_db),
):
    """服务端代理申请 warrant_id，密钥不下发前端。"""
    return coach.oral_eval_warrant_for_user(db, user, client_ip=get_client_ip(request))


@router.get("/oral-eval/audio/")
def oral_eval_audio(
    url: str = Query(min_length=8, max_length=1000),
    _user: User = Depends(get_current_user),
):
    """代理拉取口语评测云端录音（解决 HTTPS 页无法播 http 音频）。"""
    try:
        data, content_type = oral_eval_svc.fetch_oral_audio_bytes(url)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    return Response(
        content=data,
        media_type=content_type,
        headers={"Cache-Control": "private, max-age=3600"},
    )


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
        title=body.title,
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
        source_type=body.source_type,
        video_id=body.video_id,
        subtitle_id=body.subtitle_id,
        article_id=body.article_id,
        segment_id=body.segment_id,
        title=body.title,
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
        mode=body.mode,
        source_type=body.source_type,
        video_id=body.video_id,
        subtitle_id=body.subtitle_id,
        article_id=body.article_id,
        segment_id=body.segment_id,
        title=body.title,
    )


@router.get("/practice-records/")
def list_practice_records(
    mode: str | None = Query(default=None, max_length=16),
    video_id: str | None = Query(default=None, max_length=32),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """练习记录列表（查阅不扣额度）。"""
    return practice_records_svc.list_practice_records(
        db, user, mode=mode, video_id=video_id, page=page, page_size=page_size
    )


@router.get("/practice-records/shadow/")
def list_shadow_tracks(
    video_id: str = Query(..., min_length=1, max_length=32),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """某视频下影子跟读音轨（每字幕最新一条）。"""
    return practice_records_svc.list_shadow_tracks_for_video(db, user, video_id)


@router.post("/practice-records/shadow/")
def upsert_shadow_record(
    body: ShadowTrackUpsertIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """创建或覆盖某字幕的影子跟读记录（随后再上传 audio）。"""
    row = practice_records_svc.upsert_shadow_record(
        db,
        user,
        video_id=body.video_id,
        subtitle_id=body.subtitle_id,
        title=body.title,
        ref_text=body.ref_text,
    )
    return practice_records_svc.record_to_dict(row)


@router.get("/practice-records/{record_id}/")
def get_practice_record(
    record_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = practice_records_svc.get_practice_record(db, user, record_id)
    if not row:
        raise HTTPException(status_code=404, detail="练习记录不存在")
    covers = practice_records_svc.covers_for_records(db, [row])
    cover, source_title = covers.get(row.id, ("", ""))
    return practice_records_svc.record_to_dict(
        row, include_detail=True, cover_url=cover, source_title=source_title
    )


@router.delete("/practice-records/{record_id}/")
def delete_practice_record(
    record_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    ok = practice_records_svc.delete_practice_record(db, user, record_id)
    if not ok:
        raise HTTPException(status_code=404, detail="练习记录不存在")
    return {"ok": True}


@router.post("/practice-records/{record_id}/audio/")
async def upload_practice_audio(
    record_id: int,
    file: UploadFile = File(...),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """前端上传本地录音到练习记录（云端录音转存失败时的回退）。"""
    row = practice_records_svc.get_practice_record(db, user, record_id)
    if not row:
        raise HTTPException(status_code=404, detail="练习记录不存在")
    data = await file.read()
    if not data:
        raise HTTPException(status_code=400, detail="录音文件为空")
    ctype = (file.content_type or "audio/ogg").split(";")[0].strip()
    try:
        url = practice_records_svc.archive_audio_bytes(
            db, user, row, data, content_type=ctype, source="upload"
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"录音上传失败：{exc}") from exc
    return {"ok": True, "audio_url": url, "id": row.id}


@router.post("/practice-tts/")
def practice_tts(
    body: PracticeTtsIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """跟读/单词打分示范音（Ryan / Katerina）。不计入 AI 日额度；本地磁盘缓存。"""
    from ..services.ai_quota import record_usage

    audio, cache_hit = practice_tts_svc.synthesize_practice_tts(
        text=body.text,
        voice=body.voice,
        mode=body.mode,
    )
    record_usage(
        db,
        user,
        action="practice_tts",
        provider="dashscope",
        billed=not cache_hit,
        cache_hit=cache_hit,
        counts_quota=False,
        meta={"voice": body.voice, "mode": body.mode},
    )
    return Response(
        content=audio,
        media_type="audio/mpeg",
        headers={
            "X-Practice-TTS-Cache": "HIT" if cache_hit else "MISS",
            "Cache-Control": "private, max-age=86400",
        },
    )


@router.get("/voice-clone/")
def voice_clone_status(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """当前用户复刻音色状态（不含原始 voice 密钥以外的敏感配置）。"""
    row = voice_clone_svc.get_row(db, user)
    return {
        "configured": voice_clone_svc.voice_clone_ready(),
        "provider": "cosyvoice",
        "needsReenroll": voice_clone_svc.needs_reenroll(row),
        "enrollText": voice_clone_svc.DEFAULT_ENROLL_TEXT,
        "minDurationMs": voice_clone_svc.MIN_DURATION_MS,
        "maxDurationMs": voice_clone_svc.RECOMMENDED_MAX_MS,
        "voice": voice_clone_svc.row_to_dict(row),
    }


@router.post("/voice-clone/")
async def voice_clone_create(
    file: UploadFile = File(...),
    text: str = Form(default=""),
    language: str = Form(default="en"),
    duration_ms: int | None = Form(default=None),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """上传录音创建/替换复刻音色。每用户仅保留 1 条；重录会先删旧音色。"""
    from ..services.ai_quota import record_usage

    data = await file.read()
    if not data:
        raise HTTPException(status_code=400, detail="录音文件为空")
    ctype = (file.content_type or "audio/webm").split(";")[0].strip()
    row = voice_clone_svc.create_or_replace(
        db,
        user,
        audio_data=data,
        content_type=ctype,
        text=text,
        language=language,
        duration_ms=duration_ms,
    )
    record_usage(
        db,
        user,
        action="voice_clone_create",
        provider="dashscope",
        billed=True,
        cache_hit=False,
        counts_quota=False,
        meta={"fallback": row.fallback_mode},
    )
    return {
        "ok": True,
        "voice": voice_clone_svc.row_to_dict(row),
        "fallbackMode": bool(row.fallback_mode),
        "message": (
            "音色已创建，但样本质量一般，建议重新录制以获得更像你的声音"
            if row.fallback_mode
            else "音色创建成功"
        ),
    }


@router.delete("/voice-clone/")
def voice_clone_delete(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    ok = voice_clone_svc.delete_for_user(db, user)
    if not ok:
        raise HTTPException(status_code=404, detail="尚未复刻声音")
    return {"ok": True}


@router.patch("/voice-clone/preference/")
def voice_clone_preference(
    body: VoiceClonePreferIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """跨端同步：是否用复刻音色朗读字幕。"""
    row = voice_clone_svc.set_prefer_playback(db, user, body.prefer_playback)
    return {"ok": True, "voice": voice_clone_svc.row_to_dict(row)}


@router.get("/voice-clone/sample/")
def voice_clone_sample(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """回放用户报名时保留的样本录音。"""
    row = voice_clone_svc.get_row(db, user)
    if not row:
        raise HTTPException(status_code=404, detail="尚未复刻声音")
    data, ctype = voice_clone_svc.read_sample(row)
    return Response(
        content=data,
        media_type=ctype or "audio/mpeg",
        headers={"Cache-Control": "private, max-age=3600"},
    )


@router.post("/voice-clone/speak/")
def voice_clone_speak(
    body: VoiceCloneSpeakIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """用用户复刻音色朗读字幕文本（当前句）。"""
    from ..services.ai_quota import record_usage

    audio, cache_hit = voice_clone_svc.synthesize_for_user(
        db, user, body.text, duration_ms=body.duration_ms
    )
    record_usage(
        db,
        user,
        action="voice_clone_speak",
        provider="dashscope",
        billed=not cache_hit,
        cache_hit=cache_hit,
        counts_quota=False,
        meta={},
    )
    return Response(
        content=audio,
        media_type="audio/mpeg",
        headers={
            "X-Voice-Clone-Cache": "HIT" if cache_hit else "MISS",
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
