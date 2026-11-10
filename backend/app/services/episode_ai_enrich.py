"""用户导入剧集的 AI 富化后台任务：ASR 生成字幕 + 中文/IPA + 重点词高亮 + 难度。

用独立 DB 会话在守护线程中执行，结果写回 episodes.ai_status / ai_error，
前端在详情页轮询该状态展示「AI 生成中…」。
"""
from __future__ import annotations

import logging
import shutil
import tempfile
import threading
import urllib.request
from pathlib import Path

from sqlalchemy.orm import Session

from ..database import DATA_DIR, SessionLocal
from ..dict.config import DEEPSEEK_API_KEY
from ..models import Episode, Subtitle
from ..qiniu_storage import is_our_qiniu_url, qiniu_media_expires, sign_url
from .asr_dashscope import dashscope_asr_configured, transcribe_audio_to_sentences
from .episode_admin import replace_subtitles
from .subtitle_analyze import analyze_subtitles_with_deepseek
from .subtitle_translate import enrich_subtitles_with_deepseek

logger = logging.getLogger(__name__)


def ai_enrich_configured() -> bool:
    """中文翻译/重点词高亮依赖 DeepSeek。"""
    return bool(DEEPSEEK_API_KEY)


def _load_rows(db: Session, episode: Episode) -> list[dict]:
    subs = (
        db.query(Subtitle)
        .filter(Subtitle.episode_id == episode.id)
        .order_by(Subtitle.index)
        .all()
    )
    return [
        {
            "index": s.index,
            "start": s.start,
            "end": s.end,
            "english": s.english or "",
            "chinese": s.chinese or "",
            "english_html": s.english_html or "",
            "ipa": s.ipa or "",
        }
        for s in subs
    ]


def _resolve_asr_source(episode: Episode, video_id: str) -> tuple[Path | None, str | None, Path | None]:
    """定位 ASR 音源：本地文件 / 七牛公网地址 / 外部地址下载到临时文件。

    返回 (本地音频, 七牛 file_url, 需清理的临时目录)。
    """
    local = DATA_DIR / "media" / video_id / "audio.mp3"
    if local.is_file() and local.stat().st_size > 0:
        return local, None, None

    remote = (getattr(episode, "audio_url", "") or "").strip()
    if not remote:
        raise RuntimeError("找不到音频文件，无法生成字幕")

    if remote.startswith(("http://", "https://")) and is_our_qiniu_url(remote):
        return None, remote, None

    work = Path(tempfile.mkdtemp(prefix="vloglish-asr-", dir=DATA_DIR))
    tmp = work / "audio.mp3"
    try:
        url = sign_url(remote, expires=qiniu_media_expires())
        req = urllib.request.Request(url, headers={"User-Agent": "vloglish-asr/1.0"})
        with urllib.request.urlopen(req, timeout=120) as resp, tmp.open("wb") as out:
            shutil.copyfileobj(resp, out)
        if not tmp.is_file() or tmp.stat().st_size == 0:
            raise RuntimeError("下载音频为空")
        return tmp, None, work
    except Exception as exc:  # noqa: BLE001
        shutil.rmtree(work, ignore_errors=True)
        raise RuntimeError(f"下载音频失败：{exc}") from exc


def run_ai_enrich(video_id: str, *, do_asr: bool) -> None:
    """同步执行（由 schedule_ai_enrich 放到后台线程）。"""
    db: Session = SessionLocal()
    try:
        episode = db.query(Episode).filter(Episode.video_id == video_id).first()
        if not episode:
            return
        episode.ai_status = "processing"
        episode.ai_error = ""
        db.commit()

        rows = _load_rows(db, episode)
        if not rows and do_asr:
            if not dashscope_asr_configured():
                raise RuntimeError("未配置语音识别（DASHSCOPE_API_KEY），无法从视频生成字幕")
            audio, file_url, temp_dir = _resolve_asr_source(episode, video_id)
            try:
                sentences = transcribe_audio_to_sentences(
                    audio, video_id=video_id, file_url=file_url
                )
            finally:
                if temp_dir is not None:
                    shutil.rmtree(temp_dir, ignore_errors=True)
            rows = [
                {
                    "index": i + 1,
                    "start": s["start"],
                    "end": s["end"],
                    "english": s["text"],
                    "chinese": "",
                    "english_html": "",
                    "ipa": "",
                }
                for i, s in enumerate(sentences)
            ]
        if not rows:
            raise RuntimeError("没有可用的字幕（请上传字幕或启用语音识别）")

        # 中文 + IPA（失败不阻塞高亮）
        try:
            enrich_subtitles_with_deepseek(
                rows,
                translate_chinese=True,
                episode_title=episode.short_title or "",
                episode_summary=episode.summary or "",
            )
        except Exception:
            logger.warning("AI 翻译失败，继续生成重点词高亮 video=%s", video_id, exc_info=True)

        clip_length = float(max((r["end"] for r in rows), default=0.0))
        metrics = analyze_subtitles_with_deepseek(rows, clip_length=clip_length or None)

        replace_subtitles(db, episode.id, rows)
        episode.subtitle_count = len(rows)
        episode.clip_length = clip_length
        episode.stars = int(metrics.get("stars", episode.stars or 3) or 3)
        episode.voca_size = int(metrics.get("voca_size", episode.voca_size or 0) or 0)
        episode.ai_status = "done"
        episode.ai_error = ""
        db.commit()
        logger.info("AI 富化完成 video=%s subtitles=%d", video_id, len(rows))
    except Exception as exc:  # noqa: BLE001
        logger.exception("AI 富化失败 video=%s", video_id)
        try:
            db.rollback()
        except Exception:
            pass
        try:
            episode = db.query(Episode).filter(Episode.video_id == video_id).first()
            if episode:
                episode.ai_status = "failed"
                episode.ai_error = (str(exc) or "AI 生成失败")[:500]
                db.commit()
        except Exception:
            logger.exception("标记 AI 失败状态时出错 video=%s", video_id)
    finally:
        db.close()


def schedule_ai_enrich(video_id: str, *, do_asr: bool) -> None:
    threading.Thread(
        target=run_ai_enrich,
        args=(video_id,),
        kwargs={"do_asr": do_asr},
        name=f"ai-enrich-{video_id}",
        daemon=True,
    ).start()
