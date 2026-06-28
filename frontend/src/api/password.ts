import api from './client'

export interface ForgotPasswordResponse {
  message: string
  reset_url?: string | null
  reset_token?: string | null
}

export async function requestPasswordReset(email: string) {
  const { data } = await api.post<ForgotPasswordResponse>('/api/auth/forgot-password/', { email })
  return data
}

export async function resetPasswordByEmail(email: string, password: string) {
  const { data } = await api.post<{ success: boolean; message: string }>(
    '/api/auth/reset-password-by-email/',
    { email, password },
  )
  return data
}

export async function resetPassword(token: string, password: string) {
  const { data } = await api.post<{ success: boolean; message: string }>('/api/auth/reset-password/', {
    token,
    password,
  })
  return data
}
