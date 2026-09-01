import { onUnmounted, ref } from 'vue'
import { fetchClonedSpeak } from '@/api/voiceClone'

export type SpeakReadyInfo = {
  /** 可能为 0：不再为对齐去阻塞等待 metadata */
  durationSec: number
}

/**
 * 用复刻音色朗读字幕。
 * speak() 正常播完返回 true；被 stop() 打断返回 false。
 * onReady 在音频 blob 就绪、即将 play 时立刻回调（不阻塞等 duration）。
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

      // 立刻回调，避免等 loadedmetadata（手机上可卡数百毫秒）
      if (opts?.onReady) {
        await opts.onReady({ durationSec: 0 })
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
