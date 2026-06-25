import axios from 'axios'
import {
  clearTokens,
  getAccessToken,
  getErrorDetail,
  getRefreshToken,
  isRemoteLoginDetail,
  setRemoteLoginNotice,
} from '@/api/tokens'

const DEVICE_KEY = 'device_id'
const DEMO_CODE_KEY = 'demo_code'
const DEMO_VERIFIED_KEY = 'demo_code_verified'

export function getDeviceId(): string {
  let id = localStorage.getItem(DEVICE_KEY)
  if (!id) {
    id = crypto.randomUUID()
    localStorage.setItem(DEVICE_KEY, id)
  }
  return id
}

export function isDemoVerified(): boolean {
  return localStorage.getItem(DEMO_VERIFIED_KEY) === 'true'
}

export function getDemoCode(): string | null {
  return localStorage.getItem(DEMO_CODE_KEY)
}

export function setDemoVerified(code: string, affiliateCode?: string | null) {
  localStorage.setItem(DEMO_CODE_KEY, code)
  localStorage.setItem(DEMO_VERIFIED_KEY, 'true')
  if (affiliateCode) localStorage.setItem('a_code', affiliateCode)
}

const api = axios.create({
  baseURL: '',
  timeout: 30000,
  withCredentials: true,
  headers: { 'Content-Type': 'application/json' },
})

api.interceptors.request.use((config) => {
  config.headers = config.headers ?? {}
  config.headers['X-Device-Id'] = getDeviceId()
  config.headers['X-Timestamp'] = String(Math.floor(Date.now() / 1000))
  config.headers['X-Nonce'] = crypto.randomUUID()

  const token = getAccessToken()
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

let refreshPromise: Promise<string | null> | null = null

async function handleForcedLogout() {
  setRemoteLoginNotice()
  clearTokens()
  const { useAuthStore } = await import('@/stores/auth')
  useAuthStore().clearSession()
  const path = window.location.pathname
  if (!path.startsWith('/login') && !path.startsWith('/signup') && !path.startsWith('/gnadmin')) {
    window.location.href = '/login?reason=remote'
  }
}

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const original = error.config
    const detail = getErrorDetail(error)

    if (isRemoteLoginDetail(detail)) {
      await handleForcedLogout()
      return Promise.reject(error)
    }

    if (!original || error.response?.status !== 401 || original._authRetry) {
      return Promise.reject(error)
    }

    const url = String(original.url ?? '')
    if (url.includes('/api/auth/login') || url.includes('/api/auth/register') || url.includes('/api/token/refresh') || url.includes('/api/auth/forgot-password') || url.includes('/api/auth/reset-password')) {
      return Promise.reject(error)
    }

    const refresh = getRefreshToken()
    if (!refresh) {
      clearTokens()
      const { useAuthStore } = await import('@/stores/auth')
      useAuthStore().clearSession()
      return Promise.reject(error)
    }

    if (!refreshPromise) {
      refreshPromise = import('@/stores/auth')
        .then(({ useAuthStore }) => useAuthStore().refreshAccess())
        .catch(async (err) => {
          if (isRemoteLoginDetail(getErrorDetail(err))) {
            await handleForcedLogout()
          } else {
            clearTokens()
            const { useAuthStore } = await import('@/stores/auth')
            useAuthStore().clearSession()
          }
          return null
        })
        .finally(() => {
          refreshPromise = null
        })
    }

    const newAccess = await refreshPromise
    if (!newAccess) return Promise.reject(error)

    original._authRetry = true
    original.headers = original.headers ?? {}
    original.headers.Authorization = `Bearer ${newAccess}`
    return api(original)
  },
)

export default api

export { DEVICE_KEY, DEMO_CODE_KEY, DEMO_VERIFIED_KEY }
