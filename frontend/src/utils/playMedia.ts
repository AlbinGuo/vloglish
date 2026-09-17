/**
 * Android System WebView 在 pause / seek 之后，play() 经常：
 * - 返回 AbortError（仍在 seeking）
 * - Promise 空成功但 paused 仍为 true
 * - 媒体管道休眠，需要一次微 seek 才能唤醒
 * 网页 Chrome 一般没有这些问题。
 */

function waitForEvent(el: HTMLMediaElement, type: string, ms: number) {
  return new Promise<void>((resolve) => {
    if (type === 'seeked' && !el.seeking) {
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

export async function resumeMedia(el: HTMLMediaElement | null | undefined): Promise<boolean> {
  if (!el || !el.isConnected) return false
  if (el.ended) {
    try {
      el.currentTime = 0
    } catch {
      /* ignore */
    }
  }
  if (!el.paused && !el.ended) return true

  try {
    if (await tryPlay(el)) return true
  } catch (err) {
    const name = err instanceof DOMException ? err.name : ''
    if (name === 'NotAllowedError') return !el.paused
  }

  if (el.seeking) await waitForEvent(el, 'seeked', 1600)
  if (el.readyState < 2) await waitForEvent(el, 'canplay', 1600)

  try {
    if (await tryPlay(el)) return true
  } catch {
    /* recover below */
  }

  const t = Number.isFinite(el.currentTime) ? el.currentTime : 0
  try {
    el.currentTime = t
  } catch {
    /* ignore */
  }
  await waitForEvent(el, 'seeked', 800)
  try {
    return await tryPlay(el)
  } catch {
    return !el.paused && !el.ended
  }
}

export async function seekMedia(
  el: HTMLMediaElement | null | undefined,
  time: number,
  opts?: { resume?: boolean },
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
  await waitForEvent(el, 'seeked', 1600)
  if (resume) await resumeMedia(el)
}
