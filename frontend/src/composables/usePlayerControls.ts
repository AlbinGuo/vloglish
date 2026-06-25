import { computed, onMounted, onUnmounted, ref, type Ref } from 'vue'

import type { Subtitle } from '@/types'



export const PLAYBACK_RATES = [0.5, 0.7, 0.75, 1, 1.25, 1.5, 2] as const

export const LOOP_COUNT_OPTIONS = [1, 2, 3, 4, 5, 10, 50, 100, 0] as const



export type LoopMode = 'off' | 'sentence' | 'ab'

export type AbLoopPhase = 'off' | 'waitB' | 'active'



export interface PlayerControlOptions {

  videoRef: Ref<HTMLVideoElement | null>

  sortedSubs: Ref<Subtitle[]>

  currentIndex: Ref<number>

  onIndexChange?: (index: number) => void

}



export function usePlayerControls(opts: PlayerControlOptions) {

  const playbackRate = ref(1)

  const loopMode = ref<LoopMode>('off')

  const sentenceLoopCount = ref(1)

  const sentenceLoopsDone = ref(0)

  const pauseAfterSentence = ref(false)

  const loopInterval = ref(0)

  const loopPointA = ref<number | null>(null)

  const loopPointB = ref<number | null>(null)

  const abLoopPhase = ref<AbLoopPhase>('off')

  const showHelp = ref(false)

  const isPlaying = ref(false)

  const currentTime = ref(0)



  let sentenceLoopTimer: ReturnType<typeof setTimeout> | null = null



  const currentSub = computed(() => opts.sortedSubs.value[opts.currentIndex.value] ?? null)



  const mainActionLabel = computed(() => (isPlaying.value ? '暂停' : '重播'))



  const loopStatusText = computed(() => {

    if (loopMode.value === 'sentence') {

      const n = sentenceLoopCount.value

      const label = n > 0 ? `${sentenceLoopsDone.value}/${n}` : '∞'

      const gap = loopInterval.value > 0 ? ` · 间隔${loopInterval.value}s` : ''

      return `单句循环 ${label}${gap}`

    }

    if (loopMode.value === 'ab' && loopPointA.value != null && loopPointB.value != null) {

      return `A-B ${formatTime(loopPointA.value)} – ${formatTime(loopPointB.value)}`

    }

    if (abLoopPhase.value === 'waitB' && loopPointA.value != null) {

      return `A 点 ${formatTime(loopPointA.value)} · 请设 B 点`

    }

    return ''

  })



  function formatTime(sec: number) {

    const m = Math.floor(sec / 60)

    const s = Math.floor(sec % 60)

    return `${m}:${String(s).padStart(2, '0')}`

  }



  function clearSentenceLoopTimer() {

    if (sentenceLoopTimer) {

      clearTimeout(sentenceLoopTimer)

      sentenceLoopTimer = null

    }

  }



  function getVideo() {

    return opts.videoRef.value

  }



  function seekTo(sub: Subtitle) {

    const v = getVideo()

    if (!v) return

    clearSentenceLoopTimer()

    v.currentTime = sub.start

    currentTime.value = sub.start

    opts.currentIndex.value = opts.sortedSubs.value.indexOf(sub)

    opts.onIndexChange?.(opts.currentIndex.value)

    sentenceLoopsDone.value = 0

  }



  function prevSentence() {

    if (opts.currentIndex.value > 0) seekTo(opts.sortedSubs.value[opts.currentIndex.value - 1])

  }



  function nextSentence() {

    if (opts.currentIndex.value < opts.sortedSubs.value.length - 1)

      seekTo(opts.sortedSubs.value[opts.currentIndex.value + 1])

  }



  function togglePlay() {

    const v = getVideo()

    if (!v) return

    if (v.paused) {

      void v.play()

      isPlaying.value = true

    } else {

      v.pause()

      isPlaying.value = false

    }

  }



  function setRate(rate: number) {

    playbackRate.value = rate

    const v = getVideo()

    if (v) v.playbackRate = rate

  }



  function adjustRate(delta: number) {

    const rates = [...PLAYBACK_RATES]

    const idx = rates.findIndex((r) => r >= playbackRate.value - 0.01)

    const next = Math.max(0, Math.min(rates.length - 1, idx + delta))

    setRate(rates[next])

  }



  function setSentenceLoopCount(count: number) {

    sentenceLoopCount.value = count

    sentenceLoopsDone.value = 0

  }



  function enableSentenceLoop() {

    loopMode.value = 'sentence'

    loopPointA.value = null

    loopPointB.value = null

    abLoopPhase.value = 'off'

    sentenceLoopsDone.value = 0

    clearSentenceLoopTimer()

    const sub = currentSub.value

    if (sub) {

      seekTo(sub)

      const v = getVideo()

      if (v) {

        void v.play()

        isPlaying.value = true

      }

    }

  }



  function toggleSentenceLoop() {

    if (loopMode.value === 'sentence') {

      loopMode.value = 'off'

      sentenceLoopsDone.value = 0

      clearSentenceLoopTimer()

    } else {

      enableSentenceLoop()

    }

  }



  function cycleLoopCount() {

    const options = [...LOOP_COUNT_OPTIONS]

    const idx = options.indexOf(sentenceLoopCount.value as typeof options[number])

    const next = options[(idx + 1) % options.length]

    setSentenceLoopCount(next)

    enableSentenceLoop()

  }



  function cycleLoopInterval() {

    loopInterval.value = loopInterval.value >= 5 ? 0 : loopInterval.value + 1

  }



  function setLoopPoint(which: 'A' | 'B') {

    const v = getVideo()

    if (!v) return

    const t = v.currentTime

    if (which === 'A') {

      if (loopMode.value === 'ab' && abLoopPhase.value === 'active') clearAbLoop()

      loopPointA.value = Math.max(0, t - 0.2)

      loopPointB.value = null

      loopMode.value = 'ab'

      abLoopPhase.value = 'waitB'

    } else {

      if (loopPointA.value == null) {

        setLoopPoint('A')

        return

      }

      if (t <= loopPointA.value + 0.5) return

      loopPointB.value = t

      loopPointA.value = Math.min(loopPointA.value, t)

      loopPointB.value = Math.max(loopPointA.value, t)

      abLoopPhase.value = 'active'

      loopMode.value = 'ab'

    }

  }



  function clearAbLoop() {

    loopPointA.value = null

    loopPointB.value = null

    abLoopPhase.value = 'off'

    if (loopMode.value === 'ab') loopMode.value = 'off'

  }



  function replayCurrentSentence() {

    const sub = currentSub.value

    if (sub) {

      seekTo(sub)

      void getVideo()?.play()

      isPlaying.value = true

    }

  }



  function handleSentenceLoopEnd(v: HTMLVideoElement, sub: Subtitle) {

    if (pauseAfterSentence.value) {

      v.pause()

      isPlaying.value = false

      return

    }



    if (sentenceLoopCount.value > 0 && sentenceLoopsDone.value >= sentenceLoopCount.value) {

      loopMode.value = 'off'

      sentenceLoopsDone.value = 0

      v.pause()

      isPlaying.value = false

      return

    }



    const restart = () => {

      sentenceLoopTimer = null

      if (sentenceLoopCount.value > 0) {

        sentenceLoopsDone.value += 1

      }

      v.currentTime = sub.start + 0.01

      void v.play()

      isPlaying.value = true

    }



    if (loopInterval.value > 0) {

      v.pause()

      isPlaying.value = false

      sentenceLoopTimer = setTimeout(restart, loopInterval.value * 1000)

    } else {

      restart()

    }

  }



  function onTimeUpdate() {

    const v = getVideo()

    if (!v || !opts.sortedSubs.value.length) return



    const t = v.currentTime

    currentTime.value = t

    const subs = opts.sortedSubs.value

    const playingIndex = opts.currentIndex.value

    const playingSub = subs[playingIndex]



    if (loopMode.value === 'sentence' && playingSub && !sentenceLoopTimer) {

      if (t >= playingSub.end - 0.05) {

        handleSentenceLoopEnd(v, playingSub)

        return

      }

    }



    const idx = subs.findIndex((s) => t >= s.start && t < s.end)

    if (idx >= 0 && idx !== opts.currentIndex.value) {

      if (loopMode.value !== 'sentence') {

        opts.currentIndex.value = idx

        opts.onIndexChange?.(idx)

        sentenceLoopsDone.value = 0

        clearSentenceLoopTimer()

      }

    }



    const sub = subs[opts.currentIndex.value]

    if (!sub) return



    if (loopMode.value === 'ab' && loopPointA.value != null && loopPointB.value != null) {

      if (t >= loopPointB.value - 0.05) {

        v.currentTime = loopPointA.value

      }

    }

  }



  function onPlayState() {

    isPlaying.value = !getVideo()?.paused

  }



  function onVideoEnded() {

    const v = getVideo()

    if (!v) return

    clearSentenceLoopTimer()

    v.currentTime = 0

    currentTime.value = 0

    if (opts.sortedSubs.value.length) {

      opts.currentIndex.value = 0

      opts.onIndexChange?.(0)

    }

    sentenceLoopsDone.value = 0

    void v.play()

    isPlaying.value = true

  }



  function handleKeydown(e: KeyboardEvent) {

    const tag = (e.target as HTMLElement)?.tagName

    if (tag === 'INPUT' || tag === 'TEXTAREA') return



    switch (e.key) {

      case ' ':

        e.preventDefault()

        if (isPlaying.value) togglePlay()

        else replayCurrentSentence()

        break

      case 'ArrowLeft':

        e.preventDefault()

        prevSentence()

        break

      case 'ArrowRight':

        e.preventDefault()

        nextSentence()

        break

      case 'ArrowUp':

        e.preventDefault()

        adjustRate(1)

        break

      case 'ArrowDown':

        e.preventDefault()

        adjustRate(-1)

        break

      case 'l':

      case 'L':

        cycleLoopCount()

        break

      case 'r':

      case 'R':

        replayCurrentSentence()

        break

      case '[':

        setLoopPoint('A')

        break

      case ']':

        setLoopPoint('B')

        break

      case 'Escape':

        if (showHelp.value) showHelp.value = false

        else clearAbLoop()

        break

      case '?':

        showHelp.value = !showHelp.value

        break

      case 'f':

      case 'F':

        break

    }

  }



  onMounted(() => window.addEventListener('keydown', handleKeydown))

  onUnmounted(() => {

    window.removeEventListener('keydown', handleKeydown)

    clearSentenceLoopTimer()

  })



  return {

    playbackRate,

    loopMode,

    sentenceLoopCount,

    sentenceLoopsDone,

    pauseAfterSentence,

    loopInterval,

    loopPointA,

    loopPointB,

    abLoopPhase,

    showHelp,

    isPlaying,

    currentTime,

    currentSub,

    mainActionLabel,

    loopStatusText,

    seekTo,

    prevSentence,

    nextSentence,

    togglePlay,

    setRate,

    setSentenceLoopCount,

    enableSentenceLoop,

    toggleSentenceLoop,

    cycleLoopCount,

    cycleLoopInterval,

    setLoopPoint,

    clearAbLoop,

    replayCurrentSentence,

    onTimeUpdate,

    onPlayState,

    onVideoEnded,

    formatTime,

  }

}

