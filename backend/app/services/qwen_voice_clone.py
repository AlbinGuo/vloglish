"""阿里云百炼 Qwen-TTS 声音复刻（enrollment）与 VC 合成。

与识图用的 compatible-mode 无关；TTS / 复刻必须走 /api/v1。
"""

from __future__ import annotations

import base64
import json
import os
import re
import urllib.error
import urllib.request

from .qwen_dashscope_tts import qwen_tts_configured
from .tts_common import ensure_mp3_bytes, normalize_tts_text

VOICE_CLONE_TTS_MODEL = "qwen3-tts-vc-2026-01-22"
VOICE_ENROLLMENT_MODEL = "qwen-voice-enrollment"

_PREFERRED_NAME_RE = re.compile(r"^[A-Za-z0-9_]{1,16}$")
_ALLOWED_LANG = frozenset({"zh", "en", "de", "it", "pt", "es", "ja", "ko", "fr", "ru"})


def voice_clone_configured() -> bool:
    return qwen_tts_configured()


def _api_key() -> str:
    return os.getenv("DASHSCOPE_API_KEY", "").strip()


def _tts_api_base() -> str:
    """复刻/合成 base：禁止误用 compatible-mode。"""
    custom = os.getenv("DASHSCOPE_TTS_BASE_URL", "").strip()
    base = custom or os.getenv("DASHSCOPE_BASE_URL", "https://dashscope.aliyuncs.com/api/v1").strip()
    base = base.rstrip("/")
    if "compatible-mode" in base.lower():
        return "https://dashscope.aliyuncs.com/api/v1"
    if not base:
        return "https://dashscope.aliyuncs.com/api/v1"
    return base


def _customization_url() -> str:
    return f"{_tts_api_base()}/services/audio/tts/customization"


def _generation_url() -> str:
    custom = os.getenv("DASHSCOPE_TTS_URL", "").strip()
    if custom and "compatible-mode" not in custom.lower():
        return custom
    return f"{_tts_api_base()}/services/aigc/multimodal-generation/generation"


def sanitize_preferred_name(name: str, *, fallback: str = "vloglish") -> str:
    cleaned = re.sub(r"[^A-Za-z0-9_]", "", (name or "").strip())[:16]
    if _PREFERRED_NAME_RE.fullmatch(cleaned):
        return cleaned
    fb = re.sub(r"[^A-Za-z0-9_]", "", fallback)[:16] or "vloglish"
    return fb


def normalize_clone_language(language: str | None) -> str:
    lang = (language or "en").strip().lower()
    if lang in ("yue", "cantonese"):
        return "zh"
    if lang in _ALLOWED_LANG:
        return lang
    return "en"


