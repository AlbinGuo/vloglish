import { randomUUID } from '@/utils/randomId'

const ACCESS_KEY = 'admin_access_token'
const REFRESH_KEY = 'admin_refresh_token'
const DEVICE_KEY = 'admin_device_id'

/** 管理端独立设备 ID，避免与用户端同 device 互踢会话 */
export function getAdminDeviceId(): string {
  let id = localStorage.getItem(DEVICE_KEY)
  if (!id) {
    id = `admin-${randomUUID()}`
    localStorage.setItem(DEVICE_KEY, id)
  }
  return id
}

function migrateLegacyTokens() {
  const access = sessionStorage.getItem(ACCESS_KEY)
  const refresh = sessionStorage.getItem(REFRESH_KEY)
  if (!access || !refresh) return
  localStorage.setItem(ACCESS_KEY, access)
  localStorage.setItem(REFRESH_KEY, refresh)
  sessionStorage.removeItem(ACCESS_KEY)
  sessionStorage.removeItem(REFRESH_KEY)
}

/** 管理员 token 使用 localStorage，以便新标签页预览等场景共享登录态 */
export function getAdminAccessToken() {
  migrateLegacyTokens()
  return localStorage.getItem(ACCESS_KEY)
}

export function getAdminRefreshToken() {
  migrateLegacyTokens()
  return localStorage.getItem(REFRESH_KEY)
}

export function setAdminTokens(access: string, refresh: string) {
  localStorage.setItem(ACCESS_KEY, access)
  localStorage.setItem(REFRESH_KEY, refresh)
  sessionStorage.removeItem(ACCESS_KEY)
  sessionStorage.removeItem(REFRESH_KEY)
}

export function clearAdminTokens() {
  localStorage.removeItem(ACCESS_KEY)
  localStorage.removeItem(REFRESH_KEY)
  sessionStorage.removeItem(ACCESS_KEY)
  sessionStorage.removeItem(REFRESH_KEY)
}
