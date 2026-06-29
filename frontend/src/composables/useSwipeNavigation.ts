import { onUnmounted, watch, type Ref } from 'vue'

type SwipeHandlers = {
  onSwipeLeft?: () => void
  onSwipeRight?: () => void
}

const SWIPE_THRESHOLD_PX = 56
const MAX_VERTICAL_DRIFT_PX = 40

export function useSwipeNavigation(elRef: Ref<HTMLElement | null>, handlers: SwipeHandlers) {
  let startX = 0
  let startY = 0
  let tracking = false

  function onTouchStart(e: TouchEvent) {
    if (e.touches.length !== 1) return
    startX = e.touches[0]!.clientX
    startY = e.touches[0]!.clientY
    tracking = true
  }

  function onTouchEnd(e: TouchEvent) {
    if (!tracking) return
    tracking = false
    const touch = e.changedTouches[0]
    if (!touch) return

    const dx = touch.clientX - startX
    const dy = touch.clientY - startY
    if (Math.abs(dy) > MAX_VERTICAL_DRIFT_PX) return
    if (Math.abs(dx) < SWIPE_THRESHOLD_PX) return

    if (dx < 0) handlers.onSwipeLeft?.()
    else handlers.onSwipeRight?.()
  }

  function bind(el: HTMLElement | null) {
    if (!el) return () => {}
    el.addEventListener('touchstart', onTouchStart, { passive: true })
    el.addEventListener('touchend', onTouchEnd, { passive: true })
    return () => {
      el.removeEventListener('touchstart', onTouchStart)
      el.removeEventListener('touchend', onTouchEnd)
    }
  }

  let cleanup: (() => void) | undefined

  watch(
    elRef,
    (el) => {
      cleanup?.()
      cleanup = bind(el)
    },
    { immediate: true },
  )

  onUnmounted(() => cleanup?.())
}
