import json
from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, Integer, String, Table, Text
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


class Episode(Base):
    __tablename__ = "episodes"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    index: Mapped[int] = mapped_column(Integer, default=0)
    video_id: Mapped[str] = mapped_column(String(32), unique=True, index=True)
    short_title: Mapped[str] = mapped_column(String(256))
    summary: Mapped[str] = mapped_column(Text, default="")
    remark: Mapped[str] = mapped_column(Text, default="")
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
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    is_demo: Mapped[bool] = mapped_column(Boolean, default=False)

    author: Mapped["Author"] = relationship()
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


class EpisodeFavorite(Base):
    __tablename__ = "episode_favorites"

    device_id: Mapped[str] = mapped_column(String(64), primary_key=True)
    episode_id: Mapped[int] = mapped_column(ForeignKey("episodes.id"), primary_key=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class DemoCode(Base):
    __tablename__ = "demo_codes"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    code: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    affiliate_code: Mapped[str | None] = mapped_column(String(64), nullable=True)
    active: Mapped[bool] = mapped_column(Boolean, default=True)

    episodes: Mapped[list["Episode"]] = relationship(secondary=demo_episodes)
