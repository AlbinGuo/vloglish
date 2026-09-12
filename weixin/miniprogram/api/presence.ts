import { request } from '../utils/request'
import { wxDeviceKind } from '../utils/device'

export function sendPresenceHeartbeat() {
  const device = wxDeviceKind()
  return request<{ ok: boolean }>({
    url: '/api/presence/heartbeat/',
    method: 'POST',
    data: {
      client: 'weixin',
      ...(device ? { device } : {}),
    },
  })
}
