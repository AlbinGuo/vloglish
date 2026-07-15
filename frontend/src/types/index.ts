export interface User {
  id: number
  email: string
  nickname: string | null
  phone: string | null
  is_member: boolean
}

export interface Author {
  name: string
  gender: 'm' | 'f'
  nationality: string
  accent: string
}

export interface Tag {
  id: number
  name: string
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
  series_id?: number | null
  series_slug?: string
  series_title?: string
  series_index?: number | null
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
}

export interface SeriesSummary {
  id: number
  slug: string
  title: string
  summary: string
  cover: string
  episode_count: number
  sort_order: number
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
