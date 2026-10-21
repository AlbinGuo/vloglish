import { isNativePlatform } from '@/utils/platform'

/**
 * App(原生)语音识别封装。
 *
 * 背景：Web 端用阿里云 Web SDK + 浏览器 SpeechRecognition，但在 Capacitor 的
 * iOS/Android WebView 里都不可用。这里改用原生识别插件
 * (@capacitor-community/speech-recognition)：iOS 走 SFSpeechRecognizer，
 * Android 走系统 SpeechRecognizer，识别出文字后交给后端「识别点评」。
 *
 * partialResults=true 时各平台行为一致：start() 立即返回，识别过程通过
 * partialResults 事件推送中间结果，直到调用 stop()（或系统自动停止）。
 */

/** 识别到内容后，停顿多久自动结束并触发点评 */
const SILENCE_MS = 2000
/** 刚点麦克风后，给用户开口的初始时间 */
const INITIAL_MS = 15000

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

/** 当前是否在原生 App 且具备原生语音识别能力 */
export function nativeSpeechAvailable(): boolean {
  return isNativePlatform()
}

export interface NativeListenHandlers {
  language?: string
  /** 识别到（可能不完整）的文字，实时回调 */
  onPartial?: (text: string) => void
  /** 识别结束（系统自动停或调用 stop）后的最终文字 */
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

  // 某些机型首次 available() 可能瞬时返回 false，这里不再据此直接放弃，
  // 交给真正的 start() 去判定（可用性异常会在 start 阶段报错）。
  try {
    await SR.available()
  } catch {
    /* 某些平台无 available 实现时继续尝试 */
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
    h.onFinal?.(finalText)
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
  // 说完停顿后自动结束：不依赖各平台是否派发 stopped 事件
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
        }
        // 每次识别到内容都重置停顿计时
        schedule(SILENCE_MS)
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

  let startedMatches: string[] = []
  try {
    const started = await SR.start({
      language: h.language || 'en-US',
      maxResults: 1,
      partialResults: true,
      popup: false,
    })
    startedMatches = Array.isArray(started?.matches) ? started.matches : []
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

  // 少数平台 start 结束时才返回最终结果（未走 partialResults 的情况）
  if (startedMatches.length && !finalText) {
    const first = String(startedMatches[0] ?? '').trim()
    if (first) {
      finalText = first
      h.onPartial?.(first)
    }
  }

  if (!ended) schedule(INITIAL_MS)

  return {
    stop: async () => {
      await stopAndFinish()
    },
  }
}
