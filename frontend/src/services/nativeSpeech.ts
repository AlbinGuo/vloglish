import { isNativePlatform } from '@/utils/platform'

/**
 * App(原生)语音识别封装。
 *
 * 背景：Web 端用阿里云 Web SDK + 浏览器 SpeechRecognition，但在 Capacitor 的
 * iOS/Android WebView 里都不可用。这里改用原生识别插件
 * (@capacitor-community/speech-recognition)：iOS 走 SFSpeechRecognizer，
 * Android 走系统 SpeechRecognizer。
 *
 * 关键坑：iOS 在「持续喂麦克风音频」时 SFSpeechRecognizer 不会自动判定结束，
 * start()/最终结果会一直挂着。所以这里用 partialResults:true 拿实时文字，
 * 再用「静音检测」在停顿后主动 stop() 触发收尾与点评。
 */

/** 识别到内容后，停顿多久判定「说完了」并自动结束 */
const SILENCE_MS = 1600
/** 刚启动后，给用户开口的时间；超时仍无内容则结束 */
const INITIAL_MS = 12000

type PermissionState2 = 'prompt' | 'prompt-with-rationale' | 'granted' | 'denied'

type SRPlugin = {
  available: () => Promise<{ available: boolean }>
  start: (o?: Record<string, unknown>) => Promise<{ matches?: string[] }>
  stop: () => Promise<void>
  checkPermissions: () => Promise<{ speechRecognition: PermissionState2 }>
  requestPermissions: () => Promise<{ speechRecognition: PermissionState2 }>
  addListener: (event: string, cb: (data: any) => void) => Promise<{ remove: () => void }>
  removeAllListeners: () => Promise<void>
}

let pluginPromise: Promise<SRPlugin | null> | null = null

async function loadSR(): Promise<SRPlugin | null> {
  if (!isNativePlatform()) return null
  if (!pluginPromise) {
    pluginPromise = import('@capacitor-community/speech-recognition')
      .then((m: any) => (m?.SpeechRecognition ?? m?.default ?? null) as SRPlugin | null)
      .catch(() => null)
  }
  return pluginPromise
}

/** 当前是否在原生 App */
export function nativeSpeechAvailable(): boolean {
  return isNativePlatform()
}

export interface NativeListenHandlers {
  language?: string
  /** 识别到（可能不完整）的文字，实时回调 */
  onPartial?: (text: string) => void
  /** 识别结束后的最终文字 */
  onFinal?: (text: string) => void
  /** 失败/不可用提示 */
  onError?: (message: string) => void
}

export interface NativeListenController {
  stop: () => Promise<void>
}

export async function startNativeListen(
  h: NativeListenHandlers,
): Promise<NativeListenController | null> {
  const SR = await loadSR()
  if (!SR) {
    h.onError?.('当前设备不支持原生语音识别')
    return null
  }

  // 某些机型首次 available() 可能瞬时返回 false，不据此放弃，交给 start() 判定
  try {
    await SR.available()
  } catch {
    /* 某些平台无 available 实现时继续 */
  }

  try {
    const perm = await SR.checkPermissions()
    if (perm?.speechRecognition !== 'granted') {
      const req = await SR.requestPermissions()
      if (req?.speechRecognition !== 'granted') {
        h.onError?.('未获得麦克风/语音识别权限，请在系统设置中开启')
        return null
      }
    }
  } catch {
    /* 权限接口异常时仍尝试开始，失败会在 start 阶段报错 */
  }

  let finalText = ''
  let ended = false
  let silenceTimer: ReturnType<typeof setTimeout> | null = null
  const handles: Array<{ remove: () => void }> = []

  const clearSilence = () => {
    if (silenceTimer) {
      clearTimeout(silenceTimer)
      silenceTimer = null
    }
  }
  const cleanup = () => {
    clearSilence()
    for (const hd of handles) {
      try {
        hd.remove()
      } catch {
        /* ignore */
      }
    }
    handles.length = 0
  }
  const finish = () => {
    if (ended) return
    ended = true
    cleanup()
    h.onFinal?.(finalText.trim())
  }
  const stopAndFinish = async () => {
    clearSilence()
    if (ended) return
    try {
      await SR.stop()
    } catch {
      /* ignore */
    }
    finish()
  }
  // 停顿检测：每次听到新内容都重置计时；到点主动 stop 触发收尾
  const schedule = (ms: number) => {
    clearSilence()
    if (ended) return
    silenceTimer = setTimeout(() => {
      silenceTimer = null
      void stopAndFinish()
    }, ms)
  }

  try {
    handles.push(
      await SR.addListener('partialResults', (data: any) => {
        if (ended) return
        const arr = Array.isArray(data?.matches) ? data.matches : []
        const text = String(arr[0] ?? '').trim()
        if (text) {
          finalText = text
          h.onPartial?.(text)
          // 只在真正识别到内容时重置停顿计时，避免空结果刷屏导致永不结束
          schedule(SILENCE_MS)
        }
      }),
    )
    handles.push(
      await SR.addListener('listeningState', (data: any) => {
        if (data?.status === 'stopped') finish()
      }),
    )
  } catch {
    /* 监听注册失败不影响开始 */
  }

  let startPromise: Promise<{ matches?: string[] }>
  try {
    startPromise = SR.start({
      language: h.language || 'en-US',
      maxResults: 1,
      partialResults: true,
      popup: false,
    })
  } catch (e: unknown) {
    cleanup()
    const msg = String((e as { message?: string })?.message || e || '')
    if (/no match|not recognized|no speech|没有识别|无法识别/i.test(msg)) {
      h.onError?.('没有识别到语音，请再说一次')
    } else {
      h.onError?.(msg ? msg.slice(0, 140) : '语音识别启动失败')
    }
    return null
  }

  // partialResults:true 时 start() 会立即返回，通常没有 matches；有的话也当补充
  startPromise
    .then((res) => {
      const arr = Array.isArray(res?.matches) ? res.matches : []
      const text = String(arr[0] ?? '').trim()
      if (text && !finalText) {
        finalText = text
        h.onPartial?.(text)
      }
    })
    .catch((e: unknown) => {
      if (ended) return
      const msg = String((e as { message?: string })?.message || e || '')
      if (/no match|not recognized|no speech|没有识别|无法识别/i.test(msg)) {
        h.onError?.('没有识别到语音，请再说一次')
      } else {
        h.onError?.(msg ? msg.slice(0, 140) : '语音识别失败')
      }
    })

  if (!ended) schedule(INITIAL_MS)

  return {
    stop: async () => {
      await stopAndFinish()
    },
  }
}
