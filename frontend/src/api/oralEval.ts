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

function apiDetail(error: unknown, fallback: string): string {
  const err = error as {
    response?: { data?: { detail?: unknown }; status?: number }
    message?: string
  }
  const detail = err.response?.data?.detail
  if (typeof detail === 'string' && detail.trim()) return detail.trim()
  if (Array.isArray(detail)) {
    const first = detail.find((x) => typeof x === 'string' || (x && typeof x === 'object'))
    if (typeof first === 'string' && first.trim()) return first.trim()
    if (first && typeof first === 'object' && 'msg' in first) {
      const msg = (first as { msg?: unknown }).msg
      if (typeof msg === 'string' && msg.trim()) return msg.trim()
    }
  }
  if (typeof err.message === 'string' && err.message.trim()) {
    // 把 axios 通用 502 文案换成更可读的提示
    if (/status code 502/i.test(err.message)) return fallback
    return err.message.trim()
  }
  return fallback
}

export async function fetchOralEvalWarrant() {
  try {
    const { data } = await api.post<OralEvalWarrant>('/api/ai/oral-eval/warrant/')
    return data
  } catch (e) {
    throw new Error(apiDetail(e, '口语评测授权失败，请稍后重试'))
  }
}

export async function aiShadowingOralFeedback(
  videoId: string,
  subtitleId: number,
  oralResult: Record<string, unknown>,
) {
  try {
    const { data } = await api.post<AiShadowingResult>('/api/ai/shadowing-oral-feedback/', {
      video_id: videoId,
      subtitle_id: subtitleId,
      oral_result: oralResult,
    })
    return data
  } catch (e) {
    throw new Error(apiDetail(e, '口语评测结果提交失败'))
  }
}

export async function aiOralEvalFeedback(
  refText: string,
  oralResult: Record<string, unknown>,
  coreType: OralCoreType,
) {
  try {
    const { data } = await api.post<AiShadowingResult>('/api/ai/oral-eval/feedback/', {
      ref_text: refText,
      oral_result: oralResult,
      core_type: coreType,
    })
    return data
  } catch (e) {
    throw new Error(apiDetail(e, '口语评测结果提交失败'))
  }
}

export async function aiShadowingTextFeedback(target: string, transcript: string) {
  const { data } = await api.post<AiShadowingResult>('/api/ai/shadowing-text-feedback/', {
    target,
    transcript,
  })
  return data
}
