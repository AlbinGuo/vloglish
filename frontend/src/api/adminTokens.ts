const ACCESS_KEY = 'admin_access_token'
const REFRESH_KEY = 'admin_refresh_token'

export function getAdminAccessToken() {
  return sessionStorage.getItem(ACCESS_KEY)
}

export function getAdminRefreshToken() {
  return sessionStorage.getItem(REFRESH_KEY)
}

export function setAdminTokens(access: string, refresh: string) {
  sessionStorage.setItem(ACCESS_KEY, access)
  sessionStorage.setItem(REFRESH_KEY, refresh)
}

export function clearAdminTokens() {
  sessionStorage.removeItem(ACCESS_KEY)
  sessionStorage.removeItem(REFRESH_KEY)
}
