import { ref } from 'vue'
import { fetchOralEvalStatus, fetchOralEvalWarrant, type OralEvalWarrant } from '@/api/oralEval'

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

function defaultEvalTimeMs(refText: string) {
  const words = refText.trim().split(/\s+/).filter(Boolean).length
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

export function useOralEvalEngine() {
  const available = ref(false)
  const ready = ref(false)
  const volume = ref(0)
  const evaluating = ref(false)

  let engine: EngineInstance | null = null
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

  async function ensureEngine(): Promise<EngineInstance> {
    const warrant = await getWarrant()
    applicationId = warrant.application_id || applicationId
    userId = warrant.user_id
    accent = warrant.accent || accent
    await loadSdk(warrant.sdk_url)

    const Ctor = window.EngineEvaluat
    if (!Ctor) throw new Error('口语评测 SDK 不可用')

    if (!engine) {
      engine = new Ctor({
        applicationId,
        userId,
        warrantId: warrant.warrant_id,
        coreType: 'en.sent.score',
        logIsOpen: false,
        micAllowCallback: () => undefined,
        micForbidCallback: () => undefined,
        micVolumeCallback: (data: number) => {
          volume.value = Number(data) || 0
        },
        JSSDKNotSupport: () => undefined,
        noNetwork: () => undefined,
        engineFirstInitDone: () => undefined,
        engineBackResultDone: () => undefined,
        engineBackResultFail: () => undefined,
      })
    }
    return engine
  }

  function evaluateSentence(refText: string): Promise<Record<string, unknown>> {
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
        reject(new Error(detail.slice(0, 200)))
      }

      void (async () => {
        try {
          evaluating.value = true
          const inst = await ensureEngine()
          const warrant = await getWarrant()
          const params: Record<string, unknown> = {
            coreType: 'en.sent.score',
            refText: text,
            warrantId: warrant.warrant_id,
            rank: 100,
            precision: 0.5,
            attachAudioUrl: 1,
            outputPhones: 0,
            accent,
            evalTime: defaultEvalTimeMs(text),
          }
          inst.startRecord(params, finishOk, finishErr)
        } catch (e) {
          finishErr(e instanceof Error ? e.message : '口语评测启动失败')
        }
      })()
    })
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
    evaluateSentence,
    stop,
    cancel,
  }
}
