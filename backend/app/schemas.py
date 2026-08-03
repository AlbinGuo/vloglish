from pydantic import BaseModel, EmailStr, Field
from datetime import datetime

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
    # 可选：运营/抖音激活码；不填则为普通用户
    activation_code: str | None = Field(default=None, max_length=64)


class ActivateMembershipIn(BaseModel):
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


class AdminDauPointOut(BaseModel):
    date: str
    dau: int


class AdminFunnelRegisterLearnOut(BaseModel):
    users_total: int
    users_learned: int
    rate: float
    registered_30d: int
    learned_among_registered_30d: int
    rate_30d: float
    first_learn_today: int = 0


class AdminFunnelMemberOut(BaseModel):
    users_total: int
    members_total: int
    rate: float
    activated_7d: int
    activated_30d: int
    registered_30d: int
    members_among_registered_30d: int
    rate_among_registered_30d: float


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
    dau_today: int = 0
    dau_trend: list[AdminDauPointOut] = []
    funnel_register_learn: AdminFunnelRegisterLearnOut | None = None
    funnel_member: AdminFunnelMemberOut | None = None


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
    is_online: bool = False
    member_activated_at: str | None = None
    activation_code: str | None = None
    created_at: str
    last_active_at: str | None = None
    watch_time_7d: int = 0
    visit_days_7d: int = 0
    visit_days_30d: int = 0
    visit_sessions_today: int = 0
    visit_sessions_7d: int = 0
    visit_sessions_30d: int = 0
    completed_episodes: int = 0
    lookup_count: int = 0
    signup_country: str | None = None
    signup_region: str | None = None
    signup_city: str | None = None


class AdminVisitHourBucketOut(BaseModel):
    hour: int
    label: str
    users: int
    sessions: int


class AdminVisitHourlyStatsOut(BaseModel):
    days: int
    timezone: str = "Asia/Shanghai"
    total_sessions: int = 0
    total_users: int = 0
    peak_hour: int | None = None
    peak_label: str | None = None
    peak_users: int = 0
    low_hour: int | None = None
    low_label: str | None = None
    low_users: int = 0
    hours: list[AdminVisitHourBucketOut]


class AdminUserGeoStatItemOut(BaseModel):
    region: str
    count: int


class AdminUserGeoNamedItemOut(BaseModel):
    name: str
    map_name: str = ""
    count: int


class AdminUserGeoCityItemOut(BaseModel):
    name: str
    province: str
    count: int


class AdminUserGeoStatsOut(BaseModel):
    total_users: int
    known_users: int
    unknown_users: int
    china_users: int = 0
    overseas_users: int = 0
    by_region: list[AdminUserGeoStatItemOut]
    by_country: list[AdminUserGeoNamedItemOut] = []
    by_province: list[AdminUserGeoNamedItemOut] = []
    by_city: list[AdminUserGeoCityItemOut] = []


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
    vocab_summary: str = ""
    video_context: str = ""
    stars: int = Field(default=3, ge=1, le=5)
    voca_size: int = Field(default=0, ge=0)
    cover: str = ""
    video_url: str = ""
    audio_url: str = ""
    thumbnail_url: str = ""
    original_video_url: str = ""
    is_demo: bool = False
    is_pinned: bool = False
    status: str = Field(default="draft", pattern=EPISODE_STATUS_PATTERN)
    rejection_reason: str = ""
    series_id: int | None = None
    series_index: int | None = Field(default=None, ge=1)
    author: AdminAuthorIn
    tag_names: list[str] = []
    subtitles: list[AdminSubtitleIn] = []


