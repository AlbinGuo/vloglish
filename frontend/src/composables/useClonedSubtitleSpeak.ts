import { onUnmounted, ref } from 'vue'
import { fetchClonedSpeak } from '@/api/voiceClone'

/** 1 样本静音 wav，用于在用户点击时解锁后续 play() */
const SILENT_WAV =
  'data:audio/wav;base64,UklGRigAAABXQVZFZm10IBIAAAABAAEARKwAAIhYAQACABAAAABkYXRhAgAAAAEA'

/**
 * 复刻音色朗读：复用同一 Audio（避免句末销毁后下一句被自动播放策略拦住），
 * 按字幕时间窗窄幅微调播速。
 */
export function useClonedSubtitleSpeak() {
  const speaking = ref(false)
  const error = ref('')
  let audio: HTMLAudioElement | null = null
  let objectUrl: string | null = null
  let session = 0
  let activeKey = ''
  let unlocked = false

  function ensureAudio(): HTMLAudioElement {
    if (!audio) {
      audio = new Audio()
      audio.preload = 'auto'
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

  /** 必须在用户点击播放的同步调用链里执行，解锁后续换句 play() */
  function unlock(): void {
    const el = ensureAudio()
    try {
      el.muted = true
      if (!unlocked) el.src = SILENT_WAV
      const p = el.play()
      if (p && typeof p.then === 'function') {
        void p
          .then(() => {
            unlocked = true
            el.muted = false
            const src = el.currentSrc || el.src || ''
            if (!speaking.value && src.startsWith('data:audio/wav')) el.pause()
          })
          .catch(() => {
            el.muted = false
          })
      } else {
        el.muted = false
        unlocked = true
      }
    } catch {
      el.muted = false
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
    if (key && key === activeKey && speaking.value) return true

    error.value = ''
    const mySession = session + 1
    session = mySession
    activeKey = key

    const el = ensureAudio()
    detachHandlers(el)
    try {
      el.pause()
    } catch {
      /* ignore */
    }

    speaking.value = true
    try {
      const blob = await fetchClonedSpeak(cleaned, Math.round(Math.max(0.2, wallClockSec) * 1000))
      if (mySession !== session) return false

      if (objectUrl) {
        URL.revokeObjectURL(objectUrl)
        objectUrl = null
      }
      objectUrl = URL.createObjectURL(blob)
      el.muted = false
      el.src = objectUrl
      el.load()
      const natural = await readDurationSec(el)
      if (mySession !== session) return false

      const windowSec = Math.max(0.2, wallClockSec)
      if (natural > 0.05) {
        el.playbackRate = Math.min(1.15, Math.max(0.85, natural / windowSec))
      } else {
        el.playbackRate = 1
      }

      const finished = await new Promise<boolean>((resolve) => {
        if (mySession !== session) {
          resolve(false)
          return
        }
        el.onended = () => resolve(mySession === session)
        el.onerror = () => {
          if (mySession === session) error.value = '音频播放失败'
          resolve(false)
        }
        const start = el.play()
        if (start && typeof start.catch === 'function') {
          void start.catch(() => {
            if (mySession === session) error.value = '音频播放失败'
            resolve(false)
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

  function prefetch(text: string, durationMs?: number) {
    const cleaned = (text || '').trim()
    if (!cleaned) return
    void fetchClonedSpeak(cleaned, durationMs).catch(() => {
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

  return { speaking, error, speak, speakFitted, stop, prefetch, unlock }
}
