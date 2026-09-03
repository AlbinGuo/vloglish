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

export type ArticleListOut = {
  count: number
  next: string | null
  results: ArticleListItem[]
}

export function listArticles(page = 1, pageSize = 20) {
  const q = `page=${page}&page_size=${pageSize}&ordering=-published_at`
  return request<ArticleListOut>({
    url: `/api/articles/?${q}`,
    auth: true,
  })
}
