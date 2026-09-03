"""把微信影子账号合并进邮箱主账号。"""

from __future__ import annotations

from datetime import datetime

from sqlalchemy.orm import Session

from ..demo_access import user_is_member
from ..models import (
    ActivationCode,
    AiUsageEvent,
    Article,
    Episode,
    LearningSession,
    MembershipOrder,
    PasswordResetToken,
    RefreshToken,
    User,
    UserArticleFavorite,
    UserArticleOpen,
    UserArticleProgress,
    UserAuthorSubscription,
    UserClonedVoice,
    UserDailyVisit,
    UserEpisodeFavorite,
    UserEpisodeProgress,
    UserFeedback,
    UserNotification,
    UserPageDwell,
    UserPracticeRecord,
    UserSubtitleProgress,
    UserVocabularyItem,
    UserVisitSession,
    UserWordLookup,
    WishRequest,
    WishRequestLike,
    WordPracticeSession,
    WordPracticeStat,
    WordPracticeWrong,
)

WECHAT_EMAIL_SUFFIX = "@weixin.vloglish.invalid"


def is_wechat_only(user: User) -> bool:
    email = (user.email or "").strip().lower()
    return email.endswith(WECHAT_EMAIL_SUFFIX)


def merge_membership(target: User, source: User) -> None:
    src_member = user_is_member(source)
    dst_member = user_is_member(target)
    if not src_member and not dst_member:
        return
    target.is_member = True
    if source.member_activated_at and (
        target.member_activated_at is None or source.member_activated_at < target.member_activated_at
    ):
        target.member_activated_at = source.member_activated_at
    src_forever = src_member and source.member_until is None and source.is_member
    dst_forever = dst_member and target.member_until is None and target.is_member
    if src_forever or dst_forever:
        target.member_until = None
        return
    untils = [t for t in (source.member_until, target.member_until) if t]
    target.member_until = max(untils) if untils else None


def _move_wx_identity(target: User, source: User) -> None:
    if source.wx_openid:
        if target.wx_openid and target.wx_openid != source.wx_openid:
            raise ValueError("该网页账号已绑定其他微信")
        target.wx_openid = source.wx_openid
        source.wx_openid = None
    if source.wx_unionid and not target.wx_unionid:
        target.wx_unionid = source.wx_unionid
    if source.wx_session_key:
        target.wx_session_key = source.wx_session_key
        source.wx_session_key = None
    if source.nickname and not target.nickname:
        target.nickname = source.nickname


def _reassign(db: Session, model, src: int, dst: int) -> None:
    db.query(model).filter(model.user_id == src).update({model.user_id: dst}, synchronize_session=False)


def _take_if_free(db: Session, model, src: int, dst: int, key: str) -> None:
    src_rows = db.query(model).filter(model.user_id == src).all()
    taken = {getattr(r, key) for r in db.query(model).filter(model.user_id == dst).all()}
    for row in src_rows:
        k = getattr(row, key)
        if k in taken:
            db.delete(row)
        else:
            row.user_id = dst
            taken.add(k)


