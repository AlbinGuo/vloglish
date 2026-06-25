import api from './client'
import type { EntryDetail, EpisodeDetail, EpisodeSummary, Tag } from '@/types'

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

export async function getEpisodeDetail(videoId: string) {
  const { data } = await api.get<{ episode: EpisodeDetail; total_episodes: number }>(
    `/api/episode/${videoId}/detail/`,
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
  const { data } = await api.get<EntryDetail>('/api/entry-detail/', {
    params: { entry_id: entryId },
  })
  return data
}

export async function lookupWord(word: string, type: 1 | 2, context: string) {
  const { data } = await api.get<EntryDetail>('/api/lookup/', {
    params: { word, type, context },
  })
  return data
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
