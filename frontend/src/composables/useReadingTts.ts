import type { InjectionKey, Ref } from 'vue'
import { computed, onUnmounted, ref, watch } from 'vue'
import type { ArticleSegment } from '@/api/articles'
import { fetchClonedSpeak } from '@/api/voiceClone'
import { useReadingSettings } from '@/composables/useReadingSettings'
import { useVoiceCloneStore } from '@/stores/voiceClone'
import { stopSpeaking } from '@/utils/speakWord'

const SILENT_WAV =
  'data:audio/wav;base64,UklGRigAAABXQVZFZm10IBIAAAABAAEARKwAAIhYAQACABAAAABkYXRhAgAAAAEA'

export interface ReadingTtsContext {
  hasAudio: Ref<boolean>
  usingCloned: Ref<boolean>
  synthesizing: Ref<boolean>
  error: Ref<string>
  isPlaying: Ref<boolean>
  playingIndex: Ref<number | null>
  canPlaySegment: (index: number) => boolean
  playSegment: (index: number, continuous?: boolean, rate?: number) => void
  /** 连续播放 [startIndex, endIndex] 闭区间内可朗读的段落 */
  playRange: (startIndex: number, endIndex: number, rate?: number) => void
  toggleCurrent: () => void
  playContinuous: () => void
  pause: () => void
  resume: () => void
  stop: () => void
  prevSegment: () => void
  nextSegment: () => void
  replayCurrent: () => void
}

export const READING_TTS_KEY: InjectionKey<ReadingTtsContext> = Symbol('reading-tts')

