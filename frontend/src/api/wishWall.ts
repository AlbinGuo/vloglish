import api from '@/api/client'

export interface WishItem {
  id: number
  title: string
  body: string
  admin_reply: string
  like_count: number
  liked: boolean
  status: string
  mine: boolean
  created_at: string
}

export async function listWishes(params: { sort?: 'hot' | 'new'; page?: number; page_size?: number } = {}) {
  const { data } = await api.get<{ count: number; results: WishItem[] }>('/api/wish-wall/', {
    params: {
      sort: params.sort || 'hot',
      page: params.page ?? 1,
      page_size: params.page_size ?? 40,
    },
  })
  return data
}

export async function createWish(payload: { title: string; body: string }) {
  const { data } = await api.post<{ id: number; message: string }>('/api/wish-wall/', payload)
  return data
}

export async function toggleWishLike(id: number) {
  const { data } = await api.post<{ liked: boolean; like_count: number }>(`/api/wish-wall/${id}/like/`)
  return data
}
