import { onUnmounted, ref } from 'vue'
import { fetchClonedSpeak } from '@/api/voiceClone'

export type SpeakReadyInfo = {
  durationSec: number
}

/**
 * 用复刻音色朗读字幕：可单句，也可由外部循环接下句。
 * speak() 正常播完返回 true；被 stop() 打断返回 false。
 * onReady 在拿到音频时长、即将开播时回调，便于同步驱动视频画面。
 */
export function useClonedSubtitleSpeak() {
  const speaking = ref(false)
  const error = ref('')
  let audio: HTMLAudioElement | null = null
  let objectUrl: string | null = null
  let session = 0

  function stop() {
    session += 1
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
    if (Number.isFinite(el.duration) && el.duration > 0) {
      return Promise.resolve(el.duration)
    }
    return new Promise((resolve) => {
      const done = () => {
        el.removeEventListener('loadedmetadata', done)
        el.removeEventListener('durationchange', done)
        resolve(Number.isFinite(el.duration) && el.duration > 0 ? el.duration : 0)
      }
      el.addEventListener('loadedmetadata', done)
      el.addEventListener('durationchange', done)
      // 部分浏览器需 play/pause 才出时长；给个短超时兜底
      window.setTimeout(done, 800)
    })
  }

  async function speak(
    text: string,
    opts?: { onReady?: (info: SpeakReadyInfo) => void | Promise<void> },
  ): Promise<boolean> {
    const cleaned = (text || '').trim()
    if (!cleaned) {
      error.value = '当前句没有英文文本'
      return false
    }
    error.value = ''
    const mySession = session + 1
    session = mySession
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
      const blob = await fetchClonedSpeak(cleaned)
      if (mySession !== session) return false
      objectUrl = URL.createObjectURL(blob)
      audio = new Audio(objectUrl)
      audio.preload = 'auto'
      const durationSec = await readDurationSec(audio)
      if (mySession !== session) return false
      if (opts?.onReady) {
        await opts.onReady({ durationSec: durationSec > 0 ? durationSec : 0 })
      }
      if (mySession !== session) return false

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
      }
    }
  }

  /** 预取下一句，减少接句等待 */
  function prefetch(text: string) {
    const cleaned = (text || '').trim()
    if (!cleaned) return
    void fetchClonedSpeak(cleaned).catch(() => {
      /* ignore */
    })
  }

  onUnmounted(() => stop())

  return { speaking, error, speak, stop, prefetch }
}
