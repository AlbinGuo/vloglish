import { onUnmounted, ref } from 'vue'
import { fetchClonedSpeak } from '@/api/voiceClone'

/**
 * 用复刻音色朗读字幕：可单句，也可由外部循环接下句。
 * speak() 正常播完返回 true；被 stop() 打断返回 false。
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

  async function speak(text: string): Promise<boolean> {
    const cleaned = (text || '').trim()
    if (!cleaned) {
      error.value = '当前句没有英文文本'
      return false
    }
    error.value = ''
    // 停掉上一句，但不清 speaking，避免链式播放时 UI 闪一下
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
