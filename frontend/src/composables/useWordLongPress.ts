import { onUnmounted } from 'vue'

type LongPressOptions = {
  delayMs?: number
  moveThresholdPx?: number
  enabled?: () => boolean
  onLongPress: (event: PointerEvent) => void
}

/** 长按手势：超时触发 onLongPress；随后 click 可用 consumeIfFired() 拦截 */
export function useWordLongPress(options: LongPressOptions) {
  const delayMs = options.delayMs ?? 480
  const moveThresholdPx = options.moveThresholdPx ?? 12

  let timer: ReturnType<typeof setTimeout> | null = null
  let fired = false
  let startX = 0
  let startY = 0
  let activePointerId: number | null = null

  function clearTimer() {
    if (timer != null) {
      clearTimeout(timer)
      timer = null
    }
  }

  function reset() {
    clearTimer()
    activePointerId = null
  }

  function onPointerDown(e: PointerEvent) {
    if (options.enabled && !options.enabled()) return
    if (e.pointerType === 'mouse' && e.button !== 0) return

    reset()
    fired = false
    startX = e.clientX
    startY = e.clientY
    activePointerId = e.pointerId

    timer = setTimeout(() => {
      timer = null
      fired = true
      options.onLongPress(e)
      try {
        navigator.vibrate?.(12)
      } catch {
        // ignore
      }
    }, delayMs)
  }

  function onPointerMove(e: PointerEvent) {
    if (activePointerId != null && e.pointerId !== activePointerId) return
    if (!timer) return
    const dx = e.clientX - startX
    const dy = e.clientY - startY
    if (Math.hypot(dx, dy) > moveThresholdPx) {
      clearTimer()
    }
  }

  function onPointerUp(e: PointerEvent) {
    if (activePointerId != null && e.pointerId !== activePointerId) return
    clearTimer()
    activePointerId = null
  }

  function onPointerCancel(e: PointerEvent) {
    if (activePointerId != null && e.pointerId !== activePointerId) return
    reset()
    fired = false
  }

  /** 若刚完成长按，消费掉并返回 true（用于跳过随后的 click 查词） */
  function consumeIfFired() {
    if (!fired) return false
    fired = false
    return true
  }

  function onContextMenu(e: Event) {
    if (fired || timer != null) {
      e.preventDefault()
    }
  }

  onUnmounted(reset)

  return {
    onPointerDown,
    onPointerMove,
    onPointerUp,
    onPointerCancel,
    onContextMenu,
    consumeIfFired,
  }
}
