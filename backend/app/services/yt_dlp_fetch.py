"""Download episode media from YouTube / TikTok via yt-dlp."""
from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import tempfile
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from pathlib import Path

from ..database import DATA_DIR
from ..dict.deepseek import localize_video_metadata_with_deepseek
from ..qiniu_storage import QiniuConfig, upload_file
from .media_transcode import ensure_browser_compatible_video
from .subtitle_analyze import analyze_subtitles_with_deepseek
from .subtitle_translate import enrich_subtitles_with_deepseek
from .vtt_import import subtitles_have_chinese, vtt_to_subtitle_dicts


@dataclass(frozen=True)
class YtDlpTools:
    yt_dlp: Path
    ffmpeg_dir: Path
    cookies: Path | None

    @classmethod
    def from_env(cls) -> YtDlpTools:
        tools_dir = Path(os.getenv("VLOGISH_TOOLS_DIR", r"E:\vloglish"))
        yt_dlp = Path(os.getenv("YT_DLP_BIN", tools_dir / "yt-dlp.exe"))
        ffmpeg_dir = Path(os.getenv("FFMPEG_DIR", tools_dir))
        cookies_env = os.getenv("YT_DLP_COOKIES", "").strip()
        cookies = Path(cookies_env) if cookies_env else tools_dir / "cookies.txt"
        if not cookies.is_file():
            cookies = None
        if not yt_dlp.is_file():
            raise RuntimeError(f"未找到 yt-dlp：{yt_dlp}")
        if not (ffmpeg_dir / "ffmpeg.exe").is_file() and not shutil.which("ffmpeg"):
            raise RuntimeError(f"未找到 ffmpeg，请检查 FFMPEG_DIR 或 PATH：{ffmpeg_dir}")
        return cls(yt_dlp=yt_dlp, ffmpeg_dir=ffmpeg_dir, cookies=cookies)


@dataclass
class FetchedMedia:
    title: str
    summary: str
    author_name: str
    duration: float
    source_id: str
    webpage_url: str
    work_dir: Path
    video_path: Path
    audio_path: Path
    thumbnail_path: Path
    vtt_path: Path | None


def clean_social_text(text: str) -> str:
    """Remove hashtags, @mentions, and normalize whitespace."""
    if not text:
        return ""
    lines: list[str] = []
    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        line = re.sub(r"#[\w\u4e00-\u9fff\u3040-\u30ff]+", "", line)
        line = re.sub(r"@[\w.\-]+", "", line)
        line = re.sub(r"\s+", " ", line).strip()
        if line:
            lines.append(line)
    return "\n".join(lines)


def _extract_video_metadata(info: dict) -> dict[str, str]:
    title = clean_social_text(str(info.get("title") or info.get("alt_title") or "").strip())
    summary = clean_social_text(str(info.get("description") or "").strip())
    if not summary:
        alt = clean_social_text(str(info.get("alt_title") or "").strip())
        if alt and alt != title:
            summary = alt

    author_name = ""
    for key in ("uploader", "channel", "creator", "artist", "uploader_id"):
        val = str(info.get(key) or "").strip()
        if val and val.lower() not in {"na", "none", "unknown"}:
            author_name = val
            break

    if len(summary) > 2000:
        summary = summary[:1997].rstrip() + "..."

    return {
        "title": title or "Untitled",
        "summary": summary,
        "author_name": author_name,
    }


def is_supported_source_url(url: str) -> bool:
    url = url.strip().lower()
    return bool(url and ("youtube.com" in url or "youtu.be" in url or "tiktok.com" in url))


def sanitize_slug(value: str) -> str:
    slug = re.sub(r"[^\w\-]+", "-", value.strip(), flags=re.UNICODE)
    slug = re.sub(r"-{2,}", "-", slug).strip("-")
    return slug[:64] or "episode"


def _pick_english_vtt(work_dir: Path, stem: str = "media") -> Path | None:
    vtts = sorted(work_dir.glob(f"{stem}*.vtt"))
    if not vtts:
        return None

    def score(path: Path) -> tuple[int, str]:
        name = path.stem
        pts = 0
        if name == f"{stem}.en":
            pts += 100
        elif name.startswith(f"{stem}.en-"):
            pts += 70
        elif ".en" in name:
            pts += 40
        if "auto" in name.lower():
            pts -= 25
        return (-pts, name)

    return sorted(vtts, key=score)[0]


