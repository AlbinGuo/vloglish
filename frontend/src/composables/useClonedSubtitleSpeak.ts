import { onUnmounted, ref } from 'vue'
import { fetchClonedSpeak } from '@/api/voiceClone'

/** 1 样本静音 wav，用于在用户点击时解锁后续 play() */
const SILENT_WAV =
  'data:audio/wav;base64,UklGRigAAABXQVZFZm10IBIAAAABAAEARKwAAIhYAQACABAAAABkYXRhAgAAAAEA'

/**
 * 复刻音色朗读：复用同一 Audio（避免句末销毁后下一句被自动播放策略拦住）。
 * 默认原速播放，只在明显超出本句剩余时长时轻微加速，避免把停顿和语气拉平。
 */
export function useClonedSubtitleSpeak() {
  const speaking = ref(false)
  const error = ref('')
  let audio: HTMLAudioElement | null = null
  let objectUrl: string | null = null
  let session = 0
  let activeKey = ''
  let unlocked = false
  let holdPaused = false

  function ensureAudio(): HTMLAudioElement {
    if (!audio) {
      audio = new Audio()
      audio.preload = 'auto'
      audio.playsInline = true
      audio.setAttribute('playsinline', 'true')
    }
    return audio
  }

  function detachHandlers(el: HTMLAudioElement) {
    el.onended = null
    el.onerror = null
    el.onpause = null
  }

  function stop() {
    session += 1
    activeKey = ''
    error.value = ''
    speaking.value = false
    holdPaused = false
    if (audio) {
      try {
        detachHandlers(audio)
        audio.pause()
      } catch {
        /* ignore */
      }
    }
    if (objectUrl) {
      URL.revokeObjectURL(objectUrl)
      objectUrl = null
    }
  }

  function isSpeechSrc(el: HTMLAudioElement): boolean {
    const src = el.currentSrc || el.src || ''
    return src.startsWith('blob:')
  }

  /** 跟着视频暂停：不取消当前句，续播时从停住的位置继续。 */
  function pausePlayback(): void {
    holdPaused = true
    if (!audio || !isSpeechSrc(audio)) return
    try {
      audio.pause()
    } catch {
      /* ignore */
    }
  }

  /** 跟着视频继续：从当前句停住的位置接着读。 */
  function resumePlayback(): void {
    holdPaused = false
    if (!audio || !isSpeechSrc(audio) || audio.ended) return
    const start = audio.play()
    if (start && typeof start.catch === 'function') {
      void start.catch(() => {
        error.value = '浏览器拦截了复刻音，请再点一次播放'
      })
    }
  }

  /** 当前句是否仍在合成或出声（已结束/异常停住不算）。 */
  function isUtteranceActive(): boolean {
    if (holdPaused) return true
    if (audio && isSpeechSrc(audio)) {
      if (audio.ended) return false
      if (!audio.paused) return true
    }
    return speaking.value && !(audio && isSpeechSrc(audio) && audio.paused)
  }

  /**
   * 必须在用户点击的同步调用链里执行。
   * 用同一 Audio 循环播静音样本并保持 playing，后续换 src 才不会被自动播放策略拦住。
   * 不要在合成完成前 pause，Safari / iOS 会收回播放权限。
   */
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
            /* 仍尝试后续 speakFitted */
          })
      } else {
        unlocked = true
      }
    } catch {
      /* ignore */
    }
  }

  function readDurationSec(el: HTMLAudioElement): Promise<number> {
    if (Number.isFinite(el.duration) && el.duration > 0 && el.duration !== Infinity) {
      return Promise.resolve(el.duration)
    }
    return new Promise((resolve) => {
      const finish = () => {
        el.removeEventListener('loadedmetadata', finish)
        el.removeEventListener('durationchange', finish)
        const d = el.duration
        resolve(Number.isFinite(d) && d > 0 && d !== Infinity ? d : 0)
      }
      el.addEventListener('loadedmetadata', finish)
      el.addEventListener('durationchange', finish)
      window.setTimeout(finish, 600)
    })
  }

  async function speakFitted(
    text: string,
    wallClockSec: number,
    key: string,
  ): Promise<boolean> {
    const cleaned = (text || '').trim()
    if (!cleaned) {
      error.value = '当前句没有英文文本'
      return false
    }
    if (key && key === activeKey && speaking.value) {
      return isUtteranceActive()
    }

    error.value = ''
    const mySession = session + 1
    session = mySession
    activeKey = key

    const el = ensureAudio()
    detachHandlers(el)
    // 合成等待期间保持 Audio 处于 playing（unlock 的静音循环），不要 pause

    speaking.value = true
    try {
      const blob = await fetchClonedSpeak(cleaned)
      if (mySession !== session) return false

      const prevUrl = objectUrl
      objectUrl = URL.createObjectURL(blob)
      el.loop = false
      el.muted = false
      el.src = objectUrl
      if (prevUrl) URL.revokeObjectURL(prevUrl)
      const natural = await readDurationSec(el)
      if (mySession !== session) return false

      const windowSec = Math.max(0.2, wallClockSec)
      // 短于时间窗：原速播完，剩余时间就是自然停顿
      // 明显超窗：最多加速到 1.08，避免整句被拉成匀速
      if (natural > windowSec * 1.25) {
        el.playbackRate = Math.min(1.08, natural / windowSec)
      } else {
        el.playbackRate = 1
      }

      const finished = await new Promise<boolean>((resolve) => {
        let settled = false
        const settle = (ok: boolean) => {
          if (settled) return
          settled = true
          resolve(ok)
        }
        if (mySession !== session) {
          settle(false)
          return
        }
        el.onended = () => settle(mySession === session && el.ended)
        el.onerror = () => {
          if (mySession === session) error.value = '音频播放失败'
          settle(false)
        }
        if (holdPaused) return
        const start = el.play()
        if (el.ended) {
          settle(mySession === session)
          return
        }
        if (start && typeof start.catch === 'function') {
          void start.catch(() => {
            if (mySession === session) {
              error.value = '浏览器拦截了复刻音，请再点一次播放'
            }
            settle(false)
          })
        }
      })
      return finished
    } catch (e) {
      if (mySession === session) {
        error.value = e instanceof Error ? e.message : '朗读失败'
      }
      return false
    } finally {
      if (mySession === session) {
        speaking.value = false
        if (activeKey === key) activeKey = ''
      }
    }
  }

  async function speak(text: string): Promise<boolean> {
    return speakFitted(text, 2.5, `loose:${text.slice(0, 24)}`)
  }

  function prefetch(text: string, _durationMs?: number) {
    const cleaned = (text || '').trim()
    if (!cleaned) return
    void fetchClonedSpeak(cleaned).catch(() => {
      /* ignore */
    })
  }

  onUnmounted(() => {
    stop()
    if (audio) {
      audio.src = ''
      audio = null
    }
    unlocked = false
  })

  return {
    speaking,
    error,
    speak,
    speakFitted,
    stop,
    pausePlayback,
    resumePlayback,
    isUtteranceActive,
    prefetch,
    unlock,
  }
}