class AdminEpisodeUpdateIn(BaseModel):
    index: int | None = None
    short_title: str | None = Field(default=None, min_length=1, max_length=256)
    summary: str | None = None
    remark: str | None = None
    vocab_summary: str | None = None
    video_context: str | None = None
    stars: int | None = Field(default=None, ge=1, le=5)
    voca_size: int | None = Field(default=None, ge=0)
    cover: str | None = None
    video_url: str | None = None
    audio_url: str | None = None
    thumbnail_url: str | None = None
    original_video_url: str | None = None
    is_demo: bool | None = None
    is_pinned: bool | None = None
    status: str | None = Field(default=None, pattern=EPISODE_STATUS_PATTERN)
    rejection_reason: str | None = None
    series_id: int | None = None
    series_index: int | None = Field(default=None, ge=1)
    clear_series: bool = False
    author: AdminAuthorIn | None = None
    tag_names: list[str] | None = None
    subtitles: list[AdminSubtitleIn] | None = None
    # 用户投稿：True=全站可见；False=仅投稿者可见（仍在「我的语料库」）
    is_catalog_public: bool | None = None


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
    is_pinned: bool = False
    is_user_submitted: bool = False
    is_catalog_public: bool = False
    tag_names: list[str] = []
    series_id: int | None = None
    series_title: str = ""
    series_index: int | None = None
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
    vocab_summary: str = ""
    video_context: str = ""
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
    is_pinned: bool = False
    status: str
    rejection_reason: str = ""
    is_user_submitted: bool = False
    is_catalog_public: bool = False
    submitted_by_user_id: int | None = None
    submitted_by_email: str = ""
    submitted_by_nickname: str = ""
    series_id: int | None = None
    series_index: int | None = None
    series_title: str = ""
    author: AdminAuthorIn
    tag_names: list[str]
    subtitles: list[AdminSubtitleIn]
    created_at: str


class VocabSummaryItemOut(BaseModel):
    en: str
    zh: str = ""
    note: str = ""
    example: str = ""
    level: str = ""


class VocabSummaryGroupOut(BaseModel):
    title: str
    items: list[VocabSummaryItemOut] = []


SERIES_STATUS_PATTERN = "^(draft|published|archived)$"


class AdminSeriesCreateIn(BaseModel):
    slug: str = Field(min_length=1, max_length=64)
    title: str = Field(min_length=1, max_length=256)
    summary: str = ""
    cover: str = ""
    status: str = Field(default="draft", pattern=SERIES_STATUS_PATTERN)
    sort_order: int = 0


class AdminSeriesUpdateIn(BaseModel):
    slug: str | None = Field(default=None, min_length=1, max_length=64)
    title: str | None = Field(default=None, min_length=1, max_length=256)
    summary: str | None = None
    cover: str | None = None
    status: str | None = Field(default=None, pattern=SERIES_STATUS_PATTERN)
    sort_order: int | None = None


class AdminSeriesOut(BaseModel):
    id: int
    slug: str
    title: str
    summary: str
    cover: str
    status: str
    sort_order: int
    episode_count: int = 0
    created_at: str
    published_at: str = ""


class AdminSeriesListOut(BaseModel):
    count: int
    results: list[AdminSeriesOut]


class AdminVttImportIn(BaseModel):
    vtt_text: str = Field(min_length=1)
    title: str = Field(default="", description="剧集标题，帮助按剧情翻译")
    summary: str = Field(default="", description="剧集摘要，帮助按剧情翻译")
    translate_chinese: bool = Field(
        default=False,
        description="是否用 AI 翻译/改写中文；需 enrich_ai=True 才生效",
    )
    enrich_ai: bool = Field(
        default=False,
        description="是否调用 DeepSeek（翻译/音标/高亮）。False 时仅解析导入，秒级返回",
    )


class AdminVttImportOut(BaseModel):
    subtitles: list[AdminSubtitleIn]
    subtitle_count: int
    clip_length: float
    had_chinese: bool = False
    translated_count: int = 0
    ipa_count: int = 0
    stars: int = 3
    voca_size: int = 0
    highlight_count: int = 0
    warnings: list[str] = []
    done: bool = True
    phase: str = "done"
    remaining: int = 0


