import api from './client'

export interface EpisodeProgress {
  video_id: string
  last_subtitle_index: number
  last_position_sec: number
  max_reached_index: number
  watch_time_sec: number
  completion_percent: number
  is_completed: boolean
  last_watched_at: string
  completed_at: string | null
}

export interface LearningSummary {
  total_watch_time_sec: number
  completed_episodes: number
  in_progress_episodes: number
  vocabulary_count: number
  lookup_count: number
  learning_days: number
  streak_days: number
  today_watch_time_sec: number
  today_completed: number
  week_watch_time_sec: number
}

export interface RecentEpisode {
  video_id: string
  short_title: string
  cover: string
  completion_percent: number
  is_completed: boolean
  last_subtitle_index: number
  last_watched_at: string
}

export interface VocabularyItem {
  id: number
  entry_id: number
  word: string
  token_type: number
  source_video_id: string
  source_episode_title: string
  created_at: string
  exam_tags?: string[]
  ipa?: string
  definition_cn?: string
  source_type?: string
}

export type ArticleVocabularyItem = VocabularyItem

export interface WordLookupRecord {
  id: number
  entry_id: number
  word: string
  token_type: number
  context: string
  video_id: string
  episode_title: string
  is_saved: boolean
  looked_up_at: string
}

export async function getEpisodeProgress(videoId: string) {
  const { data } = await api.get<EpisodeProgress>(`/api/learning/progress/${videoId}/`)
  return data
}

export async function updateEpisodeProgress(
  videoId: string,
  payload: Partial<{
    last_subtitle_index: number
    last_position_sec: number
    max_reached_index: number
    watch_time_delta_sec: number
    heard_subtitle_id: number
    is_completed: boolean
    session_id: number
    session_lookups_delta: number
    session_replays_delta: number
    playback_rate: number
    subtitle_mode: string
    loop_mode: string
  }>,
) {
  const { data } = await api.put<EpisodeProgress>(`/api/learning/progress/${videoId}/`, payload)
  return data
}

export async function getLearningSummary() {
  const { data } = await api.get<LearningSummary>('/api/learning/summary/')
  return data
}

export async function getRecentEpisodes() {
  const { data } = await api.get<RecentEpisode[]>('/api/learning/recent/')
  return data
}

export async function getLearningCalendar(days = 90) {
  const { data } = await api.get<{ days: { date: string; watch_time_sec: number; sessions: number }[] }>(
    '/api/learning/calendar/',
    { params: { days } },
  )
  return data.days
}

export async function startLearningSession(videoId: string, subtitleMode: string, loopMode: string) {
  const { data } = await api.post<{ id: number; video_id: string; started_at: string }>(
    '/api/learning/sessions/',
    { video_id: videoId, subtitle_mode: subtitleMode, loop_mode: loopMode },
  )
  return data
}

export async function endLearningSession(sessionId: number) {
  await api.post(`/api/learning/sessions/${sessionId}/end/`)
}

export async function getVocabulary() {
  const { data } = await api.get<VocabularyItem[]>('/api/learning/vocabulary/')
  return data
}

export async function getArticleVocabulary(articleRef: string) {
  const { data } = await api.get<VocabularyItem[]>('/api/learning/vocabulary/', {
    params: { article_ref: articleRef },
  })
  return data
}

export async function saveVocabulary(payload: {
  entry_id: number
  word: string
  token_type: number
  video_id?: string
  episode_id?: number
  subtitle_id?: number
  article_ref?: string
  segment_id?: number
  source_type?: string
}) {
  const { data } = await api.post<VocabularyItem>('/api/learning/vocabulary/', payload)
  return data
}

export async function removeVocabulary(entryId: number) {
  await api.delete(`/api/learning/vocabulary/${entryId}/`)
}

export async function getLookupHistory(videoId?: string, page = 1) {
  const { data } = await api.get<{ count: number; results: WordLookupRecord[] }>('/api/learning/lookups/', {
    params: { video_id: videoId, page, page_size: 50 },
  })
  return data
}

export interface SubtitleProgress {
  subtitle_id: number
  heard_count: number
  is_marked_learned: boolean
  last_heard_at: string
}

export async function getSubtitleProgress(videoId: string) {
  const { data } = await api.get<{ results: SubtitleProgress[] }>(`/api/learning/subtitles/${videoId}/`)
  return data.results
}

export async function updateSubtitleProgress(subtitleId: number, isMarkedLearned: boolean) {
  const { data } = await api.patch<SubtitleProgress>(`/api/learning/subtitles/${subtitleId}/`, {
    is_marked_learned: isMarkedLearned,
  })
  return data
}
