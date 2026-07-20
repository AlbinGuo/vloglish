import axios from 'axios'
import { clearAdminTokens, getAdminAccessToken, getAdminRefreshToken, setAdminTokens } from '@/api/adminTokens'
import { getDeviceId } from '@/api/client'
import type { EpisodeDetail } from '@/types'

const adminApi = axios.create({
  baseURL: '',
  timeout: 30000,
  headers: { 'Content-Type': 'application/json' },
})

adminApi.interceptors.request.use((config) => {
  config.headers = config.headers ?? {}
  config.headers['X-Device-Id'] = getDeviceId()
  const token = getAdminAccessToken()
  if (token) config.headers.Authorization = `Bearer ${token}`
  // FormData 需由浏览器自动带 multipart boundary，不能沿用默认 application/json
  if (typeof FormData !== 'undefined' && config.data instanceof FormData) {
    const headers = config.headers as { delete?: (key: string) => void; set?: (key: string, value: unknown) => void }
    if (typeof headers.delete === 'function') headers.delete('Content-Type')
    else if (typeof headers.set === 'function') headers.set('Content-Type', false)
    else delete (config.headers as Record<string, unknown>)['Content-Type']
  }
  return config
})

let refreshPromise: Promise<string | null> | null = null

adminApi.interceptors.response.use(
  (response) => response,
  async (error) => {
    const original = error.config
    if (!original || error.response?.status !== 401 || original._adminAuthRetry) {
      return Promise.reject(error)
    }
    if (String(original.url ?? '').includes('/api/admin/auth/login')) {
      return Promise.reject(error)
    }
    if (String(original.url ?? '').includes('/api/admin/auth/me')) {
      clearAdminTokens()
      return Promise.reject(error)
    }

    const refresh = getAdminRefreshToken()
    if (!refresh) {
      clearAdminTokens()
      return Promise.reject(error)
    }

    if (!refreshPromise) {
      refreshPromise = adminApi
        .post<{ access: string; refresh: string }>('/api/token/refresh/', { refresh })
        .then((res) => {
          setAdminTokens(res.data.access, res.data.refresh)
          return res.data.access
        })
        .catch(() => {
          clearAdminTokens()
          return null
        })
        .finally(() => {
          refreshPromise = null
        })
    }

    const newAccess = await refreshPromise
    if (!newAccess) return Promise.reject(error)

    original._adminAuthRetry = true
    original.headers = original.headers ?? {}
    original.headers.Authorization = `Bearer ${newAccess}`
    return adminApi(original)
  },
)

export default adminApi

export interface AdminUser {
  id: number
  email: string
  nickname: string | null
  phone: string | null
  is_member: boolean
  is_staff: boolean
}

export interface DashboardStats {
  users_total: number
  users_today: number
  members_total: number
  episodes_total: number
  episodes_published: number
  episodes_draft: number
  episodes_missing_media: number
  activation_codes_total: number
  activation_codes_available: number
  activation_codes_used: number
  learning_active_7d: number
  learning_completions_total: number
  learning_lookups_total: number
  online_users_now: number
}

export interface AdminPresenceOnline {
  online_users: number
  window_sec: number
}

export interface AdminLearningStats {
  active_learners_7d: number
  active_learners_30d: number
  total_watch_hours: number
  total_completions: number
  total_lookups: number
  total_vocabulary_items: number
  top_episodes: { video_id: string; title: string; completions: number; learners: number }[]
  daily_activity: { date: string; watch_time_sec: number; sessions: number; completions: number }[]
}

export interface ActivationCodeRow {
  id: number
  code: string
  used_by_user_id: number | null
  used_by_email: string | null
  used_at: string | null
  created_at: string
}

export interface UserRow {
  id: number
  email: string
  nickname: string | null
  phone: string | null
  is_member: boolean
  is_active: boolean
  is_staff: boolean
  is_online?: boolean
  member_activated_at: string | null
  created_at: string
  last_active_at: string | null
  watch_time_7d: number
  completed_episodes: number
  lookup_count: number
  signup_country: string | null
  signup_region: string | null
  signup_city: string | null
}

export interface AdminUserGeoStats {
  total_users: number
  known_users: number
  unknown_users: number
  china_users?: number
  overseas_users?: number
  by_region: { region: string; count: number }[]
  by_country?: { name: string; map_name: string; count: number }[]
  by_province?: { name: string; map_name: string; count: number }[]
  by_city?: { name: string; province: string; count: number }[]
}

export type AdminUserSegmentKey =
  | 'active_7d'
  | 'churn_risk'
  | 'new_inactive'
  | 'deep_learners'
  | 'members'
  | 'non_members'