class AdminSubtitleEnrichIn(BaseModel):
    subtitles: list[AdminSubtitleIn] = Field(min_length=1)
    title: str = Field(default="", description="剧集标题，帮助按剧情翻译")
    summary: str = Field(default="", description="剧集摘要，帮助按剧情翻译")
    translate_chinese: bool = Field(
        default=False,
        description="True=AI 翻译/改写中文；False=保留现有中文，仅生成音标与高亮",
    )
    max_batches: int = Field(
        default=3,
        ge=1,
        le=20,
        description="本轮最多处理几批 DeepSeek 请求，便于长字幕分轮续跑",
    )


class AdminFetchMediaIn(BaseModel):
    url: str = Field(min_length=8)
    slug: str = Field(default="", max_length=64)
    enrich_subtitles: bool = False


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
    """用户仅提交外链；媒体与字幕由管理员手工上传。"""

    original_video_url: str = Field(min_length=8)
    accent: str = Field(default="美国", max_length=32)
    note: str = Field(default="", max_length=500)


class UserEpisodeSubmitOut(BaseModel):
    video_id: str
    short_title: str
    status: str
    message: str = "提交成功，视频将在管理员审核通过后上传语料，预计1-2个小时出审核结果~"


class UserSubmissionItemOut(BaseModel):
    video_id: str
    short_title: str
    original_video_url: str
    status: str
    rejection_reason: str = ""
    created_at: str
    has_media: bool = False
    accent: str = ""
    cover: str = ""


class UserSubmissionListOut(BaseModel):
    count: int
    results: list[UserSubmissionItemOut]


class UserCorpusBadgeOut(BaseModel):
    count: int
    has_new: bool


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
    id: int = 0
    name: str
    gender: str
    nationality: str
    accent: str


class AuthorCatalogOut(BaseModel):
    id: int
    name: str
    gender: str
    nationality: str
    accent: str
    episode_count: int
    covers: list[str] = []


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
    is_pinned: bool = False
    learner_count: int = 0
    remark: str = ""
    series_id: int | None = None
    series_slug: str = ""
    series_title: str = ""
    series_index: int | None = None


class SubtitleOut(BaseModel):
    id: int
    index: int
    start: float
    end: float
    english: str
    chinese: str
    ipa: str
    english_html: str


class EpisodeSeriesNavOut(BaseModel):
    id: int
    slug: str
    title: str
    series_index: int
    episode_count: int
    prev_video_id: str | None = None
    next_video_id: str | None = None


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
    series: EpisodeSeriesNavOut | None = None
    vocab_summary: list[VocabSummaryGroupOut] = []
    vocab_summary_text: str = ""
    video_context: str = ""


class EpisodeDetailResponse(BaseModel):
    episode: EpisodeDetailOut
    total_episodes: int


class SeriesSummaryOut(BaseModel):
    id: int
    slug: str
    title: str
    summary: str
    cover: str
    episode_count: int = 0
    sort_order: int = 0


class SeriesDetailOut(BaseModel):
    id: int
    slug: str
    title: str
    summary: str
    cover: str
    episode_count: int
    episodes: list[EpisodeSummaryOut]


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
    image_url: str = ""
    episode_id: int | None = None
    video_id: str | None = None
    article_id: str | None = None
    is_read: bool
    created_at: str


class NotificationListOut(BaseModel):
    count: int
    unread_count: int
    results: list[NotificationOut]


class UnreadCountOut(BaseModel):
    unread_count: int


class EpisodePublishedPopupOut(BaseModel):
    id: int
    type: str = "episode_published"
    title: str
    body: str
    episode_id: int | None = None
    video_id: str | None = None
    article_id: str | None = None
    episode_title: str = ""
    cover_url: str = ""
    submitted_at: str = ""
    created_at: str


class EpisodePublishedPopupListOut(BaseModel):
    results: list[EpisodePublishedPopupOut]


class AckPopupsIn(BaseModel):
    ids: list[int]


class AdminReleasePopupUserOut(BaseModel):
    user_id: int
    email: str
    nickname: str = ""
    popup_acked_at: str = ""


