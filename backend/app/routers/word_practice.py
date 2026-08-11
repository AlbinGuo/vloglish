"""用户端：单词拼写练习。"""

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user
from ..models import User
from ..services import word_practice as svc
from ..services.example_translation import resolve_example_zh

router = APIRouter(prefix="/api/word-practice", tags=["word-practice"])


class WordPracticeStartIn(BaseModel):
    source: str = Field(default="vocab", description="vocab | episode_vocab | vocab_wrong")
    video_id: str = ""
    limit: int = Field(default=15, ge=5, le=50)


class WordPracticeItemOut(BaseModel):
    vocabulary_item_id: int | None = None
    entry_id: int
    word: str
    ipa: str = ""
    definition_cn: str = ""
    source_video_id: str = ""
    source_subtitle_id: int | None = None
    source_segment_id: int | None = None
    context: str = ""
    context_zh: str = ""


class WordPracticeStartOut(BaseModel):
    session_id: int
    source: str
    video_id: str = ""
    total_count: int
    items: list[WordPracticeItemOut]


class ContextTranslateIn(BaseModel):
    english: str = Field(..., min_length=1, max_length=2000)
    source_subtitle_id: int | None = None
    source_segment_id: int | None = None


class ContextTranslateOut(BaseModel):
    chinese: str
    from_cache: bool = False
    quota: dict | None = None


class WordPracticeResultIn(BaseModel):
    entry_id: int
    try_count: int = 1
    had_wrong: bool = False
    latency_ms: int = 0


class WordPracticeFinishIn(BaseModel):
    results: list[WordPracticeResultIn] = []
    duration_ms: int = 0
    chars_typed: int = 0


class WordPracticeFinishOut(BaseModel):
    session_id: int
    total_count: int
    correct_count: int
    wrong_count: int
    duration_ms: int
    chars_typed: int
    accuracy: int = 0


class WordPracticeWrongOut(BaseModel):
    id: int
    entry_id: int
    vocabulary_item_id: int | None = None
    word: str
    wrong_count: int
    last_wrong_at: str = ""
    ipa: str = ""
    definition_cn: str = ""


@router.post("/sessions/", response_model=WordPracticeStartOut)
def start_session(
    body: WordPracticeStartIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        row = svc.start_session(
            db,
            user.id,
            source=body.source,
            video_id=body.video_id,
            limit=body.limit,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    data = svc.session_to_start_dict(row)
    return WordPracticeStartOut(**data)


@router.post("/sessions/{session_id}/finish/", response_model=WordPracticeFinishOut)
def finish_session(
    session_id: int,
    body: WordPracticeFinishIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        data = svc.finish_session(
            db,
            user.id,
            session_id,
            results=[r.model_dump() for r in body.results],
            duration_ms=body.duration_ms,
            chars_typed=body.chars_typed,
        )
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e)) from e
    return WordPracticeFinishOut(**data)


@router.get("/wrongs/", response_model=list[WordPracticeWrongOut])
def get_wrongs(
    limit: int = Query(100, ge=1, le=200),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return [WordPracticeWrongOut(**row) for row in svc.list_wrongs(db, user.id, limit=limit)]


@router.get("/wrongs/count/")
def get_wrong_count(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return {"count": svc.wrong_count(db, user.id)}


@router.post("/context-translate/", response_model=ContextTranslateOut)
def translate_context(
    body: ContextTranslateIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """例句缺中文时按需 AI 翻译；同一英文全站共享缓存，命中不扣额度。"""
    try:
        data = resolve_example_zh(
            db,
            user,
            english=body.english,
            source_subtitle_id=body.source_subtitle_id,
            source_segment_id=body.source_segment_id,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    return ContextTranslateOut(
        chinese=str(data.get("chinese") or ""),
        from_cache=bool(data.get("from_cache")),
        quota=data.get("quota"),
    )
