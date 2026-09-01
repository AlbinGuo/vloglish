"""阿里云百炼 CosyVoice 声音复刻与非实时合成（含 SSML）。"""

from __future__ import annotations

import json
import os
import re
import urllib.error
import urllib.request

from .qwen_dashscope_tts import qwen_tts_configured
from .tts_common import ensure_mp3_bytes, normalize_tts_text

VOICE_CLONE_TTS_MODEL = (
    os.getenv("COSYVOICE_TTS_MODEL", "cosyvoice-v3-plus").strip() or "cosyvoice-v3-plus"
)
VOICE_ENROLLMENT_MODEL = "voice-enrollment"

_PREFIX_RE = re.compile(r"^[a-z0-9]{1,10}$")


def voice_clone_configured() -> bool:
    return qwen_tts_configured()


def is_cosyvoice_model(model: str | None) -> bool:
    m = (model or "").strip().lower()
    return m.startswith("cosyvoice-") or m.startswith("qwen-audio-3.0-tts")


def _api_key() -> str:
    return os.getenv("DASHSCOPE_API_KEY", "").strip()


def _tts_api_base() -> str:
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


def _synthesizer_url() -> str:
    custom = os.getenv("DASHSCOPE_COSYVOICE_TTS_URL", "").strip()
    if custom and "compatible-mode" not in custom.lower():
        return custom
    return f"{_tts_api_base()}/services/audio/tts/SpeechSynthesizer"


def sanitize_prefix(name: str, *, fallback: str = "vloglish") -> str:
    cleaned = re.sub(r"[^a-z0-9]", "", (name or "").strip().lower())[:10]
    if _PREFIX_RE.fullmatch(cleaned):
        return cleaned
    fb = re.sub(r"[^a-z0-9]", "", fallback.lower())[:10] or "vloglish"
    return fb[:10]


def normalize_clone_language(language: str | None) -> str:
    lang = (language or "en").strip().lower()
    if lang in ("yue", "cantonese"):
        return "zh"
    if len(lang) >= 2:
        return lang[:2]
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
            message = (
                detail.get("message")
                or detail.get("Message")
                or raw[:500]
            )
            code = detail.get("code") or detail.get("Code")
            if code:
                message = f"{code}: {message}"
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


def create_cloned_voice(*, audio_url: str, language: str = "en", prefix: str = "vloglish") -> dict:
    url = (audio_url or "").strip()
    if not url:
        raise RuntimeError("缺少样本音频 URL")
    name = sanitize_prefix(prefix)
    lang = normalize_clone_language(language)
    payload = {
        "model": VOICE_ENROLLMENT_MODEL,
        "input": {
            "action": "create_voice",
            "target_model": VOICE_CLONE_TTS_MODEL,
            "prefix": name,
            "url": url,
            "language_hints": [lang],
        },
    }
    body = _post_json(_customization_url(), payload, timeout=180)
    _raise_if_error(body)
    output = body.get("output") or {}
    voice = (output.get("voice_id") or output.get("voice") or "").strip()
    if not voice:
        raise RuntimeError("复刻未返回 voice_id")
    target = (output.get("target_model") or VOICE_CLONE_TTS_MODEL).strip() or VOICE_CLONE_TTS_MODEL
    return {"voice": voice, "target_model": target, "fallback_mode": False}


def delete_cloned_voice(voice: str) -> None:
    voice_id = (voice or "").strip()
    if not voice_id:
        return
    payload = {
        "model": VOICE_ENROLLMENT_MODEL,
        "input": {"action": "delete_voice", "voice_id": voice_id},
    }
    body = _post_json(_customization_url(), payload, timeout=60)
    _raise_if_error(body)


def synthesize_with_cloned_voice(
    text: str,
    *,
    voice: str,
    tts_model: str = VOICE_CLONE_TTS_MODEL,
    language: str = "en",
    enable_ssml: bool = False,
    rate: float | None = None,
    pitch: float | None = None,
    instruction: str | None = None,
) -> bytes:
    voice_id = (voice or "").strip()
    if not voice_id:
        raise RuntimeError("缺少复刻音色")
    model = (tts_model or VOICE_CLONE_TTS_MODEL).strip() or VOICE_CLONE_TTS_MODEL
    if not is_cosyvoice_model(model):
        model = VOICE_CLONE_TTS_MODEL

    cleaned = text if enable_ssml else normalize_tts_text(text)
    lang = normalize_clone_language(language)
    inp: dict = {
        "text": cleaned,
        "voice": voice_id,
        "format": "mp3",
        "sample_rate": 24000,
        "language_hints": [lang],
    }
    if enable_ssml:
        inp["enable_ssml"] = True
    if rate is not None:
        inp["rate"] = max(0.5, min(2.0, float(rate)))
    if pitch is not None:
        inp["pitch"] = max(0.5, min(2.0, float(pitch)))
    hint = (instruction or "").strip()
    if hint:
        inp["instruction"] = hint[:100]

    payload = {"model": model, "input": inp}
    body = _post_json(_synthesizer_url(), payload, timeout=120)
    _raise_if_error(body)
    audio = (body.get("output") or {}).get("audio") or {}
    url = audio.get("url")
    data_b64 = audio.get("data")
    if url:
        try:
            with urllib.request.urlopen(url, timeout=120) as resp:
                audio_data = resp.read()
        except urllib.error.HTTPError as exc:
            raise RuntimeError(f"DashScope 音频下载失败 ({exc.code})") from exc
    elif data_b64:
        import base64

        audio_data = base64.b64decode(data_b64)
    else:
        raise RuntimeError("DashScope TTS 未返回音频")

    if not audio_data:
        raise RuntimeError("DashScope 音频下载为空")
    return ensure_mp3_bytes(audio_data)
