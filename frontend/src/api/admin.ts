import axios from 'axios'
import { clearAdminTokens, getAdminAccessToken, getAdminRefreshToken, setAdminTokens } from '@/api/adminTokens'
import { getDeviceId } from '@/api/client'

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
  member_activated_at: string | null
  created_at: string
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

export async function adminListUsers(params: { page?: number; page_size?: number; search?: string }) {
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
  video_id: string
  short_title: string
  stars: number
  status: string
  subtitle_count: number
  clip_length: number
  author_name: string
  is_demo: boolean
  created_at: string
}

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
  status: string
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
  status: string
  author: AdminAuthorInput
  tag_names: string[]
  subtitles: AdminSubtitle[]
}

export async function adminListTags() {
  const { data } = await adminApi.get<AdminTag[]>('/api/admin/tags/')
  return data
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
}) {
  const { data } = await adminApi.get<{ count: number; results: AdminEpisodeListItem[] }>(
    '/api/admin/episodes/',
    { params },
  )
  return data
}

export async function adminGetEpisode(id: number) {
  const { data } = await adminApi.get<AdminEpisodeDetail>(`/api/admin/episodes/${id}/`)
  return data
}

export async function adminCreateEpisode(payload: AdminEpisodePayload) {
  const { data } = await adminApi.post<AdminEpisodeDetail>('/api/admin/episodes/', payload)
  return data
}

export async function adminUpdateEpisode(id: number, payload: Partial<AdminEpisodePayload>) {
  const { data } = await adminApi.patch<AdminEpisodeDetail>(`/api/admin/episodes/${id}/`, payload)
  return data
}

export async function adminDeleteEpisode(id: number) {
  await adminApi.delete(`/api/admin/episodes/${id}/`)
}

export async function adminImportVtt(vttText: string) {
  const { data } = await adminApi.post<{ subtitles: AdminSubtitle[]; subtitle_count: number; clip_length: number }>(
    '/api/admin/episodes/import-vtt/',
    { vtt_text: vttText },
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
