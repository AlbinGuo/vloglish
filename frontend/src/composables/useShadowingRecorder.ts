import { onUnmounted, ref } from 'vue'

export type ShadowRecorderPhase = 'idle' | 'preparing' | 'waiting' | 'recording' | 'stopping' | 'error'

function pickMimeType(): string {
  const candidates = [
    'audio/webm;codecs=opus',
    'audio/webm',
    'audio/ogg;codecs=opus',
    'audio/mp4',
  ]
  if (typeof MediaRecorder === 'undefined') return ''
  for (const c of candidates) {
    if (MediaRecorder.isTypeSupported(c)) return c
  }
  return ''
}

/**
 * 影子跟读录音：参考音开播后按 delay 开录，由外部在句末调用 stop。
 */
export function useShadowingRecorder() {
  const phase = ref<ShadowRecorderPhase>('idle')
  const error = ref('')
  const micEnabled = ref(true)
  const hasMicPermission = ref(false)

  let stream: MediaStream | null = null
  let recorder: MediaRecorder | null = null
  let chunks: BlobPart[] = []
  let delayTimer: ReturnType<typeof setTimeout> | null = null
  let mimeType = ''

  function clearDelayTimer() {
    if (delayTimer) {
      clearTimeout(delayTimer)
      delayTimer = null
    }
  }

  async function ensureMic(): Promise<boolean> {
    error.value = ''
    if (!micEnabled.value) {
      hasMicPermission.value = false
      return false
    }
    if (typeof navigator === 'undefined' || !navigator.mediaDevices?.getUserMedia) {
      error.value = '当前环境不支持录音'
      phase.value = 'error'
      return false
    }
    try {
      phase.value = 'preparing'
      if (!stream) {
        stream = await navigator.mediaDevices.getUserMedia({
          audio: {
            echoCancellation: true,
            noiseSuppression: true,
            autoGainControl: true,
          },
        })
      }
      hasMicPermission.value = true
      phase.value = 'idle'
      return true
    } catch {
      error.value = '无法使用麦克风，可改为只听不录'
      hasMicPermission.value = false
      phase.value = 'error'
      micEnabled.value = false
      return false
    }
  }

  function releaseMic() {
    clearDelayTimer()
    if (recorder && recorder.state !== 'inactive') {
      try {
        recorder.onstop = null
        recorder.stop()
      } catch {
        /* ignore */
      }
    }
    recorder = null
    chunks = []
    if (stream) {
      for (const track of stream.getTracks()) track.stop()
      stream = null
    }
    hasMicPermission.value = false
    phase.value = 'idle'
  }

  /**
   * 参考音已开始播放时调用。delaySec 后开始录音（mic 关闭则跳过录音）。
   */
  async function armAfterReferenceStart(delaySec: number): Promise<void> {
    clearDelayTimer()
    chunks = []
    error.value = ''

    if (!micEnabled.value) {
      phase.value = 'waiting'
      return
    }

    const ok = await ensureMic()
    if (!ok || !stream) {
      phase.value = micEnabled.value ? 'error' : 'waiting'
      return
    }

    mimeType = pickMimeType()
    try {
      recorder = mimeType
        ? new MediaRecorder(stream, { mimeType })
        : new MediaRecorder(stream)
    } catch {
      error.value = '无法启动录音'
      phase.value = 'error'
      return
    }

    chunks = []
    recorder.ondataavailable = (ev) => {
      if (ev.data && ev.data.size > 0) chunks.push(ev.data)
    }

    const delayMs = Math.max(0, Math.round(delaySec * 1000))
    phase.value = delayMs > 0 ? 'waiting' : 'recording'

    const startRec = () => {
      delayTimer = null
      if (!recorder || recorder.state !== 'inactive') return
      try {
        recorder.start(200)
        phase.value = 'recording'
      } catch {
        error.value = '录音启动失败'
        phase.value = 'error'
      }
    }

    if (delayMs <= 0) startRec()
    else delayTimer = setTimeout(startRec, delayMs)
  }

  function stop(): Promise<Blob | null> {
    clearDelayTimer()
    return new Promise((resolve) => {
      if (!recorder || recorder.state === 'inactive') {
        phase.value = 'idle'
        resolve(null)
        return
      }
      phase.value = 'stopping'
      const rec = recorder
      rec.onstop = () => {
        const type = rec.mimeType || mimeType || 'audio/webm'
        const blob = chunks.length ? new Blob(chunks, { type }) : null
        chunks = []
        recorder = null
        phase.value = 'idle'
        resolve(blob && blob.size > 0 ? blob : null)
      }
      try {
        rec.stop()
      } catch {
        phase.value = 'idle'
        resolve(null)
      }
    })
  }

  function cancel() {
    clearDelayTimer()
    if (recorder && recorder.state !== 'inactive') {
      try {
        recorder.onstop = null
        recorder.stop()
      } catch {
        /* ignore */
      }
    }
    recorder = null
    chunks = []
    phase.value = 'idle'
  }

  onUnmounted(() => {
    releaseMic()
  })

  return {
    phase,
    error,
    micEnabled,
    hasMicPermission,
    ensureMic,
    releaseMic,
    armAfterReferenceStart,
    stop,
    cancel,
  }
}