def _find_media_file(work_dir: Path, stem: str, extensions: tuple[str, ...]) -> Path | None:
    for ext in extensions:
        path = work_dir / f"{stem}{ext}"
        if path.is_file():
            return path
    matches = []
    for ext in extensions:
        matches.extend(work_dir.glob(f"{stem}*{ext}"))
    return matches[0] if matches else None


AUDIO_FORMAT = "bestaudio[ext=m4a]/bestaudio[ext=mp3]/bestaudio[acodec^=mp4a]/bestaudio"

H264_FORMAT_BEST = (
    "best[ext=mp4][vcodec^=avc1]/"
    "best[ext=mp4][vcodec^=h264]/"
    "bestvideo[vcodec^=avc1]+bestaudio/"
    "bestvideo[vcodec^=h264]+bestaudio/"
    "b[ext=mp4][vcodec!=hevc][vcodec!=h265]/"
    "bv*+ba/b"
)


def normalize_fetch_quality(quality: str | None) -> int | None:
    """720 / 1080 / best。返回最大高度；None 表示不限。"""
    q = (quality or "720").strip().lower().rstrip("p")
    if q in {"best", "max", "0"}:
        return None
    if q == "1080":
        return 1080
    return 720


def _video_format(max_height: int | None) -> str:
    if max_height is None:
        return H264_FORMAT_BEST
    h = max_height
    return (
        f"best[height<={h}][ext=mp4][vcodec^=avc1]/"
        f"best[height<={h}][ext=mp4][vcodec^=h264]/"
        f"bestvideo[height<={h}][vcodec^=avc1]+bestaudio/"
        f"bestvideo[height<={h}][vcodec^=h264]+bestaudio/"
        f"best[height<={h}][ext=mp4]/"
        f"{H264_FORMAT_BEST}"
    )


def _extract_audio_mp3(video_path: Path, ffmpeg_dir: Path) -> Path:
    ffmpeg = ffmpeg_dir / "ffmpeg.exe"
    if not ffmpeg.is_file():
        import shutil

        ffmpeg_cmd = shutil.which("ffmpeg")
        if not ffmpeg_cmd:
            raise RuntimeError("未找到 ffmpeg，无法提取音频")
        ffmpeg = Path(ffmpeg_cmd)
    output = video_path.with_name("media.mp3")
    proc = subprocess.run(
        [
            str(ffmpeg),
            "-y",
            "-i",
            str(video_path),
            "-vn",
            "-acodec",
            "libmp3lame",
            "-q:a",
            "4",
            str(output),
        ],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=int(os.getenv("FFMPEG_TRANSCODE_TIMEOUT", "14400")),
    )
    if proc.returncode != 0 or not output.is_file():
        detail = (proc.stderr or proc.stdout or "").strip()
        raise RuntimeError(detail[-2000:] if detail else "音频提取失败")
    return output


def _is_youtube_url(url: str) -> bool:
    u = (url or "").lower()
    return "youtube.com" in u or "youtu.be" in u


def _looks_like_http_403(detail: str) -> bool:
    lower = (detail or "").lower()
    return "403" in lower and ("forbidden" in lower or "unable to download" in lower)


def _detect_js_runtime() -> str:
    configured = os.getenv("YT_DLP_JS_RUNTIME", "").strip().lower()
    if configured:
        return configured
    if shutil.which("deno"):
        return "deno"
    if shutil.which("node"):
        return "node"
    return ""


def _video_format_403_fallback(max_height: int | None) -> str:
    """403 时改下「已合并」的 progressive 流，避开 DASH/android_sdkless。"""
    if max_height is None:
        return "b[ext=mp4]/b"
    h = max_height
    return f"b[height<={h}][ext=mp4]/b[height<={h}]/best[height<={h}][ext=mp4]/b[ext=mp4]/b"


def _video_format_hls(max_height: int | None) -> str:
    """ios 客户端只稳 HLS；非 m3u8 的 ios https 流容易 403。"""
    cap = f"[height<={max_height}]" if max_height else ""
    return (
        f"bv{cap}[protocol=m3u8_native]+ba[protocol=m3u8_native]/"
        f"b{cap}[protocol=m3u8_native]/"
        "b[protocol=m3u8_native]/b"
    )


