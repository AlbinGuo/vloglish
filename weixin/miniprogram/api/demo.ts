import { request } from '../utils/request'
import { getDeviceId } from '../utils/auth'

export async function verifyDemoCode(code: string) {
  return request<{ success: boolean; affiliate_code?: string }>({
    url: '/api/demo/verify-code/',
    method: 'POST',
    data: { code, device_id: getDeviceId() },
    auth: false,
  })
}
