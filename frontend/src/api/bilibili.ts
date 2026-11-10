import api from './client'

export interface BilibiliResolved {
  bvid: string
  page: number
  cid: number
  title: string
  summary: string
  cover: string
  cover_proxy: string
  author_name: string
  author_avatar: string
  duration: number
  canonical_url: string
}

export interface BilibiliImportResult {
  video_id: string
  short_title: string
  status: string
  message: string
}

export async function resolveBilibili(input: string) {
  const { data } = await api.get<BilibiliResolved>('/api/bilibili/resolve', {
    params: { url: input },
    timeout: 20000,
  })
  return data
}

export async function importBilibili(bvid: string, page = 1) {
  const { data } = await api.post<BilibiliImportResult>(
    '/api/episodes/submit/bilibili/',
    { bvid, page },
    { timeout: 30000 },
  )
  return data
}
