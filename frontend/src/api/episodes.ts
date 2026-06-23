import api from './client'
import type { EntryDetail, EpisodeDetail, EpisodeSummary, Tag } from '@/types'

export interface EpisodeListParams {
  page?: number
  page_size?: number
  stars?: number
  accent?: string
  gender?: string
  tag?: number
  ordering?: string
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

export async function getEntryDetail(entryId: number) {
  const { data } = await api.get<EntryDetail>('/api/entry-detail/', {
    params: { entry_id: entryId },
  })
  return data
}

export async function lookupToken(id: number, type: 1 | 2) {
  const { data } = await api.get<EntryDetail & { eid: number }>('/api/lookup/', {
    params: { id, type },
  })
  return data
}
