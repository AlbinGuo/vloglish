import { request } from '../utils/request'

export type ArticleListItem = {
  article_id: string
  title: string
  summary: string
  source: string
  topic: string
  stars: number
  word_count: number
  segment_count: number
  cover: string
  published_at: string | null
  is_new: boolean
  accessible: boolean
  progress?: {
    is_completed: boolean
    completion_percent: number
  } | null
}

export type ArticleQuota = {
  is_member: boolean
  monthly_limit: number | null
  opened_this_month: number
  remaining: number | null
}

export type ArticleListOut = {
  count: number
  next: string | null
  results: ArticleListItem[]
  quota?: ArticleQuota
}

export type ContinueArticle = {
  article_id: string
  title: string
  source: string
  cover: string
  completion_percent: number
  last_read_at: string | null
}

export function listArticles(page = 1, pageSize = 20) {
  const q = `page=${page}&page_size=${pageSize}&ordering=-published_at`
  return request<ArticleListOut>({
    url: `/api/articles/?${q}`,
    auth: true,
  })
}

export function continueReading() {
  return request<{ results: ContinueArticle[] }>({
    url: '/api/articles/continue/',
    auth: true,
  })
}

export type ArticleSegment = {
  id: number
  index: number
  english: string
  chinese: string
  english_html: string
  audio_url: string
  duration_ms: number
}

export type ArticleDetail = {
  article_id: string
  title: string
  summary: string
  source: string
  topic: string
  stars: number
  word_count: number
  segment_count: number
  cover: string
  published_at: string | null
  segments: ArticleSegment[]
  progress?: {
    last_segment_index: number
    completion_percent: number
    is_completed: boolean
  } | null
}

export function getArticle(articleId: string) {
  return request<ArticleDetail>({
    url: `/api/articles/${encodeURIComponent(articleId)}/`,
    auth: true,
  })
}

export function updateArticleProgress(articleId: string, lastSegmentIndex: number) {
  return request<void>({
    url: `/api/articles/${encodeURIComponent(articleId)}/progress/`,
    method: 'PATCH',
    data: { last_segment_index: lastSegmentIndex, read_time_delta_sec: 0 },
  })
}

export function displaySource(source: string): string {
  const t = (source || '').trim()
  if (!t || t === '用户投稿') return ''
  return t
}
