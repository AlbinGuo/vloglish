import type { InjectionKey, Ref } from 'vue'
import { computed, onUnmounted, ref, watch } from 'vue'
import type { ArticleSegment } from '@/api/articles'
import { useReadingSettings } from '@/composables/useReadingSettings'
import { stopSpeaking } from '@/utils/speakWord'

export interface ReadingTtsContext {
  hasAudio: Ref<boolean>
  isPlaying: Ref<boolean>
  playingIndex: Ref<number | null>
  playSegment: (index: number, continuous?: boolean, rate?: number) => void
  /** 连续播放 [startIndex, endIndex] 闭区间内有音频的段落 */
  playRange: (startIndex: number, endIndex: number, rate?: number) => void
  toggleCurrent: () => void
  playContinuous: () => void
  pause: () => void
  resume: () => void
  stop: () => void
  prevSegment: () => void
  nextSegment: () => void
}

export const READING_TTS_KEY: InjectionKey<ReadingTtsContext> = Symbol('reading-tts')

export function useReadingTts(opts: {
  segments: Ref<ArticleSegment[]>
  currentIndex: Ref<number>
  setCurrentIndex: (index: number) => void
  scrollToSegment: (index: number, behavior?: ScrollBehavior) => void
}) {
  const { ttsRate, autoAdvance, autoScrollOnTts } = useReadingSettings()

  const audioEl = ref<HTMLAudioElement | null>(null)
  const isPlaying = ref(false)
  const playingIndex = ref<number | null>(null)
  const continuous = ref(false)
  /** 连播上界（含）；null 表示不限制（沿用全文 autoAdvance） */
  const rangeEndIndex = ref<number | null>(null)
  const pendingRate = ref<number | null>(null)

  const hasAudio = computed(() => opts.segments.value.some((s) => Boolean(s.audio_url?.trim())))

  function cleanupAudio() {
    if (audioEl.value) {
      audioEl.value.onended = null
      audioEl.value.onpause = null
      audioEl.value.onplay = null
      audioEl.value.pause()
      audioEl.value = null
    }
  }

  function stop() {
    continuous.value = false
    rangeEndIndex.value = null
    pendingRate.value = null
    isPlaying.value = false
    playingIndex.value = null
    cleanupAudio()
  }

  function pause() {
    audioEl.value?.pause()
    isPlaying.value = false
  }

  function resume() {
    const el = audioEl.value
    if (!el || el.ended) return
    void el.play().catch(() => {
      stop()
    })
  }

  function segmentByIndex(index: number) {
    return opts.segments.value.find((s) => s.index === index)
  }

  function playSegment(
    index: number,
    keepContinuous = continuous.value,
    rate?: number,
    endIndex?: number | null,
  ) {
    const seg = segmentByIndex(index)
    if (!seg?.audio_url?.trim()) return

    stopSpeaking()
    cleanupAudio()
    continuous.value = keepContinuous
    if (endIndex !== undefined) rangeEndIndex.value = endIndex
    if (rate != null) pendingRate.value = rate

    const el = new Audio(seg.audio_url)
    el.playbackRate = pendingRate.value ?? rate ?? ttsRate.value
    el.onplay = () => {
      isPlaying.value = true
      playingIndex.value = index
      opts.setCurrentIndex(index)
      if (autoScrollOnTts.value) opts.scrollToSegment(index)
    }
    el.onpause = () => {
      if (!el.ended) isPlaying.value = false
    }
    el.onended = () => {
      isPlaying.value = false
      cleanupAudio()

      const end = rangeEndIndex.value
      const nextIndex = index + 1
      if (end != null) {
        if (!continuous.value || nextIndex > end) {
          continuous.value = false
          rangeEndIndex.value = null
          pendingRate.value = null
          playingIndex.value = null
          return
        }
        const hasNext = opts.segments.value.some(
          (s) => s.index === nextIndex && nextIndex <= end && s.audio_url?.trim(),
        )
        if (hasNext) {
          playSegment(nextIndex, true, pendingRate.value ?? undefined, end)
        } else {
          continuous.value = false
          rangeEndIndex.value = null
          pendingRate.value = null
          playingIndex.value = null
        }
        return
      }

      const shouldAdvance = continuous.value || autoAdvance.value
      if (!shouldAdvance) {
        continuous.value = false
        playingIndex.value = null
        return
      }

      const hasNext = opts.segments.value.some((s) => s.index === nextIndex && s.audio_url?.trim())
      if (hasNext) {
        playSegment(nextIndex, true, pendingRate.value ?? undefined)
      } else {
        continuous.value = false
        pendingRate.value = null
        playingIndex.value = null
      }
    }

    audioEl.value = el
    void el.play().catch(() => {
      stop()
    })
  }

  function playRange(startIndex: number, endIndex: number, rate?: number) {
    const start = Math.min(startIndex, endIndex)
    const end = Math.max(startIndex, endIndex)
    playSegment(start, true, rate, end)
  }

  function toggleCurrent() {
    if (isPlaying.value && playingIndex.value === opts.currentIndex.value) {
      pause()
      return
    }
    if (isPlaying.value) {
      playSegment(opts.currentIndex.value, false)
      return
    }
    playSegment(opts.currentIndex.value, false)
  }

  function playContinuous() {
    playSegment(opts.currentIndex.value, true)
  }

  function prevSegment() {
    const prev = Math.max(0, opts.currentIndex.value - 1)
    opts.setCurrentIndex(prev)
    if (autoScrollOnTts.value) opts.scrollToSegment(prev)
    if (isPlaying.value) playSegment(prev, continuous.value)
  }

  function nextSegment() {
    const max = Math.max(0, opts.segments.value.length - 1)
    const next = Math.min(max, opts.currentIndex.value + 1)
    opts.setCurrentIndex(next)
    if (autoScrollOnTts.value) opts.scrollToSegment(next)
    if (isPlaying.value) playSegment(next, continuous.value)
  }

  watch(ttsRate, (rate) => {
    if (audioEl.value) audioEl.value.playbackRate = rate
  })

  onUnmounted(stop)

  return {
    hasAudio,
    isPlaying,
    playingIndex,
    playSegment,
    playRange,
    toggleCurrent,
    playContinuous,
    pause,
    resume,
    stop,
    prevSegment,
    nextSegment,
  }
}