export interface AdminUserSegment {
  key: AdminUserSegmentKey
  label: string
  count: number
}

export async function adminLogin(email: string, password: string) {
  const { data } = await adminApi.post<{ access: string; refresh: string; user: AdminUser }>(
    '/api/admin/auth/login/',
    { email, password },
  )
  return data
}

export async function adminFetchMe() {
  const { data } = await adminApi.get<AdminUser>('/api/admin/auth/me/')
  return data
}

export async function adminFetchDashboard() {
  const { data } = await adminApi.get<DashboardStats>('/api/admin/dashboard/')
  return data
}

export async function adminFetchOnlineUsers() {
  const { data } = await adminApi.get<AdminPresenceOnline>('/api/admin/presence/online/')
  return data
}

export async function adminFetchLearningStats() {
  const { data } = await adminApi.get<AdminLearningStats>('/api/admin/learning/stats/')
  return data
}

export async function adminListActivationCodes(params: {
  status?: string
  page?: number
  page_size?: number
}) {
  const { data } = await adminApi.get<{ count: number; results: ActivationCodeRow[] }>(
    '/api/admin/activation-codes/',
    { params },
  )
  return data
}

export async function adminGenerateCodes(count: number) {
  const { data } = await adminApi.post<{ codes: string[] }>('/api/admin/activation-codes/generate/', {
    count,
  })
  return data
}

export async function adminDeleteCode(code: string) {
  await adminApi.delete(`/api/admin/activation-codes/${encodeURIComponent(code)}/`)
}

export async function adminFetchUserGeoStats() {
  const { data } = await adminApi.get<AdminUserGeoStats>('/api/admin/users/geo-stats/')
  return data
}

export async function adminFetchUserSegments() {
  const { data } = await adminApi.get<{ segments: AdminUserSegment[] }>('/api/admin/users/segments/')
  return data.segments
}

export async function adminListUsers(params: {
  page?: number
  page_size?: number
  search?: string
  segment?: AdminUserSegmentKey | ''
}) {
  const { data } = await adminApi.get<{ count: number; results: UserRow[] }>('/api/admin/users/', {
    params,
  })
  return data
}

export async function adminUpdateUser(
  userId: number,
  payload: Partial<Pick<UserRow, 'is_member' | 'is_active' | 'nickname' | 'phone'>>,
) {
  const { data } = await adminApi.patch<AdminUser>(`/api/admin/users/${userId}/`, payload)
  return data
}

export interface AdminTag {
  id: number
  name: string
  episode_count: number
}

export interface AdminAuthor {
  id: number
  name: string
  gender: string
  nationality: string
  accent: string
  episode_count: number
}

export type AdminAuthorInput = Omit<AdminAuthor, 'id' | 'episode_count'>

export interface AdminSubtitle {
  index: number
  start: number
  end: number
  english: string
  chinese: string
  ipa: string
  english_html: string
}

export interface AdminEpisodeListItem {
  id: number
  index: number
  video_id: string
  short_title: string
  stars: number
  status: string
  subtitle_count: number
  clip_length: number
  author_name: string
  cover: string
  is_demo: boolean
  is_pinned?: boolean
  is_user_submitted: boolean
  tag_names: string[]
  series_id?: number | null
  series_title?: string
  series_index?: number | null
  created_at: string
  play_count: number
  unique_learners: number
  completions: number
  completion_rate: number
  plays_7d: number
  plays_30d: number
}

export type AdminEpisodeSortField =
  | 'id'
  | 'index'
  | 'play_count'
  | 'unique_learners'
  | 'completions'
  | 'completion_rate'
  | 'plays_7d'
  | 'plays_30d'

export interface AdminEpisodeDetail {
  id: number
  video_id: string
  index: number
  short_title: string
  summary: string
  remark: string
  stars: number
  voca_size: number
  subtitle_count: number
  clip_length: number
  cover: string
  video_url: string
  audio_url: string
  thumbnail_url: string
  original_video_url: string
  is_demo: boolean
  is_pinned?: boolean
  status: string
  rejection_reason?: string
  is_user_submitted?: boolean
  series_id?: number | null
  series_index?: number | null
  series_title?: string
  author: AdminAuthorInput
  tag_names: string[]
  subtitles: AdminSubtitle[]
  created_at: string
}

