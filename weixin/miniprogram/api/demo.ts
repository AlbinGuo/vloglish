import { request } from '../utils/request'
import type { EpisodeSummary } from './episodes'

export async function verifyDemoCode(code: string) {
  return request<{ success: boolean; affiliate_code?: string }>({
    url: '/api/demo/verify-code/',
    method: 'POST',
    data: { code, device_id: wx.getStorageSync('device_id') },
    auth: false,
  })
}

export async function getDemoEpisodes() {
  return request<EpisodeSummary[]>({
    url: '/api/demo/get-episodes/',
    auth: false,
  })
}
