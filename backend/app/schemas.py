from pydantic import BaseModel, EmailStr, Field

EPISODE_STATUS_PATTERN = "^(draft|published|archived|rejected)$"


class UserOut(BaseModel):
    id: int
    email: str
    nickname: str | None = None
    phone: str | None = None
    is_member: bool


class AuthTokensOut(BaseModel):
    access: str
    refresh: str
    user: UserOut


class RegisterIn(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class LoginIn(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


class RefreshIn(BaseModel):
    refresh: str


class ActivateIn(BaseModel):
    code: str = Field(min_length=1, max_length=64)


class ForgotPasswordIn(BaseModel):
    email: EmailStr


class ForgotPasswordOut(BaseModel):
    message: str
    reset_url: str | None = None


class ResetPasswordIn(BaseModel):
    token: str = Field(min_length=1, max_length=128)
    password: str = Field(min_length=8, max_length=128)


class AdminUserOut(BaseModel):
    id: int
    email: str
    nickname: str | None = None
    phone: str | None = None
    is_member: bool
    is_staff: bool


class AdminAuthTokensOut(BaseModel):
    access: str
    refresh: str
    user: AdminUserOut


class AdminEpisodeImportIn(BaseModel):
    episodes: list[dict] = []
    details: list[dict] = []
    default_status: str = Field(default="draft", pattern=EPISODE_STATUS_PATTERN)
    mark_demo: bool = False


class AdminEpisodeImportOut(BaseModel):
    created: int
    updated: int
    total: int
    video_ids: list[str]
    errors: list[str]


class AdminDemoCodeOut(BaseModel):
    id: int
    code: str
    affiliate_code: str | None = None
    active: bool
    episode_count: int


class AdminDemoCodeListOut(BaseModel):
    results: list[AdminDemoCodeOut]


class AdminDemoEpisodeBriefOut(BaseModel):
    id: int
    video_id: str
    short_title: str
    status: str


class AdminDemoCodeDetailOut(AdminDemoCodeOut):
    episodes: list[AdminDemoEpisodeBriefOut]
    episode_ids: list[int]


class AdminDemoCodeCreateIn(BaseModel):
    code: str = Field(min_length=1, max_length=64)
    affiliate_code: str | None = None
    active: bool = True
    episode_ids: list[int] = []


class AdminDemoCodeUpdateIn(BaseModel):
    affiliate_code: str | None = None
    active: bool | None = None
    episode_ids: list[int] | None = None


class AdminDashboardOut(BaseModel):
    users_total: int
    users_today: int
    members_total: int
    episodes_total: int
    episodes_published: int
    episodes_draft: int
    episodes_missing_media: int
    activation_codes_total: int
    activation_codes_available: int
    activation_codes_used: int


class AdminActivationCodeOut(BaseModel):
    id: int
    code: str
    used_by_user_id: int | None = None
    used_by_email: str | None = None
    used_at: str | None = None
    created_at: str


class AdminActivationCodeListOut(BaseModel):
    count: int
    results: list[AdminActivationCodeOut]


class AdminGenerateCodesIn(BaseModel):
    count: int = Field(default=1, ge=1, le=500)


class AdminGenerateCodesOut(BaseModel):
    codes: list[str]


class AdminUserListItemOut(BaseModel):
    id: int
    email: str
    nickname: str | None = None
    phone: str | None = None
    is_member: bool
    is_active: bool
    is_staff: bool
    member_activated_at: str | None = None
    created_at: str


class AdminUserListOut(BaseModel):
    count: int
    results: list[AdminUserListItemOut]


class AdminUserUpdateIn(BaseModel):
    is_member: bool | None = None
    is_active: bool | None = None
    nickname: str | None = None
    phone: str | None = None


class AdminAuthorIn(BaseModel):
    name: str = Field(min_length=1, max_length=128)
    gender: str = Field(default="m", max_length=1)
    nationality: str = Field(default="", max_length=16)
    accent: str = Field(default="", max_length=32)


class AdminSubtitleIn(BaseModel):
    index: int = Field(ge=0)
    start: float = Field(ge=0)
    end: float = Field(ge=0)
    english: str
    chinese: str = ""
    ipa: str = ""
    english_html: str = ""


class AdminEpisodeCreateIn(BaseModel):
    video_id: str | None = Field(default=None, max_length=32)
    index: int = 0
    short_title: str = Field(min_length=1, max_length=256)
    summary: str = ""
    remark: str = ""
    stars: int = Field(default=3, ge=1, le=5)
    voca_size: int = Field(default=0, ge=0)
    cover: str = ""
    video_url: str = ""
    audio_url: str = ""
    thumbnail_url: str = ""
    original_video_url: str = ""
    is_demo: bool = False
    status: str = Field(default="draft", pattern=EPISODE_STATUS_PATTERN)
    rejection_reason: str = ""
    author: AdminAuthorIn
    tag_names: list[str] = []
    subtitles: list[AdminSubtitleIn] = []


class AdminEpisodeUpdateIn(BaseModel):
    index: int | None = None
    short_title: str | None = Field(default=None, min_length=1, max_length=256)
    summary: str | None = None
    remark: str | None = None
    stars: int | None = Field(default=None, ge=1, le=5)
    voca_size: int | None = Field(default=None, ge=0)
    cover: str | None = None
    video_url: str | None = None
    audio_url: str | None = None
    thumbnail_url: str | None = None
    original_video_url: str | None = None
    is_demo: bool | None = None
    status: str | None = Field(default=None, pattern=EPISODE_STATUS_PATTERN)
    rejection_reason: str | None = None
    author: AdminAuthorIn | None = None
    tag_names: list[str] | None = None
    subtitles: list[AdminSubtitleIn] | None = None


class AdminEpisodeListItemOut(BaseModel):
    id: int
    video_id: str
    short_title: str
    stars: int
    status: str
    subtitle_count: int
    clip_length: float
    author_name: str
    cover: str
    is_demo: bool
    is_user_submitted: bool = False
    created_at: str


class AdminEpisodeListOut(BaseModel):
    count: int
    results: list[AdminEpisodeListItemOut]


class AdminEpisodeDetailOut(BaseModel):
    id: int
    video_id: str
    index: int
    short_title: str
    summary: str
    remark: str
    stars: int
    voca_size: int
    subtitle_count: int
    clip_length: float
    cover: str
    video_url: str
    audio_url: str
    thumbnail_url: str
    original_video_url: str
    is_demo: bool
    status: str
    rejection_reason: str = ""
    is_user_submitted: bool = False
    author: AdminAuthorIn
    tag_names: list[str]
    subtitles: list[AdminSubtitleIn]
    created_at: str


class AdminVttImportIn(BaseModel):
    vtt_text: str = Field(min_length=1)


class AdminVttImportOut(BaseModel):
    subtitles: list[AdminSubtitleIn]
    subtitle_count: int
    clip_length: float
    had_chinese: bool = False
    translated_count: int = 0
    ipa_count: int = 0


class AdminFetchMediaIn(BaseModel):
    url: str = Field(min_length=8)
    slug: str = Field(default="", max_length=64)
    enrich_subtitles: bool = True


class AdminFetchMediaOut(BaseModel):
    title: str
    summary: str = ""
    author_name: str = ""
    original_video_url: str
    cover: str
    thumbnail_url: str
    video_url: str
    audio_url: str
    subtitles: list[AdminSubtitleIn]
    subtitle_count: int
    clip_length: float
    had_chinese: bool = False
    translated_count: int = 0
    ipa_count: int = 0
    stars: int = 3
    voca_size: int = 0
    highlight_count: int = 0
    source_id: str = ""
    warnings: list[str] = []


class UserEpisodeSubmitIn(BaseModel):
    accent: str = Field(min_length=1, max_length=32)
    title: str = Field(min_length=1, max_length=256)
    summary: str = ""
    author_name: str = ""
    stars: int = Field(default=3, ge=1, le=5)
    voca_size: int = Field(default=0, ge=0)
    original_video_url: str = Field(min_length=8)
    cover: str = ""
    thumbnail_url: str = ""
    video_url: str = Field(min_length=1)
    audio_url: str = ""
    subtitles: list[AdminSubtitleIn] = []


class UserEpisodeSubmitOut(BaseModel):
    video_id: str
    short_title: str
    status: str
    message: str = "提交成功，审核通过后将出现在目录中"


class AdminTagOut(BaseModel):
    id: int
    name: str
    episode_count: int = 0


class AdminTagCreateIn(BaseModel):
    name: str = Field(min_length=1, max_length=64)


class AdminTagUpdateIn(BaseModel):
    name: str = Field(min_length=1, max_length=64)


class AdminTagMergeIn(BaseModel):
    target_id: int = Field(ge=1)


class AdminAuthorOut(BaseModel):
    id: int
    name: str
    gender: str
    nationality: str
    accent: str
    episode_count: int = 0


class AdminAuthorCreateIn(BaseModel):
    name: str = Field(min_length=1, max_length=128)
    gender: str = Field(default="m", max_length=1)
    nationality: str = Field(default="", max_length=16)
    accent: str = Field(default="", max_length=32)


class AdminAuthorUpdateIn(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=128)
    gender: str | None = Field(default=None, max_length=1)
    nationality: str | None = Field(default=None, max_length=16)
    accent: str | None = Field(default=None, max_length=32)


class AdminAuthorMergeIn(BaseModel):
    target_id: int = Field(ge=1)


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


class NotificationOut(BaseModel):
    id: int
    type: str
    title: str
    body: str
    episode_id: int | None = None
    video_id: str | None = None
    is_read: bool
    created_at: str


class NotificationListOut(BaseModel):
    count: int
    unread_count: int
    results: list[NotificationOut]


class UnreadCountOut(BaseModel):
    unread_count: int


class AdminBroadcastCreateIn(BaseModel):
    title: str = Field(min_length=1, max_length=256)
    body: str = Field(min_length=1)


class AdminBroadcastOut(BaseModel):
    id: int
    title: str
    body: str
    recipient_count: int
    created_by_email: str = ""
    created_at: str


class AdminBroadcastListOut(BaseModel):
    count: int
    results: list[AdminBroadcastOut]
