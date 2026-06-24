import api from './client'
import type { EntryDetail, EpisodeDetail, EpisodeSummary, Tag } from '@/types'

export interface EpisodeListParams {
  page?: number
  page_size?: number
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

/** @deprecated 使用 lookupWord */
export async function lookupToken(id: number, type: 1 | 2) {
  return lookupWord(String(id), type, '')
}
