import json
from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, Integer, String, Table, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .database import Base

episode_tags = Table(
    "episode_tags",
    Base.metadata,
    Column("episode_id", ForeignKey("episodes.id"), primary_key=True),
    Column("tag_id", ForeignKey("tags.id"), primary_key=True),
)

demo_episodes = Table(
    "demo_episodes",
    Base.metadata,
    Column("demo_code_id", ForeignKey("demo_codes.id"), primary_key=True),
    Column("episode_id", ForeignKey("episodes.id"), primary_key=True),
)


class Tag(Base):
    __tablename__ = "tags"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(64), unique=True)


class Author(Base):
    __tablename__ = "authors"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(128))
    gender: Mapped[str] = mapped_column(String(1), default="m")
    nationality: Mapped[str] = mapped_column(String(16), default="")
    accent: Mapped[str] = mapped_column(String(32), default="")


class EpisodeSeries(Base):
    """强顺序合集：一集最多属于一个合集。"""

    __tablename__ = "episode_series"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    slug: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    title: Mapped[str] = mapped_column(String(256))
    summary: Mapped[str] = mapped_column(Text, default="")
    cover: Mapped[str] = mapped_column(Text, default="")
    status: Mapped[str] = mapped_column(String(16), default="draft")
    sort_order: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    published_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    episodes: Mapped[list["Episode"]] = relationship(back_populates="series")


class Episode(Base):
    __tablename__ = "episodes"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    index: Mapped[int] = mapped_column(Integer, default=0)
    video_id: Mapped[str] = mapped_column(String(32), unique=True, index=True)
    short_title: Mapped[str] = mapped_column(String(256))
    summary: Mapped[str] = mapped_column(Text, default="")
    remark: Mapped[str] = mapped_column(Text, default="")
    vocab_summary: Mapped[str] = mapped_column(Text, default="")
    video_context: Mapped[str] = mapped_column(Text, default="")
    stars: Mapped[int] = mapped_column(Integer, default=3)
    voca_size: Mapped[int] = mapped_column(Integer, default=0)
    subtitle_count: Mapped[int] = mapped_column(Integer, default=0)
    clip_length: Mapped[float] = mapped_column(Float, default=0)
    cover: Mapped[str] = mapped_column(Text, default="")
    video_url: Mapped[str] = mapped_column(Text, default="")
    audio_url: Mapped[str] = mapped_column(Text, default="")
    thumbnail_url: Mapped[str] = mapped_column(Text, default="")
    original_video_url: Mapped[str] = mapped_column(Text, default="")
    author_id: Mapped[int] = mapped_column(ForeignKey("authors.id"))
    series_id: Mapped[int | None] = mapped_column(ForeignKey("episode_series.id"), nullable=True, index=True)
    series_index: Mapped[int | None] = mapped_column(Integer, nullable=True)
    submitted_by_user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    # 用户投稿默认 False（仅投稿者可见）；管理员「转为全站可见」后为 True（公共目录 + 仍留在我的语料库）
    is_catalog_public: Mapped[bool] = mapped_column(Boolean, default=False, index=True)
    rejection_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    is_demo: Mapped[bool] = mapped_column(Boolean, default=False)
    is_pinned: Mapped[bool] = mapped_column(Boolean, default=False, index=True)
    status: Mapped[str] = mapped_column(String(16), default="published")
    published_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    # 全站上线弹窗是否已推送过（首次进入公共目录时写入）
    release_notified_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)

    author: Mapped["Author"] = relationship()
    series: Mapped["EpisodeSeries | None"] = relationship(back_populates="episodes")
    tags: Mapped[list["Tag"]] = relationship(secondary=episode_tags)
    subtitles: Mapped[list["Subtitle"]] = relationship(back_populates="episode", cascade="all, delete-orphan")


class Subtitle(Base):
    __tablename__ = "subtitles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    episode_id: Mapped[int] = mapped_column(ForeignKey("episodes.id"), index=True)
    index: Mapped[int] = mapped_column(Integer)
    start: Mapped[float] = mapped_column(Float)
    end: Mapped[float] = mapped_column(Float)
    english: Mapped[str] = mapped_column(Text)
    chinese: Mapped[str] = mapped_column(Text, default="")
    ipa: Mapped[str] = mapped_column(Text, default="")
    english_html: Mapped[str] = mapped_column(Text, default="")

    episode: Mapped["Episode"] = relationship(back_populates="subtitles")


