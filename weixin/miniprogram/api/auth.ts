import { request } from '../utils/request'
import type { AuthUser } from '../utils/auth'
import { wxPlatform } from '../utils/device'

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
    data: { code, nickname: nickname || undefined, platform: wxPlatform() || undefined },
    auth: false,
  })
}

export function fetchMe() {
  return request<AuthUser>({ url: '/api/auth/me/' })
}

export function activateMembership(activationCode: string) {
  return request<AuthUser>({
    url: '/api/auth/activate/',
    method: 'POST',
    data: { activation_code: activationCode },
  })
}

export function bindEmail(email: string, password: string) {
  return request<AuthTokens>({
    url: '/api/auth/bind-email/',
    method: 'POST',
    data: { email, password },
  })
}

export function confirmBindWechat(token: string) {
  return request<AuthTokens>({
    url: '/api/auth/bind-wechat/confirm/',
    method: 'POST',
    data: { token },
  })
}
