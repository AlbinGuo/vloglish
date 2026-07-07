import type { Ref } from 'vue'
import { useSentenceProgressStyle } from '@/composables/useSentenceProgressStyle'
import type { Subtitle } from '@/types'
import { isSentenceActive } from '@/utils/sentenceProgress'
import type { SubtitleWordHighlight } from '@/utils/subtitleWordProgress'

/** 当前句逐词颜色跟读（#0fbb35） */
export function useSubtitleReadProgress(currentTime: Ref<number>) {
  const { sentenceProgressStyle } = useSentenceProgressStyle()

  function wordHighlightFor(sub: Subtitle | null | undefined): SubtitleWordHighlight | undefined {
    if (!sub || sentenceProgressStyle.value !== 'gradient') return undefined
    const t = currentTime.value
    if (!isSentenceActive(sub, t)) return undefined
    return { time: t, start: sub.start, end: sub.end }
  }

  return { wordHighlightFor, sentenceProgressStyle }
}
