import { request } from '../utils/request'
import type { AuthUser } from '../utils/auth'

export type AuthTokens = {
  access: string
  refresh: string
  user: AuthUser
}

export function wxLoginCode(): Promise<string> {
  return new Promise((resolve, reject) => {
    wx.login({
      success: (res) => {
        if (res.code) resolve(res.code)
        else reject(new Error('未拿到微信登录码'))
      },
      fail: (err) => reject(new Error(err.errMsg || '微信登录失败')),
    })
  })
}

export function loginWithWxCode(code: string, nickname?: string) {
  return request<AuthTokens>({
    url: '/api/auth/wechat/mini/',
    method: 'POST',
    data: { code, nickname: nickname || undefined },
    auth: false,
  })
}

export function fetchMe() {
  return request<AuthUser>({ url: '/api/auth/me/' })
}
