import { request } from '../utils/request'

export function createFeedback(title: string, body: string) {
  return request<{ id: number; message: string }>({
    url: '/api/feedback/',
    method: 'POST',
    data: { title, body, image_urls: [] },
  })
}
