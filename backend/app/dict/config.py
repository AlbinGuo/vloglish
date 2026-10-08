import os

from ..env import load_app_env

load_app_env()

DEEPSEEK_API_KEY = os.getenv("DEEPSEEK_API_KEY", "").strip()
DEEPSEEK_BASE_URL = os.getenv("DEEPSEEK_BASE_URL", "https://api.deepseek.com").rstrip("/")
DEEPSEEK_MODEL = os.getenv("DEEPSEEK_MODEL", "deepseek-v4-flash")
LOOKUP_CACHE_TTL_DAYS = int(os.getenv("LOOKUP_CACHE_TTL_DAYS", "30"))

# 字幕意译/直译/专名：B 站 Index-Translate 免费公网 API（OpenAI 兼容，可不填 key）
INDEX_TRANSLATE_BASE_URL = os.getenv(
    "INDEX_TRANSLATE_BASE_URL", "https://index-translate.bilibili.com/v1"
).rstrip("/")
INDEX_TRANSLATE_MODEL = os.getenv("INDEX_TRANSLATE_MODEL", "Index-Translate-35B-A3B")
INDEX_TRANSLATE_API_KEY = os.getenv("INDEX_TRANSLATE_API_KEY", "").strip()
INDEX_TRANSLATE_PROXY = os.getenv("INDEX_TRANSLATE_PROXY", "").strip()
