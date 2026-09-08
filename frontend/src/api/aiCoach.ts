import api, { getDeviceId } from './client'
import { getAccessToken } from './tokens'
import { randomUUID } from '@/utils/randomId'

export interface AiQuota {
  is_member: boolean
  limit: number | null
  used: number
  remaining: number | null
}

/** 查询今日 AI 免费额度（不消耗） */
export async function fetchAiQuota() {
  const { data } = await api.get<AiQuota>('/api/ai/quota/')
  return data
}

export interface AiExplainResult {
  video_id: string
  subtitle_id: number
  english: string
  chinese: string
  plain_chinese: string
  structure: string
  expressions: { en: string; zh: string }[]
  paraphrase: string
  tip: string
  from_cache?: boolean
  quota?: AiQuota | null
}

export type AiExplainStreamEvent =
  | {
      type: 'meta'
      video_id: string
      subtitle_id: number
      english: string
      chinese: string
      from_cache?: boolean
      quota?: AiQuota | null
    }
  | { type: 'field'; key: keyof AiExplainResult | string; value: unknown }
  | { type: 'done'; result: AiExplainResult }
  | { type: 'error'; detail: string }

export interface AiClozeResult {
  video_id: string
  subtitle_id: number
  english: string
  chinese: string
  blanks: string[]
  hint: string
  from_cache?: boolean
  quota?: AiQuota | null
}

export interface AiShadowingWordScore {
  char: string
  score: number
}

export interface AiShadowingResult {
  video_id: string
  subtitle_id: number
  english: string
  transcript: string
  score: number
  level: string
  praise: string
  issues: string[]
  tips: string[]
  /** oral = 阿里云口语评测；llm = ASR 文本 + AI 点评 */
  engine?: 'oral' | 'llm' | string
  mode?: 'word' | 'sentence' | 'passage' | string
  core_type?: string
  accuracy?: number
  fluency?: number
  rhythm?: number
  integrity?: number | null
  words?: AiShadowingWordScore[]
  audio_url?: string
  /** 落库后的练习记录 id，便于前端补传本地录音 */
  practice_record_id?: number
  practice_audio_url?: string
  quota?: AiQuota
}

export interface DailyPathResult {
  continue_item: {
    kind: string
    video_id: string
    title: string
    cover: string
    completion_percent?: number
    reason: string
  } | null
  recommend: {
    kind: string
    video_id: string
    title: string
    cover: string
    reason: string
  }[]
  today_sentence: {
    day: string
    video_id: string
    subtitle_id: number
    english: string
    chinese: string
    cover: string
    episode_title: string
    completed: boolean
    path: string
    streak_days: number
  } | null
  vocab_preview: { word: string; meaning: string; path: string }[]
  vocab_review: {
    available: boolean
    count: number
    path: string
    reason: string
  }
  tips: string[]
  daily_streak: number
}

export interface ReadingQaResult {
  article_id: string
  segment_id: number | null
  answer: string
  quiz: { q: string; a: string }[]
  key_phrases: { en: string; zh: string }[]
  quota?: AiQuota
}

export interface VocabReviewCard {
  word: string
  prompt: string
  answer: string
  example: string
  example_zh: string
}

export async function aiExplainSubtitle(videoId: string, subtitleId: number, force = false) {
  const { data } = await api.post<AiExplainResult>('/api/ai/explain-subtitle/', {
    video_id: videoId,
    subtitle_id: subtitleId,
    force,
  })
  return data
}

/** 流式讲解：字段就绪即回调；返回最终完整结果。 */
export async function aiExplainSubtitleStream(
  videoId: string,
  subtitleId: number,
  options: {
    force?: boolean
    signal?: AbortSignal
    onEvent?: (event: AiExplainStreamEvent) => void
  } = {},
): Promise<AiExplainResult> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    Accept: 'text/event-stream',
    'X-Device-Id': getDeviceId(),
    'X-Timestamp': String(Math.floor(Date.now() / 1000)),
    'X-Nonce': randomUUID(),
  }
  const token = getAccessToken()
  if (token) headers.Authorization = `Bearer ${token}`

  const res = await fetch('/api/ai/explain-subtitle/stream/', {
    method: 'POST',
    headers,
    credentials: 'include',
    signal: options.signal,
    body: JSON.stringify({
      video_id: videoId,
      subtitle_id: subtitleId,
      force: Boolean(options.force),
    }),
  })

  if (!res.ok) {
    let detail = '讲解失败，请稍后重试'
    try {
      const errBody = await res.json()
      if (typeof errBody?.detail === 'string') detail = errBody.detail
    } catch {
      /* ignore */
    }
    throw new Error(detail)
  }

  const reader = res.body?.getReader()
  if (!reader) throw new Error('浏览器不支持流式响应')

  const decoder = new TextDecoder()
  let buffer = ''
  let finalResult: AiExplainResult | null = null

  const handleData = (raw: string) => {
    let event: AiExplainStreamEvent
    try {
      event = JSON.parse(raw) as AiExplainStreamEvent
    } catch {
      return
    }
    options.onEvent?.(event)
    if (event.type === 'error') {
      throw new Error(event.detail || '讲解失败，请稍后重试')
    }
    if (event.type === 'done') {
      finalResult = event.result
    }
  }

  while (true) {
    const { done, value } = await reader.read()
    if (done) break
    buffer += decoder.decode(value, { stream: true })
    const parts = buffer.split('\n')
    buffer = parts.pop() || ''
    for (const line of parts) {
      const trimmed = line.trim()
      if (!trimmed.startsWith('data:')) continue
      handleData(trimmed.slice(5).trim())
    }
  }
  const tail = buffer.trim()
  if (tail.startsWith('data:')) {
    handleData(tail.slice(5).trim())
  }

  if (!finalResult) throw new Error('讲解未完成，请稍后重试')
  return finalResult
}

export async function aiGenerateCloze(videoId: string, subtitleId: number, force = false) {
  const { data } = await api.post<AiClozeResult>(
    '/api/ai/generate-cloze/',
    {
      video_id: videoId,
      subtitle_id: subtitleId,
      force,
    },
    { timeout: 60000 },
  )
  return data
}

export async function aiShadowingFeedback(videoId: string, subtitleId: number, transcript: string) {
  const { data } = await api.post<AiShadowingResult>('/api/ai/shadowing-feedback/', {
    video_id: videoId,
    subtitle_id: subtitleId,
    transcript,
  })
  return data
}

export async function aiDailyPath() {
  const { data } = await api.get<DailyPathResult>('/api/ai/daily-path/')
  return data
}

export async function aiReadingQa(payload: {
  article_id: string
  segment_id?: number | null
  question?: string
}) {
  const { data } = await api.post<ReadingQaResult>('/api/ai/reading-qa/', {
    article_id: payload.article_id,
    segment_id: payload.segment_id ?? null,
    question: payload.question || '',
  })
  return data
}

export interface VocabReviewResult {
  available: boolean
  count: number
  cards: VocabReviewCard[]
  from_cache?: boolean
  cache_hit?: boolean
  cached_at?: string | null
  message?: string
  quota?: AiQuota
}

/** generate=false 仅窥视缓存；generate=true 复用缓存或生成；force=true 强制重新生成 */
export async function aiVocabReview(generate = false, force = false) {
  const { data } = await api.get<VocabReviewResult>('/api/ai/vocab-review/', {
    params: {
      generate: generate ? 1 : 0,
      force: force ? 1 : 0,
    },
  })
  return data
}
