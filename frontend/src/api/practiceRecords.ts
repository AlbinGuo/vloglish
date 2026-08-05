import api from '@/api/client'

export type PracticeMode = 'word' | 'sentence' | 'passage'

export interface PracticeRecord {
  id: number
  mode: PracticeMode | string
  engine: string
  source_type: string
  video_id: string
  subtitle_id: number | null
  article_id: string
  segment_id: number | null
  title: string
  ref_text: string
  transcript: string
  score: number
  level: string
  accuracy: number | null
  fluency: number | null
  rhythm: number | null
  integrity: number | null
  praise: string
  audio_url: string
  audio_source: string
  has_audio: boolean
  created_at: string | null
  issues?: string[]
  tips?: string[]
  words?: { char: string; score: number }[]
  result?: Record<string, unknown>
}

export interface PracticeRecordList {
  count: number
  page: number
  page_size: number
  results: PracticeRecord[]
}

export async function listPracticeRecords(params?: {
  mode?: PracticeMode | ''
  page?: number
  page_size?: number
}) {
  const { data } = await api.get<PracticeRecordList>('/api/ai/practice-records/', {
    params: {
      mode: params?.mode || undefined,
      page: params?.page ?? 1,
      page_size: params?.page_size ?? 20,
    },
  })
  return data
}

export async function getPracticeRecord(id: number) {
  const { data } = await api.get<PracticeRecord>(`/api/ai/practice-records/${id}/`)
  return data
}

export async function deletePracticeRecord(id: number) {
  const { data } = await api.delete<{ ok: boolean }>(`/api/ai/practice-records/${id}/`)
  return data
}

export async function uploadPracticeAudio(recordId: number, blob: Blob) {
  const form = new FormData()
  const type = blob.type || 'audio/ogg'
  const ext = type.includes('webm') ? 'webm' : type.includes('wav') ? 'wav' : type.includes('mpeg') || type.includes('mp3') ? 'mp3' : 'ogg'
  form.append('file', blob, `practice.${ext}`)
  const { data } = await api.post<{ ok: boolean; audio_url: string; id: number }>(
    `/api/ai/practice-records/${recordId}/audio/`,
    form,
    { timeout: 60000 },
  )
  return data
}
