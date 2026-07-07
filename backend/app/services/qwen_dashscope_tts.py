"""阿里云百炼 DashScope Qwen3-TTS（非实时 HTTP API）。"""

from __future__ import annotations

import json
import os
import urllib.error
import urllib.request

from .tts_common import ensure_mp3_bytes, normalize_tts_text


def qwen_tts_configured() -> bool:
    return bool(os.getenv("DASHSCOPE_API_KEY", "").strip())


def _api_url() -> str:
    custom = os.getenv("DASHSCOPE_TTS_URL", "").strip()
    if custom:
        return custom
    base = os.getenv("DASHSCOPE_BASE_URL", "https://dashscope.aliyuncs.com/api/v1").strip().rstrip("/")
    return f"{base}/services/aigc/multimodal-generation/generation"


def _build_payload(text: str) -> dict:
    model = os.getenv("QWEN_TTS_MODEL", "qwen3-tts-flash").strip() or "qwen3-tts-flash"
    voice = os.getenv("QWEN_TTS_VOICE", "Ryan").strip() or "Ryan"
    language = os.getenv("QWEN_TTS_LANGUAGE", "English").strip() or "English"

    payload: dict = {
        "model": model,
        "input": {
            "text": text,
            "voice": voice,
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


def synthesize_speech(text: str) -> bytes:
    api_key = os.getenv("DASHSCOPE_API_KEY", "").strip()
    if not api_key:
        raise RuntimeError("未配置 DASHSCOPE_API_KEY")

    cleaned = normalize_tts_text(text)
    payload = _build_payload(cleaned)

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
