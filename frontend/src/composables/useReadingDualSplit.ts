import { onUnmounted, ref, watch } from 'vue'

const STORAGE_KEY = 'reading-dual-left-percent'
const MIN_PERCENT = 28
const MAX_PERCENT = 72
const DEFAULT_PERCENT = 50

function loadLeftPercent(): number {
  try {
    const raw = Number(localStorage.getItem(STORAGE_KEY))
    if (Number.isFinite(raw) && raw >= MIN_PERCENT && raw <= MAX_PERCENT) return raw
  } catch {
    /* ignore */
  }
  return DEFAULT_PERCENT
}

const leftPercent = ref(loadLeftPercent())
const dragging = ref(false)

watch(leftPercent, (value) => {
  try {
    localStorage.setItem(STORAGE_KEY, String(Math.round(value * 10) / 10))
  } catch {
    /* ignore */
  }
})

/** 文章详情「全文」栏宽度拖拽（右侧为词文对照 + 段落） */
export function useReadingDualSplit() {
  let moveHandler: ((e: PointerEvent) => void) | null = null
  let upHandler: ((e: PointerEvent) => void) | null = null

  function clamp(value: number) {
    return Math.min(MAX_PERCENT, Math.max(MIN_PERCENT, value))
  }

  function stopDragging() {
    dragging.value = false
    document.body.style.removeProperty('cursor')
    document.body.style.removeProperty('user-select')
    if (moveHandler) {
      window.removeEventListener('pointermove', moveHandler)
      moveHandler = null
    }
    if (upHandler) {
      window.removeEventListener('pointerup', upHandler)
      window.removeEventListener('pointercancel', upHandler)
      upHandler = null
    }
  }

  function startDrag(event: PointerEvent, container: HTMLElement | null) {
    if (!container || event.button !== 0) return
    event.preventDefault()

    const rect = container.getBoundingClientRect()
    if (rect.width <= 0) return

    const startX = event.clientX
    const startPercent = leftPercent.value
    dragging.value = true
    document.body.style.cursor = 'col-resize'
    document.body.style.userSelect = 'none'

    moveHandler = (ev: PointerEvent) => {
      const deltaPercent = ((ev.clientX - startX) / rect.width) * 100
      leftPercent.value = clamp(startPercent + deltaPercent)
    }
    upHandler = () => stopDragging()

    window.addEventListener('pointermove', moveHandler)
    window.addEventListener('pointerup', upHandler)
    window.addEventListener('pointercancel', upHandler)
  }

  onUnmounted(stopDragging)

  return {
    leftPercent,
    dragging,
    startDrag,
    minPercent: MIN_PERCENT,
    maxPercent: MAX_PERCENT,
  }
}
