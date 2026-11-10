"""阿里云 DashScope 录音文件识别（ASR）：音频 -> 带时间轴的英文字幕句。

流程：上传音频到七牛（拿公网签名 URL）-> 提交 DashScope 异步识别任务 -> 轮询 ->
拉取 transcription JSON -> 解析出 [{start, end, text}]（单位：秒）。

相关环境变量：
- DASHSCOPE_API_KEY（必填，复用 Qwen TTS 的 Key）
- DASHSCOPE_BASE_URL（默认 https://dashscope.aliyuncs.com/api/v1）
- DASHSCOPE_ASR_MODEL（默认 paraformer-v2，可改 sensevoice-v1）
- DASHSCOPE_ASR_LANGUAGE（默认 auto，可改 en）
- DASHSCOPE_ASR_TIMEOUT（默认 900 秒）
"""
from __future__ import annotations

import json
import logging
import os
import time
import urllib.error
import urllib.request
from pathlib import Path

from ..qiniu_storage import QiniuConfig, delete_object, sign_url, upload_file

logger = logging.getLogger(__name__)


def dashscope_asr_configured() -> bool:
    return bool(os.getenv("DASHSCOPE_API_KEY", "").strip())


def _api_base() -> str:
    return os.getenv("DASHSCOPE_BASE_URL", "https://dashscope.aliyuncs.com/api/v1").strip().rstrip("/")


def _asr_model() -> str:
    return os.getenv("DASHSCOPE_ASR_MODEL", "paraformer-v2").strip() or "paraformer-v2"


def _asr_language() -> str:
    return os.getenv("DASHSCOPE_ASR_LANGUAGE", "auto").strip() or "auto"


def _asr_timeout() -> int:
    try:
        return max(120, int(os.getenv("DASHSCOPE_ASR_TIMEOUT", "900")))
    except ValueError:
        return 900


def _headers(async_submit: bool = False) -> dict:
    key = os.getenv("DASHSCOPE_API_KEY", "").strip()
    if not key:
        raise RuntimeError("未配置 DASHSCOPE_API_KEY，无法进行语音识别")
    headers = {
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
    }
    if async_submit:
        headers["X-DashScope-Async"] = "enable"
    return headers


def _http_json(
    method: str, url: str, *, headers: dict, body: dict | None = None, timeout: int = 60
) -> dict:
    data = json.dumps(body).encode("utf-8") if body is not None else None
    req = urllib.request.Request(url, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return json.loads(resp.read().decode("utf-8", "ignore"))
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", "ignore")[:400]
        raise RuntimeError(f"DashScope 请求失败 HTTP {exc.code}: {detail}") from exc


def _upload_audio(audio_path: Path, video_id: str) -> tuple[QiniuConfig, str, str]:
    cfg = QiniuConfig.from_env()
    key = cfg.object_key("asr", f"{video_id}{audio_path.suffix or '.mp3'}")
    upload_file(cfg, audio_path, key)
    signed = sign_url(cfg.public_url(key), expires=7200, cfg=cfg)
    return cfg, key, signed


def _submit_task(file_url: str) -> str:
    url = f"{_api_base()}/services/audio/asr/transcription"
    body = {
        "model": _asr_model(),
        "input": {"file_urls": [file_url]},
        "parameters": {"language": _asr_language(), "channel_id": [0]},
    }
    payload = _http_json("POST", url, headers=_headers(async_submit=True), body=body)
    task_id = (payload.get("output") or {}).get("task_id")
    if not task_id:
        raise RuntimeError(
            f"DashScope 未返回 task_id: {json.dumps(payload, ensure_ascii=False)[:300]}"
        )
    return task_id


def _poll_task(task_id: str) -> dict:
    url = f"{_api_base()}/tasks/{task_id}"
    deadline = time.time() + _asr_timeout()
    interval = 1.0
    last: dict = {}
    while time.time() < deadline:
        payload = _http_json("GET", url, headers=_headers())
        output = payload.get("output") or {}
        status = (output.get("task_status") or "").upper()
        last = payload
        if status == "SUCCEEDED":
            return output
        if status in {"FAILED", "CANCELED", "UNKNOWN"}:
            msg = output.get("message") or output.get("code") or status
            raise RuntimeError(f"DashScope 识别失败: {msg}")
        time.sleep(interval)
        interval = min(interval * 1.5, 4.0)
    raise RuntimeError(
        f"DashScope 识别超时（>{_asr_timeout()}s）: "
        f"{json.dumps(last, ensure_ascii=False)[:200]}"
    )


def _fetch_transcriptions(output: dict) -> list[dict]:
    sentences: list[dict] = []
    for res in output.get("results") or []:
        if (res.get("subtask_status") or "").upper() == "FAILED":
            raise RuntimeError(f"DashScope 子任务失败: {res.get('code')} {res.get('message')}")
        t_url = res.get("transcription_url")
        if not t_url:
            continue
        req = urllib.request.Request(t_url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=60) as resp:
            doc = json.loads(resp.read().decode("utf-8", "ignore"))
        for tr in doc.get("transcripts") or []:
            for s in tr.get("sentences") or []:
                text = (s.get("text") or "").strip()
                if not text:
                    continue
                sentences.append(
                    {
                        "start": float(s.get("begin_time") or 0) / 1000.0,
                        "end": float(s.get("end_time") or 0) / 1000.0,
                        "text": text,
                    }
                )
    sentences.sort(key=lambda x: x["start"])
    return sentences


def transcribe_audio_to_sentences(
    audio_path: Path | None = None,
    *,
    video_id: str,
    file_url: str | None = None,
) -> list[dict]:
    """音频 -> [{start, end, text}]（秒）。需要七牛 + DASHSCOPE_API_KEY。

    传入 file_url（已是七牛公网基址）时直接签名复用，省去重复上传音频。
    """
    if not dashscope_asr_configured():
        raise RuntimeError("未配置 DASHSCOPE_API_KEY，无法进行语音识别")

    if file_url:
        signed_url = sign_url(file_url, expires=7200)
        task_id = _submit_task(signed_url)
        output = _poll_task(task_id)
        return _fetch_transcriptions(output)

    if audio_path is None or not audio_path.is_file():
        raise RuntimeError("找不到音频文件，无法识别")
    cfg, key, signed_url = _upload_audio(audio_path, video_id)
    try:
        task_id = _submit_task(signed_url)
        output = _poll_task(task_id)
        return _fetch_transcriptions(output)
    finally:
        delete_object(cfg, key)
