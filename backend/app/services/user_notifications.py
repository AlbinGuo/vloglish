from datetime import datetime

from sqlalchemy.orm import Session

from ..models import Episode, User, UserNotification


def _episode_title(ep: Episode) -> str:
    return (ep.short_title or "").strip() or "未命名视频"


def is_catalog_published_episode(ep: Episode) -> bool:
    """官方内容或已设为全站可见的投稿，且已发布。"""
    if ep.status != "published":
        return False
    if ep.submitted_by_user_id is None:
        return True
    return bool(getattr(ep, "is_catalog_public", False))


def notify_catalog_episode_released(db: Session, ep: Episode) -> int:
    """全站可见视频首次上线：给所有活跃用户写弹窗通知。返回触达人数。"""
    if getattr(ep, "release_notified_at", None):
        return 0
    if not is_catalog_published_episode(ep):
        return 0

    users = db.query(User).filter(User.is_active.is_(True)).all()
    title = "新视频上线"
    body = f"「{_episode_title(ep)}」已上线，快来学习吧。"
    if users:
        db.add_all(
            [
                UserNotification(
                    user_id=user.id,
                    type="episode_new_release",
                    title=title,
                    body=body,
                    episode_id=ep.id,
                )
                for user in users
            ]
        )
    ep.release_notified_at = datetime.utcnow()
    return len(users)


def maybe_notify_catalog_release(db: Session, ep: Episode) -> int:
    """若视频刚进入公共目录且尚未推送过，则推送全站上线弹窗。"""
    return notify_catalog_episode_released(db, ep)


def notify_staff_episode_submitted(db: Session, ep: Episode, submitter: User) -> None:
    """用户投稿后通知所有管理员（待弹窗 + 通知中心）。"""
    staff_rows = (
        db.query(User)
        .filter(User.is_staff.is_(True), User.is_active.is_(True))
        .all()
    )
    if not staff_rows:
        return
    nick = (submitter.nickname or "").strip()
    who = f"{nick}（{submitter.email}）" if nick else submitter.email
    url = (ep.original_video_url or "").strip()
    body = f"{who} 提交了视频链接，请尽快审核。"
    if url:
        body += f"\n链接：{url}"
    for staff in staff_rows:
        db.add(
            UserNotification(
                user_id=staff.id,
                type="episode_submitted",
                title="新用户投稿待审核",
                body=body,
                episode_id=ep.id,
            )
        )


def notify_episode_published(db: Session, ep: Episode, user_id: int) -> None:
    db.add(
        UserNotification(
            user_id=user_id,
            type="episode_published",
            title="投稿已通过审核",
            body=f"您投稿的视频「{_episode_title(ep)}」已通过审核并发布，现在可在个人语料库中观看（仅你可见）。",
            episode_id=ep.id,
        )
    )


def notify_episode_rejected(db: Session, ep: Episode, user_id: int, reason: str) -> None:
    body = f"您投稿的视频「{_episode_title(ep)}」未通过审核。"
    if reason.strip():
        body += f"\n驳回原因：{reason.strip()}"
    db.add(
        UserNotification(
            user_id=user_id,
            type="episode_rejected",
            title="投稿未通过审核",
            body=body,
            episode_id=ep.id,
        )
    )


def maybe_notify_submitter_on_status_change(
    db: Session,
    ep: Episode,
    *,
    old_status: str,
    new_status: str,
    rejection_reason: str | None,
) -> None:
    user_id = ep.submitted_by_user_id
    if not user_id:
        return
    if old_status != "published" and new_status == "published":
        notify_episode_published(db, ep, user_id)
    elif old_status != "rejected" and new_status == "rejected":
        notify_episode_rejected(db, ep, user_id, rejection_reason or "")