# default 会带上 web/tv；当前会话一旦 SABR-only，这两家没有 https 直链。
# mweb 的 https 需要 GVS PO Token，未配置时只会告警，故默认只用 android_vr。
_YOUTUBE_CLIENTS = "android_vr,-android_sdkless,-web,-tv,-web_safari,-mweb"
_YOUTUBE_CLIENTS_IOS = "ios,-android_sdkless,-web,-tv,-web_safari,-mweb"


def _cookies_from_browser() -> str:
    return os.getenv("YT_DLP_COOKIES_FROM_BROWSER", "").strip()


def _youtube_cookies_opt_in() -> bool:
    return os.getenv("YT_DLP_YOUTUBE_COOKIES", "").strip().lower() in {"1", "true", "yes"}


def _cookies_configured(cookies: Path | None = None) -> bool:
    if _cookies_from_browser():
        return True
    if os.getenv("YT_DLP_COOKIES", "").strip():
        return True
    if cookies and cookies.is_file():
        return True
    tools_dir = Path(os.getenv("VLOGISH_TOOLS_DIR", r"E:\vloglish"))
    return (tools_dir / "cookies.txt").is_file()


def _yt_dlp_cli_extras(
    *,
    url: str = "",
    compat: bool = False,
    player_client: str | None = None,
    extractor_extra: str = "",
    use_browser_cookies: bool = True,
) -> list[str]:
    args: list[str] = []
    proxy = os.getenv("YT_DLP_PROXY", "").strip()
    if proxy:
        args.extend(["--proxy", proxy])
    impersonate = os.getenv("YT_DLP_IMPERSONATE", "").strip()
    if impersonate:
        args.extend(["--impersonate", impersonate])
    browser = _cookies_from_browser() if use_browser_cookies else ""
    if browser:
        args.extend(["--cookies-from-browser", browser])
    if _is_youtube_url(url):
        client = (player_client or os.getenv("YT_DLP_PLAYER_CLIENT", "").strip())
        if not client:
            client = _YOUTUBE_CLIENTS_IOS if compat else _YOUTUBE_CLIENTS
        extractor = f"youtube:player_client={client}"
        po_token = os.getenv("YT_DLP_PO_TOKEN", "").strip()
        if po_token:
            extractor += f";po_token={po_token}"
        if extractor_extra:
            extractor += f";{extractor_extra}"
        args.extend(["--extractor-args", extractor])
        js_runtime = _detect_js_runtime()
        if js_runtime:
            args.extend(["--js-runtimes", js_runtime])
        # 避免缓存把 SABR-only 会话粘住；先探测直链是否 403 再换格式
        args.extend(["--no-cache-dir", "--check-formats"])
    try:
        default_n = 2 if _is_youtube_url(url) else 8
        fragments = max(1, min(16, int(os.getenv("YT_DLP_CONCURRENT_FRAGMENTS", str(default_n)))))
    except ValueError:
        fragments = 2 if _is_youtube_url(url) else 8
    if compat:
        fragments = 1
    args.extend(["-N", str(fragments), "--continue"])
    return args


