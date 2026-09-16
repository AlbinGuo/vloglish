from pathlib import Path
import os

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

from .env import load_app_env
from .db_url import resolve_database_url
BASE_DIR = Path(__file__).resolve().parent.parent
load_app_env()
DATA_DIR = BASE_DIR / "data"
DATA_DIR.mkdir(exist_ok=True)

DEFAULT_SQLITE_URL = f"sqlite:///{DATA_DIR / 'teco.db'}"
DATABASE_URL = resolve_database_url(DEFAULT_SQLITE_URL)


def _int_env(name: str, default: int) -> int:
    raw = (os.getenv(name) or "").strip()
    if raw.isdigit():
        return int(raw)
    return default


def _engine_kwargs(url: str) -> dict:
    if url.startswith("sqlite"):
        return {"connect_args": {"check_same_thread": False}}
    # pool_pre_ping: detect dead connections on checkout
    # pool_recycle: avoid holding connections past common cloud idle timeouts
    # 首页会并发打多个接口；默认 5+10 在连远程库时很容易被占满
    return {
        "pool_pre_ping": True,
        "pool_recycle": 280,
        "pool_size": _int_env("DB_POOL_SIZE", 15),
        "max_overflow": _int_env("DB_MAX_OVERFLOW", 30),
        "pool_timeout": _int_env("DB_POOL_TIMEOUT", 30),
        "pool_use_lifo": True,
        "connect_args": {"connect_timeout": 10},
    }


engine = create_engine(DATABASE_URL, **_engine_kwargs(DATABASE_URL))
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


def is_postgresql() -> bool:
    return engine.dialect.name == "postgresql"
