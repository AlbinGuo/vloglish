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

  onPlaybackComplete?: () => void

  onWatchTick?: (deltaSec: number) => void

  /** 单句循环次数播完并暂停时回调（用于听写等；非「自动下一句」时按句触发） */
  onSentenceLoopComplete?: (sub: Subtitle) => void

  /** 连续跟读整段结束（最后一句次数播完） */
  onContinuousLoopComplete?: (payload: { lastSub: Subtitle; openDictation: boolean }) => void

}



export function usePlayerControls(opts: PlayerControlOptions) {

  const playbackRate = ref(1)

  const loopMode = ref<LoopMode>('off')

  /** 默认 1 遍 */
  const sentenceLoopCount = ref(1)

  const sentenceLoopsDone = ref(0)

  const pauseAfterSentence = ref(false)

  const dictationAfterLoop = ref(
    (() => {
      try {
        return localStorage.getItem('teco-dictation-after-loop') === '1'
      } catch {
        return false
      }
    })(),
  )

  /** 单句次数播完后自动进入下一句（连续跟读） */
  const autoAdvanceAfterLoop = ref(
    (() => {
      try {
        const raw = localStorage.getItem('teco-auto-advance-after-loop')
        if (raw === null) return true
        return raw === '1'
      } catch {
        return true
      }
    })(),
  )

  /** 句间间隔；连续跟读时若为 0 则按 1 秒停顿 */
  const loopInterval = ref(1)

  /** 听写「再听一遍」：播完当前句后自动暂停 */
  let oneShotPauseSub: Subtitle | null = null

  const loopPointA = ref<number | null>(null)

  const loopPointB = ref<number | null>(null)

  const abLoopPhase = ref<AbLoopPhase>('off')

  const showHelp = ref(false)

  const isPlaying = ref(false)

  const currentTime = ref(0)



  let sentenceLoopTimer: ReturnType<typeof setTimeout> | null = null

  let lastWatchTime = 0



  const currentSub = computed(() => opts.sortedSubs.value[opts.currentIndex.value] ?? null)



  const mainActionLabel = computed(() => (isPlaying.value ? '暂停' : '重播'))



  const loopStatusText = computed(() => {

    if (loopMode.value === 'sentence') {

      const n = sentenceLoopCount.value

      const label = n > 0 ? `${sentenceLoopsDone.value}/${n}` : '∞'

      const gapSec = effectiveLoopGapSec()

      const gap = gapSec > 0 ? ` · 间隔${gapSec}s` : ''

      const advance =
        autoAdvanceAfterLoop.value && n > 0 ? ' · 自动下一句' : ''

      return `单句循环 ${label}${gap}${advance}`

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



  /**
   * 听写完成后进入下一句：重新开启单句循环并播放。
   * finishSentenceLoop 会把 loopMode 关掉，若只 seek 下一句，播完不会再触发听写弹窗。
   */
  function advanceAfterDictation() {

    const subs = opts.sortedSubs.value

    const nextIdx = opts.currentIndex.value + 1

    if (nextIdx >= subs.length) return false



    clearSentenceLoopTimer()

    oneShotPauseSub = null

    loopMode.value = 'sentence'

    loopPointA.value = null

    loopPointB.value = null

    abLoopPhase.value = 'off'

    sentenceLoopsDone.value = 0



    seekTo(subs[nextIdx])

    const v = getVideo()

    if (v) {

      void v.play()

      isPlaying.value = true

    }

    return true

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

    startSentenceLoop(currentSub.value)

  }



  /** 从指定字幕开启单句循环并播放（听写：先播满次数再填空） */
  function startSentenceLoop(sub: Subtitle | null | undefined) {

    if (!sub) return false

    loopMode.value = 'sentence'

    loopPointA.value = null

    loopPointB.value = null

    abLoopPhase.value = 'off'

    sentenceLoopsDone.value = 0

    clearSentenceLoopTimer()

    oneShotPauseSub = null

    seekTo(sub)

    const v = getVideo()

    if (v) {

      void v.play()

      isPlaying.value = true

    }

    return true

  }



  /** 单句听写入口：确保有限次数 + 播完后听写，并从该句开始循环 */
  function startDictationLoop(sub: Subtitle, count?: number) {

    const n = count ?? sentenceLoopCount.value

    sentenceLoopCount.value = n > 0 ? n : 1

    dictationAfterLoop.value = true

    try {

      localStorage.setItem('teco-dictation-after-loop', '1')

    } catch {

      // ignore

    }

    return startSentenceLoop(sub)

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

      oneShotPauseSub = null

      seekTo(sub)

      void getVideo()?.play()

      isPlaying.value = true

    }

  }



  function playSentenceOnce(sub?: Subtitle | null) {

    const target = sub ?? currentSub.value

    if (!target) return

    clearSentenceLoopTimer()

    oneShotPauseSub = target

    seekTo(target)

    void getVideo()?.play()

    isPlaying.value = true

  }



  function setDictationAfterLoop(on: boolean) {

    dictationAfterLoop.value = on

    try {

      localStorage.setItem('teco-dictation-after-loop', on ? '1' : '0')

    } catch {

      // ignore

    }

  }



  function effectiveLoopGapSec() {
    if (loopInterval.value > 0) return loopInterval.value
    // 连续跟读时句与句之间至少短暂停顿 1 秒
    if (autoAdvanceAfterLoop.value && sentenceLoopCount.value > 0) return 1
    return 0
  }

  function setAutoAdvanceAfterLoop(on: boolean) {
    autoAdvanceAfterLoop.value = on
    try {
      localStorage.setItem('teco-auto-advance-after-loop', on ? '1' : '0')
    } catch {
      // ignore
    }
  }

  function finishSentenceLoop(v: HTMLVideoElement, sub: Subtitle) {
    clearSentenceLoopTimer()
    oneShotPauseSub = null

    const canAutoAdvance =
      autoAdvanceAfterLoop.value && sentenceLoopCount.value > 0

    if (canAutoAdvance) {
      const subs = opts.sortedSubs.value
      const nextIdx = opts.currentIndex.value + 1
      if (nextIdx < subs.length) {
        const gapMs = effectiveLoopGapSec() * 1000
        // 句间停顿：视频继续播，不 pause；到点后跳到下一句重计遍数
        const goNext = () => {
          sentenceLoopTimer = null
          sentenceLoopsDone.value = 0
          seekTo(subs[nextIdx])
          if (v.paused) void v.play()
          isPlaying.value = true
        }
        if (gapMs > 0) {
          isPlaying.value = true
          if (v.paused) void v.play()
          sentenceLoopTimer = setTimeout(goNext, gapMs)
        } else {
          goNext()
        }
        return
      }

      // 最后一句次数播完：整段结束
      loopMode.value = 'off'
      sentenceLoopsDone.value = 0
      v.pause()
      isPlaying.value = false
      pinToSubtitle(v, sub)
      opts.onContinuousLoopComplete?.({
        lastSub: sub,
        openDictation: dictationAfterLoop.value,
      })
      return
    }

    loopMode.value = 'off'
    sentenceLoopsDone.value = 0
    v.pause()
    isPlaying.value = false
    // 停在本句起点，避免 currentTime 落在下一句区间导致字幕列表跳转
    pinToSubtitle(v, sub)

    if (dictationAfterLoop.value) {
      opts.onSentenceLoopComplete?.(sub)
    }
  }



  function pinToSubtitle(v: HTMLVideoElement, sub: Subtitle) {

    const idx = opts.sortedSubs.value.indexOf(sub)

    v.currentTime = sub.start

    currentTime.value = sub.start

    if (idx >= 0) {

      opts.currentIndex.value = idx

      opts.onIndexChange?.(idx)

    }

  }



  function handleSentenceLoopEnd(v: HTMLVideoElement, sub: Subtitle) {

    // 本遍播放结束再计数：循环 N 次 = 实际播放 N 遍后进入听写
    if (sentenceLoopCount.value > 0) {

      sentenceLoopsDone.value += 1

      if (sentenceLoopsDone.value >= sentenceLoopCount.value) {

        finishSentenceLoop(v, sub)

        return

      }

    }



    // 听写流程需要连续播满次数，不受「单句暂停」打断
    if (pauseAfterSentence.value && !dictationAfterLoop.value) {

      v.pause()

      isPlaying.value = false

      pinToSubtitle(v, sub)

      return

    }



    // 同一句多遍：第一遍结束立刻接下一遍，不停顿、不 pause
    clearSentenceLoopTimer()

    v.currentTime = sub.start + 0.01

    currentTime.value = sub.start + 0.01

    if (v.paused) void v.play()

    isPlaying.value = true

  }



  function onTimeUpdate() {

    const v = getVideo()

    if (!v || !opts.sortedSubs.value.length) return



    const t = v.currentTime

    currentTime.value = t

    if (opts.onWatchTick && lastWatchTime > 0 && t > lastWatchTime) {
      opts.onWatchTick(Math.min(t - lastWatchTime, 2))
    }
    lastWatchTime = t

    if (oneShotPauseSub && t >= oneShotPauseSub.end - 0.05) {

      const done = oneShotPauseSub

      oneShotPauseSub = null

      v.pause()

      isPlaying.value = false

      pinToSubtitle(v, done)

      return

    }

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

    opts.onPlaybackComplete?.()

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

    dictationAfterLoop,

    setDictationAfterLoop,

    autoAdvanceAfterLoop,

    setAutoAdvanceAfterLoop,

    playSentenceOnce,

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

    advanceAfterDictation,

    togglePlay,

    setRate,

    setSentenceLoopCount,

    enableSentenceLoop,

    startSentenceLoop,

    startDictationLoop,

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

