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
    activation_code: str = Field(min_length=1, max_length=64)


class LoginIn(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


class RefreshIn(BaseModel):
    refresh: str


class ForgotPasswordIn(BaseModel):
    email: EmailStr


class ForgotPasswordOut(BaseModel):
    message: str
    reset_url: str | None = None
    reset_token: str | None = None


class ResetPasswordIn(BaseModel):
    token: str = Field(min_length=1, max_length=128)
    password: str = Field(min_length=8, max_length=128)


class ResetPasswordByEmailIn(BaseModel):
    email: EmailStr
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
    learning_active_7d: int = 0
    learning_completions_total: int = 0
    learning_lookups_total: int = 0
    online_users_now: int = 0


class AdminPresenceOnlineOut(BaseModel):
    online_users: int
    window_sec: int


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
    last_active_at: str | None = None
    watch_time_7d: int = 0
    completed_episodes: int = 0
    lookup_count: int = 0
    signup_country: str | None = None
    signup_region: str | None = None
    signup_city: str | None = None


class AdminUserGeoStatItemOut(BaseModel):
    region: str
    count: int


class AdminUserGeoStatsOut(BaseModel):
    total_users: int
    known_users: int
    unknown_users: int
    by_region: list[AdminUserGeoStatItemOut]


class AdminUserSegmentOut(BaseModel):
    key: str
    label: str
    count: int


class AdminUserSegmentsOut(BaseModel):
    segments: list[AdminUserSegmentOut]


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
    index: int
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
    tag_names: list[str] = []
    created_at: str
    play_count: int = 0
    unique_learners: int = 0
    completions: int = 0
    completion_rate: float = 0
    plays_7d: int = 0
    plays_30d: int = 0


class AdminEpisodeListOut(BaseModel):
    count: int
    results: list[AdminEpisodeListItemOut]


class AdminNextEpisodeIndexOut(BaseModel):
    next_index: int


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
    progress_percent: float = 0
    is_new: bool = False
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


class EpisodeProgressOut(BaseModel):
    video_id: str
    last_subtitle_index: int
    last_position_sec: float
    max_reached_index: int
    watch_time_sec: int
    completion_percent: float
    is_completed: bool
    last_watched_at: str
    completed_at: str | None = None


class EpisodeProgressUpdateIn(BaseModel):
    last_subtitle_index: int | None = Field(default=None, ge=0)
    last_position_sec: float | None = Field(default=None, ge=0)
    max_reached_index: int | None = Field(default=None, ge=0)
    watch_time_delta_sec: int = Field(default=0, ge=0)
    heard_subtitle_id: int | None = Field(default=None, ge=1)
    is_completed: bool = False
    session_id: int | None = None
    session_lookups_delta: int = Field(default=0, ge=0)
    session_replays_delta: int = Field(default=0, ge=0)
    playback_rate: float | None = Field(default=None, ge=0.25, le=3)
    subtitle_mode: str | None = None
    loop_mode: str | None = None


class LearningSummaryOut(BaseModel):
    total_watch_time_sec: int
    completed_episodes: int
    in_progress_episodes: int
    vocabulary_count: int
    lookup_count: int
    learning_days: int
    streak_days: int
    today_watch_time_sec: int
    today_completed: int
    week_watch_time_sec: int


class RecentEpisodeOut(BaseModel):
    video_id: str
    short_title: str
    cover: str
    completion_percent: float
    is_completed: bool
    last_subtitle_index: int
    last_watched_at: str


class VocabularyItemOut(BaseModel):
    id: int
    entry_id: int
    word: str
    token_type: int
    source_video_id: str
    source_episode_title: str
    created_at: str


class VocabularySaveIn(BaseModel):
    entry_id: int = Field(ge=1)
    word: str = Field(min_length=1, max_length=256)
    token_type: int = Field(default=1, ge=1, le=2)
    video_id: str = ""
    episode_id: int | None = None
    subtitle_id: int | None = None


class WordLookupOut(BaseModel):
    id: int
    entry_id: int
    word: str
    token_type: int
    context: str
    video_id: str
    episode_title: str
    is_saved: bool
    looked_up_at: str


class WordLookupListOut(BaseModel):
    count: int
    results: list[WordLookupOut]


class LearningSessionStartIn(BaseModel):
    video_id: str = Field(min_length=1, max_length=32)
    subtitle_mode: str = "both"
    loop_mode: str = "off"


class LearningSessionOut(BaseModel):
    id: int
    video_id: str
    started_at: str


class SubtitleProgressOut(BaseModel):
    subtitle_id: int
    heard_count: int
    is_marked_learned: bool
    last_heard_at: str


class SubtitleProgressListOut(BaseModel):
    results: list[SubtitleProgressOut]


class SubtitleProgressUpdateIn(BaseModel):
    is_marked_learned: bool | None = None


class LearningCalendarOut(BaseModel):
    days: list[dict]


class AdminLearningStatsOut(BaseModel):
    active_learners_7d: int
    active_learners_30d: int
    total_watch_hours: float
    total_completions: int
    total_lookups: int
    total_vocabulary_items: int
    top_episodes: list[dict]
    daily_activity: list[dict]


class AdminTecoAuthStatusOut(BaseModel):
    configured: bool
    session_file: str
    has_session_file: bool
    has_access_token: bool
    has_email_password: bool
    ffmpeg_configured: bool = False
    ffmpeg_dir: str = ""
    has_ffmpeg: bool = False
    has_ffprobe: bool = False


class AdminTecoCatalogItemOut(BaseModel):
    video_id: str
    index: int | None = None
    short_title: str
    stars: int = 3
    clip_length: float = 0
    subtitle_count: int = 0
    cover_preview: str = ""
    exists_in_db: bool = False
    episode_db_id: int | None = None
    qiniu_has_video: bool = False


class AdminTecoCatalogOut(BaseModel):
    index_from: int
    index_to: int
    count: int
    results: list[AdminTecoCatalogItemOut]


class AdminTecoImportEpisodeIn(BaseModel):
    video_id: str = Field(min_length=8, max_length=32)
    index: int | None = None
    short_title: str = ""
    status: str = Field(default="published", pattern=EPISODE_STATUS_PATTERN)
    skip_existing: bool = True
    apply_branding: bool = True
    media_mode: str = Field(default="full", pattern="^(full|qiniu_only)$")


class AdminTecoImportEpisodeOut(BaseModel):
    video_id: str
    skipped: bool = False
    created: bool = False
    subtitle_count: int = 0
    cover_url: str = ""
    video_url: str = ""
    warnings: list[str] = []
    message: str = ""


class AdminTecoImportRangeIn(BaseModel):
    index_from: int = Field(default=150, ge=1)
    index_to: int = Field(default=190, ge=1)
    status: str = Field(default="published", pattern=EPISODE_STATUS_PATTERN)
    skip_existing: bool = True
    apply_branding: bool = True
    media_mode: str = Field(default="full", pattern="^(full|qiniu_only)$")


class AdminTecoImportRangeOut(BaseModel):
    index_from: int
    index_to: int
    total: int
    created: int
    updated: int
    skipped: int
    failed: int
    results: list[AdminTecoImportEpisodeOut]
    errors: list[str]


class AdminTecoSyncDbFromQiniuIn(BaseModel):
    index_from: int = Field(default=150, ge=1)
    index_to: int = Field(default=190, ge=1)
    status: str = Field(default="published", pattern=EPISODE_STATUS_PATTERN)
    skip_existing: bool = True
    force_update: bool = False
