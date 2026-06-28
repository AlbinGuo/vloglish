from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user
from ..demo_access import can_access_episode
from ..episode_visibility import published_visibility_filter
from ..models import Episode, User, UserEpisodeProgress, UserSubtitleProgress, UserVocabularyItem, UserWordLookup
from ..schemas import (
    EpisodeProgressOut,
    EpisodeProgressUpdateIn,
    LearningCalendarOut,
    LearningSessionOut,
    LearningSessionStartIn,
    LearningSummaryOut,
    RecentEpisodeOut,
    SubtitleProgressListOut,
    SubtitleProgressOut,
    SubtitleProgressUpdateIn,
    VocabularyItemOut,
    VocabularySaveIn,
    WordLookupListOut,
    WordLookupOut,
)
from ..services.learning import (
    _fmt_dt,
    dedupe_lookups_by_word,
    dedupe_vocabulary_by_word,
    end_learning_session,
    learned_episode_ids,
    learning_calendar,
    learning_summary,
    progress_map_for_episodes,
    progress_to_dict,
    recent_episodes,
    remove_vocabulary,
    save_vocabulary,
    start_learning_session,
    update_episode_progress,
)

router = APIRouter(prefix="/api/learning", tags=["learning"])

# 查词历史去重后再分页，单次最多扫描条数
_LOOKUP_DEDUPE_SCAN_LIMIT = 2000


def _get_episode(db: Session, video_id: str, user: User) -> Episode:
    ep = (
        db.query(Episode)
        .filter(Episode.video_id == video_id, Episode.status == "published")
        .filter(published_visibility_filter(user))
        .first()
    )
    if not ep:
        raise HTTPException(status_code=404, detail="剧集不存在")
    if not can_access_episode(db, ep, user):
        raise HTTPException(status_code=403, detail="无权访问该内容")
    return ep


def _episode_title_map(db: Session, episode_ids: set[int]) -> dict[int, str]:
    if not episode_ids:
        return {}
    rows = db.query(Episode.id, Episode.short_title).filter(Episode.id.in_(episode_ids)).all()
    return {r[0]: r[1] for r in rows}


