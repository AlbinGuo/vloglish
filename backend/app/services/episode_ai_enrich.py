"""用户导入剧集的 AI 富化后台任务：ASR 生成字幕 + 中文/IPA + 重点词高亮 + 难度。

用独立 DB 会话在守护线程中执行，结果写回 episodes.ai_status / ai_error，
前端在详情页轮询该状态展示「AI 生成中…」。
"""
from __future__ import annotations

import logging
import threading

from sqlalchemy.orm import Session

from ..database import DATA_DIR, SessionLocal
from ..dict.config import DEEPSEEK_API_KEY
from ..models import Episode, Subtitle
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
            audio = DATA_DIR / "media" / video_id / "audio.mp3"
            sentences = transcribe_audio_to_sentences(audio, video_id=video_id)
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
