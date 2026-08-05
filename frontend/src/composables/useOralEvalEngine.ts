import { ref } from 'vue'
import {
  fetchOralEvalStatus,
  fetchOralEvalWarrant,
  type OralCoreType,
  type OralEvalWarrant,
} from '@/api/oralEval'

type EngineInstance = {
  startRecord: (params: Record<string, unknown>, done?: (msg: string) => void, fail?: (msg: string) => void) => void
  stopRecord: () => void
  cancelRecord?: () => void
}

type EngineCtor = new (params: Record<string, unknown>) => EngineInstance

declare global {
  interface Window {
    EngineEvaluat?: EngineCtor
  }
}

let sdkLoadPromise: Promise<EngineCtor> | null = null
let cachedWarrant: OralEvalWarrant | null = null

function defaultEvalTimeMs(refText: string, coreType: OralCoreType) {
  const words = refText.trim().split(/\s+/).filter(Boolean).length
  if (coreType === 'en.word.score') return Math.max(4000, 2500 + words * 800)
  if (coreType === 'en.pred.score') return Math.max(8000, 3000 + words * 450)
  return 2000 + words * 600 + 1000
}

async function loadSdk(sdkUrl: string): Promise<EngineCtor> {
  if (typeof window === 'undefined') throw new Error('非浏览器环境')
  if (window.EngineEvaluat) return window.EngineEvaluat
  if (!sdkLoadPromise) {
    sdkLoadPromise = new Promise<EngineCtor>((resolve, reject) => {
      const existing = document.querySelector<HTMLScriptElement>('script[data-oral-eval-sdk="1"]')
      if (existing) {
        existing.addEventListener('load', () => {
          if (window.EngineEvaluat) resolve(window.EngineEvaluat)
          else reject(new Error('口语评测 SDK 未就绪'))
        })
        existing.addEventListener('error', () => reject(new Error('口语评测 SDK 加载失败')))
        return
      }
      const script = document.createElement('script')
      script.src = sdkUrl
      script.async = true
      script.dataset.oralEvalSdk = '1'
      script.onload = () => {
        if (window.EngineEvaluat) resolve(window.EngineEvaluat)
        else reject(new Error('口语评测 SDK 未暴露 EngineEvaluat'))
      }
      script.onerror = () => {
        sdkLoadPromise = null
        reject(new Error('口语评测 SDK 加载失败（请放置 frontend/public/sdk/engine.js）'))
      }
      document.head.appendChild(script)
    })
  }
  return sdkLoadPromise
}

async function getWarrant(): Promise<OralEvalWarrant> {
  const now = Math.floor(Date.now() / 1000)
  if (cachedWarrant?.warrant_id && cachedWarrant.expire_at && cachedWarrant.expire_at - now > 120) {
    return cachedWarrant
  }
  cachedWarrant = await fetchOralEvalWarrant()
  return cachedWarrant
}

function streamIsLive(stream: MediaStream | null | undefined): stream is MediaStream {
  return Boolean(stream && typeof stream.getTracks === 'function' && stream.getTracks().some((t) => t.readyState === 'live'))
}

