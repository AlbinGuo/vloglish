"""Load backend environment."""
from __future__ import annotations

from pathlib import Path

from dotenv import load_dotenv

BACKEND_DIR = Path(__file__).resolve().parent.parent


def load_app_env() -> None:
    load_dotenv(BACKEND_DIR / ".env")
