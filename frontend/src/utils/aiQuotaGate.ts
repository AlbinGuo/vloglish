/** 识别「今日 AI 次数已用完」并弹出确认（不强制跳转） */

export function isAiQuotaExhaustedDetail(detail: unknown): boolean {
  return typeof detail === 'string' && detail.includes('AI 次数已用完')
}

export function extractErrorDetail(err: unknown): string | null {
  if (!err || typeof err !== 'object') {
    if (err instanceof Error && err.message) return err.message
    return null
  }
  const ax = err as {
    message?: string
    response?: { data?: { detail?: unknown } }
  }
  const fromBody = ax.response?.data?.detail
  if (typeof fromBody === 'string' && fromBody) return fromBody
  if (err instanceof Error && err.message) return err.message
  if (typeof ax.message === 'string' && ax.message) return ax.message
  return null
}

/** 若为 AI 额度用尽，弹出确认框并返回 true */
export async function promptIfAiQuotaExhausted(err: unknown): Promise<boolean> {
  const detail = extractErrorDetail(err)
  if (!isAiQuotaExhaustedDetail(detail)) return false
  const { useAiQuotaPromptStore } = await import('@/stores/aiQuotaPrompt')
  useAiQuotaPromptStore().show(detail || '')
  return true
}
