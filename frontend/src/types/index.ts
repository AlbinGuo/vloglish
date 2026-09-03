export interface User {
  id: number
  email: string
  nickname: string | null
  phone: string | null
  is_member: boolean
  avatar_key?: string | null
  member_until?: string | null
  wx_bound?: boolean
  wechat_only?: boolean
}

export interface Author {
  id?: number
  name: string
  gender: 'm' | 'f'
  nationality: string
  accent: string
  is_subscribed?: boolean
  subscriber_count?: number
}

/** 首页按作者分类 / 作者详情 */
export interface AuthorCatalogItem {
  id: number
  name: string
  gender: 'm' | 'f' | string
  nationality: string
  accent: string
  episode_count: number
  covers: string[]
  is_subscribed?: boolean
  subscriber_count?: number
}

export interface Tag {
  id: number
  name: string
  visit_count?: number
}

export interface EpisodeSummary {
  index: number
  video_id: string
  short_title: string
  summary: string
  stars: number
  voca_size: number
  subtitle_count: number
  clip_length: number
  cover: string
  author: Author
  tags: Tag[]
  created_at?: string
  is_learned?: boolean
  is_favorite?: boolean
  progress_percent?: number
  is_new?: boolean
  is_pinned?: boolean
  /** 独立学习过该集的用户数 */
  learner_count?: number
  series_id?: number | null
  series_slug?: string
  series_title?: string
  series_index?: number | null
  /** 普通用户不可看，需开通会员 */
  requires_membership?: boolean
}

export interface EpisodeSeriesNav {
  id: number
  slug: string
  title: string
  series_index: number
  episode_count: number
  prev_video_id: string | null
  next_video_id: string | null
}

export interface Subtitle {
  id: number
  index: number
  start: number
  end: number
  english: string
  chinese: string
  ipa: string
  english_html: string
}

export interface EpisodeDetail {
  index: number
  video_id: string
  short_title: string
  summary: string
  stars: number
  voca_size: number
  subtitle_count: number
  original_video_url: string
  author: Author
  tags: Tag[]
  media: {
    video_url: string
    audio_url: string
    thumbnail_url: string
  }
  subtitles: Subtitle[]
  series?: EpisodeSeriesNav | null
  /** 词汇与表达汇总（已解析分组；兼容偶发原始文本） */
  vocab_summary?: VocabSummaryGroup[] | string
  /** 汇总原文（优先用此字段在前端再解析，避免旧后端只返回空数组） */
  vocab_summary_text?: string
  /** 视频语境原文（HTML / Markdown） */
  video_context?: string
  is_favorite?: boolean
}

export interface VocabSummaryItem {
  en: string
  zh: string
  note?: string
  example?: string
  level?: string
}

export interface VocabSummaryGroup {
  title: string
  items: VocabSummaryItem[]
}

export interface SeriesSummary {
  id: number
  slug: string
  title: string
  summary: string
  cover: string
  /** 叠卡用封面（最多 3 张） */
  covers?: string[]
  episode_count: number
  sort_order: number
  /** 普通用户可见合集入口，但内容需会员 */
  requires_membership?: boolean
  published_at?: string
  latest_content_at?: string
  is_new?: boolean
}

export interface SeriesDetail {
  id: number
  slug: string
  title: string
  summary: string
  cover: string
  episode_count: number
  episodes: EpisodeSummary[]
}

export interface EntryBrief {
  id: number
  headword: string
  forms: string
  category: string
  exam_tags: string[]
}

export interface EntryDefinition {
  id: number
  pos: string
  definition_en: string
  definition_cn: string
  usage_pattern: string
  note: string
  order: number
  examples: { example_en: string; example_cn: string; order: number }[]
}

export interface EntryDetail {
  id: number
  headword: string
  category: string
  pronunciations: {
    ipa: string
    audio_url: string
    accent_type: string
    is_primary: boolean
  }[]
  definitions: EntryDefinition[]
  exam_tags: string[]
  favorite: boolean
}

export interface DemoVerifyResponse {
  success: boolean
  message: string
  affiliate_code: string | null
}