def merge_users(db: Session, *, source: User, target: User) -> User:
    """把 source（通常是微信影子号）并入 target（邮箱主账号）。调用方负责 commit。"""
    if source.id == target.id:
        return target
    if not target.is_active:
        raise ValueError("主账号已停用")

    merge_membership(target, source)
    if source.is_staff:
        target.is_staff = True
    _move_wx_identity(target, source)

    sid, tid = source.id, target.id

    _take_if_free(db, UserEpisodeFavorite, sid, tid, "episode_id")
    _take_if_free(db, UserAuthorSubscription, sid, tid, "author_id")
    _take_if_free(db, UserArticleFavorite, sid, tid, "article_id")
    _take_if_free(db, WishRequestLike, sid, tid, "wish_id")
    _take_if_free(db, UserVocabularyItem, sid, tid, "entry_id")
    _take_if_free(db, UserSubtitleProgress, sid, tid, "subtitle_id")

    for row in db.query(UserEpisodeProgress).filter(UserEpisodeProgress.user_id == sid).all():
        dest = (
            db.query(UserEpisodeProgress)
            .filter(UserEpisodeProgress.user_id == tid, UserEpisodeProgress.episode_id == row.episode_id)
            .first()
        )
        if dest:
            dest.watch_time_sec = max(dest.watch_time_sec or 0, row.watch_time_sec or 0)
            dest.max_reached_index = max(dest.max_reached_index or 0, row.max_reached_index or 0)
            dest.last_subtitle_index = max(dest.last_subtitle_index or 0, row.last_subtitle_index or 0)
            dest.completion_percent = max(dest.completion_percent or 0, row.completion_percent or 0)
            dest.is_completed = dest.is_completed or row.is_completed
            if row.last_watched_at and (not dest.last_watched_at or row.last_watched_at > dest.last_watched_at):
                dest.last_watched_at = row.last_watched_at
            db.delete(row)
        else:
            row.user_id = tid

    for row in db.query(UserArticleProgress).filter(UserArticleProgress.user_id == sid).all():
        dest = (
            db.query(UserArticleProgress)
            .filter(UserArticleProgress.user_id == tid, UserArticleProgress.article_id == row.article_id)
            .first()
        )
        if dest:
            dest.read_time_sec = max(dest.read_time_sec or 0, row.read_time_sec or 0)
            dest.max_reached_index = max(dest.max_reached_index or 0, row.max_reached_index or 0)
            dest.completion_percent = max(dest.completion_percent or 0, row.completion_percent or 0)
            dest.is_completed = dest.is_completed or row.is_completed
            if row.last_read_at and (not dest.last_read_at or row.last_read_at > dest.last_read_at):
                dest.last_read_at = row.last_read_at
            db.delete(row)
        else:
            row.user_id = tid

    for row in db.query(UserDailyVisit).filter(UserDailyVisit.user_id == sid).all():
        dest = (
            db.query(UserDailyVisit)
            .filter(UserDailyVisit.user_id == tid, UserDailyVisit.visit_date == row.visit_date)
            .first()
        )
        if dest:
            dest.hit_count = (dest.hit_count or 0) + (row.hit_count or 0)
            dest.session_count = (dest.session_count or 0) + (row.session_count or 0)
            db.delete(row)
        else:
            row.user_id = tid

    for row in db.query(UserPageDwell).filter(UserPageDwell.user_id == sid).all():
        dest = (
            db.query(UserPageDwell)
            .filter(
                UserPageDwell.user_id == tid,
                UserPageDwell.visit_date == row.visit_date,
                UserPageDwell.page_key == row.page_key,
            )
            .first()
        )
        if dest:
            dest.dwell_seconds = (dest.dwell_seconds or 0) + (row.dwell_seconds or 0)
            dest.hit_count = (dest.hit_count or 0) + (row.hit_count or 0)
            db.delete(row)
        else:
            row.user_id = tid

    for row in db.query(WordPracticeWrong).filter(WordPracticeWrong.user_id == sid).all():
        dest = (
            db.query(WordPracticeWrong)
            .filter(WordPracticeWrong.user_id == tid, WordPracticeWrong.entry_id == row.entry_id)
            .first()
        )
        if dest:
            dest.wrong_count = (dest.wrong_count or 0) + (row.wrong_count or 0)
            db.delete(row)
        else:
            row.user_id = tid

    for row in db.query(WordPracticeStat).filter(WordPracticeStat.user_id == sid).all():
        dest = (
            db.query(WordPracticeStat)
            .filter(WordPracticeStat.user_id == tid, WordPracticeStat.entry_id == row.entry_id)
            .first()
        )
        if dest:
            dest.practice_count = (dest.practice_count or 0) + (row.practice_count or 0)
            dest.wrong_count_total = (dest.wrong_count_total or 0) + (row.wrong_count_total or 0)
            db.delete(row)
        else:
            row.user_id = tid

    src_voice = db.query(UserClonedVoice).filter(UserClonedVoice.user_id == sid).first()
    dst_voice = db.query(UserClonedVoice).filter(UserClonedVoice.user_id == tid).first()
    if src_voice:
        if dst_voice:
            db.delete(src_voice)
        else:
            src_voice.user_id = tid

    _reassign(db, UserNotification, sid, tid)
    _reassign(db, UserFeedback, sid, tid)
    _reassign(db, WishRequest, sid, tid)
    _reassign(db, LearningSession, sid, tid)
    _reassign(db, UserWordLookup, sid, tid)
    _reassign(db, UserVisitSession, sid, tid)
    _reassign(db, UserPracticeRecord, sid, tid)
    _reassign(db, WordPracticeSession, sid, tid)
    _reassign(db, MembershipOrder, sid, tid)
    _reassign(db, PasswordResetToken, sid, tid)
    db.query(AiUsageEvent).filter(AiUsageEvent.user_id == sid).update(
        {AiUsageEvent.user_id: tid}, synchronize_session=False
    )
    db.query(UserArticleOpen).filter(UserArticleOpen.user_id == sid).update(
        {UserArticleOpen.user_id: tid}, synchronize_session=False
    )
    db.query(Episode).filter(Episode.submitted_by_user_id == sid).update(
        {Episode.submitted_by_user_id: tid}, synchronize_session=False
    )
    db.query(Article).filter(Article.submitted_by_user_id == sid).update(
        {Article.submitted_by_user_id: tid}, synchronize_session=False
    )
    db.query(ActivationCode).filter(ActivationCode.used_by_user_id == sid).update(
        {ActivationCode.used_by_user_id: tid}, synchronize_session=False
    )
    db.query(RefreshToken).filter(RefreshToken.user_id == sid).delete(synchronize_session=False)

    source.is_active = False
    source.session_version = (source.session_version or 1) + 1
    source.wx_unionid = None
    source.updated_at = datetime.utcnow()
    return target
