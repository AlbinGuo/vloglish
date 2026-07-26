import api from './client'
import { fetchWordLookup } from '@/composables/useWordLookupCache'
import type { EntryDetail } from '@/types'
export interface ArticleProgress {
  last_segment_index: number
  max_reached_index: number
  completion_percent: number
  is_completed: boolean
  last_read_at: string | null
}

export interface ArticleSummary {
  article_id: string
  title: string
  summary: string
  source: string
  topic: string
  stars: number
  word_count: number
  segment_count: number
  cover: string
  published_at: string
  progress: ArticleProgress | null
  accessible: boolean
}

export interface ArticleSegment {
  id: number
  index: number
  english: string
  chinese: string
  english_html: string
  audio_url: string
  duration_ms: number
}

export interface ArticleDetail {
  article_id: string
  title: string
  summary: string
  source: string
  source_url: string
  topic: string
  stars: number
  word_count: number
  segment_count: number
  cover: string
  published_at: string
  tts_status: string
  /** 词汇与表达汇总（已解析分组，与剧集汇总同格式） */
  vocab_summary?: import('@/utils/vocabSummary').VocabSummaryGroup[]
  vocab_summary_text?: string
  segments: ArticleSegment[]
  progress: ArticleProgress | null
}

export interface ArticleQuota {
  is_member: boolean
  monthly_limit: number | null
  opened_this_month: number
  remaining: number | null
}

export interface ArticleListResponse {
  count: number
  next: string | null
  results: ArticleSummary[]
  quota: ArticleQuota
}

export interface ContinueReadingItem {
  article_id: string
  title: string
  source: string
  cover: string
  completion_percent: number
  last_read_at: string | null
}

export interface ArticleFilters {
  sources: string[]
  topics: string[]
}

export interface ArticleListParams {
  page?: number
  page_size?: number
  source?: string
  topic?: string
  stars?: number
  status?: 'all' | 'in_progress' | 'completed'
  ordering?: string
  q?: string
}

export async function getArticleList(params: ArticleListParams = {}) {
  const { data } = await api.get<ArticleListResponse>('/api/articles/', { params })
  return data
}

export async function getArticleFilters() {
  const { data } = await api.get<ArticleFilters>('/api/articles/filters/')
  return data
}

export async function getContinueReadingArticles() {
  const { data } = await api.get<{ results: ContinueReadingItem[] }>('/api/articles/continue/')
  return data.results
}

export async function getArticleDetail(articleId: string) {
  const { data } = await api.get<ArticleDetail>(`/api/articles/${articleId}/`)
  return data
}

export async function updateArticleProgress(
  articleId: string,
  payload: { last_segment_index: number; read_time_delta_sec?: number },
) {
  const { data } = await api.patch<ArticleProgress>(`/api/articles/${articleId}/progress/`, payload)
  return data
}

export async function lookupWordInArticle(
  word: string,
  type: 1 | 2,
  context: string,
  meta: { article_id: string; segment_id?: number },
) {
  const entry = await fetchWordLookup(word, type, context, meta)
  if (!entry) throw new Error('查词失败')
  return entry
}