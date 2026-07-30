from sqlalchemy.orm import Session

from ..models import Episode, UserNotification


def _episode_title(ep: Episode) -> str:
    return (ep.short_title or "").strip() or "未命名视频"


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
