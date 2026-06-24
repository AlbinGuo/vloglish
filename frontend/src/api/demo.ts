import api, { setDemoVerified } from './client'
import type { DemoVerifyResponse, EpisodeSummary } from '@/types'

export async function verifyDemoCode(code: string) {
  const { getDeviceId } = await import('./client')
  const deviceId = getDeviceId()
  const { data } = await api.post<DemoVerifyResponse>('/api/demo/verify-code/', {
    code,
    device_id: deviceId,
  })
  if (data.success) setDemoVerified(code, data.affiliate_code)
  return data
}

export async function getDemoEpisodes() {
  const { data } = await api.get<EpisodeSummary[]>('/api/demo/get-episodes/')
  return data
}

export { getEpisodeDetail, getEntryDetail, lookupWord } from './episodes'
