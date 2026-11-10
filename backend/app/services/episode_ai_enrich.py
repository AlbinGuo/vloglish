"""用户导入剧集的 AI 富化后台任务：ASR 生成字幕 + 中文/IPA + 重点词高亮 + 难度。

用独立 DB 会话在守护线程中执行，结果写回 episodes.ai_status / ai_error，
前端在详情页轮询该状态展示「AI 生成中…」。
"""
from __future__ import annotations

import logging
import os
import shutil
import tempfile
import threading
import urllib.parse
import urllib.request
from pathlib import Path

from sqlalchemy.orm import Session

from ..database import DATA_DIR, SessionLocal
from ..dict.config import DEEPSEEK_API_KEY
from ..models import Episode, Subtitle
from ..qiniu_storage import is_our_qiniu_url, qiniu_media_expires, sign_url
from .asr_dashscope import dashscope_asr_configured, transcribe_audio_to_sentences
from .episode_admin import replace_subtitles
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


def _prepare_bilibili_audio(api_url: str) -> tuple[Path, None, Path]:
    """B 站直连剧集没有本地音频：下载 durl 并抽取 mp3 到临时文件供 ASR 使用。"""
    from .bilibili_meta import download_audio, extract_bvid
    from .local_submit import _extract_audio_mp3

    parsed = urllib.parse.urlparse(api_url)
    bvid = extract_bvid(parsed.path)
    if not bvid:
        raise RuntimeError("无法解析 B 站视频地址")
    qs = urllib.parse.parse_qs(parsed.query)
    try:
        page = int((qs.get("p") or ["1"])[0] or 1)
    except ValueError:
        page = 1

    work = Path(tempfile.mkdtemp(prefix="vloglish-asr-bili-", dir=DATA_DIR))
    src = work / "source.mp4"
    out = work / "audio.mp3"
    try:
        download_audio(bvid, page, src)
        _extract_audio_mp3(src, out)
        src.unlink(missing_ok=True)
        if not out.is_file() or out.stat().st_size == 0:
            raise RuntimeError("提取音频为空")
        return out, None, work
    except Exception as exc:  # noqa: BLE001
        shutil.rmtree(work, ignore_errors=True)
        raise RuntimeError(f"准备 B 站音频失败：{exc}") from exc


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

    if remote.startswith("/api/bilibili/"):
        return _prepare_bilibili_audio(remote)

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


def _translate_batch_size() -> int:
    try:
        return max(5, int(os.getenv("SUBTITLE_TRANSLATE_BATCH", "30")))
    except ValueError:
        return 30


def _translate_chinese_enabled() -> bool:
    """SUBTITLE_TRANSLATE_CHINESE=0 时只生成英文字幕（跳过中文翻译/IPA，最快）。"""
    return os.getenv("SUBTITLE_TRANSLATE_CHINESE", "1").strip().lower() not in {
        "0",
        "false",
        "no",
        "off",
    }


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

        # 中文字幕（+IPA）；SUBTITLE_TRANSLATE_CHINESE=0 时只生成英文字幕，最快
        if _translate_chinese_enabled():
            try:
                enrich_subtitles_with_deepseek(
                    rows,
                    translate_chinese=True,
                    episode_title=episode.short_title or "",
                    episode_summary=episode.summary or "",
                    build_brief=False,
                    batch_size=_translate_batch_size(),
                )
            except Exception:
                logger.warning("AI 翻译失败，继续写入英文字幕 video=%s", video_id, exc_info=True)
        else:
            logger.info("仅英文字幕（SUBTITLE_TRANSLATE_CHINESE=0） video=%s", video_id)

        clip_length = float(max((r["end"] for r in rows), default=0.0))

        replace_subtitles(db, episode.id, rows)
        episode.subtitle_count = len(rows)
        episode.clip_length = clip_length
        episode.ai_status = "done"
        episode.ai_error = ""
        db.commit()
        logger.info("AI 字幕完成（无高亮） video=%s subtitles=%d", video_id, len(rows))
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
