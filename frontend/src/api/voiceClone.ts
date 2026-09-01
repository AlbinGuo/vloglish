import api from '@/api/client'

export type ClonedVoiceInfo = {
  voice: string
  ttsModel: string
  name: string
  preferredName?: string
  fallbackMode: boolean
  preferPlayback?: boolean
  hasSample: boolean
  sampleText?: string
  language?: string
  createdAt?: string | null
  updatedAt?: string | null
}

export type VoiceCloneStatus = {
  configured: boolean
  enrollText: string
  minDurationMs: number
  maxDurationMs: number
  voice: ClonedVoiceInfo | null
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

export async function fetchVoiceCloneStatus(): Promise<VoiceCloneStatus> {
  const { data } = await api.get<VoiceCloneStatus>('/api/ai/voice-clone/')
  return data
}

export async function createVoiceClone(opts: {
  blob: Blob
  text: string
  language?: string
  durationMs: number
  filename?: string
}): Promise<{ ok: boolean; voice: ClonedVoiceInfo; fallbackMode: boolean; message: string }> {
  const form = new FormData()
  const name = opts.filename || 'voice-clone.webm'
  form.append('file', opts.blob, name)
  form.append('text', opts.text)
  form.append('language', opts.language || 'en')
  form.append('duration_ms', String(Math.round(opts.durationMs)))
  const { data } = await api.post<{
    ok: boolean
    voice: ClonedVoiceInfo
    fallbackMode: boolean
    message: string
  }>('/api/ai/voice-clone/', form, { timeout: 180000 })
  return data
}

export async function deleteVoiceClone(): Promise<void> {
  await api.delete('/api/ai/voice-clone/')
}

export async function setVoiceClonePreferPlayback(preferPlayback: boolean): Promise<ClonedVoiceInfo> {
  const { data } = await api.patch<{ ok: boolean; voice: ClonedVoiceInfo }>(
    '/api/ai/voice-clone/preference/',
    { prefer_playback: preferPlayback },
  )
  return data.voice
}

export async function fetchVoiceCloneSample(): Promise<Blob> {
  const { data } = await api.get<Blob>('/api/ai/voice-clone/sample/', {
    responseType: 'blob',
    timeout: 60000,
  })
  if (!(data instanceof Blob)) throw new Error('样本返回无效')
  if (data.type && data.type.includes('application/json')) {
    throw new Error(await detailFromBlob(data, '无法加载样本'))
  }
  return data
}

const speakCache: { key: string; blob: Blob }[] = []
const MAX_SPEAK_CACHE = 30

export async function fetchClonedSpeak(text: string): Promise<Blob> {
  const key = text.trim().replace(/\s+/g, ' ')
  const hit = speakCache.find((e) => e.key === key)
  if (hit) return hit.blob

  try {
    const { data } = await api.post<Blob>(
      '/api/ai/voice-clone/speak/',
      { text: key },
      { responseType: 'blob', timeout: 60000 },
    )
    if (!(data instanceof Blob)) throw new Error('合成返回无效')
    if (data.type && data.type.includes('application/json')) {
      throw new Error(await detailFromBlob(data, '合成失败'))
    }
    speakCache.push({ key, blob: data })
    while (speakCache.length > MAX_SPEAK_CACHE) speakCache.shift()
    return data
  } catch (e: unknown) {
    const err = e as { response?: { data?: unknown }; message?: string }
    const data = err.response?.data
    if (data instanceof Blob) {
      throw new Error(await detailFromBlob(data, '合成失败'))
    }
    if (e instanceof Error && e.message) throw e
    throw new Error(typeof err.message === 'string' ? err.message : '合成失败')
  }
}

export function clearClonedSpeakCache() {
  speakCache.length = 0
}
