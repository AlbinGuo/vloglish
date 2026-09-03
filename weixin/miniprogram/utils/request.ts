import { API_BASE } from '../config'
import { getAccessToken, getDeviceId } from './auth'

type Method = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE'

export class ApiError extends Error {
  status: number
  constructor(status: number, message: string) {
    super(message)
    this.status = status
  }
}

function detailMessage(data: unknown, fallback: string): string {
  if (data && typeof data === 'object' && 'detail' in data) {
    const detail = (data as { detail?: unknown }).detail
    if (typeof detail === 'string' && detail.trim()) return detail
    if (detail && typeof detail === 'object' && 'message' in detail) {
      const msg = (detail as { message?: unknown }).message
      if (typeof msg === 'string' && msg.trim()) return msg
    }
  }
  return fallback
}

export function request<T>(opts: {
  url: string
  method?: Method
  data?: Record<string, unknown> | string
  auth?: boolean
}): Promise<T> {
  const header: Record<string, string> = {
    'Content-Type': 'application/json',
    'X-Device-Id': getDeviceId(),
    'X-Client': 'weixin',
  }
  const auth = opts.auth !== false
  const token = getAccessToken()
  if (auth && token) header.Authorization = `Bearer ${token}`

  return new Promise((resolve, reject) => {
    wx.request({
      url: `${API_BASE}${opts.url}`,
      method: opts.method || 'GET',
      data: opts.data,
      header,
      timeout: 30000,
      success(res) {
        const status = res.statusCode || 0
        if (status >= 200 && status < 300) {
          resolve(res.data as T)
          return
        }
        reject(new ApiError(status, detailMessage(res.data, `请求失败 (${status})`)))
      },
      fail(err) {
        reject(new Error(err.errMsg || '网络不可用'))
      },
    })
  })
}
