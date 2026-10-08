import api from './client'
import { cacheWordLookupEntry, fetchWordLookup, type WordLookupMeta } from '@/composables/useWordLookupCache'
import type {
  AuthorCatalogItem,
  EntryDetail,
  EpisodeDetail,
  EpisodeSummary,
  SeriesDetail,
  SeriesSummary,
  Tag,
} from '@/types'


export interface EpisodeListParams {
  page?: number
  page_size?: number
  offset?: number
  stars?: number
  accent?: string
  accents?: string
  gender?: string
  tag?: number
  tags?: string
  series_id?: number
  series_slug?: string
  author_id?: number
  date?: string
  /** lt3: <3分钟；lt8: >3分钟且<8分钟；gt8: >8分钟 */
  duration?: 'lt3' | 'lt8' | 'gt8'
  status?: 'all' | 'learned' | 'unlearned' | 'favorite'
  ordering?: string
  search?: string
  /** 逗号分隔，指定卡片（可含合集内视频） */
  video_ids?: string
}

export interface EpisodeListResponse {
  count: number
  results: EpisodeSummary[]
}

export async function getEpisodeList(params: EpisodeListParams = {}) {
  const { data } = await api.get<EpisodeListResponse>('/api/episode-list/', { params })
  return data
}

export async function getEpisodeTags() {
  const { data } = await api.get<Tag[]>('/api/episode-tags/')
  return data
}

/** 主题标签（按访问热度排序；不传 limit 则返回全部） */
export async function getPopularEpisodeTags(limit?: number) {
  const { data } = await api.get<Tag[]>('/api/episode-tags/', {
    params: {
      sort: 'popular',
      ...(limit != null ? { limit } : {}),
    },
  })
  return data
}

export async function getAuthorAccents() {
  const { data } = await api.get<{ accent: string }[]>('/api/author-accents/')
  return data.map((a) => a.accent)
}

export interface AuthorCatalogParams {
  accents?: string
  gender?: string
  stars?: number
  tags?: string
  date?: string
  duration?: 'lt3' | 'lt8' | 'gt8'
  status?: 'all' | 'learned' | 'unlearned' | 'favorite'
  search?: string
}

export async function getAuthorsCatalog(params: AuthorCatalogParams = {}) {
  const { data } = await api.get<{ count: number; results: AuthorCatalogItem[] }>('/api/authors/', {
    params,
  })
  return data
}

export async function getAuthorDetail(authorId: number) {
  const { data } = await api.get<AuthorCatalogItem>(`/api/authors/${authorId}/`)
  return data
}

export async function getEpisodeDetail(videoId: string) {
  const { data } = await api.get<{ episode: EpisodeDetail; total_episodes: number }>(
    `/api/episode/${videoId}/detail/`,
  )
  return data
}

export async function generateSubtitleLiteral(videoId: string, subtitleId: number) {
  const { data } = await api.post<{
    chinese_literal: string
    glossary: { en: string; zh: string }[]
    hits: { en: string; zh: string }[]
  }>(`/api/episode/${videoId}/subtitles/${subtitleId}/literal/`, {}, { timeout: 60000 })
  return data
}

export interface EpisodeWordCardDto {
  word: string
  type: 1 | 2
  context: string
  highlight: string | null
  subtitle_id?: number | null
  type_label: string
  exam_tags: string[]
  ipa: string
  meaning: string
  entry: EntryDetail
}

export interface EpisodeWordCardsResponse {
  video_id: string
  from_cache: boolean
  count: number
  cards: EpisodeWordCardDto[]
}

/** 整集词卡（服务端共享缓存，首次生成后其他用户直接读缓存） */
export async function getEpisodeWordCards(videoId: string, opts?: { cacheOnly?: boolean }) {
  const { data } = await api.get<EpisodeWordCardsResponse>(`/api/episode/${videoId}/word-cards/`, {
    params: opts?.cacheOnly ? { cache_only: true } : undefined,
  })
  return data
}

