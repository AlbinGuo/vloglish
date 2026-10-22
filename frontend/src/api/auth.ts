import api from './client'
import type { User } from '@/types'

export interface AuthTokensResponse {
  access: string
  refresh: string
  user: User
}

export async function register(email: string, password: string, activationCode?: string) {
  const payload: { email: string; password: string; activation_code?: string } = {
    email,
    password,
  }
  const code = activationCode?.trim()
  if (code) payload.activation_code = code
  const { data } = await api.post<AuthTokensResponse>('/api/auth/register/', payload)
  return data
}

export async function login(email: string, password: string) {
  const { data } = await api.post<AuthTokensResponse>('/api/auth/login/', { email, password })
  return data
}

/** 为当前账号设置/修改登录邮箱与密码（Apple 登录用户绑定网页登录） */
export async function setAccountCredentials(payload: {
  email: string
  password: string
  current_password?: string
}) {
  const { data } = await api.post<User>('/api/auth/set-credentials/', payload)
  return data
}

export async function appleLogin(payload: {
  identity_token: string
  authorization_code?: string
  full_name?: string
}) {
  const { data } = await api.post<AuthTokensResponse>('/api/auth/apple/', payload)
  return data
}

export async function refreshAuthToken(refresh: string) {
  const { data } = await api.post<AuthTokensResponse>('/api/token/refresh/', { refresh })
  return data
}

export async function fetchCurrentUser() {
  const { data } = await api.get<User>('/api/auth/me/')
  return data
}

export async function setUserAvatar(payload: { avatar_key?: string; cycle?: boolean }) {
  const { data } = await api.post<User>('/api/auth/avatar/', payload)
  return data
}

export async function activateMembership(activationCode: string) {
  const { data } = await api.post<User>('/api/auth/activate/', {
    activation_code: activationCode.trim(),
  })
  return data
}

export async function logout(refresh: string) {
  await api.post('/api/auth/logout/', { refresh })
}

export async function deleteAccount(payload: { password?: string; confirmation: string }) {
  await api.post('/api/auth/delete-account/', payload)
}

export async function prepareBindWechat() {
  const { data } = await api.post<{ token: string; expires_in: number }>('/api/auth/bind-wechat/prepare/')
  return data
}

export async function fetchBindWechatQr(token: string) {
  const { data } = await api.get<Blob>('/api/auth/bind-wechat/qrcode/', {
    params: { token },
    responseType: 'blob',
  })
  return data
}

export async function fetchBindWechatStatus(token: string) {
  const { data } = await api.get<{ status: string; user?: User | null }>('/api/auth/bind-wechat/status/', {
    params: { token },
  })
  return data
}
