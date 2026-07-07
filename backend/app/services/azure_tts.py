"""Azure Neural TTS（REST API，无额外 SDK 依赖）。"""

from __future__ import annotations

import os
import urllib.error
import urllib.request
import xml.sax.saxutils as saxutils

from .tts_common import normalize_tts_text


def _escape_xml(text: str) -> str:
    return saxutils.escape(text)


def azure_tts_configured() -> bool:
    return bool(os.getenv("AZURE_SPEECH_KEY", "").strip())


def get_azure_tts_endpoint() -> str:
    region = os.getenv("AZURE_SPEECH_REGION", "chinaeast2").strip()
    endpoint = os.getenv("AZURE_SPEECH_ENDPOINT", "").strip()
    if endpoint:
        url = endpoint.rstrip("/")
        if not url.endswith("/cognitiveservices/v1"):
            url = f"{url}/cognitiveservices/v1"
        return url
    if region.endswith(".cn") or region.startswith("china"):
        return f"https://{region}.tts.speech.azure.cn/cognitiveservices/v1"
    return f"https://{region}.tts.speech.microsoft.com/cognitiveservices/v1"


def synthesize_speech(text: str) -> bytes:
    key = os.getenv("AZURE_SPEECH_KEY", "").strip()
    if not key:
        raise RuntimeError("未配置 AZURE_SPEECH_KEY")

    cleaned = normalize_tts_text(text)
    voice = os.getenv("AZURE_SPEECH_VOICE", "en-US-JennyNeural").strip() or "en-US-JennyNeural"
    ssml = (
        f"<speak version='1.0' xml:lang='en-US'>"
        f"<voice name='{voice}'>{_escape_xml(cleaned)}</voice>"
        f"</speak>"
    )
    req = urllib.request.Request(
        get_azure_tts_endpoint(),
        data=ssml.encode("utf-8"),
        method="POST",
        headers={
            "Ocp-Apim-Subscription-Key": key,
            "Content-Type": "application/ssml+xml",
            "X-Microsoft-OutputFormat": "audio-16khz-128kbitrate-mono-mp3",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = resp.read()
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")[:500]
        raise RuntimeError(f"Azure TTS 请求失败 ({exc.code}): {body}") from exc
    if not data:
        raise RuntimeError("Azure TTS 返回空音频")
    return data
