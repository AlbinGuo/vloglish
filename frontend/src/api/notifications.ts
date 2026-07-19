import api from './client'

export interface Notification {
  id: number
  type: string
  title: string
  body: string
  image_url: string
  episode_id: number | null
  video_id: string | null
  is_read: boolean
  created_at: string
}

export interface NotificationListResponse {
  count: number
  unread_count: number
  results: Notification[]
}

export async function getNotifications(page = 1, pageSize = 20) {
  const { data } = await api.get<NotificationListResponse>('/api/notifications/', {
    params: { page, page_size: pageSize },
  })
  return data
}

export async function getUnreadNotificationCount() {
  const { data } = await api.get<{ unread_count: number }>('/api/notifications/unread-count/')
  return data.unread_count
}

export async function markNotificationRead(id: number) {
  const { data } = await api.post<{ success: boolean }>(`/api/notifications/${id}/read/`)
  return data
}

export async function markAllNotificationsRead() {
  const { data } = await api.post<{ success: boolean }>('/api/notifications/read-all/')
  return data
}