class AdminReleasePopupStatsOut(BaseModel):
    episode_id: int
    video_id: str
    short_title: str
    notified: bool
    release_notified_at: str = ""
    recipient_count: int = 0
    seen_count: int = 0
    unseen_count: int = 0
    seen_users: list[AdminReleasePopupUserOut] = []
    unseen_users: list[AdminReleasePopupUserOut] = []


class AdminEpisodeSubmittedPopupOut(BaseModel):
    id: int
    title: str
    body: str
    episode_id: int | None = None
    episode_title: str = ""
    original_video_url: str = ""
    submitter_email: str = ""
    submitter_nickname: str = ""
    submitted_at: str = ""
    created_at: str


class AdminEpisodeSubmittedPopupListOut(BaseModel):
    results: list[AdminEpisodeSubmittedPopupOut]


class AdminBroadcastCreateIn(BaseModel):
    title: str = Field(min_length=1, max_length=256)
    body: str = Field(min_length=1)
    image_url: str = ""


class AdminBroadcastOut(BaseModel):
    id: int
    title: str
    body: str
    image_url: str = ""
    recipient_count: int
    created_by_email: str = ""
    created_at: str


class AdminBroadcastListOut(BaseModel):
    count: int
    results: list[AdminBroadcastOut]


class AdminNotificationImageOut(BaseModel):
    image_url: str


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
    exam_tags: list[str] = []
    ipa: str = ""
    definition_cn: str = ""
    source_type: str = ""


class VocabularySaveIn(BaseModel):
    entry_id: int = Field(ge=1)
    word: str = Field(min_length=1, max_length=256)
    token_type: int = Field(default=1, ge=1, le=2)
    video_id: str = ""
    episode_id: int | None = None
    subtitle_id: int | None = None
    article_id: int | None = None
    segment_id: int | None = None
    article_ref: str = ""
    source_type: str = ""


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


ARTICLE_STATUS_PATTERN = "^(draft|published|archived)$"


class ArticleProgressUpdateIn(BaseModel):
    last_segment_index: int = Field(default=0, ge=0)
    read_time_delta_sec: int = Field(default=0, ge=0)


class ArticleProgressOut(BaseModel):
    last_segment_index: int
    max_reached_index: int
    completion_percent: float
    is_completed: bool
    last_read_at: str | None = None


class AdminArticleSegmentIn(BaseModel):
    english: str
    chinese: str = ""
    english_html: str = ""
    audio_url: str = ""
    duration_ms: int = 0


class AdminArticleTtsIn(BaseModel):
    voice: str | None = None
    max_segments: int = Field(default=8, ge=1, le=40)
    skip_existing: bool = True
    force: bool = Field(
        default=False,
        description="True 时清空已有音频后重生成；仅应在任务首轮传入",
    )


class AdminArticleTtsOut(BaseModel):
    generated: int
    failed: int
    total: int
    tts_status: str
    error_sample: str = ""
    voice: str = ""
    done: bool = True
    remaining: int = 0
    skipped: int = 0
    processed: int = 0


class AdminArticleCreateIn(BaseModel):
    article_id: str | None = None
    title: str = ""
    summary: str = ""
    source: str = ""
    source_url: str = ""
    topic: str = ""
    cover: str = ""
    stars: int = Field(default=3, ge=1, le=5)
    status: str = Field(default="draft", pattern=ARTICLE_STATUS_PATTERN)
    published_at: datetime | None = None


class AdminArticleUpdateIn(BaseModel):
    title: str | None = None
    summary: str | None = None
    source: str | None = None
    source_url: str | None = None
    topic: str | None = None
    cover: str | None = None
    stars: int | None = Field(default=None, ge=1, le=5)
    status: str | None = Field(default=None, pattern=ARTICLE_STATUS_PATTERN)
    published_at: datetime | None = None
    vocab_summary: str | None = None


class AdminArticleListItemOut(BaseModel):
    id: int
    article_id: str
    title: str
    source: str
    topic: str
    stars: int
    word_count: int
    segment_count: int
    status: str
    published_at: str
    created_at: str


