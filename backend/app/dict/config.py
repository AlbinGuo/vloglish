import os

from ..env import load_app_env

load_app_env()

DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY", "").strip()
DEEPSEEK_BASE_URL = os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com").rstrip("/")
DEEPSEEK_MODEL = os.getenv("DEEPSEEK_MODEL", "deepseek-v4-flash")
LOOKUP_CACHE_TTL_DAYS = int(os.getenv("LOOKUP_CACHE_TTL_DAYS", "30"))
