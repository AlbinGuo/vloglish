from datetime import datetime

from sqlalchemy.orm import Session

from ..models import Article, Author, Episode, User, UserNotification
from .author_subscribe import subscriber_user_ids
from .push import enqueue_push


def _episode_title(ep: Episode) -> str:
    return (ep.short_title or "").strip() or "未命名视频"


def _article_title(article: Article) -> str:
    return (article.title or "").strip() or "未命名文章"


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
    subscriber_ids = subscriber_user_ids(db, ep.author_id)
    author_name = ""
    if ep.author_id:
        author = getattr(ep, "author", None) or db.query(Author).filter(Author.id == ep.author_id).first()
        author_name = (author.name or "").strip() if author else ""
    title = "新视频上线"
    body = f"「{_episode_title(ep)}」已上线，快来学习吧。"
    if users:
        db.add_all(
            [
                UserNotification(
                    user_id=user.id,
                    type="author_new_episode" if user.id in subscriber_ids else "episode_new_release",
                    title=(
                        f"{author_name} 发布了新视频"
                        if user.id in subscriber_ids and author_name
                        else title
                    ),
                    body=body,
                    episode_id=ep.id,
                )
                for user in users
            ]
        )
    enqueue_push(
        db,
        title="新视频上线",
        body=f"「{_episode_title(ep)}」已上线，快来学习吧。",
        data={"type": "episode_new_release", "video_id": ep.video_id},
    )
    ep.release_notified_at = datetime.utcnow()
    return len(users)


def maybe_notify_catalog_release(db: Session, ep: Episode) -> int:
    """若视频刚进入公共目录且尚未推送过，则推送全站上线弹窗。"""
    return notify_catalog_episode_released(db, ep)


def is_catalog_published_article(article: Article) -> bool:
    """官方内容或已设为全站可见的投稿，且已发布。"""
    if article.status != "published":
        return False
    if article.submitted_by_user_id is None:
        return True
    return bool(getattr(article, "is_catalog_public", False))


def notify_catalog_article_released(db: Session, article: Article) -> int:
    """全站可见文章首次上线：给所有活跃用户写弹窗通知。返回触达人数。"""
    if getattr(article, "release_notified_at", None):
        return 0
    if not is_catalog_published_article(article):
        return 0

    users = db.query(User).filter(User.is_active.is_(True)).all()
    title = "新文章上线"
    body = f"「{_article_title(article)}」已上线，快来阅读吧。"
    if users:
        db.add_all(
            [
                UserNotification(
                    user_id=user.id,
                    type="article_new_release",
                    title=title,
                    body=body,
                    article_id=article.id,
                )
                for user in users
            ]
        )
    article.release_notified_at = datetime.utcnow()
    return len(users)


def maybe_notify_article_release(db: Session, article: Article) -> int:
    """若文章刚发布且尚未推送过，则推送全站上线弹窗。"""
    return notify_catalog_article_released(db, article)


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


def notify_staff_article_submitted(db: Session, article: Article, submitter: User) -> None:
    staff_rows = (
        db.query(User)
        .filter(User.is_staff.is_(True), User.is_active.is_(True))
        .all()
    )
    if not staff_rows:
        return
    nick = (submitter.nickname or "").strip()
    who = f"{nick}（{submitter.email}）" if nick else submitter.email
    body = f"{who} 提交了文章投稿，请尽快审核。"
    url = (article.source_url or "").strip()
    if url:
        body += f"\n链接：{url}"
    if (article.submit_body or "").strip():
        body += "\n含用户粘贴的英文正文。"
    for staff in staff_rows:
        db.add(
            UserNotification(
                user_id=staff.id,
                type="article_submitted",
                title="新文章投稿待审核",
                body=body,
                article_id=article.id,
            )
        )


def notify_article_published(db: Session, article: Article, user_id: int) -> None:
    db.add(
        UserNotification(
            user_id=user_id,
            type="article_published",
            title="文章投稿已通过审核",
            body=(
                f"您投稿的文章「{_article_title(article)}」已通过审核并发布，"
                "现在可在个人语料库中阅读（仅你可见）。"
            ),
            article_id=article.id,
        )
    )


def notify_article_rejected(db: Session, article: Article, user_id: int, reason: str) -> None:
    body = f"您投稿的文章「{_article_title(article)}」未通过审核。"
    if reason.strip():
        body += f"\n驳回原因：{reason.strip()}"
    db.add(
        UserNotification(
            user_id=user_id,
            type="article_rejected",
            title="文章投稿未通过审核",
            body=body,
            article_id=article.id,
        )
    )


def maybe_notify_article_submitter_on_status_change(
    db: Session,
    article: Article,
    *,
    old_status: str,
    new_status: str,
    rejection_reason: str | None,
) -> None:
    user_id = article.submitted_by_user_id
    if not user_id:
        return
    if old_status != "published" and new_status == "published":
        notify_article_published(db, article, user_id)
    elif old_status != "rejected" and new_status == "rejected":
        notify_article_rejected(db, article, user_id, rejection_reason or "")