@router.get("/progress/{video_id}/", response_model=EpisodeProgressOut)
def get_progress(
    video_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    episode = _get_episode(db, video_id, user)
    row = (
        db.query(UserEpisodeProgress)
        .filter(UserEpisodeProgress.user_id == user.id, UserEpisodeProgress.episode_id == episode.id)
        .first()
    )
    if not row:
        return EpisodeProgressOut(
            video_id=episode.video_id,
            last_subtitle_index=0,
            last_position_sec=0,
            max_reached_index=0,
            watch_time_sec=0,
            completion_percent=0,
            is_completed=False,
            last_watched_at="",
            completed_at=None,
        )
    return EpisodeProgressOut(**progress_to_dict(row, episode))


@router.put("/progress/{video_id}/", response_model=EpisodeProgressOut)
def put_progress(
    video_id: str,
    body: EpisodeProgressUpdateIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    episode = _get_episode(db, video_id, user)
    row = update_episode_progress(db, user, episode, body.model_dump())
    return EpisodeProgressOut(**progress_to_dict(row, episode))


@router.get("/summary/", response_model=LearningSummaryOut)
def get_summary(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return LearningSummaryOut(**learning_summary(db, user.id))


@router.get("/recent/", response_model=list[RecentEpisodeOut])
def get_recent(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return [RecentEpisodeOut(**row) for row in recent_episodes(db, user.id)]


@router.get("/calendar/", response_model=LearningCalendarOut)
def get_calendar(
    days: int = Query(90, ge=7, le=365),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return LearningCalendarOut(days=learning_calendar(db, user.id, days))


@router.post("/sessions/", response_model=LearningSessionOut)
def create_session(
    body: LearningSessionStartIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    episode = _get_episode(db, body.video_id, user)
    session = start_learning_session(db, user, episode, body.model_dump())
    return LearningSessionOut(id=session.id, video_id=episode.video_id, started_at=_fmt_dt(session.started_at))


@router.post("/sessions/{session_id}/end/")
def finish_session(
    session_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    end_learning_session(db, user.id, session_id)
    return {"success": True}


@router.get("/vocabulary/", response_model=list[VocabularyItemOut])
def list_vocabulary(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    rows = (
        db.query(UserVocabularyItem)
        .filter(UserVocabularyItem.user_id == user.id)
        .order_by(UserVocabularyItem.created_at.desc())
        .all()
    )
    rows = dedupe_vocabulary_by_word(rows)
    ep_ids = {r.source_episode_id for r in rows if r.source_episode_id}
    titles = _episode_title_map(db, ep_ids)
    return [
        VocabularyItemOut(
            id=r.id,
            entry_id=r.entry_id,
            word=r.word,
            token_type=r.token_type,
            source_video_id=r.source_video_id,
            source_episode_title=titles.get(r.source_episode_id or 0, ""),
            created_at=_fmt_dt(r.created_at),
        )
        for r in rows
    ]


@router.post("/vocabulary/", response_model=VocabularyItemOut)
def add_vocabulary(
    body: VocabularySaveIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    episode_id = body.episode_id
    if body.video_id and not episode_id:
        ep = db.query(Episode).filter(Episode.video_id == body.video_id).first()
        episode_id = ep.id if ep else None
    row = save_vocabulary(
        db,
        user,
        {
            "entry_id": body.entry_id,
            "word": body.word,
            "token_type": body.token_type,
            "episode_id": episode_id,
            "subtitle_id": body.subtitle_id,
            "video_id": body.video_id,
        },
    )
    title = ""
    if row.source_episode_id:
        ep = db.query(Episode).filter(Episode.id == row.source_episode_id).first()
        title = ep.short_title if ep else ""
    return VocabularyItemOut(
        id=row.id,
        entry_id=row.entry_id,
        word=row.word,
        token_type=row.token_type,
        source_video_id=row.source_video_id,
        source_episode_title=title,
        created_at=_fmt_dt(row.created_at),
    )


@router.delete("/vocabulary/{entry_id}/")
def delete_vocabulary(
    entry_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not remove_vocabulary(db, user.id, entry_id):
        raise HTTPException(status_code=404, detail="生词不存在")
    return {"success": True}


@router.get("/lookups/", response_model=WordLookupListOut)
def list_lookups(
    video_id: str | None = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(30, ge=1, le=100),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    q = db.query(UserWordLookup).filter(UserWordLookup.user_id == user.id)
    if video_id:
        q = q.filter(UserWordLookup.video_id == video_id)
    rows = (
        q.order_by(UserWordLookup.looked_up_at.desc())
        .limit(_LOOKUP_DEDUPE_SCAN_LIMIT)
        .all()
    )
    deduped = dedupe_lookups_by_word(rows)
    total = len(deduped)
    start = (page - 1) * page_size
    page_rows = deduped[start : start + page_size]
    ep_ids = {r.episode_id for r in page_rows if r.episode_id}
    titles = _episode_title_map(db, ep_ids)
    saved_ids = {
        v[0]
        for v in db.query(UserVocabularyItem.entry_id)
        .filter(UserVocabularyItem.user_id == user.id)
        .all()
    }
    return WordLookupListOut(
        count=total,
        results=[
            WordLookupOut(
                id=r.id,
                entry_id=r.entry_id,
                word=r.word,
                token_type=r.token_type,
                context=r.context,
                video_id=r.video_id,
                episode_title=titles.get(r.episode_id or 0, ""),
                is_saved=r.entry_id in saved_ids,
                looked_up_at=_fmt_dt(r.looked_up_at),
            )
            for r in page_rows
        ],
    )


@router.get("/subtitles/{video_id}/", response_model=SubtitleProgressListOut)
def list_subtitle_progress(
    video_id: str,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    episode = _get_episode(db, video_id, user)
    rows = (
        db.query(UserSubtitleProgress)
        .filter(UserSubtitleProgress.user_id == user.id, UserSubtitleProgress.episode_id == episode.id)
        .all()
    )
    return SubtitleProgressListOut(
        results=[
            SubtitleProgressOut(
                subtitle_id=r.subtitle_id,
                heard_count=r.heard_count,
                is_marked_learned=r.is_marked_learned,
                last_heard_at=_fmt_dt(r.last_heard_at),
            )
            for r in rows
        ]
    )


@router.patch("/subtitles/{subtitle_id}/", response_model=SubtitleProgressOut)
def patch_subtitle_progress(
    subtitle_id: int,
    body: SubtitleProgressUpdateIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    row = (
        db.query(UserSubtitleProgress)
        .filter(UserSubtitleProgress.user_id == user.id, UserSubtitleProgress.subtitle_id == subtitle_id)
        .first()
    )
    if not row:
        raise HTTPException(status_code=404, detail="字幕进度不存在")
    if body.is_marked_learned is not None:
        row.is_marked_learned = body.is_marked_learned
    row.last_heard_at = datetime.utcnow()
    db.commit()
    db.refresh(row)
    return SubtitleProgressOut(
        subtitle_id=row.subtitle_id,
        heard_count=row.heard_count,
        is_marked_learned=row.is_marked_learned,
        last_heard_at=_fmt_dt(row.last_heard_at),
    )