/** 用已生成的整集词卡预热查词内存缓存，不触发 DeepSeek 重建 */
export async function warmEpisodeWordLookups(videoId: string) {
  const id = videoId.trim()
  if (!id) return
  try {
    const data = await getEpisodeWordCards(id, { cacheOnly: true })
    for (const card of data.cards || []) {
      if (card.entry) {
        cacheWordLookupEntry(card.entry, card.word, card.type, card.context || '')
      }
    }
  } catch {
    // 预热失败不影响播放
  }
}

export async function getSeriesList() {
  const { data } = await api.get<{ count: number; results: SeriesSummary[] }>('/api/series/')
  return data
}

export async function getSeriesDetail(slug: string) {
  const { data } = await api.get<SeriesDetail>(`/api/series/${slug}/`)
  return data
}

export async function getEnglishNavCounts() {
  const { data } = await api.get<{ videos: number; series: number; articles: number }>(
    '/api/english/nav-counts/',
  )
  return data
}

export async function getEnglishNavNew() {
  const { data } = await api.get<{
    series: number
    articles: number
    has_series_new?: boolean
    has_articles_new?: boolean
  }>('/api/english/nav-new/')
  return data
}

export async function setEpisodeFavorite(videoId: string, favorite: boolean) {
  if (favorite) {
    const { data } = await api.post<{ success: boolean; is_favorite: boolean }>(
      `/api/episodes/${videoId}/favorite/`,
    )
    return data
  }
  const { data } = await api.delete<{ success: boolean; is_favorite: boolean }>(
    `/api/episodes/${videoId}/favorite/`,
  )
  return data
}

export async function setAuthorSubscribe(authorId: number, subscribed: boolean) {
  if (subscribed) {
    const { data } = await api.post<{
      success: boolean
      is_subscribed: boolean
      subscriber_count: number
    }>(`/api/authors/${authorId}/subscribe/`)
    return data
  }
  const { data } = await api.delete<{
    success: boolean
    is_subscribed: boolean
    subscriber_count: number
  }>(`/api/authors/${authorId}/subscribe/`)
  return data
}

export async function getEntryDetail(entryId: number) {
  const { fetchEntryById } = await import('@/composables/useWordLookupCache')
  const entry = await fetchEntryById(entryId)
  if (!entry) throw new Error('Entry not found')
  return entry
}

export async function lookupWord(
  word: string,
  type: 1 | 2,
  context: string,
  meta?: { video_id?: string; subtitle_id?: number; episode_id?: number },
) {
  const entry = await fetchWordLookup(word, type, context, meta satisfies WordLookupMeta)
  if (!entry) throw new Error('查词失败')
  return entry
}

export interface SubmitEpisodePayload {
  original_video_url: string
  accent?: string
  note?: string
}

export interface SubmitEpisodeResult {
  video_id: string
  short_title: string
  status: string
  message: string
}

export interface UserSubmissionItem {
  video_id: string
  short_title: string
  original_video_url: string
  status: string
  rejection_reason: string
  created_at: string
  has_media: boolean
  accent: string
  cover: string
}

export async function submitUserEpisode(payload: SubmitEpisodePayload) {
  const { data } = await api.post<SubmitEpisodeResult>('/api/episodes/submit/', payload)
  return data
}

export async function listMySubmissions() {
  const { data } = await api.get<{ count: number; results: UserSubmissionItem[] }>(
    '/api/episodes/submit/',
  )
  return data
}

export async function getMyCorpusBadge() {
  const { data } = await api.get<{ count: number; has_new: boolean }>(
    '/api/episodes/submit/badge/',
  )
  return data
}

export async function markMyCorpusSeen() {
  const { data } = await api.post<{ success: boolean }>('/api/episodes/submit/seen/')
  return data
}

/** @deprecated 使用 lookupWord */
export async function lookupToken(id: number, type: 1 | 2) {
  return lookupWord(String(id), type, '')
}
