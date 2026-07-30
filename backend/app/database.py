from pathlib import Path

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


def _engine_kwargs(url: str) -> dict:
    if url.startswith("sqlite"):
        return {"connect_args": {"check_same_thread": False}}
    # pool_pre_ping: detect dead connections on checkout
    # pool_recycle: avoid holding connections past common cloud idle timeouts
    return {"pool_pre_ping": True, "pool_recycle": 280}


engine = create_engine(DATABASE_URL, **_engine_kwargs(DATABASE_URL))
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def is_postgresql() -> bool:
    return engine.dialect.name == "postgresql"
