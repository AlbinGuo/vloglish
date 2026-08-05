import api from '@/api/client'
import type { AiShadowingResult } from '@/api/aiCoach'

export interface OralEvalStatus {
  enabled: boolean
  application_id: string
  sdk_url: string
  accent: string
  core_type: string
}

export interface OralEvalWarrant {
  warrant_id: string
  expire_at: number | null
  application_id: string
  user_id: string
  sdk_url: string
  accent: string
}

export async function fetchOralEvalStatus() {
  const { data } = await api.get<OralEvalStatus>('/api/ai/oral-eval/status/')
  return data
}

export async function fetchOralEvalWarrant() {
  const { data } = await api.post<OralEvalWarrant>('/api/ai/oral-eval/warrant/')
  return data
}

export async function aiShadowingOralFeedback(
  videoId: string,
  subtitleId: number,
  oralResult: Record<string, unknown>,
) {
  const { data } = await api.post<AiShadowingResult>('/api/ai/shadowing-oral-feedback/', {
    video_id: videoId,
    subtitle_id: subtitleId,
    oral_result: oralResult,
  })
  return data
}
