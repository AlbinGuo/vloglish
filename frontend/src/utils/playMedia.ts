/**
 * Android System WebView 在 pause / seek 之后，play() 经常：
 * - 返回 AbortError（仍在 seeking）
 * - Promise 空成功但 paused 仍为 true
 * - 媒体管道休眠，需要一次微 seek 才能唤醒
 * 网页 Chrome 一般没有这些问题。
 */

type AbortFn = (() => boolean) | undefined

function aborted(shouldAbort: AbortFn) {
  return shouldAbort?.() === true
}

function stopIfAborted(el: HTMLMediaElement, shouldAbort: AbortFn) {
  if (!aborted(shouldAbort)) return false
  try {
    el.pause()
  } catch {
    /* ignore */
  }
  return true
}

function waitForEvent(el: HTMLMediaElement, type: string, ms: number, shouldAbort?: AbortFn) {
  return new Promise<void>((resolve) => {
    if (aborted(shouldAbort) || (type === 'seeked' && !el.seeking)) {
      resolve()
      return
    }
    const timer = window.setTimeout(() => {
      el.removeEventListener(type, onEvent)
      resolve()
    }, ms)
    const onEvent = () => {
      window.clearTimeout(timer)
      resolve()
    }
    el.addEventListener(type, onEvent, { once: true })
  })
}

async function tryPlay(el: HTMLMediaElement) {
  const pending = el.play()
  if (pending && typeof pending.then === 'function') await pending
  return !el.paused && !el.ended
}

export async function resumeMedia(
  el: HTMLMediaElement | null | undefined,
  shouldAbort?: AbortFn,
): Promise<boolean> {
  if (!el || !el.isConnected) return false
  if (stopIfAborted(el, shouldAbort)) return false
  if (el.ended) {
    try {
      el.currentTime = 0
    } catch {
      /* ignore */
    }
  }
  if (!el.paused && !el.ended) return !aborted(shouldAbort)

  try {
    if (await tryPlay(el)) return !stopIfAborted(el, shouldAbort)
  } catch (err) {
    const name = err instanceof DOMException ? err.name : ''
    if (name === 'NotAllowedError') return !el.paused && !aborted(shouldAbort)
  }
  if (stopIfAborted(el, shouldAbort)) return false

  if (el.seeking) await waitForEvent(el, 'seeked', 1600, shouldAbort)
  if (stopIfAborted(el, shouldAbort)) return false
  if (el.readyState < 2) await waitForEvent(el, 'canplay', 1600, shouldAbort)
  if (stopIfAborted(el, shouldAbort)) return false

  try {
    if (await tryPlay(el)) return !stopIfAborted(el, shouldAbort)
  } catch {
    /* recover below */
  }
  if (stopIfAborted(el, shouldAbort)) return false

  const t = Number.isFinite(el.currentTime) ? el.currentTime : 0
  try {
    el.currentTime = t
  } catch {
    /* ignore */
  }
  await waitForEvent(el, 'seeked', 800, shouldAbort)
  if (stopIfAborted(el, shouldAbort)) return false
  try {
    const ok = await tryPlay(el)
    if (stopIfAborted(el, shouldAbort)) return false
    return ok
  } catch {
    return !el.paused && !el.ended && !aborted(shouldAbort)
  }
}

/** 只停播放，保留 src，给暂停按钮用 */
export function pauseMedia(el: HTMLMediaElement | null | undefined) {
  if (!el) return
  try {
    el.pause()
  } catch {
    /* ignore */
  }
}

/** 卸载 / 换实例前先停掉并断开资源，避免 Chrome 把已移除的 video 继续出声 */
export function silenceMedia(el: HTMLMediaElement | null | undefined) {
  pauseMedia(el)
  if (!el) return
  try {
    el.removeAttribute('src')
    el.srcObject = null
    el.load()
  } catch {
    /* ignore */
  }
}

export async function seekMedia(
  el: HTMLMediaElement | null | undefined,
  time: number,
  opts?: { resume?: boolean; shouldAbort?: AbortFn },
) {
  if (!el || !el.isConnected) return
  const resume = opts?.resume ?? !el.paused
  const max = Number.isFinite(el.duration) && el.duration > 0 ? el.duration : time
  const next = Math.max(0, Math.min(max, time))
  try {
    el.currentTime = next
  } catch {
    /* ignore */
  }
  await waitForEvent(el, 'seeked', 1600, opts?.shouldAbort)
  if (aborted(opts?.shouldAbort)) return
  if (resume) await resumeMedia(el, opts?.shouldAbort)
}
