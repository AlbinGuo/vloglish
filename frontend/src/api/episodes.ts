import api from './client'
import { fetchWordLookup, type WordLookupMeta } from '@/composables/useWordLookupCache'
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
  status?: 'all' | 'learned' | 'unlearned' | 'favorite'
  ordering?: string
  search?: string
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
export async function getEpisodeWordCards(videoId: string) {
  const { data } = await api.get<EpisodeWordCardsResponse>(`/api/episode/${videoId}/word-cards/`)
  return data
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

export interface FetchMediaResult {
  title: string
  summary: string
  author_name: string
  original_video_url: string
  cover: string
  thumbnail_url: string
  video_url: string
  audio_url: string
  subtitles: {
    index: number
    start: number
    end: number
    english: string
    chinese: string
    ipa: string
    english_html: string
  }[]
  subtitle_count: number
  clip_length: number
  had_chinese: boolean
  translated_count: number
  ipa_count: number
  stars: number
  voca_size: number
  highlight_count: number
  source_id: string
  warnings: string[]
}

export async function fetchSubmitMediaFromUrl(payload: { url: string }) {
  const { data } = await api.post<FetchMediaResult>(
    '/api/episodes/submit/fetch-media/',
    { url: payload.url, enrich_subtitles: true },
    { timeout: 900000 },
  )
  return data
}

export interface SubmitEpisodePayload {
  accent: string
  title: string
  summary: string
  author_name: string
  stars: number
  voca_size: number
  original_video_url: string
  cover: string
  thumbnail_url: string
  video_url: string
  audio_url: string
  subtitles: FetchMediaResult['subtitles']
}

export interface SubmitEpisodeResult {
  video_id: string
  short_title: string
  status: string
  message: string
}

export async function submitUserEpisode(payload: SubmitEpisodePayload) {
  const { data } = await api.post<SubmitEpisodeResult>('/api/episodes/submit/', payload)
  return data
}

/** @deprecated 使用 lookupWord */
export async function lookupToken(id: number, type: 1 | 2) {
  return lookupWord(String(id), type, '')
}
