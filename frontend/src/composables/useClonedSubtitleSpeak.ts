import { onUnmounted, ref } from 'vue'
import { fetchClonedSpeak } from '@/api/voiceClone'

/**
 * 复刻音色朗读：按字幕时间窗缩放播速，与视频原时间轴对齐。
 */
export function useClonedSubtitleSpeak() {
  const speaking = ref(false)
  const error = ref('')
  let audio: HTMLAudioElement | null = null
  let objectUrl: string | null = null
  let session = 0
  let activeKey = ''

  function stop() {
    session += 1
    activeKey = ''
    error.value = ''
    if (audio) {
      try {
        audio.onended = null
        audio.onerror = null
        audio.pause()
        audio.src = ''
      } catch {
        /* ignore */
      }
      audio = null
    }
    if (objectUrl) {
      URL.revokeObjectURL(objectUrl)
      objectUrl = null
    }
    speaking.value = false
  }

  function readDurationSec(el: HTMLAudioElement): Promise<number> {
    if (Number.isFinite(el.duration) && el.duration > 0) return Promise.resolve(el.duration)
    return new Promise((resolve) => {
      const finish = () => {
        el.removeEventListener('loadedmetadata', finish)
        el.removeEventListener('durationchange', finish)
        resolve(Number.isFinite(el.duration) && el.duration > 0 ? el.duration : 0)
      }
      el.addEventListener('loadedmetadata', finish)
      el.addEventListener('durationchange', finish)
      window.setTimeout(finish, 400)
    })
  }

  /**
   * 在 wallClockSec 墙钟时间内读完（通过 audio.playbackRate 拉伸/压缩）。
   * key 相同且正在播则跳过，避免 timeupdate 重复触发。
   */
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

    if (audio) {
      try {
        audio.onended = null
        audio.onerror = null
        audio.pause()
        audio.src = ''
      } catch {
        /* ignore */
      }
      audio = null
    }
    if (objectUrl) {
      URL.revokeObjectURL(objectUrl)
      objectUrl = null
    }

    speaking.value = true
    try {
      const blob = await fetchClonedSpeak(cleaned, Math.round(Math.max(0.2, wallClockSec) * 1000))
      if (mySession !== session) return false

      objectUrl = URL.createObjectURL(blob)
      audio = new Audio(objectUrl)
      audio.preload = 'auto'
      const natural = await readDurationSec(audio)
      if (mySession !== session) return false

      const windowSec = Math.max(0.2, wallClockSec)
      if (natural > 0.05) {
        // SSML 已按时间窗估语速；此处只做窄幅微调，避免整句硬拉变调
        const rate = Math.min(1.15, Math.max(0.85, natural / windowSec))
        audio.playbackRate = rate
      } else {
        audio.playbackRate = 1
      }

      const finished = await new Promise<boolean>((resolve) => {
        if (!audio || mySession !== session) {
          resolve(false)
          return
        }
        audio.onended = () => resolve(mySession === session)
        audio.onerror = () => {
          if (mySession === session) error.value = '音频播放失败'
          resolve(false)
        }
        void audio.play().catch(() => {
          if (mySession === session) error.value = '音频播放失败'
          resolve(false)
        })
      })
      return finished
    } catch (e) {
      if (mySession === session) {
        error.value = e instanceof Error ? e.message : '朗读失败'
      }
      return false
    } finally {
      if (mySession === session) {
        if (audio) {
          try {
            audio.onended = null
            audio.onerror = null
            audio.pause()
            audio.src = ''
          } catch {
            /* ignore */
          }
          audio = null
        }
        if (objectUrl) {
          URL.revokeObjectURL(objectUrl)
          objectUrl = null
        }
        speaking.value = false
        if (activeKey === key) activeKey = ''
      }
    }
  }

  /** @deprecated 兼容旧调用：不拟合时长 */
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

  onUnmounted(() => stop())

  return { speaking, error, speak, speakFitted, stop, prefetch }
}
