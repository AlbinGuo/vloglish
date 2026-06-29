from sqlalchemy import or_

from .models import Episode, User


def published_visibility_filter(user: User | None):
    """已发布剧集中，用户投稿仅对投稿者本人可见。"""
    if user is None:
        return Episode.submitted_by_user_id.is_(None)
    return or_(
        Episode.submitted_by_user_id.is_(None),
        Episode.submitted_by_user_id == user.id,
    )


def can_view_published_episode(episode: Episode, user: User | None) -> bool:
    if episode.submitted_by_user_id is None:
        return True
    return user is not None and user.id == episode.submitted_by_user_id
