import api from '@/api/client'

export interface FeedbackItem {
  id: number
  title: string
  body: string
  image_urls: string[]
  status: string
  created_at: string
}

export async function uploadFeedbackImage(file: File) {
  const form = new FormData()
  form.append('file', file)
  const { data } = await api.post<{ image_url: string }>('/api/feedback/upload-image/', form, {
    timeout: 120000,
  })
  return data
}

export async function createFeedback(payload: {
  title: string
  body: string
  image_urls?: string[]
}) {
  const { data } = await api.post<{ id: number; message: string }>('/api/feedback/', {
    title: payload.title,
    body: payload.body,
    image_urls: payload.image_urls || [],
  })
  return data
}

export async function listMyFeedback() {
  const { data } = await api.get<FeedbackItem[]>('/api/feedback/mine/')
  return data
}
