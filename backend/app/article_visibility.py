from sqlalchemy import or_

from .models import Article, User


def catalog_visibility_filter():
    """公共读报目录：官方文章，或管理员已「转为全站可见」的用户投稿。"""
    return or_(
        Article.submitted_by_user_id.is_(None),
        Article.is_catalog_public.is_(True),
    )


def can_view_published_article(article: Article, user: User | None) -> bool:
    """已发布文章：公共内容所有人可看；未转全站的投稿仅投稿者可看。"""
    if article.status != "published":
        return False
    if article.submitted_by_user_id is None:
        return True
    if bool(getattr(article, "is_catalog_public", False)):
        return True
    return user is not None and user.id == article.submitted_by_user_id


def is_catalog_published_article(article: Article) -> bool:
    if article.status != "published":
        return False
    if article.submitted_by_user_id is None:
        return True
    return bool(getattr(article, "is_catalog_public", False))
