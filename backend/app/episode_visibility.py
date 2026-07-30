from sqlalchemy import or_

from .models import Episode, User


def catalog_visibility_filter():
    """公共目录可见：官方内容，或管理员已「转为全站可见」的用户投稿。"""
    return or_(
        Episode.submitted_by_user_id.is_(None),
        Episode.is_catalog_public.is_(True),
    )


def published_visibility_filter(user: User | None):
    """列表/目录查询用。不含「仅个人语料库」投稿，避免投稿者登录后在首页看到自己的私密投稿。"""
    # user 参数保留以兼容现有调用方；目录可见性不依赖当前登录用户。
    _ = user
    return catalog_visibility_filter()


def can_view_published_episode(episode: Episode, user: User | None) -> bool:
    """单集访问：公共内容所有人可看；未转全站的投稿仅投稿者可看。"""
    if episode.submitted_by_user_id is None:
        return True
    if bool(getattr(episode, "is_catalog_public", False)):
        return True
    return user is not None and user.id == episode.submitted_by_user_id
