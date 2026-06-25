const ACCESS_KEY = 'access_token'
const REFRESH_KEY = 'refresh_token'

export function getAccessToken() {
  return sessionStorage.getItem(ACCESS_KEY)
}

export function getRefreshToken() {
  return sessionStorage.getItem(REFRESH_KEY)
}

export function setTokens(access: string, refresh: string) {
  sessionStorage.setItem(ACCESS_KEY, access)
  sessionStorage.setItem(REFRESH_KEY, refresh)
}

export function clearTokens() {
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
