"""阿里云百炼 DashScope Qwen3-TTS（非实时 HTTP API）。"""

from __future__ import annotations

import json
import os
import urllib.error
import urllib.request

from .tts_common import ensure_mp3_bytes, normalize_tts_text


_PLACEHOLDER_KEYS = frozenset(
    {
        "",
        "sk-xxx",
        "xxx",
        "changeme",
        "your-api-key",
        "your_api_key",
        "REPLACE_ME",
    }
)


def _dashscope_api_key() -> str:
    return os.getenv("DASHSCOPE_API_KEY", "").strip()


def qwen_tts_configured() -> bool:
    key = _dashscope_api_key()
    if not key or key in _PLACEHOLDER_KEYS:
        return False
    # 文档示例里的假值，避免当成已配置去请求
    if key.lower().endswith("xxx") and len(key) < 16:
        return False
    return True


QWEN_ARTICLE_VOICES = ("Ryan", "Katerina")


def resolve_qwen_voice(voice: str | None = None) -> str:
    default = os.getenv("QWEN_TTS_VOICE", "Ryan").strip() or "Ryan"
    if not voice or not voice.strip():
        return default if default in QWEN_ARTICLE_VOICES else QWEN_ARTICLE_VOICES[0]
    cleaned = voice.strip()
    if cleaned not in QWEN_ARTICLE_VOICES:
        allowed = ", ".join(QWEN_ARTICLE_VOICES)
        raise ValueError(f"不支持音色: {cleaned}，可选: {allowed}")
    return cleaned


def _api_url() -> str:
    custom = os.getenv("DASHSCOPE_TTS_URL", "").strip()
    if custom:
        return custom
    base = os.getenv("DASHSCOPE_BASE_URL", "https://dashscope.aliyuncs.com/api/v1").strip().rstrip("/")
    return f"{base}/services/aigc/multimodal-generation/generation"


def _build_payload(text: str, *, voice: str | None = None) -> dict:
    model = os.getenv("QWEN_TTS_MODEL", "qwen3-tts-flash").strip() or "qwen3-tts-flash"
    voice_name = resolve_qwen_voice(voice)
    language = os.getenv("QWEN_TTS_LANGUAGE", "English").strip() or "English"

    payload: dict = {
        "model": model,
        "input": {
            "text": text,
            "voice": voice_name,
            "language_type": language,
        },
    }

    instructions = os.getenv("QWEN_TTS_INSTRUCTIONS", "").strip()
    if instructions and "instruct" in model.lower():
        payload["input"]["instructions"] = instructions
        payload["input"]["optimize_instructions"] = (
            os.getenv("QWEN_TTS_OPTIMIZE_INSTRUCTIONS", "true").strip().lower() != "false"
        )
    return payload


def _parse_response(body: dict) -> str:
    status = body.get("status_code")
    if status and int(status) != 200:
        raise RuntimeError(body.get("message") or f"DashScope TTS 失败 (HTTP {status})")
    if body.get("code"):
        raise RuntimeError(body.get("message") or f"DashScope TTS 错误: {body.get('code')}")

    audio = (body.get("output") or {}).get("audio") or {}
    url = audio.get("url")
    if not url:
        raise RuntimeError("DashScope TTS 未返回音频 URL")
    return url


def synthesize_speech(text: str, *, voice: str | None = None) -> bytes:
    if not qwen_tts_configured():
        raise RuntimeError("未配置有效的 DASHSCOPE_API_KEY（请在百炼控制台创建并写入 backend/.env）")
    api_key = _dashscope_api_key()

    cleaned = normalize_tts_text(text)
    payload = _build_payload(cleaned, voice=voice)

    req = urllib.request.Request(
        _api_url(),
        data=json.dumps(payload, ensure_ascii=False).encode("utf-8"),
        method="POST",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
    )

    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            body = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        raw = exc.read().decode("utf-8", errors="replace")
        try:
            detail = json.loads(raw)
            message = detail.get("message") or raw[:500]
        except json.JSONDecodeError:
            message = raw[:500]
        if exc.code == 401:
            raise RuntimeError(
                "DashScope API Key 无效或已失效，请到百炼控制台重置后更新 backend/.env 的 DASHSCOPE_API_KEY 并重启后端"
            ) from exc
        raise RuntimeError(f"DashScope TTS 请求失败 ({exc.code}): {message}") from exc

    audio_url = _parse_response(body)

    try:
        with urllib.request.urlopen(audio_url, timeout=120) as resp:
            audio_data = resp.read()
    except urllib.error.HTTPError as exc:
        raise RuntimeError(f"DashScope 音频下载失败 ({exc.code})") from exc

    if not audio_data:
        raise RuntimeError("DashScope 音频下载为空")

    return ensure_mp3_bytes(audio_data)
