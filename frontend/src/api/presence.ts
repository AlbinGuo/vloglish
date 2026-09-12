import api from '@/api/client'
import { getDeviceKind, getNativePlatform, isNativePlatform } from '@/utils/platform'

/** 与后端 page_dwell.ALLOWED_PAGE_KEYS 对齐的路由名 */
export const TRACKED_PAGE_KEYS = new Set([
  'HomePage',
  'SeriesList',
  'SeriesDetail',
  'AuthorDetail',
  'NewsReadingList',
  'NewsReading',
  'EpisodePage',
  'DemoEpisode',
  'SubmitEpisode',
  'SubmitArticle',
  'MySubmissions',
  'Notifications',
  'Learning',
  'Vocabulary',
  'Pricing',
  'DemoPage',
])

export function normalizePresencePageKey(name: unknown): string | undefined {
  if (typeof name !== 'string' || !name) return undefined
  return TRACKED_PAGE_KEYS.has(name) ? name : undefined
}

export async function sendPresenceHeartbeat(pageKey?: string | null) {
  const page_key = pageKey && TRACKED_PAGE_KEYS.has(pageKey) ? pageKey : undefined
  const native = getNativePlatform()
  const client = isNativePlatform() && (native === 'ios' || native === 'android') ? native : 'web'
  await api.post('/api/presence/heartbeat/', {
    ...(page_key ? { page_key } : {}),
    client,
    device: getDeviceKind(),
  })
}