def _format_ytdlp_error(detail: str, url: str) -> str:
    lower = detail.lower()
    platform = "YouTube / TikTok"
    if "tiktok.com" in url.lower():
        platform = "TikTok"
    elif "youtube.com" in url.lower() or "youtu.be" in url.lower():
        platform = "YouTube"

    if (
        "eof occurred in violation of protocol" in lower
        or "ssleoferror" in lower
        or "unexpected_eof_while_reading" in lower
        or "ssl: unexpected_eof" in lower
        or "connection aborted" in lower
        or "connectionreseterror" in lower
        or "connection reset" in lower
        or "10054" in detail
        or "forcibly closed" in lower
    ):
        proxy = os.getenv("YT_DLP_PROXY", "").strip()
        proxy_hint = (
            f"当前已配置 YT_DLP_PROXY={proxy}，请确认：① 代理软件已开启；② 端口一致；"
            f"③ 系统代理/TUN 不要和 yt-dlp 双重劫持（可先关 Clash 系统代理，只留 YT_DLP_PROXY）；④ 换可用节点后重试。"
            if proxy
            else "当前未配置 YT_DLP_PROXY。本地请在 backend/.env 增加例如：YT_DLP_PROXY=http://127.0.0.1:7890（端口以 Clash/V2Ray 的 HTTP 代理为准），保存后重启后端再试。"
        )
        return (
            f"连接 {platform} 被中断（Connection reset / 10054，常见于国内直连 YouTube 失败或代理未生效）。\n"
            f"{proxy_hint}\n"
            "也可执行 yt-dlp -U 更新，或在本地成功下载后再上传七牛。\n\n"
            f"原始错误：{detail[-800:]}"
        )

    if "network is unreachable" in lower or "failed to establish" in lower or "timed out" in lower:
        return (
            f"无法直连 {platform}（国内网络或 ECS 常见）。"
            "本地开发请在 backend/.env 配置 YT_DLP_PROXY；生产环境请在 .env.prod 配置可访问的代理，"
            "或在本地 Windows 抓取后上传七牛。"
            f"\n\n原始错误：{detail[-800:]}"
        )
    if _looks_like_http_403(detail) and platform == "YouTube":
        sabr = "sabr" in lower
        has_cookies = _cookies_configured()
        cookie_hint = (
            "YouTube 默认不再带 cookies.txt（登录态 + 代理 IP 会 403）。"
            "年龄限制片才需要在 backend/.env 设 YT_DLP_YOUTUBE_COOKIES=1。"
            if has_cookies
            else "一般不用 cookies；年龄限制片再设 YT_DLP_YOUTUBE_COOKIES=1。"
        )
        if sabr:
            return (
                "YouTube 对当前会话启用了 SABR-only（web/tv 没有 https 直链）。"
                "请重启后端后再抓一次（已避开 tv/web，并会自动改试 android_vr / ios HLS）。"
                "若仍失败：① 换一个代理节点（最有效）；② 本机 yt-dlp 已更新，确认后端用的是 E:\\vloglish\\yt-dlp.exe；"
                f"③ {cookie_hint}\n\n"
                f"原始错误：{detail[-800:]}"
            )
        js = _detect_js_runtime()
        js_hint = (
            f"已检测到 JS 运行时 {js}。"
            if js
            else "未检测到 Deno/Node。YouTube 解签名需要其一，请安装后重启后端。"
        )
        return (
            "YouTube 拒绝了媒体流下载（HTTP 403）。"
            f"① 换代理节点后重试；② {cookie_hint}③ {js_hint}\n\n"
            f"原始错误：{detail[-800:]}"
        )
    return detail[-2000:] if detail else "yt-dlp 执行失败"


def _run_yt_dlp(
    tools: YtDlpTools,
    url: str,
    work_dir: Path,
    *,
    fmt: str,
    stem: str,
    write_subtitles: bool = False,
    write_thumbnail: bool = False,
    write_info: bool = False,
    merge_mp4: bool = False,
    compat: bool = False,
    player_client: str | None = None,
    extractor_extra: str = "",
    use_cookies: bool = True,
) -> None:
    out_template = str(work_dir / f"{stem}.%(ext)s")
    cmd = [
        str(tools.yt_dlp),
        "--ffmpeg-location",
        str(tools.ffmpeg_dir),
        "--no-playlist",
        "-f",
        fmt,
        "-o",
        out_template,
    ]
    if merge_mp4:
        cmd.extend(["--merge-output-format", "mp4"])
    if write_thumbnail:
        cmd.extend(["--write-thumbnail", "--convert-thumbnails", "webp"])
    if write_info:
        cmd.append("--write-info-json")
    if write_subtitles:
        cmd.extend(
            [
                "--write-subs",
                "--write-auto-subs",
                "--sub-langs",
                "en.*,en",
                "--sub-format",
                "vtt",
            ]
        )
    allow_any_cookies = use_cookies and (not _is_youtube_url(url) or _youtube_cookies_opt_in())
    browser_cookies = bool(_cookies_from_browser()) if allow_any_cookies else False
    if allow_any_cookies and tools.cookies and not browser_cookies:
        cmd.extend(["--cookies", str(tools.cookies)])
    cmd.extend(
        _yt_dlp_cli_extras(
            url=url,
            compat=compat,
            player_client=player_client,
            extractor_extra=extractor_extra,
            use_browser_cookies=browser_cookies,
        )
    )
    cmd.append(url)

    timeout_sec = int(os.getenv("YT_DLP_TIMEOUT", "14400"))
    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=timeout_sec,
        )
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError(
            f"yt-dlp 下载超时（已等待 {timeout_sec} 秒）。长视频请在 backend/.env 提高 "
            f"YT_DLP_TIMEOUT 后重启后端，或先在本机用 yt-dlp 下完再上传七牛。"
        ) from exc
    if proc.returncode != 0:
        detail = (proc.stderr or proc.stdout or "").strip()
        raise RuntimeError(_format_ytdlp_error(detail, url))


