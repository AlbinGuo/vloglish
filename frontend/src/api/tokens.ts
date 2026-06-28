const ACCESS_KEY = 'access_token'
const REFRESH_KEY = 'refresh_token'

function migrateFromSessionStorage(key: string): string | null {
  const fromLocal = localStorage.getItem(key)
  if (fromLocal) return fromLocal
  const fromSession = sessionStorage.getItem(key)
  if (!fromSession) return null
  localStorage.setItem(key, fromSession)
  sessionStorage.removeItem(key)
  return fromSession
}

export function getAccessToken() {
  return migrateFromSessionStorage(ACCESS_KEY)
}

export function getRefreshToken() {
  return migrateFromSessionStorage(REFRESH_KEY)
}

export function setTokens(access: string, refresh: string) {
  localStorage.setItem(ACCESS_KEY, access)
  localStorage.setItem(REFRESH_KEY, refresh)
  sessionStorage.removeItem(ACCESS_KEY)
  sessionStorage.removeItem(REFRESH_KEY)
}

export function clearTokens() {
  localStorage.removeItem(ACCESS_KEY)
  localStorage.removeItem(REFRESH_KEY)
  sessionStorage.removeItem(ACCESS_KEY)
  sessionStorage.removeItem(REFRESH_KEY)
}

export const REMOTE_LOGIN_DETAIL = '您的账号已在其他设备登录，请重新登录'
const REMOTE_LOGIN_NOTICE_KEY = 'remote_login_notice'

export function isRemoteLoginDetail(detail: unknown): boolean {
  return detail === REMOTE_LOGIN_DETAIL
}

export function setRemoteLoginNotice() {
  sessionStorage.setItem(REMOTE_LOGIN_NOTICE_KEY, '1')
}

export function consumeRemoteLoginNotice(): boolean {
  if (sessionStorage.getItem(REMOTE_LOGIN_NOTICE_KEY) !== '1') return false
  sessionStorage.removeItem(REMOTE_LOGIN_NOTICE_KEY)
  return true
}

export function getErrorDetail(error: unknown): string | undefined {
  const detail = (error as { response?: { data?: { detail?: string } } })?.response?.data?.detail
  return typeof detail === 'string' ? detail : undefined
}
