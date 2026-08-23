import { onUnmounted, ref, watch } from 'vue'

const STORAGE_KEY = 'teco-episode-video-percent'
const MIN_PERCENT = 32
const MAX_PERCENT = 62
const DEFAULT_PERCENT = 46

function loadVideoPercent(): number {
  try {
    const raw = Number(localStorage.getItem(STORAGE_KEY))
    if (Number.isFinite(raw) && raw >= MIN_PERCENT && raw <= MAX_PERCENT) return raw
  } catch {
    /* ignore */
  }
  return DEFAULT_PERCENT
}

const videoPercent = ref(loadVideoPercent())
const dragging = ref(false)

watch(videoPercent, (value) => {
  try {
    localStorage.setItem(STORAGE_KEY, String(Math.round(value * 10) / 10))
  } catch {
    /* ignore */
  }
})

function clamp(value: number) {
  return Math.min(MAX_PERCENT, Math.max(MIN_PERCENT, value))
}

/** 视频详情左右栏宽度：PC / iPad 横屏可拖，记住比例，双击复位 */
export function useEpisodeVideoSplit() {
  let moveHandler: ((e: PointerEvent) => void) | null = null
  let upHandler: ((e: PointerEvent) => void) | null = null

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
    const startPercent = videoPercent.value
    dragging.value = true
    document.body.style.cursor = 'col-resize'
    document.body.style.userSelect = 'none'

    moveHandler = (ev: PointerEvent) => {
      const deltaPercent = ((ev.clientX - startX) / rect.width) * 100
      videoPercent.value = clamp(startPercent + deltaPercent)
    }
    upHandler = () => stopDragging()

    window.addEventListener('pointermove', moveHandler)
    window.addEventListener('pointerup', upHandler)
    window.addEventListener('pointercancel', upHandler)
  }

  function reset() {
    videoPercent.value = DEFAULT_PERCENT
  }

  function nudge(delta: number) {
    videoPercent.value = clamp(videoPercent.value + delta)
  }

  onUnmounted(stopDragging)

  return {
    videoPercent,
    dragging,
    startDrag,
    reset,
    nudge,
    minPercent: MIN_PERCENT,
    maxPercent: MAX_PERCENT,
    defaultPercent: DEFAULT_PERCENT,
  }
}