export type AdminEpisodePayload = {
  video_id?: string
  index: number
  short_title: string
  summary: string
  remark: string
  stars: number
  voca_size: number
  cover: string
  video_url: string
  audio_url: string
  thumbnail_url: string
  original_video_url: string
  is_demo: boolean
  is_pinned?: boolean
  status: string
  rejection_reason?: string
  series_id?: number | null
  series_index?: number | null
  clear_series?: boolean
  author: AdminAuthorInput
  tag_names: string[]
  subtitles: AdminSubtitle[]
}

export interface AdminSeries {
  id: number
  slug: string
  title: string
  summary: string
  cover: string
  status: string
  sort_order: number
  episode_count: number
  created_at: string
  published_at: string
}

export type AdminSeriesPayload = {
  slug: string
  title: string
  summary: string
  cover: string
  status: string
  sort_order: number
}

export async function adminListTags() {
  const { data } = await adminApi.get<AdminTag[]>('/api/admin/tags/')
  return data
}

export async function adminListSeries(params?: { status?: string; search?: string }) {
  const { data } = await adminApi.get<{ count: number; results: AdminSeries[] }>('/api/admin/series/', {
    params,
  })
  return data
}

export async function adminCreateSeries(payload: AdminSeriesPayload) {
  const { data } = await adminApi.post<AdminSeries>('/api/admin/series/', payload)
  return data
}

export async function adminUpdateSeries(id: number, payload: Partial<AdminSeriesPayload>) {
  const { data } = await adminApi.patch<AdminSeries>(`/api/admin/series/${id}/`, payload)
  return data
}

export async function adminDeleteSeries(id: number) {
  await adminApi.delete(`/api/admin/series/${id}/`)
}

export async function adminListAuthors() {
  const { data } = await adminApi.get<AdminAuthor[]>('/api/admin/authors/')
  return data
}

export async function adminCreateTag(name: string) {
  const { data } = await adminApi.post<AdminTag>('/api/admin/tags/', { name })
  return data
}

export async function adminUpdateTag(id: number, name: string) {
  const { data } = await adminApi.patch<AdminTag>(`/api/admin/tags/${id}/`, { name })
  return data
}

export async function adminDeleteTag(id: number) {
  await adminApi.delete(`/api/admin/tags/${id}/`)
}

export async function adminMergeTag(id: number, targetId: number) {
  const { data } = await adminApi.post<AdminTag>(`/api/admin/tags/${id}/merge/`, { target_id: targetId })
  return data
}

export async function adminCreateAuthor(payload: AdminAuthorInput) {
  const { data } = await adminApi.post<AdminAuthor>('/api/admin/authors/', payload)
  return data
}

export async function adminUpdateAuthor(id: number, payload: Partial<AdminAuthorInput>) {
  const { data } = await adminApi.patch<AdminAuthor>(`/api/admin/authors/${id}/`, payload)
  return data
}

export async function adminDeleteAuthor(id: number) {
  await adminApi.delete(`/api/admin/authors/${id}/`)
}

export async function adminMergeAuthor(id: number, targetId: number) {
  const { data } = await adminApi.post<AdminAuthor>(`/api/admin/authors/${id}/merge/`, { target_id: targetId })
  return data
}

export async function adminListEpisodes(params: {
  page?: number
  page_size?: number
  search?: string
  status?: string
  stars?: number
  series_id?: number
  sort_by?: AdminEpisodeSortField
  sort_dir?: 'asc' | 'desc'
}) {
  const { data } = await adminApi.get<{ count: number; results: AdminEpisodeListItem[] }>(
    '/api/admin/episodes/',
    { params },
  )
  return data
}

export async function adminGetNextEpisodeIndex() {
  const { data } = await adminApi.get<{ next_index: number }>('/api/admin/episodes/next-index/')
  return data.next_index
}

export async function adminGetEpisode(id: number) {
  const { data } = await adminApi.get<AdminEpisodeDetail>(`/api/admin/episodes/${id}/`)
  return data
}

export async function adminGetEpisodePreview(videoId: string) {
  const { data } = await adminApi.get<{ episode: EpisodeDetail; total_episodes: number }>(
    `/api/admin/episodes/preview/${encodeURIComponent(videoId)}/`,
  )
  return data
}

export async function adminCreateEpisode(payload: AdminEpisodePayload) {
  const { data } = await adminApi.post<AdminEpisodeDetail>('/api/admin/episodes/', payload, {
    timeout: 90000,
  })
  return data
}

export async function adminUpdateEpisode(id: number, payload: Partial<AdminEpisodePayload>) {
  const { data } = await adminApi.patch<AdminEpisodeDetail>(`/api/admin/episodes/${id}/`, payload, {
    timeout: 90000,
  })
  return data
}

export async function adminDeleteEpisode(id: number) {
  await adminApi.delete(`/api/admin/episodes/${id}/`)
}

