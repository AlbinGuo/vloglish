import { isNativePlatform } from '@/utils/platform'

/**
 * App(原生)语音识别封装。
 *
 * 背景：Web 端用阿里云 Web SDK + 浏览器 SpeechRecognition，但在 Capacitor 的
 * iOS/Android WebView 里都不可用。这里改用原生识别插件
 * (@capacitor-community/speech-recognition)：iOS 走 SFSpeechRecognizer，
 * Android 走系统 SpeechRecognizer。
 *
 * 采用 partialResults:false —— 各平台在「说完/停止」时会通过 start() 的返回值
 * 给出最终识别文本（iOS: 说话停顿后给最终结果；Android: onResults 给最终 matches）。
 * 这比依赖 partialResults 事件更稳，避免事件没送达导致「没有任何反应」。
 */

/** 说话后最多聆听这么久，超时强制结束（防止一直挂着不点评） */
const MAX_LISTEN_MS = 15000

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
  /** 识别到（可能不完整）的文字，实时回调（当前方案可能不触发） */
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

  let ended = false
  let safetyTimer: ReturnType<typeof setTimeout> | null = null

  const clearSafety = () => {
    if (safetyTimer) {
      clearTimeout(safetyTimer)
      safetyTimer = null
    }
  }
  const finish = (text: string) => {
    if (ended) return
    ended = true
    clearSafety()
    h.onFinal?.(text.trim())
  }
  const fail = (message: string) => {
    if (ended) return
    ended = true
    clearSafety()
    h.onError?.(message)
  }

  let startPromise: Promise<{ matches?: string[] }>
  try {
    startPromise = SR.start({
      language: h.language || 'en-US',
      maxResults: 1,
      partialResults: false,
      popup: false,
    })
  } catch (e: unknown) {
    const msg = String((e as { message?: string })?.message || e || '')
    fail(msg ? msg.slice(0, 140) : '语音识别启动失败')
    return null
  }

  startPromise
    .then((res) => {
      const arr = Array.isArray(res?.matches) ? res.matches : []
      finish(String(arr[0] ?? ''))
    })
    .catch((e: unknown) => {
      const msg = String((e as { message?: string })?.message || e || '')
      if (/no match|not recognized|no speech|没有识别|无法识别|timeout/i.test(msg)) {
        fail('没有识别到语音，请再说一次')
      } else {
        fail(msg ? msg.slice(0, 140) : '语音识别失败')
      }
    })

  safetyTimer = setTimeout(() => {
    if (ended) return
    void SR.stop().catch(() => undefined)
  }, MAX_LISTEN_MS)

  return {
    stop: async () => {
      if (ended) return
      try {
        await SR.stop()
      } catch {
        /* ignore */
      }
      // stop() 后 start() 会返回最终文本并走 finish；这里做兜底，避免个别平台不返回
      setTimeout(() => {
        if (!ended) finish('')
      }, 1500)
    },
  }
}
