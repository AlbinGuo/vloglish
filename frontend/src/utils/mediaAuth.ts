import { API_BASE_URL } from '@/api/client'
import { getAccessToken } from '@/api/tokens'

const LOCAL_MEDIA_PREFIX = '/api/episode/'

/**
 * 本地媒体端点（/api/episode/{id}/video|audio|cover/）需要鉴权，但 <video>/<audio>
 * 无法携带 Authorization 头，因此用 ?token= 鉴权。
 *
 * 兼容两种形态：
 * - Web：接口返回根相对路径 /api/episode/...
 * - App：拦截器已把媒体补成后端绝对地址，需按 pathname 识别后仍注入 token
 */
export function withLocalMediaAuth(url: string): string {
  const cleaned = (url || '').trim()
  if (!cleaned) return ''

  let base = cleaned
  if (/^https?:\/\//i.test(cleaned)) {
    let path = cleaned
    try {
      path = new URL(cleaned).pathname
    } catch {
      return cleaned
    }
    if (!path.startsWith(LOCAL_MEDIA_PREFIX)) return cleaned
  } else {
    const normalized = cleaned.startsWith('/') ? cleaned : `/${cleaned}`
    if (!normalized.startsWith(LOCAL_MEDIA_PREFIX)) return cleaned
    base = API_BASE_URL ? `${API_BASE_URL}${normalized}` : normalized
  }

  const token = getAccessToken()
  if (!token) return base
  return `${base}${base.includes('?') ? '&' : '?'}token=${encodeURIComponent(token)}`
}
