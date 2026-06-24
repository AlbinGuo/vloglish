from pydantic import BaseModel


class AuthorOut(BaseModel):
    name: str
    gender: str
    nationality: str
    accent: str


class TagOut(BaseModel):
    id: int
    name: str


class EpisodeSummaryOut(BaseModel):
    index: int
    video_id: str
    short_title: str
    summary: str
    stars: int
    voca_size: int
    subtitle_count: int
    clip_length: float
    cover: str
    author: AuthorOut
    tags: list[TagOut]
    created_at: str = ""
    is_learned: bool = False
    is_favorite: bool = False
    remark: str = ""


class SubtitleOut(BaseModel):
    id: int
    index: int
    start: float
    end: float
    english: str
    chinese: str
    ipa: str
    english_html: str


class EpisodeDetailOut(BaseModel):
    index: int
    video_id: str
    short_title: str
    summary: str
    remark: str
    stars: int
    voca_size: int
    subtitle_count: int
    original_video_url: str
    author: AuthorOut
    tags: list[TagOut]
    media: dict
    subtitles: list[SubtitleOut]


class EpisodeDetailResponse(BaseModel):
    episode: EpisodeDetailOut
    total_episodes: int


class DemoVerifyIn(BaseModel):
    code: str
    device_id: str


class DemoVerifyOut(BaseModel):
    success: bool
    message: str
    affiliate_code: str | None = None


class EpisodeListResponse(BaseModel):
    count: int
    results: list[EpisodeSummaryOut]


class EntryBriefOut(BaseModel):
    id: int
    headword: str
    forms: str
    category: str
    exam_tags: list


class EntriesResponse(BaseModel):
    entries: list[EntryBriefOut]
