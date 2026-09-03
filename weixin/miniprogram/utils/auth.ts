import { ACCESS_KEY, DEVICE_KEY, REFRESH_KEY, USER_KEY } from '../config'

export type AuthUser = {
  id: number
  email: string
  nickname: string | null
  phone: string | null
  is_member: boolean
  avatar_key: string | null
  member_until?: string | null
}

function randomId(): string {
  const hex = () => Math.floor(Math.random() * 0x10000).toString(16).padStart(4, '0')
  return `${hex()}${hex()}-${hex()}-${hex()}-${hex()}-${hex()}${hex()}${hex()}`
}

export function getDeviceId(): string {
  let id = wx.getStorageSync(DEVICE_KEY) as string
  if (!id) {
    id = randomId()
    wx.setStorageSync(DEVICE_KEY, id)
  }
  return id
}

export function getAccessToken(): string {
  return (wx.getStorageSync(ACCESS_KEY) as string) || ''
}

export function getRefreshToken(): string {
  return (wx.getStorageSync(REFRESH_KEY) as string) || ''
}

export function getStoredUser(): AuthUser | null {
  const raw = wx.getStorageSync(USER_KEY)
  if (!raw || typeof raw !== 'object') return null
  return raw as AuthUser
}

export function setSession(access: string, refresh: string, user: AuthUser): void {
  wx.setStorageSync(ACCESS_KEY, access)
  wx.setStorageSync(REFRESH_KEY, refresh)
  wx.setStorageSync(USER_KEY, user)
}

export function clearSession(): void {
  wx.removeStorageSync(ACCESS_KEY)
  wx.removeStorageSync(REFRESH_KEY)
  wx.removeStorageSync(USER_KEY)
}

export function displayName(user: AuthUser | null): string {
  if (!user) return '未登录'
  return (user.nickname || '').trim() || `学员 ${user.id}`
}
