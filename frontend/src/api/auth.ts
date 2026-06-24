import api from './client'
import type { User } from '@/types'

export interface AuthTokensResponse {
  access: string
  refresh: string
  user: User
}

export async function register(email: string, password: string) {
  const { data } = await api.post<AuthTokensResponse>('/api/auth/register/', { email, password })
  return data
}

export async function login(email: string, password: string) {
  const { data } = await api.post<AuthTokensResponse>('/api/auth/login/', { email, password })
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

export async function activateMembership(code: string) {
  const { data } = await api.post<User>('/api/auth/activate/', { code })
  return data
}

export async function logout(refresh: string) {
  await api.post('/api/auth/logout/', { refresh })
}
