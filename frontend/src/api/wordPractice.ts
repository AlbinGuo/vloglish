import api from './client'

export type WordPracticeSource = 'vocab' | 'episode_vocab' | 'vocab_wrong'

export interface WordPracticeItem {
  vocabulary_item_id: number | null
  entry_id: number
  word: string
  ipa: string
  definition_cn: string
  source_video_id: string
  source_subtitle_id: number | null
  source_segment_id?: number | null
  context: string
  /** 例句中文（字幕/段落/词条兜底 / AI 缓存） */
  context_zh?: string
}

export interface ContextTranslateResult {
  chinese: string
  from_cache: boolean
  quota?: {
    is_member?: boolean
    limit?: number | null
    used?: number
    remaining?: number | null
  } | null
}

export interface WordPracticeSession {
  session_id: number
  source: WordPracticeSource | string
  video_id: string
  total_count: number
  items: WordPracticeItem[]
}

export interface WordPracticeFinishResult {
  session_id: number
  total_count: number
  correct_count: number
  wrong_count: number
  duration_ms: number
  chars_typed: number
  accuracy: number
}

export interface WordPracticeWrongItem {
  id: number
  entry_id: number
  vocabulary_item_id: number | null
  word: string
  wrong_count: number
  last_wrong_at: string
  ipa: string
  definition_cn: string
}

export async function startWordPractice(payload: {
  source: WordPracticeSource
  video_id?: string
  limit?: number
}) {
  const { data } = await api.post<WordPracticeSession>('/api/word-practice/sessions/', {
    source: payload.source,
    video_id: payload.video_id || '',
    limit: payload.limit ?? 15,
  })
  return data
}

export async function finishWordPractice(
  sessionId: number,
  payload: {
    results: { entry_id: number; try_count: number; had_wrong: boolean; latency_ms: number }[]
    duration_ms: number
    chars_typed: number
  },
) {
  const { data } = await api.post<WordPracticeFinishResult>(
    `/api/word-practice/sessions/${sessionId}/finish/`,
    payload,
  )
  return data
}

export async function fetchWordPracticeWrongs(limit = 100) {
  const { data } = await api.get<WordPracticeWrongItem[]>('/api/word-practice/wrongs/', {
    params: { limit },
  })
  return data
}

export async function fetchWordPracticeWrongCount() {
  const { data } = await api.get<{ count: number }>('/api/word-practice/wrongs/count/')
  return data.count
}

/** 例句缺中文时按需翻译；同一英文全站共享缓存 */
export async function translateWordPracticeContext(payload: {
  english: string
  source_subtitle_id?: number | null
  source_segment_id?: number | null
}) {
  const { data } = await api.post<ContextTranslateResult>('/api/word-practice/context-translate/', {
    english: payload.english,
    source_subtitle_id: payload.source_subtitle_id ?? undefined,
    source_segment_id: payload.source_segment_id ?? undefined,
  })
  return data
}

export interface ContextClipResult {
  source_subtitle_id: number
  video_id: string
  video_url: string
  start: number
  end: number
  english: string
  chinese: string
}

/** 按字幕拉取可播原句片段（签名 URL 即时签发） */
export async function fetchWordPracticeContextClip(sourceSubtitleId: number) {
  const { data } = await api.get<ContextClipResult>('/api/word-practice/context-clip/', {
    params: { source_subtitle_id: sourceSubtitleId },
  })
  return data
}