export function useReadingTts(opts: {
  segments: Ref<ArticleSegment[]>
  currentIndex: Ref<number>
  setCurrentIndex: (index: number) => void
  scrollToSegment: (index: number, behavior?: ScrollBehavior) => void
}) {
  const { ttsRate, autoAdvance, autoScrollOnTts } = useReadingSettings()
  const voiceClone = useVoiceCloneStore()

  const audioEl = ref<HTMLAudioElement | null>(null)
  const isPlaying = ref(false)
  const playingIndex = ref<number | null>(null)
  const synthesizing = ref(false)
  const error = ref('')
  const continuous = ref(false)
  /** 连播上界（含）；null 表示不限制（沿用全文 autoAdvance） */
  const rangeEndIndex = ref<number | null>(null)
  const pendingRate = ref<number | null>(null)
  let playGen = 0
  let objectUrl: string | null = null
  let unlocked = false

  const usingCloned = computed(
    () => voiceClone.subtitleVoiceMode === 'cloned' && voiceClone.hasClonedVoice,
  )

  const hasPrebuiltAudio = computed(() =>
    opts.segments.value.some((s) => Boolean(s.audio_url?.trim())),
  )
  const hasClonedPlayable = computed(
    () => voiceClone.hasClonedVoice && opts.segments.value.some((s) => Boolean(s.english?.trim())),
  )
  const hasAudio = computed(() => hasPrebuiltAudio.value || hasClonedPlayable.value)

  function canPlaySegment(index: number): boolean {
    const seg = segmentByIndex(index)
    if (!seg) return false
    if (usingCloned.value) return Boolean(seg.english?.trim())
    return Boolean(seg.audio_url?.trim())
  }

  function segmentByIndex(index: number): ArticleSegment | undefined {
    return opts.segments.value.find((s) => s.index === index)
  }

  function revokeObjectUrl() {
    if (objectUrl) {
      URL.revokeObjectURL(objectUrl)
      objectUrl = null
    }
  }

  function ensureAudio(): HTMLAudioElement {
    if (!audioEl.value) {
      const el = new Audio()
      el.preload = 'auto'
      el.playsInline = true
      el.setAttribute('playsinline', 'true')
      audioEl.value = el
    }
    return audioEl.value
  }

  function detachHandlers(el: HTMLAudioElement) {
    el.onended = null
    el.onerror = null
    el.onpause = null
    el.onplay = null
  }

  function cleanupAudio() {
    synthesizing.value = false
    if (audioEl.value) {
      try {
        detachHandlers(audioEl.value)
        audioEl.value.pause()
      } catch {
        /* ignore */
      }
    }
    revokeObjectUrl()
  }

  function stop() {
    playGen += 1
    continuous.value = false
    rangeEndIndex.value = null
    pendingRate.value = null
    isPlaying.value = false
    playingIndex.value = null
    synthesizing.value = false
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

  /** 必须在用户点击的同步调用链里执行，避免合成等待后被自动播放策略拦住。 */
  function unlock(): void {
    const el = ensureAudio()
    try {
      el.muted = true
      el.loop = true
      if (!unlocked) el.src = SILENT_WAV
      const p = el.play()
      if (p && typeof p.then === 'function') {
        void p
          .then(() => {
            unlocked = true
          })
          .catch(() => {
            /* 仍尝试后续 play */
          })
      } else {
        unlocked = true
      }
    } catch {
      /* ignore */
    }
  }

  function prefetchCloned(index: number) {
    if (!usingCloned.value) return
    const seg = segmentByIndex(index)
    const text = (seg?.english || '').trim().replace(/\s+/g, ' ')
    if (!text) return
    void fetchClonedSpeak(text).catch(() => {
      /* ignore */
    })
  }

  function bindAndPlay(el: HTMLAudioElement, index: number, src: string, cloned: boolean) {
    detachHandlers(el)
    if (cloned) {
      const prev = objectUrl
      objectUrl = src
      if (prev && prev !== src) URL.revokeObjectURL(prev)
    } else {
      revokeObjectUrl()
    }
    el.loop = false
    el.muted = false
    el.playbackRate = pendingRate.value ?? ttsRate.value
    el.src = src
    el.onplay = () => {
      synthesizing.value = false
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
      synthesizing.value = false
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
        if (canPlaySegment(nextIndex) && nextIndex <= end) {
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

      if (canPlaySegment(nextIndex)) {
        playSegment(nextIndex, true, pendingRate.value ?? undefined)
      } else {
        continuous.value = false
        pendingRate.value = null
        playingIndex.value = null
      }
    }
    el.onerror = () => {
      synthesizing.value = false
      error.value = '音频播放失败'
      isPlaying.value = false
    }
    void el.play().catch(() => {
      error.value = '浏览器拦截了朗读，请再点一次播放'
      stop()
    })
    prefetchCloned(index + 1)
  }

  function playSegment(
    index: number,
    keepContinuous = continuous.value,
    rate?: number,
    endIndex?: number | null,
  ) {
    const seg = segmentByIndex(index)
    if (!seg) return
    const cloned = usingCloned.value
    if (cloned) {
      if (!seg.english?.trim()) return
    } else if (!seg.audio_url?.trim()) {
      return
    }

    stopSpeaking()
    const gen = ++playGen
    continuous.value = keepContinuous
    if (endIndex !== undefined) rangeEndIndex.value = endIndex
    if (rate != null) pendingRate.value = rate
    error.value = ''
    playingIndex.value = index
    opts.setCurrentIndex(index)

    const el = ensureAudio()
    detachHandlers(el)

    if (!cloned) {
      synthesizing.value = false
      bindAndPlay(el, index, seg.audio_url, false)
      return
    }

    unlock()
    synthesizing.value = true
    const text = seg.english.trim().replace(/\s+/g, ' ')
    void fetchClonedSpeak(text)
      .then((blob) => {
        if (gen !== playGen) return
        const url = URL.createObjectURL(blob)
        bindAndPlay(el, index, url, true)
      })
      .catch((e: unknown) => {
        if (gen !== playGen) return
        synthesizing.value = false
        error.value = e instanceof Error ? e.message : '复刻朗读失败'
        isPlaying.value = false
        playingIndex.value = null
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
    playSegment(opts.currentIndex.value, false)
  }

  function playContinuous() {
    playSegment(opts.currentIndex.value, true)
  }

  function replayCurrent() {
    if (playingIndex.value == null && !isPlaying.value && !synthesizing.value) return
    const idx = playingIndex.value ?? opts.currentIndex.value
    playSegment(idx, continuous.value, pendingRate.value ?? undefined, rangeEndIndex.value)
  }

  function prevSegment() {
    const prev = Math.max(0, opts.currentIndex.value - 1)
    opts.setCurrentIndex(prev)
    if (autoScrollOnTts.value) opts.scrollToSegment(prev)
    if (isPlaying.value || synthesizing.value) playSegment(prev, continuous.value)
  }

  function nextSegment() {
    const max = Math.max(0, opts.segments.value.length - 1)
    const next = Math.min(max, opts.currentIndex.value + 1)
    opts.setCurrentIndex(next)
    if (autoScrollOnTts.value) opts.scrollToSegment(next)
    if (isPlaying.value || synthesizing.value) playSegment(next, continuous.value)
  }

  watch(ttsRate, (rate) => {
    if (audioEl.value) audioEl.value.playbackRate = rate
  })

  watch(usingCloned, () => {
    if (isPlaying.value || synthesizing.value) replayCurrent()
  })

  onUnmounted(() => {
    stop()
    if (audioEl.value) {
      audioEl.value.src = ''
      audioEl.value = null
    }
    unlocked = false
  })

  return {
    hasAudio,
    usingCloned,
    synthesizing,
    error,
    isPlaying,
    playingIndex,
    canPlaySegment,
    playSegment,
    playRange,
    toggleCurrent,
    playContinuous,
    pause,
    resume,
    stop,
    prevSegment,
    nextSegment,
    replayCurrent,
  }
}