export function useOralEvalEngine() {
  const available = ref(false)
  const ready = ref(false)
  const volume = ref(0)
  const evaluating = ref(false)

  let engine: EngineInstance | null = null
  /** SDK 在构造时异步申请麦克风；未就绪时 startRecord 会报 createMediaStreamSource 错 */
  let micReadyPromise: Promise<void> | null = null
  let accent = 'am'
  let applicationId = ''
  let userId = ''

  async function probe() {
    try {
      const status = await fetchOralEvalStatus()
      available.value = Boolean(status.enabled && status.sdk_url)
      if (!available.value) {
        ready.value = true
        return false
      }
      accent = status.accent || 'am'
      applicationId = status.application_id
      await loadSdk(status.sdk_url)
      ready.value = true
      return true
    } catch {
      available.value = false
      ready.value = true
      return false
    }
  }

  function resetEngine() {
    try {
      engine?.cancelRecord?.()
    } catch {
      /* ignore */
    }
    engine = null
    micReadyPromise = null
  }

  async function ensureEngine(): Promise<EngineInstance> {
    const warrant = await getWarrant()
    applicationId = warrant.application_id || applicationId
    userId = warrant.user_id
    accent = warrant.accent || accent
    await loadSdk(warrant.sdk_url)

    const Ctor = window.EngineEvaluat
    if (!Ctor) throw new Error('口语评测 SDK 不可用')

    // 已有实例但麦克风流已失效 → 重建
    const existingStream = (engine as unknown as { _audio?: { stream?: MediaStream } } | null)?._audio?.stream
    if (engine && existingStream != null && !streamIsLive(existingStream)) {
      resetEngine()
    }

    if (!engine) {
      micReadyPromise = new Promise<void>((resolve, reject) => {
        let settled = false
        const timer = window.setTimeout(() => {
          if (settled) return
          settled = true
          reject(new Error('麦克风初始化超时，请检查权限后重试'))
        }, 20000)

        const finishOk = () => {
          if (settled) return
          settled = true
          window.clearTimeout(timer)
          resolve()
        }
        const finishErr = (msg: string) => {
          if (settled) return
          settled = true
          window.clearTimeout(timer)
          resetEngine()
          reject(new Error(msg))
        }

        try {
          engine = new Ctor({
            applicationId,
            userId,
            warrantId: warrant.warrant_id,
            coreType: 'en.sent.score',
            logIsOpen: false,
            micAllowCallback: () => finishOk(),
            micForbidCallback: () => finishErr('麦克风权限被拒绝或无法打开'),
            micVolumeCallback: (data: number) => {
              volume.value = Number(data) || 0
            },
            JSSDKNotSupport: () => finishErr('当前浏览器不支持口语评测'),
            noNetwork: () => undefined,
            engineFirstInitDone: () => undefined,
            engineBackResultDone: () => undefined,
            engineBackResultFail: () => undefined,
          })
        } catch (e) {
          finishErr(e instanceof Error ? e.message : '口语评测引擎初始化失败')
        }
      })
    }

    if (micReadyPromise) await micReadyPromise

    const liveStream = (engine as unknown as { _audio?: { stream?: MediaStream } } | null)?._audio?.stream
    if (liveStream != null && !streamIsLive(liveStream)) {
      resetEngine()
      throw new Error('麦克风未就绪，请允许权限后重试')
    }

    return engine!
  }

  function evaluate(
    refText: string,
    coreType: OralCoreType = 'en.sent.score',
  ): Promise<Record<string, unknown>> {
    const text = refText.trim()
    if (!text) return Promise.reject(new Error('评测文本为空'))

    return new Promise((resolve, reject) => {
      let settled = false
      const finishOk = (msg: string) => {
        if (settled) return
        settled = true
        evaluating.value = false
        try {
          const parsed = typeof msg === 'string' ? JSON.parse(msg) : msg
          resolve((parsed || {}) as Record<string, unknown>)
        } catch {
          reject(new Error('评测结果解析失败'))
        }
      }
      const finishErr = (msg: unknown) => {
        if (settled) return
        settled = true
        evaluating.value = false
        const detail =
          typeof msg === 'string'
            ? msg
            : msg && typeof msg === 'object'
              ? JSON.stringify(msg)
              : '口语评测失败'
        // MediaStream 类错误更友好
        const textMsg = detail.slice(0, 200)
        if (/MediaStream|createMediaStreamSource/i.test(textMsg)) {
          reject(new Error('麦克风未就绪，请允许权限后重试'))
          return
        }
        reject(new Error(textMsg))
      }

      void (async () => {
        try {
          evaluating.value = true
          const inst = await ensureEngine()
          const warrant = await getWarrant()
          const params: Record<string, unknown> = {
            coreType,
            refText: text,
            warrantId: warrant.warrant_id,
            rank: 100,
            precision: 0.5,
            attachAudioUrl: 1,
            outputPhones: coreType === 'en.word.score' ? 1 : 0,
            accent,
            evalTime: defaultEvalTimeMs(text, coreType),
          }
          inst.startRecord(params, finishOk, finishErr)
        } catch (e) {
          finishErr(e instanceof Error ? e.message : '口语评测启动失败')
        }
      })()
    })
  }

  /** @deprecated 使用 evaluate(text, 'en.sent.score') */
  function evaluateSentence(refText: string) {
    return evaluate(refText, 'en.sent.score')
  }

  function stop() {
    try {
      engine?.stopRecord()
    } catch {
      /* ignore */
    }
  }

  function cancel() {
    try {
      engine?.cancelRecord?.()
    } catch {
      /* ignore */
    }
    evaluating.value = false
  }

  return {
    available,
    ready,
    volume,
    evaluating,
    probe,
    evaluate,
    evaluateSentence,
    stop,
    cancel,
    resetEngine,
  }
}
