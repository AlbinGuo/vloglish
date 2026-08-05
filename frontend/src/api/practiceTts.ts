import api from '@/api/client'

export type PracticeTtsVoice = 'Ryan' | 'Katerina'
export type PracticeTtsMode = 'word' | 'sentence' | 'passage'

const MAX_CLIENT_CACHE = 40

type CacheEntry = { key: string; blob: Blob }

/** 会话内 LRU：同一文本+音色不重复打后端 */
const clientCache: CacheEntry[] = []

function cacheKey(text: string, voice: PracticeTtsVoice): string {
  return `${voice}\n${text.trim().replace(/\s+/g, ' ')}`
}

function getCached(key: string): Blob | null {
  const idx = clientCache.findIndex((e) => e.key === key)
  if (idx < 0) return null
  const [entry] = clientCache.splice(idx, 1)
  clientCache.push(entry)
  return entry.blob
}

function putCached(key: string, blob: Blob) {
  const idx = clientCache.findIndex((e) => e.key === key)
  if (idx >= 0) clientCache.splice(idx, 1)
  clientCache.push({ key, blob })
  while (clientCache.length > MAX_CLIENT_CACHE) {
    clientCache.shift()
  }
}

async function detailFromBlob(blob: Blob, fallback: string): Promise<string> {
  try {
    const textBody = await blob.text()
    const parsed = JSON.parse(textBody) as { detail?: string }
    if (typeof parsed.detail === 'string' && parsed.detail.trim()) return parsed.detail
  } catch {
    /* ignore */
  }
  return fallback
}

export async function fetchPracticeTts(
  text: string,
  voice: PracticeTtsVoice,
  mode: PracticeTtsMode = 'sentence',
): Promise<Blob> {
  const key = cacheKey(text, voice)
  const hit = getCached(key)
  if (hit) return hit

  try {
    const { data } = await api.post<Blob>(
      '/api/ai/practice-tts/',
      { text, voice, mode },
      { responseType: 'blob', timeout: 60000 },
    )
    if (!(data instanceof Blob)) {
      throw new Error('示范音返回格式无效')
    }
    if (data.type && data.type.includes('application/json')) {
      throw new Error(await detailFromBlob(data, '示范音合成失败'))
    }
    putCached(key, data)
    return data
  } catch (e: unknown) {
    const err = e as { response?: { data?: unknown }; message?: string }
    const data = err.response?.data
    if (data instanceof Blob) {
      throw new Error(await detailFromBlob(data, '示范音暂不可用'))
    }
    if (e instanceof Error && e.message) throw e
    throw new Error(typeof err.message === 'string' ? err.message : '示范音暂不可用')
  }
}
