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
  favorite: unknown | null
}

export interface DemoVerifyResponse {
  success: boolean
  message: string
  affiliate_code: string | null
}