class AdminArticleListOut(BaseModel):
    count: int
    results: list[AdminArticleListItemOut]


class AdminArticleDetailOut(BaseModel):
    id: int
    article_id: str
    title: str
    summary: str
    source: str
    source_url: str
    topic: str
    stars: int
    word_count: int
    segment_count: int
    cover: str
    published_at: str
    status: str
    tts_status: str = "none"
    vocab_summary: list[VocabSummaryGroupOut] = []
    vocab_summary_text: str = ""
    segments: list[AdminArticleSegmentIn]
    progress: ArticleProgressOut | None = None


class AdminArticleUploadCoverIn(BaseModel):
    source_url: str


class AdminArticleUploadCoverOut(BaseModel):
    cover: str


class AdminArticleImportTextIn(BaseModel):
    english_text: str
    auto_translate: bool = False
    auto_analyze: bool = False


class AdminArticleImportTextOut(BaseModel):
    segment_count: int
    word_count: int
    stars: int


class AdminArticleEnrichIn(BaseModel):
    translate: bool = True
    analyze: bool = True
    max_batches: int = Field(default=3, ge=1, le=20)
    force_analyze: bool = Field(
        default=False,
        description="True 时清空已有高亮后重跑分析（用于「仅重新分析词汇」）",
    )


class AdminArticleEnrichOut(BaseModel):
    segment_count: int
    word_count: int
    stars: int
    translated: bool = False
    analyzed: bool = False
    voca_size: int = 0
    highlight_count: int = 0
    annotate_failed: int = 0
    done: bool = True
    phase: str = "done"
    remaining: int = 0
    translated_count: int = 0


# ——— 用户反馈 ———

class FeedbackImageOut(BaseModel):
    image_url: str


class FeedbackCreateIn(BaseModel):
    title: str = Field(min_length=1, max_length=120)
    body: str = Field(min_length=1, max_length=4000)
    image_urls: list[str] = Field(default_factory=list, max_length=3)


class FeedbackOut(BaseModel):
    id: int
    title: str
    body: str
    image_urls: list[str] = []
    status: str
    created_at: str


class FeedbackCreateOut(BaseModel):
    id: int
    message: str = "感谢反馈，我们会尽快查看"


class AdminFeedbackOut(BaseModel):
    id: int
    user_id: int
    user_email: str = ""
    user_nickname: str = ""
    title: str
    body: str
    image_urls: list[str] = []
    status: str
    admin_note: str = ""
    created_at: str
    updated_at: str = ""


class AdminFeedbackListOut(BaseModel):
    count: int
    results: list[AdminFeedbackOut]


class AdminFeedbackUpdateIn(BaseModel):
    status: str | None = None
    admin_note: str | None = None


class MembershipPricingOut(BaseModel):
    subject: str
    amount_yuan: str
    amount_cent: int
    currency: str = "CNY"
    mock: bool = False
    description: str = "一次性付费，永久会员"


class MembershipOrderCreateIn(BaseModel):
    """须登录后下单；邮箱取当前账号，无需再传。"""
    channel: str = Field(default="page", pattern="^(page|wap)$")


class MembershipOrderOut(BaseModel):
    order_no: str
    email: str
    amount_yuan: str
    amount_cent: int
    status: str
    mock: bool = False
    pay_url: str | None = None
    return_url: str = ""
    signup_url: str | None = None
    activation_code: str | None = None
    email_is_member: bool = False
    membership_activated: bool = False
    paid_at: str | None = None
    created_at: str = ""


class AdminMembershipOrderOut(BaseModel):
    id: int
    order_no: str
    email: str
    amount_yuan: str
    amount_cent: int
    status: str
    channel: str
    alipay_trade_no: str = ""
    activation_code: str | None = None
    paid_at: str | None = None
    created_at: str = ""


class AdminMembershipOrderListOut(BaseModel):
    count: int
    results: list[AdminMembershipOrderOut]