def _load_info_json(work_dir: Path) -> dict:
    info_path = work_dir / "media.info.json"
    if not info_path.is_file():
        return {}
    try:
        data = json.loads(info_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"yt-dlp 元数据 JSON 解析失败：{exc}") from exc
    return data if isinstance(data, dict) else {}


def download_source_media(
    url: str,
    *,
    write_subtitles: bool = True,
    quality: str = "720",
) -> FetchedMedia:
    url = url.strip()
    if not is_supported_source_url(url):
        raise RuntimeError("仅支持 YouTube 或 TikTok 链接")

    tools = YtDlpTools.from_env()
    work_dir = Path(tempfile.mkdtemp(prefix="vloglish-ytdlp-", dir=DATA_DIR))
    max_height = normalize_fetch_quality(quality)
    video_err: Exception | None = None
    audio_err: Exception | None = None

    def _download_video() -> None:
        _run_yt_dlp(
            tools,
            url,
            work_dir,
            fmt=_video_format(max_height),
            stem="media",
            write_subtitles=write_subtitles,
            write_thumbnail=True,
            write_info=True,
            merge_mp4=True,
            use_cookies=not _is_youtube_url(url) or _youtube_cookies_opt_in(),
        )

    def _download_audio() -> None:
        _run_yt_dlp(
            tools,
            url,
            work_dir,
            fmt=AUDIO_FORMAT,
            stem="audio",
            use_cookies=not _is_youtube_url(url) or _youtube_cookies_opt_in(),
        )

    try:
        if _is_youtube_url(url):
            # 音视频并行容易把同一会话打成 SABR-only，YouTube 改为先视频后音频
            try:
                _download_video()
            except Exception as exc:
                video_err = exc
        else:
            with ThreadPoolExecutor(max_workers=2) as pool:
                fut_video = pool.submit(_download_video)
                fut_audio = pool.submit(_download_audio)
                try:
                    fut_video.result()
                except Exception as exc:
                    video_err = exc
                try:
                    fut_audio.result()
                except Exception as exc:
                    audio_err = exc
        if video_err and _is_youtube_url(url) and _looks_like_http_403(str(video_err)):
            retries = (
                {
                    "player_client": "android_vr",
                    "fmt": _video_format_403_fallback(max_height),
                    "extractor_extra": "",
                    "use_cookies": False,
                },
                {
                    "player_client": _YOUTUBE_CLIENTS_IOS,
                    "fmt": _video_format_hls(max_height),
                    "extractor_extra": "formats=missing_pot",
                    "use_cookies": False,
                },
                {
                    "player_client": "android_vr",
                    "fmt": "18/b[ext=mp4]/b",
                    "extractor_extra": "",
                    "use_cookies": False,
                },
            )
            for attempt in retries:
                try:
                    _run_yt_dlp(
                        tools,
                        url,
                        work_dir,
                        fmt=str(attempt["fmt"]),
                        stem="media",
                        write_subtitles=write_subtitles,
                        write_thumbnail=True,
                        write_info=True,
                        merge_mp4=True,
                        compat=True,
                        player_client=str(attempt["player_client"]),
                        extractor_extra=str(attempt["extractor_extra"]),
                        use_cookies=bool(attempt["use_cookies"]),
                    )
                    video_err = None
                    break
                except Exception as exc:
                    video_err = exc
        if video_err:
            raise video_err
        if _is_youtube_url(url):
            try:
                _download_audio()
            except Exception as exc:
                audio_err = exc
    except Exception:
        shutil.rmtree(work_dir, ignore_errors=True)
        raise

    info = _load_info_json(work_dir)
    meta = _extract_video_metadata(info)
    video_path = _find_media_file(work_dir, "media", (".mp4", ".webm", ".mkv", ".ts"))
    if not video_path:
        shutil.rmtree(work_dir, ignore_errors=True)
        raise RuntimeError("未下载到视频文件")

    audio_path = _find_media_file(work_dir, "audio", (".m4a", ".mp3", ".opus", ".webm", ".wav"))
    thumbnail_path = _find_media_file(work_dir, "media", (".webp", ".jpg", ".jpeg", ".png"))
    vtt_path = _pick_english_vtt(work_dir) if write_subtitles else None

    title = meta["title"]
    duration = float(info.get("duration") or 0)
    source_id = str(info.get("id") or "").strip()
    webpage_url = str(info.get("webpage_url") or url).strip()

    if not audio_path:
        try:
            audio_path = _extract_audio_mp3(video_path, tools.ffmpeg_dir)
        except RuntimeError:
            shutil.rmtree(work_dir, ignore_errors=True)
            detail = str(audio_err) if audio_err else "未知错误"
            raise RuntimeError(f"未下载到独立音轨，且从视频提取音频失败：{detail[-400:]}")

    video_path, _ = ensure_browser_compatible_video(video_path, tools.ffmpeg_dir)

    return FetchedMedia(
        title=title,
        summary=meta["summary"],
        author_name=meta["author_name"],
        duration=duration,
        source_id=source_id,
        webpage_url=webpage_url,
        work_dir=work_dir,
        video_path=video_path,
        audio_path=audio_path,
        thumbnail_path=thumbnail_path or Path(),
        vtt_path=vtt_path,
    )


