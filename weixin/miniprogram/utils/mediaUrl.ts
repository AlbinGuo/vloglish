import { API_BASE } from '../config'

/** 封面走站点中转，避免七牛防盗链拦截小程序 Referer。 */
export function resolveCoverUrl(url: string): string {
  const cleaned = (url || '').trim()
  if (!cleaned) return ''
  return `${API_BASE}/api/public/cover/?u=${encodeURIComponent(cleaned)}`
}
