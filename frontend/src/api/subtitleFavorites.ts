import api from './client'

export interface SubtitleFavorite {
  id: number
  video_id: string
  subtitle_id: number | null
  subtitle_index: number
  start_sec: number
  end_sec: number
  english: string
  chinese: string
  ipa: string
  english_html: string
  episode_title: string
  cover_url: string
  created_at: string
  already_saved: boolean
}

export async function getSubtitleFavorites(
  params: { videoId?: string; limit?: number; offset?: number } = {},
) {
  const { data } = await api.get<SubtitleFavorite[]>('/api/subtitle-favorites/', {
    params: {
      video_id: params.videoId || undefined,
      limit: params.limit,
      offset: params.offset,
    },
  })
  return data
}

export async function saveSubtitleFavorite(subtitleId: number) {
  const { data } = await api.post<SubtitleFavorite>('/api/subtitle-favorites/', {
    subtitle_id: subtitleId,
  })
  return data
}

export async function removeSubtitleFavoriteBySubtitle(subtitleId: number) {
  await api.delete(`/api/subtitle-favorites/by-subtitle/${subtitleId}/`)
}

export async function removeSubtitleFavorite(favoriteId: number) {
  await api.delete(`/api/subtitle-favorites/${favoriteId}/`)
}
