import { computed, onMounted, onUnmounted, ref, type Ref } from 'vue'

import type { Subtitle } from '@/types'
import { resumeMedia } from '@/utils/playMedia'



export const PLAYBACK_RATES = [0.5, 0.7, 0.75, 1, 1.25, 1.5, 2] as const

export const LOOP_COUNT_OPTIONS = [1, 2, 3, 4, 5, 10, 50, 100] as const



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

  /** 返回 true 表示已接管重播（如复刻 TTS 链） */
  onReplaySentence?: () => boolean

  /** 返回 true 表示已接管上一句/下一句 */
  onStepSentence?: (delta: 1 | -1) => boolean

  /** 返回 true 表示已接管播放/暂停（复刻模式下用 TTS） */
  onTogglePlay?: () => boolean

}



export function usePlayerControls(opts: PlayerControlOptions) {

  const playbackRate = ref(1)

  const loopMode = ref<LoopMode>('off')

  /** 默认 1 遍 */
  const sentenceLoopCount = ref(1)

  function clampLoopCount(count: number) {
    if (!Number.isFinite(count) || count < 1) return 1
    return Math.floor(count)
  }

  /** 进入单句循环模式但不强制开播（开关立即生效用） */
  function armSentenceLoopMode() {
    const alreadyOn = loopMode.value === 'sentence'
    loopMode.value = 'sentence'
    loopPointA.value = null
    loopPointB.value = null
    abLoopPhase.value = 'off'
    if (!alreadyOn) sentenceLoopsDone.value = 0
    clearSentenceLoopTimer()
    oneShotPauseSub = null

    // 若从句中途打开循环，先回到句首，避免「半句」被算作第一遍
    const sub = currentSub.value
    const v = getVideo()
    if (sub && v && v.currentTime > sub.start + 0.12) {
      v.currentTime = sub.start
      currentTime.value = sub.start
      sentenceLoopsDone.value = 0
    }
  }

  const sentenceLoopsDone = ref(0)

  const pauseAfterSentence = ref(
    (() => {
      try {
        return localStorage.getItem('teco-pause-after-sentence') === '1'
      } catch {
        return false
      }
    })(),
  )

  /** 句末停下时的短提示（「本句结束 · 点播放继续」） */
  const pauseHintText = ref('')
  let pauseHintTimer: ReturnType<typeof setTimeout> | null = null

  function flashPauseHint(text: string, ms = 1600) {
    if (pauseHintTimer) {
      clearTimeout(pauseHintTimer)
      pauseHintTimer = null
    }
    pauseHintText.value = text
    pauseHintTimer = setTimeout(() => {
      pauseHintTimer = null
      pauseHintText.value = ''
    }, ms)
  }

  const dictationAfterLoop = ref(
    (() => {
      try {
        return localStorage.getItem('teco-dictation-after-loop') === '1'
      } catch {
        return false
      }
    })(),
  )

  /** 单句次数播完后自动进入下一句（默认开启） */
  const autoAdvanceAfterLoop = ref(
    (() => {
      try {
        const raw = localStorage.getItem('teco-auto-advance-after-loop')
        if (raw === null) {
          localStorage.setItem('teco-auto-advance-after-loop', '1')
          return true
        }
        return raw === '1'
      } catch {
        return true
      }
    })(),
  )

  function setPauseAfterSentence(on: boolean) {
    pauseAfterSentence.value = on
    try {
      localStorage.setItem('teco-pause-after-sentence', on ? '1' : '0')
    } catch {
      // ignore
    }
    if (on) {
      armSentenceLoopMode()
      // 与「自动下一句」互斥
      if (autoAdvanceAfterLoop.value) setAutoAdvanceAfterLoop(false)
    } else {
      // 关闭句末停下时恢复默认：自动下一句
      setAutoAdvanceAfterLoop(true)
    }
  }

  /** 句间 / 遍间间隔（秒）；0 = 无缝接下一遍或下一句 */
  const loopInterval = ref(
    (() => {
      try {
        const raw = Number(localStorage.getItem('teco-loop-interval') || '0')
        if (!Number.isFinite(raw)) return 0
        return Math.min(5, Math.max(0, Math.floor(raw)))
      } catch {
        return 0
      }
    })(),
  )

  const gapRemainingMs = ref(0)
  const gapDurationMs = ref(0)
  const gapKind = ref<'repeat' | 'next' | ''>('')
  const gapActive = computed(() => gapKind.value !== '')

  /** 听写「再听一遍」：播完当前句后自动暂停 */
  let oneShotPauseSub: Subtitle | null = null

  const loopPointA = ref<number | null>(null)

  const loopPointB = ref<number | null>(null)

  const abLoopPhase = ref<AbLoopPhase>('off')

  const showHelp = ref(false)

  const isPlaying = ref(false)

  const currentTime = ref(0)



  let sentenceLoopTimer: ReturnType<typeof setTimeout> | null = null
  let gapTickTimer: ReturnType<typeof setInterval> | null = null
  /** 间隔时冻住播放头，避免漏出下一句 */
  let sentenceHoldAt: number | null = null
  let gapOnDone: (() => void) | null = null
  let gapDeadlineAt = 0

  let lastWatchTime = 0



  const currentSub = computed(() => opts.sortedSubs.value[opts.currentIndex.value] ?? null)



  const mainActionLabel = computed(() => (isPlaying.value ? '暂停' : '重播'))



  const loopStatusText = computed(() => {

    if (loopMode.value === 'sentence') {

      const n = sentenceLoopCount.value

      const label = `${sentenceLoopsDone.value}/${n}`

      const gapSec = effectiveLoopGapSec()

      const gap = gapSec > 0 ? ` · 间隔${gapSec}s` : ''

      const advance = autoAdvanceAfterLoop.value ? ' · 自动下一句' : ''

      const pause = pauseAfterSentence.value ? ' · 句末停下' : ''

      return `单句循环 ${label}${gap}${advance}${pause}`

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



  function clearGapUi() {
    if (gapTickTimer) {
      clearInterval(gapTickTimer)
      gapTickTimer = null
    }
    gapRemainingMs.value = 0
    gapDurationMs.value = 0
    gapKind.value = ''
    gapDeadlineAt = 0
  }

  function clearSentenceLoopTimer() {
    if (sentenceLoopTimer) {
      clearTimeout(sentenceLoopTimer)
      sentenceLoopTimer = null
    }
    sentenceHoldAt = null
    gapOnDone = null
    clearGapUi()
  }

  function skipGapHold() {
    const fn = gapOnDone
    gapOnDone = null
    clearSentenceLoopTimer()
    fn?.()
  }



  function getVideo() {

    return opts.videoRef.value

  }



  function seekTo(sub: Subtitle) {
    clearSentenceLoopTimer()

    // 按 id 定位，避免 sortedSubs 重算后 indexOf 引用失效变成 -1
    const idx = opts.sortedSubs.value.findIndex((s) => s.id === sub.id)
    if (idx >= 0) {
      opts.currentIndex.value = idx
      opts.onIndexChange?.(idx)
    }

    const v = getVideo()
    if (!v) {
      // 播放器未挂载时仍更新当前句，视频就绪后再靠 currentTime 对齐
      currentTime.value = sub.start
      sentenceLoopsDone.value = 0
      return
    }

    v.currentTime = sub.start
    currentTime.value = sub.start
    sentenceLoopsDone.value = 0
  }



  function playAfterSeekIfPauseMode() {
    if (!pauseAfterSentence.value || dictationAfterLoop.value) return
    loopMode.value = 'sentence'
    const v = getVideo()
    if (!v) return
    void resumeMedia(v).then((ok) => {
      isPlaying.value = ok
    })
  }

  function prevSentence() {

    if (opts.onStepSentence?.(-1)) return

    if (opts.currentIndex.value > 0) {
      sentenceLoopsDone.value = 0
      clearSentenceLoopTimer()
      seekTo(opts.sortedSubs.value[opts.currentIndex.value - 1])
      playAfterSeekIfPauseMode()
    }

  }



  function nextSentence() {

    if (opts.onStepSentence?.(1)) return

    if (opts.currentIndex.value < opts.sortedSubs.value.length - 1) {
      sentenceLoopsDone.value = 0
      clearSentenceLoopTimer()
      seekTo(opts.sortedSubs.value[opts.currentIndex.value + 1])
      // 句末停下：换句后自动开播，播完再停
      playAfterSeekIfPauseMode()
    }

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
    if (opts.onTogglePlay?.()) return
    const v = getVideo()
    if (!v) return
    if (gapOnDone) {
      skipGapHold()
      return
    }
    if (v.paused || v.ended) {
      void resumeMedia(v).then((ok) => {
        isPlaying.value = ok
      })
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

    sentenceLoopCount.value = clampLoopCount(count)

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

    const cur = clampLoopCount(sentenceLoopCount.value)

    const idx = options.indexOf(cur as (typeof options)[number])

    const next = options[(idx >= 0 ? idx + 1 : 0) % options.length]

    setSentenceLoopCount(next)

    enableSentenceLoop()

  }



  function cycleLoopInterval() {
    loopInterval.value = loopInterval.value >= 5 ? 0 : loopInterval.value + 1
    try {
      localStorage.setItem('teco-loop-interval', String(loopInterval.value))
    } catch {
      // ignore
    }
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

    if (opts.onReplaySentence?.()) return

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
    return Math.max(0, loopInterval.value || 0)
  }

  function beginGapHold(
    v: HTMLVideoElement,
    sub: Subtitle,
    gapSec: number,
    kind: 'repeat' | 'next',
    onDone: () => void,
  ) {
    const gapMs = Math.round(Math.max(0, gapSec) * 1000)
    if (gapMs <= 0) {
      onDone()
      return
    }

    clearSentenceLoopTimer()
    const hold = Math.max(sub.start, sub.end - 0.05)
    sentenceHoldAt = hold
    v.currentTime = hold
    currentTime.value = hold
    v.pause()
    isPlaying.value = true

    gapKind.value = kind
    gapDurationMs.value = gapMs
    gapRemainingMs.value = gapMs
    gapDeadlineAt = performance.now() + gapMs
    gapOnDone = onDone

    gapTickTimer = setInterval(() => {
      const left = Math.max(0, gapDeadlineAt - performance.now())
      gapRemainingMs.value = left
      if (left <= 0 && gapTickTimer) {
        clearInterval(gapTickTimer)
        gapTickTimer = null
      }
    }, 80)

    sentenceLoopTimer = setTimeout(() => {
      const fn = gapOnDone
      gapOnDone = null
      clearSentenceLoopTimer()
      fn?.()
    }, gapMs)
  }

  function replaySameSentenceAfterGap(v: HTMLVideoElement, sub: Subtitle) {
    const gapSec = effectiveLoopGapSec()
    if (gapSec <= 0) {
      replaySameSentenceNow(v, sub)
      return
    }
    beginGapHold(v, sub, gapSec, 'repeat', () => replaySameSentenceNow(v, sub))
  }

  function playNextSubtitleAfterGap(v: HTMLVideoElement, sub: Subtitle) {
    const subs = opts.sortedSubs.value
    const nextIdx = opts.currentIndex.value + 1
    if (nextIdx >= subs.length) return false
    const goNext = () => {
      sentenceLoopsDone.value = 0
      seekTo(subs[nextIdx])
      void v.play().then(() => {
        isPlaying.value = true
      }).catch(() => {
        isPlaying.value = false
      })
    }
    const gapSec = effectiveLoopGapSec()
    if (gapSec <= 0) {
      goNext()
      return true
    }
    beginGapHold(v, sub, gapSec, 'next', goNext)
    return true
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
      !dictationAfterLoop.value
      && sentenceLoopCount.value > 0
      && (autoAdvanceAfterLoop.value || effectiveLoopGapSec() > 0)

    if (canAutoAdvance) {
      if (playNextSubtitleAfterGap(v, sub)) return

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



  function replaySameSentenceNow(v: HTMLVideoElement, sub: Subtitle) {
    clearSentenceLoopTimer()
    v.currentTime = sub.start + 0.01
    currentTime.value = sub.start + 0.01
    if (v.paused) void v.play()
    isPlaying.value = true
  }

  /** 句末停下：连播满次数后暂停，保持单句循环（不关循环、不自动跳句） */
  function pauseAfterLoopRound(v: HTMLVideoElement, sub: Subtitle) {
    clearSentenceLoopTimer()
    loopMode.value = 'sentence'
    const n = clampLoopCount(sentenceLoopCount.value)
    sentenceLoopsDone.value = 0
    v.pause()
    isPlaying.value = false
    pinToSubtitle(v, sub)
    flashPauseHint(`已连播 ${n} 遍 · 点播放再练 · 下一句自动播`)
  }

  function handleSentenceLoopEnd(v: HTMLVideoElement, sub: Subtitle) {
    const n = clampLoopCount(sentenceLoopCount.value)
    sentenceLoopsDone.value += 1

    // 句末停下：连播 N 遍后停下（保持循环）
    if (pauseAfterSentence.value && !dictationAfterLoop.value) {
      if (sentenceLoopsDone.value >= n) {
        pauseAfterLoopRound(v, sub)
        return
      }
      replaySameSentenceAfterGap(v, sub)
      return
    }

    // 播满 N 遍后：听写 / 自动下一句 / 结束循环
    if (sentenceLoopsDone.value >= n) {
      finishSentenceLoop(v, sub)
      return
    }

    replaySameSentenceAfterGap(v, sub)
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

    // 间隔倒计时：冻住画面，不让时间轴滑进下一句
    if ((sentenceLoopTimer || gapOnDone) && sentenceHoldAt != null) {
      if (t > sentenceHoldAt + 0.03 || t < sentenceHoldAt - 0.12) {
        v.currentTime = sentenceHoldAt
        currentTime.value = sentenceHoldAt
      }
      return
    }

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



    if (loopMode.value === 'sentence' && playingSub && !sentenceLoopTimer && !gapOnDone) {

      if (t >= playingSub.end - 0.05) {

        handleSentenceLoopEnd(v, playingSub)

        return

      }

    }

    if (
      loopMode.value === 'off'
      && playingSub
      && !sentenceLoopTimer
      && !gapOnDone
      && !oneShotPauseSub
      && !v.paused
      && effectiveLoopGapSec() > 0
      && t >= playingSub.end - 0.05
    ) {
      if (!playNextSubtitleAfterGap(v, playingSub)) {
        v.pause()
        isPlaying.value = false
      }
      return
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

        if (opts.onTogglePlay?.()) break

        if (isPlaying.value) togglePlay()

        else if (opts.onReplaySentence?.()) break

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

        if (opts.onReplaySentence?.()) break

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

    if (pauseHintTimer) {
      clearTimeout(pauseHintTimer)
      pauseHintTimer = null
    }

  })



  return {

    playbackRate,

    loopMode,

    sentenceLoopCount,

    sentenceLoopsDone,

    pauseAfterSentence,

    setPauseAfterSentence,

    pauseHintText,

    armSentenceLoopMode,

    dictationAfterLoop,

    setDictationAfterLoop,

    autoAdvanceAfterLoop,

    setAutoAdvanceAfterLoop,

    playSentenceOnce,

    loopInterval,

    gapRemainingMs,

    gapDurationMs,

    gapKind,

    gapActive,

    skipGapHold,

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