def _post_json(url: str, payload: dict, *, timeout: int = 180) -> dict:
    if not voice_clone_configured():
        raise RuntimeError("未配置有效的 DASHSCOPE_API_KEY")
    req = urllib.request.Request(
        url,
        data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
        method="POST",
        headers={
            "Authorization": f"Bearer {_api_key()}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        raw = exc.read().decode("utf-8", errors="replace")
        try:
            detail = json.loads(raw)
            message = detail.get("message") or raw[:500]
        except json.JSONDecodeError:
            message = raw[:500]
        if exc.code == 401:
            raise RuntimeError("DashScope API Key 无效或已失效") from exc
        raise RuntimeError(f"DashScope 请求失败 ({exc.code}): {message}") from exc


def _raise_if_error(body: dict) -> None:
    status = body.get("status_code")
    if status is not None and int(status) != 200:
        raise RuntimeError(body.get("message") or f"DashScope 失败 (HTTP {status})")
    if body.get("code"):
        raise RuntimeError(body.get("message") or f"DashScope 错误: {body.get('code')}")


def audio_bytes_to_data_uri(data: bytes, content_type: str) -> str:
    ctype = (content_type or "audio/mpeg").split(";")[0].strip().lower()
    if ctype in ("audio/m4a", "audio/x-m4a", "audio/aac"):
        ctype = "audio/mp4"
    if ctype not in ("audio/wav", "audio/mpeg", "audio/mp4", "audio/mp3"):
        # webm 等需先在业务层转成 mp3/wav
        ctype = "audio/mpeg"
    if ctype == "audio/mp3":
        ctype = "audio/mpeg"
    b64 = base64.b64encode(data).decode("ascii")
    return f"data:{ctype};base64,{b64}"


def create_cloned_voice(
    *,
    audio_data: bytes,
    content_type: str,
    text: str,
    language: str = "en",
    preferred_name: str = "vloglish",
) -> dict:
    """调用 enrollment create，返回 {voice, target_model, fallback_mode}。"""
    if not audio_data:
        raise RuntimeError("录音为空")
    if len(audio_data) > 10 * 1024 * 1024:
        raise RuntimeError("录音超过 10MB")

    cleaned_text = normalize_tts_text(text)
    lang = normalize_clone_language(language)
    name = sanitize_preferred_name(preferred_name)
    data_uri = audio_bytes_to_data_uri(audio_data, content_type)

    payload = {
        "model": VOICE_ENROLLMENT_MODEL,
        "input": {
            "action": "create",
            "target_model": VOICE_CLONE_TTS_MODEL,
            "preferred_name": name,
            "audio": {"data": data_uri},
            "text": cleaned_text,
            "language": lang,
        },
    }
    body = _post_json(_customization_url(), payload, timeout=180)
    _raise_if_error(body)
    output = body.get("output") or {}
    voice = (output.get("voice") or "").strip()
    if not voice:
        raise RuntimeError("复刻未返回 voice")
    target = (output.get("target_model") or VOICE_CLONE_TTS_MODEL).strip() or VOICE_CLONE_TTS_MODEL
    fallback = bool(output.get("fallback_mode"))
    return {"voice": voice, "target_model": target, "fallback_mode": fallback}


def delete_cloned_voice(voice: str) -> None:
    voice_id = (voice or "").strip()
    if not voice_id:
        return
    payload = {
        "model": VOICE_ENROLLMENT_MODEL,
        "input": {"action": "delete", "voice": voice_id},
    }
    body = _post_json(_customization_url(), payload, timeout=60)
    _raise_if_error(body)


def synthesize_with_cloned_voice(
    text: str,
    *,
    voice: str,
    tts_model: str = VOICE_CLONE_TTS_MODEL,
    language_type: str = "English",
) -> bytes:
    """用复刻音色合成；model 必须等于创建时的 target_model。"""
    cleaned = normalize_tts_text(text)
    voice_id = (voice or "").strip()
    if not voice_id:
        raise RuntimeError("缺少复刻音色")
    model = (tts_model or VOICE_CLONE_TTS_MODEL).strip() or VOICE_CLONE_TTS_MODEL
    if model != VOICE_CLONE_TTS_MODEL:
        # 硬约束：禁止把复刻 voice 塞进 flash
        model = VOICE_CLONE_TTS_MODEL

    lang = (language_type or "English").strip() or "English"
    payload = {
        "model": model,
        "input": {
            "text": cleaned,
            "voice": voice_id,
            "language_type": lang,
        },
    }
    body = _post_json(_generation_url(), payload, timeout=120)
    _raise_if_error(body)
    audio = (body.get("output") or {}).get("audio") or {}
    url = audio.get("url")
    if not url:
        raise RuntimeError("DashScope TTS 未返回音频 URL")

    try:
        with urllib.request.urlopen(url, timeout=120) as resp:
            audio_data = resp.read()
    except urllib.error.HTTPError as exc:
        raise RuntimeError(f"DashScope 音频下载失败 ({exc.code})") from exc

    if not audio_data:
        raise RuntimeError("DashScope 音频下载为空")
    return ensure_mp3_bytes(audio_data)
