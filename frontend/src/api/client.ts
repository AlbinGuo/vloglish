import axios from 'axios'
import {
  clearTokens,
  getAccessToken,
  getErrorDetail,
  getRefreshToken,
  isRemoteLoginDetail,
  setRemoteLoginNotice,
} from '@/api/tokens'
import { randomUUID } from '@/utils/randomId'
import { resolveMediaUrl } from '@/utils/mediaUrl'
import { isMobileAppBuild } from '@/utils/platform'

const DEVICE_KEY = 'device_id'
const DEMO_CODE_KEY = 'demo_code'
const DEMO_VERIFIED_KEY = 'demo_code_verified'

/** App 构建走绝对 API；Web 生产同域反代时保持空字符串 */
const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || '').replace(/\/$/, '')
const useAbsoluteApi = Boolean(API_BASE_URL)

export function getDeviceId(): string {
  let id = localStorage.getItem(DEVICE_KEY)
  if (!id) {
    id = randomUUID()
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
  baseURL: API_BASE_URL,
  timeout: 30000,
  // 跨域 App 请求不要带 cookie；JWT 已在 Authorization
  withCredentials: !useAbsoluteApi,
  headers: { 'Content-Type': 'application/json' },
})

api.interceptors.request.use((config) => {
  config.headers = config.headers ?? {}
  config.headers['X-Device-Id'] = getDeviceId()
  config.headers['X-Timestamp'] = String(Math.floor(Date.now() / 1000))
  config.headers['X-Nonce'] = randomUUID()
  if (useAbsoluteApi) {
    config.headers['X-Client'] = import.meta.env.VITE_APP_TARGET === 'mobile' ? 'app' : 'web'
  }

  // FormData 需由浏览器自动带 multipart boundary，不能沿用默认 application/json
  if (typeof FormData !== 'undefined' && config.data instanceof FormData) {
    const headers = config.headers as { delete?: (k: string) => void; set?: (k: string, v: unknown) => void }
    if (typeof headers.delete === 'function') headers.delete('Content-Type')
    else if (typeof headers.set === 'function') headers.set('Content-Type', false)
    else delete (config.headers as Record<string, unknown>)['Content-Type']
  }

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
  const { default: router } = await import('@/router')
  const path = router.currentRoute.value.path
  if (!path.startsWith('/login') && !path.startsWith('/signup') && !path.startsWith('/gnadmin')) {
    await router.replace({ path: '/login', query: { reason: 'remote' } })
  }
}

function isBinaryBody(data: unknown): boolean {
  if (typeof Blob !== 'undefined' && data instanceof Blob) return true
  if (typeof ArrayBuffer !== 'undefined' && data instanceof ArrayBuffer) return true
  if (typeof ArrayBuffer !== 'undefined' && ArrayBuffer.isView(data)) return true
  return false
}

/** App WebView 为 https，把接口里的 http 媒体链升级为 https，避免图片/视频被混合内容拦截 */
function upgradeMediaUrlsInData(data: unknown): unknown {
  if (typeof data === 'string') {
    if (data.startsWith('http://') || data.startsWith('//')) return resolveMediaUrl(data)
    return data
  }
  if (isBinaryBody(data)) return data
  if (Array.isArray(data)) return data.map((item) => upgradeMediaUrlsInData(item))
  if (data && typeof data === 'object') {
    const out: Record<string, unknown> = {}
    for (const [key, value] of Object.entries(data as Record<string, unknown>)) {
      out[key] = upgradeMediaUrlsInData(value)
    }
    return out
  }
  return data
}

api.interceptors.response.use(
  (response) => {
    if (isMobileAppBuild() && response.data != null && !isBinaryBody(response.data)) {
      response.data = upgradeMediaUrlsInData(response.data)
    }
    return response
  },
  async (error) => {
    const original = error.config
    const detail = getErrorDetail(error)

    if (isRemoteLoginDetail(detail)) {
      await handleForcedLogout()
      return Promise.reject(error)
    }

    // 普通用户 AI 日额度用尽 → 弹窗确认（不强制跳转）
    if (error.response?.status === 403 && typeof detail === 'string' && detail.includes('AI 次数已用完')) {
      const { promptIfAiQuotaExhausted } = await import('@/utils/aiQuotaGate')
      await promptIfAiQuotaExhausted(error)
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

export { DEVICE_KEY, DEMO_CODE_KEY, DEMO_VERIFIED_KEY, API_BASE_URL }
