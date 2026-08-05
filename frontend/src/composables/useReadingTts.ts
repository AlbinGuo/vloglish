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
  toggleCurrent: () => void
  playContinuous: () => void
  pause: () => void
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
    isPlaying.value = false
    playingIndex.value = null
    cleanupAudio()
  }

  function pause() {
    continuous.value = false
    audioEl.value?.pause()
    isPlaying.value = false
  }

  function segmentByIndex(index: number) {
    return opts.segments.value.find((s) => s.index === index)
  }

  function playSegment(index: number, keepContinuous = continuous.value, rate?: number) {
    const seg = segmentByIndex(index)
    if (!seg?.audio_url?.trim()) return

    stopSpeaking()
    cleanupAudio()
    continuous.value = keepContinuous

    const el = new Audio(seg.audio_url)
    el.playbackRate = rate ?? ttsRate.value
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
      playingIndex.value = null
      cleanupAudio()

      const shouldAdvance = continuous.value || autoAdvance.value
      if (!shouldAdvance) {
        continuous.value = false
        return
      }

      const nextIndex = index + 1
      const hasNext = opts.segments.value.some((s) => s.index === nextIndex && s.audio_url?.trim())
      if (hasNext) {
        playSegment(nextIndex, true)
      } else {
        continuous.value = false
      }
    }

    audioEl.value = el
    void el.play().catch(() => {
      stop()
    })
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
    toggleCurrent,
    playContinuous,
    pause,
    stop,
    prevSegment,
    nextSegment,
  }
}