export async function adminImportVtt(vttText: string) {
  const { data } = await adminApi.post<{
    subtitles: AdminSubtitle[]
    subtitle_count: number
    clip_length: number
    had_chinese: boolean
    translated_count: number
    ipa_count: number
    stars: number
    voca_size: number
    highlight_count: number
  }>('/api/admin/episodes/import-subtitles/', { vtt_text: vttText }, { timeout: 900000 })
  return data
}

export interface AdminFetchMediaResult {
  title: string
  summary: string
  author_name: string
  original_video_url: string
  cover: string
  thumbnail_url: string
  video_url: string
  audio_url: string
  subtitles: AdminSubtitle[]
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

export async function adminFetchMediaFromUrl(payload: {
  url: string
  slug?: string
  enrich_subtitles?: boolean
}) {
  const { data } = await adminApi.post<AdminFetchMediaResult>(
    '/api/admin/episodes/fetch-media/',
    payload,
    { timeout: 900000 },
  )
  return data
}

export interface DemoCodeRow {
  id: number
  code: string
  affiliate_code: string | null
  active: boolean
  episode_count: number
}

export interface DemoCodeDetail extends DemoCodeRow {
  episodes: { id: number; video_id: string; short_title: string; status: string }[]
  episode_ids: number[]
}

export async function adminListDemoCodes() {
  const { data } = await adminApi.get<{ results: DemoCodeRow[] }>('/api/admin/demo-codes/')
  return data.results
}

export async function adminGetDemoCode(id: number) {
  const { data } = await adminApi.get<DemoCodeDetail>(`/api/admin/demo-codes/${id}/`)
  return data
}

export async function adminCreateDemoCode(payload: {
  code: string
  affiliate_code?: string | null
  active?: boolean
  episode_ids?: number[]
}) {
  const { data } = await adminApi.post<DemoCodeDetail>('/api/admin/demo-codes/', payload)
  return data
}

export async function adminUpdateDemoCode(
  id: number,
  payload: Partial<{ affiliate_code: string | null; active: boolean; episode_ids: number[] }>,
) {
  const { data } = await adminApi.patch<DemoCodeDetail>(`/api/admin/demo-codes/${id}/`, payload)
  return data
}

export async function adminDeleteDemoCode(id: number) {
  await adminApi.delete(`/api/admin/demo-codes/${id}/`)
}

export interface ImportResult {
  created: number
  updated: number
  total: number
  video_ids: string[]
  errors: string[]
}

export async function adminImportEpisodesJson(payload: {
  episodes: unknown[]
  details: unknown[]
  default_status?: string
  mark_demo?: boolean
}) {
  const { data } = await adminApi.post<ImportResult>('/api/admin/episodes/import-json/', payload)
  return data
}

export async function adminExportEpisodesJson() {
  const { data } = await adminApi.get<{ episodes: unknown[]; details: unknown[] }>(
    '/api/admin/episodes/export-json/',
  )
  return data
}

export interface AdminTecoAuthStatus {
  configured: boolean
  session_file: string
  has_session_file: boolean
  has_access_token: boolean
  has_email_password: boolean
  ffmpeg_configured: boolean
  ffmpeg_dir: string
  has_ffmpeg: boolean
  has_ffprobe: boolean
}

export interface AdminTecoCatalogItem {
  video_id: string
  index: number | null
  short_title: string
  stars: number
  clip_length: number
  subtitle_count: number
  cover_preview: string
  exists_in_db: boolean
  episode_db_id: number | null
  qiniu_has_video: boolean
}

export interface AdminTecoImportEpisodeResult {
  video_id: string
  skipped: boolean
  created: boolean
  subtitle_count: number
  cover_url: string
  video_url: string
  warnings: string[]
  message: string
}

export async function adminTecoAuthStatus() {
  const { data } = await adminApi.get<AdminTecoAuthStatus>('/api/admin/teco/auth-status/')
  return data
}

export async function adminTecoCatalog(indexFrom: number, indexTo: number, checkQiniu = false) {
  const { data } = await adminApi.get<{
    index_from: number
    index_to: number
    count: number
    results: AdminTecoCatalogItem[]
  }>('/api/admin/teco/catalog/', {
    params: { index_from: indexFrom, index_to: indexTo, check_qiniu: checkQiniu },
  })
  return data
}

export async function adminTecoImportEpisode(payload: {
  video_id: string
  index?: number | null
  short_title?: string
  status?: string
  skip_existing?: boolean
  apply_branding?: boolean
  media_mode?: 'full' | 'qiniu_only'
}) {
  const { data } = await adminApi.post<AdminTecoImportEpisodeResult>(
    '/api/admin/teco/import-episode/',
    payload,
    { timeout: 900000 },
  )
  return data
}

export async function adminTecoSyncDbFromQiniu(payload: {
  index_from: number
  index_to: number
  status?: string
  skip_existing?: boolean
  force_update?: boolean
}) {
  const { data } = await adminApi.post<{
    index_from: number
    index_to: number
    total: number
    created: number
    updated: number
    skipped: number
    failed: number
    results: AdminTecoImportEpisodeResult[]
    errors: string[]
  }>('/api/admin/teco/sync-db-from-qiniu/', payload, { timeout: 900000 })
  return data
}

export interface AdminBroadcast {
  id: number
  title: string
  body: string
  image_url: string
  recipient_count: number
  created_by_email: string
  created_at: string
}

export async function adminListBroadcasts(page = 1, pageSize = 20) {
  const { data } = await adminApi.get<{ count: number; results: AdminBroadcast[] }>(
    '/api/admin/notifications/broadcasts/',
    { params: { page, page_size: pageSize } },
  )
  return data
}

export async function adminUploadNotificationImage(file: File) {
  const form = new FormData()
  form.append('file', file)
  const { data } = await adminApi.post<{ image_url: string }>(
    '/api/admin/notifications/upload-image/',
    form,
    { timeout: 120000 },
  )
  return data
}

export async function adminCreateBroadcast(payload: {
  title: string
  body: string
  image_url?: string
}) {
  const { data } = await adminApi.post<AdminBroadcast>('/api/admin/notifications/broadcasts/', payload)
  return data
}

export interface AdminArticleListItem {
  id: number
  article_id: string
  title: string
  source: string
  topic: string
  stars: number
  word_count: number
  segment_count: number
  status: string
  published_at: string
  created_at: string
}

export interface AdminArticleSegment {
  english: string
  chinese: string
  english_html: string
  audio_url?: string
  duration_ms?: number
}

export interface AdminArticleDetail {
  id: number
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
  status: string
  tts_status: string
  segments: AdminArticleSegment[]
}

export async function adminListArticles(params: {
  page?: number
  page_size?: number
  status?: string
  q?: string
} = {}) {
  const { data } = await adminApi.get<{ count: number; results: AdminArticleListItem[] }>(
    '/api/admin/articles/',
    { params },
  )
  return data
}

export async function adminCreateArticle(payload: Partial<AdminArticleDetail> & { title?: string }) {
  const { data } = await adminApi.post<AdminArticleDetail>('/api/admin/articles/', payload)
  return data
}

export async function adminGetArticle(ref: string | number) {
  const { data } = await adminApi.get<AdminArticleDetail>(`/api/admin/articles/${ref}/`)
  return data
}

export async function adminUpdateArticle(ref: string | number, payload: Record<string, unknown>) {
  const { data } = await adminApi.patch<AdminArticleDetail>(`/api/admin/articles/${ref}/`, payload)
  return data
}

export async function adminUploadArticleCover(ref: string | number, sourceUrl: string) {
  const { data } = await adminApi.post<{ cover: string }>(
    `/api/admin/articles/${ref}/upload-cover/`,
    { source_url: sourceUrl },
    { timeout: 120000 },
  )
  return data
}

export async function adminDeleteArticle(ref: string | number) {
  await adminApi.delete(`/api/admin/articles/${ref}/`)
}

export async function adminImportArticleText(
  ref: string | number,
  payload: { english_text: string; auto_translate?: boolean; auto_analyze?: boolean },
) {
  const { data } = await adminApi.post<{ segment_count: number; word_count: number; stars: number }>(
    `/api/admin/articles/${ref}/import-text/`,
    payload,
    { timeout: 600000 },
  )
  return data
}

export async function adminAnalyzeArticle(ref: string | number) {
  const { data } = await adminApi.post<Record<string, number>>(`/api/admin/articles/${ref}/analyze/`)
  return data
}

export async function adminPublishArticle(ref: string | number) {
  const { data } = await adminApi.post<{ success: boolean; status: string }>(
    `/api/admin/articles/${ref}/publish/`,
  )
  return data
}

export async function adminGenerateArticleTts(ref: string | number, options: { voice?: string } = {}) {
  const { data } = await adminApi.post<{
    generated: number
    failed: number
    total: number
    tts_status: string
    error_sample?: string
    voice?: string
  }>(`/api/admin/articles/${ref}/generate-tts/`, options.voice ? { voice: options.voice } : {}, {
    timeout: 900000,
  })
  return data
}