def upload_fetched_media(
    fetched: FetchedMedia,
    *,
    slug: str,
    enrich_subtitles: bool = True,
) -> dict:
    cfg = QiniuConfig.from_env()
    uploads: dict[str, str] = {}

    video_key = cfg.object_key(slug, "video.mp4")
    audio_name = fetched.audio_path.suffix.lower()
    audio_filename = "audio.mp3" if audio_name == ".mp3" else f"audio{audio_name}"
    audio_key = cfg.object_key(slug, audio_filename)

    upload_jobs: dict[str, tuple[Path, str]] = {
        "video_url": (fetched.video_path, video_key),
        "audio_url": (fetched.audio_path, audio_key),
    }
    if fetched.thumbnail_path.is_file():
        thumb_name = fetched.thumbnail_path.name
        if not thumb_name.startswith("cover"):
            thumb_name = f"cover{fetched.thumbnail_path.suffix.lower()}"
        thumb_key = cfg.object_key(slug, thumb_name)
        upload_jobs["cover"] = (fetched.thumbnail_path, thumb_key)

    with ThreadPoolExecutor(max_workers=3) as pool:
        futures = {
            name: pool.submit(upload_file, cfg, local_path, key)
            for name, (local_path, key) in upload_jobs.items()
        }
        for name, future in futures.items():
            url = future.result()
            uploads[name] = url
            if name == "cover":
                uploads["thumbnail_url"] = url

    subtitles: list[dict] = []
    had_chinese = False
    translated_count = 0
    ipa_count = 0
    stars = 3
    voca_size = 0
    highlight_count = 0
    warnings: list[str] = []

    display_title = fetched.title
    display_summary = fetched.summary

    # 管理端「仅抓媒体」：不解析/翻译/高亮字幕，留给后续手动导入 SRT
    if not enrich_subtitles:
        warnings.append("已跳过字幕抓取与分析，请稍后手动导入 SRT/VTT")
        if display_title or display_summary:
            try:
                localized = localize_video_metadata_with_deepseek(display_title, display_summary)
                if localized.get("title"):
                    display_title = localized["title"]
                if localized.get("summary") is not None:
                    display_summary = localized["summary"]
            except Exception as exc:
                warnings.append(f"标题/摘要翻译失败：{exc}")
        clip_length = float(fetched.duration or 0)
        if len(display_summary) > 2000:
            display_summary = display_summary[:1997].rstrip() + "..."
        return {
            "title": display_title,
            "summary": display_summary,
            "author_name": fetched.author_name,
            "original_video_url": fetched.webpage_url,
            "cover": uploads.get("cover", ""),
            "thumbnail_url": uploads.get("thumbnail_url", ""),
            "video_url": uploads.get("video_url", ""),
            "audio_url": uploads.get("audio_url", ""),
            "subtitles": [],
            "subtitle_count": 0,
            "clip_length": clip_length,
            "had_chinese": False,
            "translated_count": 0,
            "ipa_count": 0,
            "stars": 3,
            "voca_size": 0,
            "highlight_count": 0,
            "source_id": fetched.source_id,
            "warnings": warnings,
        }

    if fetched.vtt_path and fetched.vtt_path.is_file():
        vtt_text = fetched.vtt_path.read_text(encoding="utf-8", errors="replace")
        subtitles = vtt_to_subtitle_dicts(vtt_text)
        had_chinese = subtitles_have_chinese(subtitles)

        if subtitles:
            clip_length_est = float(max((s["end"] for s in subtitles), default=fetched.duration or 0))

            def _run_enrich() -> tuple[int, int, dict, int, bool, int] | RuntimeError:
                try:
                    return enrich_subtitles_with_deepseek(
                        subtitles,
                        translate_chinese=not had_chinese,
                        episode_title=display_title or "",
                        episode_summary=display_summary or "",
                    )
                except Exception as exc:
                    return RuntimeError(str(exc))

            def _run_localize() -> dict[str, str] | RuntimeError:
                try:
                    return localize_video_metadata_with_deepseek(display_title, display_summary)
                except Exception as exc:
                    return RuntimeError(str(exc))

            # 翻译与标题本地化并行；高亮分析等 brief 就绪后串行，便于标出专业词汇
            translation_brief: dict = {}
            with ThreadPoolExecutor(max_workers=2) as pool:
                fut_enrich = pool.submit(_run_enrich)
                fut_localize = (
                    pool.submit(_run_localize)
                    if display_title or display_summary
                    else None
                )

                enrich_result = fut_enrich.result()
                if isinstance(enrich_result, RuntimeError):
                    warnings.append(f"字幕翻译/音标生成失败：{enrich_result}")
                else:
                    translated_count, ipa_count, translation_brief, _rem, _done, _batches = enrich_result

                if fut_localize:
                    localize_result = fut_localize.result()
                    if isinstance(localize_result, RuntimeError):
                        warnings.append(f"标题/摘要翻译失败：{localize_result}")
                    else:
                        if localize_result.get("title"):
                            display_title = localize_result["title"]
                        if localize_result.get("summary") is not None:
                            display_summary = localize_result["summary"]

            try:
                analyze_result = analyze_subtitles_with_deepseek(
                    subtitles,
                    clip_length=clip_length_est,
                    translation_brief=translation_brief or None,
                )
                stars = analyze_result["stars"]
                voca_size = analyze_result["voca_size"]
                highlight_count = analyze_result["highlight_count"]
            except Exception as exc:
                warnings.append(f"字幕难度/词汇分析失败：{exc}")
    else:
        warnings.append("未找到英文字幕 VTT，请稍后手动导入")

    clip_length = float(max((s["end"] for s in subtitles), default=fetched.duration or 0))

    if len(display_summary) > 2000:
        display_summary = display_summary[:1997].rstrip() + "..."

    return {
        "title": display_title,
        "summary": display_summary,
        "author_name": fetched.author_name,
        "original_video_url": fetched.webpage_url,
        "cover": uploads.get("cover", ""),
        "thumbnail_url": uploads.get("thumbnail_url", ""),
        "video_url": uploads.get("video_url", ""),
        "audio_url": uploads.get("audio_url", ""),
        "subtitles": subtitles,
        "subtitle_count": len(subtitles),
        "clip_length": clip_length,
        "had_chinese": had_chinese,
        "translated_count": translated_count,
        "ipa_count": ipa_count,
        "stars": stars,
        "voca_size": voca_size,
        "highlight_count": highlight_count,
        "source_id": fetched.source_id,
        "warnings": warnings,
    }


def fetch_and_upload_from_url(
    url: str,
    *,
    slug: str = "",
    enrich_subtitles: bool = True,
    quality: str = "720",
) -> dict:
    fetched = download_source_media(url, write_subtitles=enrich_subtitles, quality=quality)
    try:
        folder = slug.strip() or fetched.source_id or sanitize_slug(fetched.title)
        folder = sanitize_slug(folder)
        return upload_fetched_media(fetched, slug=folder, enrich_subtitles=enrich_subtitles)
    finally:
        shutil.rmtree(fetched.work_dir, ignore_errors=True)
