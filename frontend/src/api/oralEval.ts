import api from '@/api/client'
import type { AiShadowingResult } from '@/api/aiCoach'

export type OralCoreType = 'en.word.score' | 'en.sent.score' | 'en.pred.score'
export type OralPracticeMode = 'word' | 'sentence' | 'passage'

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

export function coreTypeForMode(mode: OralPracticeMode): OralCoreType {
  if (mode === 'word') return 'en.word.score'
  if (mode === 'passage') return 'en.pred.score'
  return 'en.sent.score'
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

export async function aiOralEvalFeedback(
  refText: string,
  oralResult: Record<string, unknown>,
  coreType: OralCoreType,
) {
  const { data } = await api.post<AiShadowingResult>('/api/ai/oral-eval/feedback/', {
    ref_text: refText,
    oral_result: oralResult,
    core_type: coreType,
  })
  return data
}

export async function aiShadowingTextFeedback(target: string, transcript: string) {
  const { data } = await api.post<AiShadowingResult>('/api/ai/shadowing-text-feedback/', {
    target,
    transcript,
  })
  return data
}
