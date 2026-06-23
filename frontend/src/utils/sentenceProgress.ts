import type { Subtitle } from '@/types'

export function isSentenceActive(sub: Subtitle, t: number): boolean {
  return t >= sub.start && t < sub.end
}

export function computeSentenceProgress(sub: Subtitle, t: number): number {
  if (!isSentenceActive(sub, t)) return 0
  const duration = sub.end - sub.start
  if (duration <= 0) return 0
  return Math.min(1, Math.max(0, (t - sub.start) / duration))
}
