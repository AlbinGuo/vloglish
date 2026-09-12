import json
from datetime import date, datetime

from sqlalchemy import Boolean, Column, Date, DateTime, Float, ForeignKey, Integer, String, Table, Text, UniqueConstraint
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
    # 管理员指定：普通用户是否可播放该集（会员限制开启时生效）
    open_to_free_users: Mapped[bool] = mapped_column(Boolean, default=False, index=True)
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


class UserAuthorSubscription(Base):
    """用户关注作者：作者上新时站内通知。"""

    __tablename__ = "user_author_subscriptions"

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    author_id: Mapped[int] = mapped_column(ForeignKey("authors.id", ondelete="CASCADE"), primary_key=True, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    nickname: Mapped[str | None] = mapped_column(String(64), nullable=True)
    phone: Mapped[str | None] = mapped_column(String(32), nullable=True)
    wx_openid: Mapped[str | None] = mapped_column(String(64), unique=True, nullable=True, index=True)
    wx_unionid: Mapped[str | None] = mapped_column(String(64), nullable=True, index=True)
    # 默认头像编号，如 fox / owl；注册或首次登录写入
    avatar_key: Mapped[str | None] = mapped_column(String(32), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_member: Mapped[bool] = mapped_column(Boolean, default=False)
    is_staff: Mapped[bool] = mapped_column(Boolean, default=False)
    member_activated_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    # 到期时间；空且 is_member 表示永久。过期后按非会员处理。
    member_until: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    # 最近开通档：quarter | year | forever | custom
    member_plan: Mapped[str | None] = mapped_column(String(16), nullable=True)
    # 微信 jscode2session 的 session_key，虚拟支付用户态签名用
    wx_session_key: Mapped[str | None] = mapped_column(String(128), nullable=True)
    session_version: Mapped[int] = mapped_column(Integer, default=1)
    last_seen_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    # 最近一次心跳客户端：web | android | ios | weixin
    last_client: Mapped[str | None] = mapped_column(String(16), nullable=True)
    # 最近一次设备：ios | android | pc
    last_device: Mapped[str | None] = mapped_column(String(16), nullable=True)
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


class AccountBindToken(Base):
    """网页端生成、小程序扫码确认的微信绑定票据。"""

    __tablename__ = "account_bind_tokens"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    token: Mapped[str] = mapped_column(String(32), unique=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    consumed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class PcPaySession(Base):
    """网页选套餐后生成的扫码支付会话。"""

    __tablename__ = "pc_pay_sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    token: Mapped[str] = mapped_column(String(32), unique=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    plan: Mapped[str] = mapped_column(String(16))
    status: Mapped[str] = mapped_column(String(16), default="pending", index=True)
    order_no: Mapped[str] = mapped_column(String(64), default="", index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime, index=True)
    paid_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class UserDailyVisit(Base):
    """用户按自然日（东八区）的到访记录：有心跳/登录即记一天。"""

    __tablename__ = "user_daily_visits"
    __table_args__ = (UniqueConstraint("user_id", "visit_date", name="uq_user_daily_visit"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    visit_date: Mapped[date] = mapped_column(Date, index=True)
    first_seen_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    last_seen_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    hit_count: Mapped[int] = mapped_column(Integer, default=1)
    # 当日到访会话次数：距上次心跳超过 SESSION_GAP 再上线则 +1
    session_count: Mapped[int] = mapped_column(Integer, default=1)


class UserVisitSession(Base):
    """每次到访会话的开始时刻，用于按小时统计上站高峰。"""

    __tablename__ = "user_visit_sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    visit_date: Mapped[date] = mapped_column(Date, index=True)
    started_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)


class UserPageDwell(Base):
    """用户按自然日（东八区）× 页面的停留秒数聚合（来自心跳间隔）。"""

    __tablename__ = "user_page_dwells"
    __table_args__ = (
        UniqueConstraint("user_id", "visit_date", "page_key", name="uq_user_page_dwell"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    visit_date: Mapped[date] = mapped_column(Date, index=True)
    page_key: Mapped[str] = mapped_column(String(64), index=True)
    dwell_seconds: Mapped[int] = mapped_column(Integer, default=0)
    hit_count: Mapped[int] = mapped_column(Integer, default=0)
    last_seen_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


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


class WishRequest(Base):
    """需求墙：公开的功能建议。"""

    __tablename__ = "wish_requests"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    title: Mapped[str] = mapped_column(String(80))
    body: Mapped[str] = mapped_column(Text, default="")
    admin_reply: Mapped[str] = mapped_column(Text, default="")
    like_count: Mapped[int] = mapped_column(Integer, default=0)
    # pending / replied / done
    status: Mapped[str] = mapped_column(String(16), default="pending", index=True)
    hidden: Mapped[bool] = mapped_column(Boolean, default=False, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class WishRequestLike(Base):
    __tablename__ = "wish_request_likes"
    __table_args__ = (UniqueConstraint("user_id", "wish_id", name="uq_wish_request_like"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    wish_id: Mapped[int] = mapped_column(ForeignKey("wish_requests.id"), index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


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


class UserSubtitleClip(Base):
    """用户自选字幕摘录（与生词本独立，不绑定词条、不写回字幕 HTML）。"""

    __tablename__ = "user_subtitle_clips"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    episode_id: Mapped[int | None] = mapped_column(ForeignKey("episodes.id"), nullable=True, index=True)
    subtitle_id: Mapped[int | None] = mapped_column(ForeignKey("subtitles.id"), nullable=True, index=True)
    video_id: Mapped[str] = mapped_column(String(32), default="", index=True)
    text: Mapped[str] = mapped_column(Text, default="")
    note: Mapped[str] = mapped_column(Text, default="")
    context_english: Mapped[str] = mapped_column(Text, default="")
    context_chinese: Mapped[str] = mapped_column(Text, default="")
    episode_title: Mapped[str] = mapped_column(String(256), default="")
    original_text: Mapped[str] = mapped_column(Text, default="")
    examples_json: Mapped[str] = mapped_column(Text, default="[]")
    examples_for: Mapped[str] = mapped_column(Text, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


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
    # 用户投稿：链接 + 可选正文；默认仅投稿者可见，管理员可开全站
    submitted_by_user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True, index=True)
    is_catalog_public: Mapped[bool] = mapped_column(Boolean, default=False)
    rejection_reason: Mapped[str] = mapped_column(Text, default="")
    submit_body: Mapped[str] = mapped_column(Text, default="")
    remark: Mapped[str] = mapped_column(Text, default="")
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


class SiteSetting(Base):
    """站点级键值配置（如会员内容门槛总开关）。"""

    __tablename__ = "site_settings"

    key: Mapped[str] = mapped_column(String(64), primary_key=True)
    value: Mapped[str] = mapped_column(Text, default="")
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class WordPracticeSession(Base):
    """单词拼写练习：一局会话。"""

    __tablename__ = "word_practice_sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    source: Mapped[str] = mapped_column(String(32), default="vocab", index=True)  # vocab|episode_vocab|vocab_wrong
    mode: Mapped[str] = mapped_column(String(16), default="type")
    video_id: Mapped[str] = mapped_column(String(32), default="", index=True)
    total_count: Mapped[int] = mapped_column(Integer, default=0)
    correct_count: Mapped[int] = mapped_column(Integer, default=0)
    wrong_count: Mapped[int] = mapped_column(Integer, default=0)
    duration_ms: Mapped[int] = mapped_column(Integer, default=0)
    chars_typed: Mapped[int] = mapped_column(Integer, default=0)
    items_json: Mapped[str] = mapped_column(Text, default="[]")
    results_json: Mapped[str] = mapped_column(Text, default="[]")
    started_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    finished_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)


class WordPracticeWrong(Base):
    """拼写错词本。"""

    __tablename__ = "word_practice_wrongs"
    __table_args__ = (UniqueConstraint("user_id", "entry_id", name="uq_word_practice_wrong"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    entry_id: Mapped[int] = mapped_column(Integer, index=True)
    vocabulary_item_id: Mapped[int | None] = mapped_column(Integer, nullable=True)
    word: Mapped[str] = mapped_column(String(256), default="")
    wrong_count: Mapped[int] = mapped_column(Integer, default=1)
    last_wrong_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    resolved_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)


class WordPracticeStat(Base):
    """每用户每词拼写掌握度。"""

    __tablename__ = "word_practice_stats"
    __table_args__ = (UniqueConstraint("user_id", "entry_id", name="uq_word_practice_stat"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    entry_id: Mapped[int] = mapped_column(Integer, index=True)
    vocabulary_item_id: Mapped[int | None] = mapped_column(Integer, nullable=True)
    status: Mapped[str] = mapped_column(String(16), default="new")  # new|learning|review|known
    practice_count: Mapped[int] = mapped_column(Integer, default=0)
    correct_streak: Mapped[int] = mapped_column(Integer, default=0)
    wrong_count_total: Mapped[int] = mapped_column(Integer, default=0)
    last_practiced_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)


class ExampleTranslationCache(Base):
    """例句英→中翻译共享缓存：同一英文例句全站只调一次 AI。"""

    __tablename__ = "example_translation_cache"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    content_hash: Mapped[str] = mapped_column(String(40), unique=True, index=True)
    english: Mapped[str] = mapped_column(Text, default="")
    chinese: Mapped[str] = mapped_column(Text, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class UserClonedVoice(Base):
    """用户声音复刻：每用户一条 CosyVoice 音色 + 保留报名样本录音。"""

    __tablename__ = "user_cloned_voices"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), unique=True, index=True)
    voice: Mapped[str] = mapped_column(String(128), default="")
    tts_model: Mapped[str] = mapped_column(String(64), default="cosyvoice-v3-plus")
    preferred_name: Mapped[str] = mapped_column(String(16), default="")
    sample_text: Mapped[str] = mapped_column(Text, default="")
    language: Mapped[str] = mapped_column(String(8), default="en")
    fallback_mode: Mapped[bool] = mapped_column(Boolean, default=False)
    # 相对 DATA_DIR 的样本路径，如 voice_clone/12/sample.mp3
    sample_relpath: Mapped[str] = mapped_column(String(256), default="")
    sample_content_type: Mapped[str] = mapped_column(String(64), default="audio/mpeg")
    # 字幕朗读是否优先用复刻音色（跨端同步）
    prefer_playback: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class UserPracticeRecord(Base):
    """口语评测 / 单词打分 / 篇章评测练习记录（含可选录音）。"""

    __tablename__ = "user_practice_records"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    mode: Mapped[str] = mapped_column(String(16), default="sentence", index=True)  # word|sentence|passage
    engine: Mapped[str] = mapped_column(String(16), default="oral")  # oral|llm
    source_type: Mapped[str] = mapped_column(String(16), default="other")  # video|article|vocab|other
    video_id: Mapped[str] = mapped_column(String(32), default="", index=True)
    subtitle_id: Mapped[int | None] = mapped_column(Integer, nullable=True)
    article_id: Mapped[str] = mapped_column(String(32), default="", index=True)
    segment_id: Mapped[int | None] = mapped_column(Integer, nullable=True)
    title: Mapped[str] = mapped_column(String(256), default="")
    ref_text: Mapped[str] = mapped_column(Text, default="")
    transcript: Mapped[str] = mapped_column(Text, default="")
    score: Mapped[int] = mapped_column(Integer, default=0)
    level: Mapped[str] = mapped_column(String(32), default="")
    accuracy: Mapped[int | None] = mapped_column(Integer, nullable=True)
    fluency: Mapped[int | None] = mapped_column(Integer, nullable=True)
    rhythm: Mapped[int | None] = mapped_column(Integer, nullable=True)
    integrity: Mapped[int | None] = mapped_column(Integer, nullable=True)
    praise: Mapped[str] = mapped_column(Text, default="")
    issues_json: Mapped[str] = mapped_column(Text, default="[]")
    tips_json: Mapped[str] = mapped_column(Text, default="[]")
    words_json: Mapped[str] = mapped_column(Text, default="[]")
    result_json: Mapped[str] = mapped_column(Text, default="{}")
    audio_url: Mapped[str] = mapped_column(Text, default="")
    audio_source: Mapped[str] = mapped_column(String(16), default="")  # remote|upload|""
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)


class UserDailySentence(Base):
    """每日一句跟读：同一用户同一自然日（东八区）只分配一句。"""

    __tablename__ = "user_daily_sentences"
    __table_args__ = (UniqueConstraint("user_id", "day", name="uq_user_daily_sentence_day"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    day: Mapped[date] = mapped_column(Date, index=True)
    video_id: Mapped[str] = mapped_column(String(32), index=True)
    subtitle_id: Mapped[int] = mapped_column(Integer)
    english: Mapped[str] = mapped_column(Text, default="")
    chinese: Mapped[str] = mapped_column(Text, default="")
    cover: Mapped[str] = mapped_column(Text, default="")
    episode_title: Mapped[str] = mapped_column(String(256), default="")
    completed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class AiUsageEvent(Base):
    """AI / 外部语音能力调用计量（含缓存命中；供配额与运营看板）。"""

    __tablename__ = "ai_usage_events"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True, index=True)
    action: Mapped[str] = mapped_column(String(32), index=True)
    provider: Mapped[str] = mapped_column(String(32), default="")
    billed: Mapped[bool] = mapped_column(Boolean, default=True)
    cache_hit: Mapped[bool] = mapped_column(Boolean, default=False)
    counts_quota: Mapped[bool] = mapped_column(Boolean, default=False)
    usage_date: Mapped[date] = mapped_column(Date, index=True)
    meta_json: Mapped[str] = mapped_column(Text, default="{}")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)


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
    # 小程序虚拟支付：quarter | year | forever | test
    plan: Mapped[str] = mapped_column(String(16), default="forever")
    product_id: Mapped[str] = mapped_column(String(64), default="")
    wx_order_id: Mapped[str] = mapped_column(String(64), default="", index=True)
    # 付款端：web | android | ios | weixin | devtools | windows | mac
    pay_client: Mapped[str] = mapped_column(String(16), default="")