class Entry(Base):
    __tablename__ = "entries"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    headword: Mapped[str] = mapped_column(String(256))
    category: Mapped[str] = mapped_column(String(64), default="单词")
    forms: Mapped[str] = mapped_column(String(256), default="")
    exam_tags_json: Mapped[str] = mapped_column(Text, default="[]")
    data_json: Mapped[str] = mapped_column(Text, default="{}")

    @property
    def exam_tags(self) -> list:
        return json.loads(self.exam_tags_json or "[]")

    @property
    def detail(self) -> dict:
        return json.loads(self.data_json or "{}")


class TokenRef(Base):
    """Legacy: 字幕 token 映射（已由 LookupCache 替代）。"""

    __tablename__ = "token_refs"

    token_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    token_type: Mapped[int] = mapped_column(Integer, primary_key=True)
    entry_id: Mapped[int] = mapped_column(ForeignKey("entries.id"), index=True)


class LookupCache(Base):
    """DeepSeek 查词结果缓存。"""

    __tablename__ = "lookup_cache"

    cache_key: Mapped[str] = mapped_column(String(64), primary_key=True)
    word: Mapped[str] = mapped_column(String(512))
    token_type: Mapped[int] = mapped_column(Integer)
    context: Mapped[str] = mapped_column(Text, default="")
    entry_id: Mapped[int] = mapped_column(Integer, index=True)
    response_json: Mapped[str] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class EpisodeWordCardCache(Base):
    """整集词卡结果缓存（跨用户共享，避免重复调用 DeepSeek）。"""

    __tablename__ = "episode_word_card_cache"

    episode_id: Mapped[int] = mapped_column(ForeignKey("episodes.id"), primary_key=True)
    content_hash: Mapped[str] = mapped_column(String(64), default="")
    cards_json: Mapped[str] = mapped_column(Text, default="[]")
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class EpisodeFavorite(Base):
    __tablename__ = "episode_favorites"

    device_id: Mapped[str] = mapped_column(String(64), primary_key=True)
    episode_id: Mapped[int] = mapped_column(ForeignKey("episodes.id"), primary_key=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class UserEpisodeFavorite(Base):
    __tablename__ = "user_episode_favorites"

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), primary_key=True)
    episode_id: Mapped[int] = mapped_column(ForeignKey("episodes.id"), primary_key=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    nickname: Mapped[str | None] = mapped_column(String(64), nullable=True)
    phone: Mapped[str | None] = mapped_column(String(32), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_member: Mapped[bool] = mapped_column(Boolean, default=False)
    is_staff: Mapped[bool] = mapped_column(Boolean, default=False)
    member_activated_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    session_version: Mapped[int] = mapped_column(Integer, default=1)
    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    # 上次进入「我的语料库」的时间；用于首页「新」角标
    my_corpus_seen_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    signup_country: Mapped[str | None] = mapped_column(String(64), nullable=True)
    signup_region: Mapped[str | None] = mapped_column(String(64), nullable=True)
    signup_city: Mapped[str | None] = mapped_column(String(64), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class RefreshToken(Base):
    __tablename__ = "refresh_tokens"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    token_hash: Mapped[str] = mapped_column(String(255))
    device_id: Mapped[str] = mapped_column(String(64), default="", index=True)
    session_key: Mapped[str] = mapped_column(String(64), default="", index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class PasswordResetToken(Base):
    __tablename__ = "password_reset_tokens"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    token_hash: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class ActivationCode(Base):
    __tablename__ = "activation_codes"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    code: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    used_by_user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    used_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class DemoCode(Base):
    __tablename__ = "demo_codes"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    code: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    affiliate_code: Mapped[str | None] = mapped_column(String(64), nullable=True)
    active: Mapped[bool] = mapped_column(Boolean, default=True)

    episodes: Mapped[list["Episode"]] = relationship(secondary=demo_episodes)


class AdminBroadcast(Base):
    __tablename__ = "admin_broadcasts"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    title: Mapped[str] = mapped_column(String(256))
    body: Mapped[str] = mapped_column(Text, default="")
    image_url: Mapped[str] = mapped_column(Text, default="")
    created_by_user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    recipient_count: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class UserNotification(Base):
    __tablename__ = "user_notifications"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    type: Mapped[str] = mapped_column(String(32))
    title: Mapped[str] = mapped_column(String(256))
    body: Mapped[str] = mapped_column(Text, default="")
    image_url: Mapped[str] = mapped_column(Text, default="")
    episode_id: Mapped[int | None] = mapped_column(ForeignKey("episodes.id"), nullable=True)
    article_id: Mapped[int | None] = mapped_column(ForeignKey("articles.id"), nullable=True)
    broadcast_id: Mapped[int | None] = mapped_column(ForeignKey("admin_broadcasts.id"), nullable=True)
    is_read: Mapped[bool] = mapped_column(Boolean, default=False)
    popup_acked_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class UserFeedback(Base):
    """用户意见反馈。"""

    __tablename__ = "user_feedbacks"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    title: Mapped[str] = mapped_column(String(120))
    body: Mapped[str] = mapped_column(Text, default="")
    image_urls_json: Mapped[str] = mapped_column(Text, default="[]")
    # pending / reviewing / done / closed
    status: Mapped[str] = mapped_column(String(16), default="pending", index=True)
    admin_note: Mapped[str] = mapped_column(Text, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    @property
    def image_urls(self) -> list[str]:
        try:
            raw = json.loads(self.image_urls_json or "[]")
        except json.JSONDecodeError:
            return []
        if not isinstance(raw, list):
            return []
        return [str(u).strip() for u in raw if str(u).strip()]


class UserEpisodeProgress(Base):
    __tablename__ = "user_episode_progress"
    __table_args__ = (UniqueConstraint("user_id", "episode_id", name="uq_user_episode_progress"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    episode_id: Mapped[int] = mapped_column(ForeignKey("episodes.id"), index=True)
    last_subtitle_index: Mapped[int] = mapped_column(Integer, default=0)
    last_position_sec: Mapped[float] = mapped_column(Float, default=0)
    max_reached_index: Mapped[int] = mapped_column(Integer, default=0)
    watch_time_sec: Mapped[int] = mapped_column(Integer, default=0)
    completion_percent: Mapped[float] = mapped_column(Float, default=0)
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False)
    first_opened_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    last_watched_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)


class UserSubtitleProgress(Base):
    __tablename__ = "user_subtitle_progress"
    __table_args__ = (UniqueConstraint("user_id", "subtitle_id", name="uq_user_subtitle_progress"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    episode_id: Mapped[int] = mapped_column(ForeignKey("episodes.id"), index=True)
    subtitle_id: Mapped[int] = mapped_column(ForeignKey("subtitles.id"), index=True)
    heard_count: Mapped[int] = mapped_column(Integer, default=0)
    is_marked_learned: Mapped[bool] = mapped_column(Boolean, default=False)
    last_heard_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class UserWordLookup(Base):
    __tablename__ = "user_word_lookups"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    entry_id: Mapped[int] = mapped_column(Integer, index=True)
    word: Mapped[str] = mapped_column(String(256))
    token_type: Mapped[int] = mapped_column(Integer, default=1)
    context: Mapped[str] = mapped_column(Text, default="")
    episode_id: Mapped[int | None] = mapped_column(ForeignKey("episodes.id"), nullable=True)
    subtitle_id: Mapped[int | None] = mapped_column(ForeignKey("subtitles.id"), nullable=True)
    article_id: Mapped[int | None] = mapped_column(ForeignKey("articles.id"), nullable=True)
    segment_id: Mapped[int | None] = mapped_column(ForeignKey("article_segments.id"), nullable=True)
    video_id: Mapped[str] = mapped_column(String(32), default="")
    looked_up_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class UserVocabularyItem(Base):
    __tablename__ = "user_vocabulary_items"
    __table_args__ = (UniqueConstraint("user_id", "entry_id", name="uq_user_vocabulary_entry"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    entry_id: Mapped[int] = mapped_column(Integer, index=True)
    word: Mapped[str] = mapped_column(String(256))
    token_type: Mapped[int] = mapped_column(Integer, default=1)
    source_episode_id: Mapped[int | None] = mapped_column(ForeignKey("episodes.id"), nullable=True)
    source_subtitle_id: Mapped[int | None] = mapped_column(ForeignKey("subtitles.id"), nullable=True)
    source_article_id: Mapped[int | None] = mapped_column(ForeignKey("articles.id"), nullable=True)
    source_segment_id: Mapped[int | None] = mapped_column(ForeignKey("article_segments.id"), nullable=True)
    source_type: Mapped[str] = mapped_column(String(16), default="video")
    source_video_id: Mapped[str] = mapped_column(String(32), default="")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class LearningSession(Base):
    __tablename__ = "learning_sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    episode_id: Mapped[int] = mapped_column(ForeignKey("episodes.id"), index=True)
    video_id: Mapped[str] = mapped_column(String(32), default="")
    started_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    ended_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    watch_time_sec: Mapped[int] = mapped_column(Integer, default=0)
    playback_rate_avg: Mapped[float] = mapped_column(Float, default=1.0)
    sentences_replayed: Mapped[int] = mapped_column(Integer, default=0)
    lookups_count: Mapped[int] = mapped_column(Integer, default=0)
    subtitle_mode: Mapped[str] = mapped_column(String(16), default="both")
    loop_mode: Mapped[str] = mapped_column(String(16), default="off")


class Article(Base):
    __tablename__ = "articles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    article_id: Mapped[str] = mapped_column(String(32), unique=True, index=True)
    title: Mapped[str] = mapped_column(String(512))
    summary: Mapped[str] = mapped_column(Text, default="")
    source: Mapped[str] = mapped_column(String(64), default="")
    source_url: Mapped[str] = mapped_column(Text, default="")
    topic: Mapped[str] = mapped_column(String(64), default="")
    cover: Mapped[str] = mapped_column(Text, default="")
    stars: Mapped[int] = mapped_column(Integer, default=3)
    word_count: Mapped[int] = mapped_column(Integer, default=0)
    segment_count: Mapped[int] = mapped_column(Integer, default=0)
    status: Mapped[str] = mapped_column(String(16), default="draft")
    is_free_preview: Mapped[bool] = mapped_column(Boolean, default=False)
    tts_status: Mapped[str] = mapped_column(String(16), default="none")
    vocab_summary: Mapped[str] = mapped_column(Text, default="")
    published_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    release_notified_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    segments: Mapped[list["ArticleSegment"]] = relationship(
        back_populates="article",
        cascade="all, delete-orphan",
        order_by="ArticleSegment.index",
    )


class ArticleSegment(Base):
    __tablename__ = "article_segments"
    __table_args__ = (UniqueConstraint("article_id", "index", name="uq_article_segment_index"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    article_id: Mapped[int] = mapped_column(ForeignKey("articles.id"), index=True)
    index: Mapped[int] = mapped_column(Integer)
    english: Mapped[str] = mapped_column(Text)
    chinese: Mapped[str] = mapped_column(Text, default="")
    english_html: Mapped[str] = mapped_column(Text, default="")
    audio_url: Mapped[str] = mapped_column(Text, default="")
    duration_ms: Mapped[int] = mapped_column(Integer, default=0)

    article: Mapped["Article"] = relationship(back_populates="segments")


class UserArticleProgress(Base):
    __tablename__ = "user_article_progress"
    __table_args__ = (UniqueConstraint("user_id", "article_id", name="uq_user_article_progress"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    article_id: Mapped[int] = mapped_column(ForeignKey("articles.id"), index=True)
    last_segment_index: Mapped[int] = mapped_column(Integer, default=0)
    max_reached_index: Mapped[int] = mapped_column(Integer, default=0)
    read_time_sec: Mapped[int] = mapped_column(Integer, default=0)
    completion_percent: Mapped[float] = mapped_column(Float, default=0)
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False)
    first_opened_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    last_read_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)


class UserArticleFavorite(Base):
    __tablename__ = "user_article_favorites"
    __table_args__ = (UniqueConstraint("user_id", "article_id", name="uq_user_article_favorite"),)

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), primary_key=True)
    article_id: Mapped[int] = mapped_column(ForeignKey("articles.id"), primary_key=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class UserArticleOpen(Base):
    __tablename__ = "user_article_opens"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True, index=True)
    device_id: Mapped[str] = mapped_column(String(64), default="", index=True)
    article_id: Mapped[int] = mapped_column(ForeignKey("articles.id"), index=True)
    opened_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class MembershipOrder(Base):
    """站内自助购买永久会员订单（支付宝）。"""

    __tablename__ = "membership_orders"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    order_no: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True, index=True)
    email: Mapped[str] = mapped_column(String(255), index=True)
    amount_cent: Mapped[int] = mapped_column(Integer)
    currency: Mapped[str] = mapped_column(String(8), default="CNY")
    status: Mapped[str] = mapped_column(String(16), default="pending", index=True)
    channel: Mapped[str] = mapped_column(String(16), default="alipay")
    alipay_trade_no: Mapped[str] = mapped_column(String(64), default="")
    activation_code_id: Mapped[int | None] = mapped_column(
        ForeignKey("activation_codes.id"), nullable=True
    )
    paid_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    notify_raw: Mapped[str] = mapped_column(Text, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
