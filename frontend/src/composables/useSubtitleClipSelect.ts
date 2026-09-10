import { onMounted, onUnmounted, ref } from 'vue'

export type ClipSelectTarget = {
  text: string
  subtitleId: number | null
  top: number
  left: number
}

const MIN_CHARS = 2

function selectionRoot(node: Node | null): HTMLElement | null {
  if (!node) return null
  const el = node.nodeType === Node.ELEMENT_NODE ? (node as HTMLElement) : node.parentElement
  return el?.closest('.subtitle-english') as HTMLElement | null
}

function normalizeSelectedText(raw: string) {
  return raw.replace(/\s+/g, ' ').trim()
}

function isToolbarEvent(e: Event) {
  return Boolean((e.target as HTMLElement | null)?.closest?.('[data-clip-select-toolbar]'))
}

function isMousePointer(e: PointerEvent) {
  return !e.pointerType || e.pointerType === 'mouse'
}

function toolbarPoint(range: Range) {
  const rect = range.getBoundingClientRect()
  const width = rect.width || 0
  const height = rect.height || 0
  const hasBox = width > 1 || height > 1
  const rawTop = hasBox ? rect.top : 72
  const rawLeft = hasBox ? rect.left + width / 2 : window.innerWidth / 2
  const maxTop = Math.max(56, window.innerHeight - 120)
  let top = Math.min(maxTop, Math.max(56, rawTop - 8))
  if (rawTop < 64 && hasBox) {
    top = Math.min(maxTop, rect.bottom + 40)
  }
  const left = Math.min(window.innerWidth - 16, Math.max(16, rawLeft))
  return { top, left }
}

/**
 * 桌面：鼠标划选即可。
 * 手机：须 touchEnabled（划选模式）打开后才捕获触控选区，避免和点词 / 长按生词本冲突。
 */
export function useSubtitleClipSelect(options: {
  enabled: () => boolean
  touchEnabled?: () => boolean
  resolveSubtitleId: (el: HTMLElement) => number | null
}) {
  const target = ref<ClipSelectTarget | null>(null)
  let suppressClickUntil = 0
  let captureTimer: ReturnType<typeof setTimeout> | null = null

  function hide() {
    target.value = null
  }

  function shouldSuppressClick() {
    if (Date.now() < suppressClickUntil) return true
    const selected = normalizeSelectedText(window.getSelection()?.toString() || '')
    return selected.length >= MIN_CHARS
  }

  function captureFromSelection() {
    if (!options.enabled()) {
      hide()
      return
    }
    const sel = window.getSelection()
    if (!sel || sel.rangeCount === 0 || sel.isCollapsed) {
      hide()
      return
    }
    const text = normalizeSelectedText(sel.toString())
    if (text.length < MIN_CHARS) {
      hide()
      return
    }
    const range = sel.getRangeAt(0)
    const startRoot = selectionRoot(range.startContainer)
    const endRoot = selectionRoot(range.endContainer)
    if (!startRoot || startRoot !== endRoot) {
      hide()
      return
    }
    const { top, left } = toolbarPoint(range)
    target.value = {
      text: text.slice(0, 500),
      subtitleId: options.resolveSubtitleId(startRoot),
      top,
      left,
    }
    suppressClickUntil = Date.now() + 450
  }

  function scheduleCapture(delayMs: number) {
    if (captureTimer != null) clearTimeout(captureTimer)
    captureTimer = setTimeout(() => {
      captureTimer = null
      window.requestAnimationFrame(captureFromSelection)
    }, delayMs)
  }

  function onPointerUp(e: PointerEvent) {
    if (isToolbarEvent(e)) return
    const mouse = isMousePointer(e)
    if (!mouse && !options.touchEnabled?.()) return
    scheduleCapture(mouse ? 0 : 200)
  }

  function onPointerDown(e: PointerEvent) {
    if (isToolbarEvent(e)) return
    if (options.touchEnabled?.()) {
      const inSubtitle = Boolean((e.target as HTMLElement | null)?.closest?.('.subtitle-english'))
      if (!inSubtitle) hide()
      return
    }
    if (target.value) hide()
  }

  function onSelectionChange() {
    if (!options.enabled() || !options.touchEnabled?.()) return
    scheduleCapture(80)
  }

  function onKeyDown(e: KeyboardEvent) {
    if (e.key === 'Escape') hide()
  }

  function onScroll() {
    if (options.touchEnabled?.()) {
      if (target.value) scheduleCapture(60)
      return
    }
    if (target.value) hide()
  }

  onMounted(() => {
    document.addEventListener('pointerup', onPointerUp)
    document.addEventListener('pointerdown', onPointerDown)
    document.addEventListener('selectionchange', onSelectionChange)
    document.addEventListener('keydown', onKeyDown)
    document.addEventListener('scroll', onScroll, true)
  })

  onUnmounted(() => {
    if (captureTimer != null) clearTimeout(captureTimer)
    document.removeEventListener('pointerup', onPointerUp)
    document.removeEventListener('pointerdown', onPointerDown)
    document.removeEventListener('selectionchange', onSelectionChange)
    document.removeEventListener('keydown', onKeyDown)
    document.removeEventListener('scroll', onScroll, true)
    hide()
  })

  return { target, hide, shouldSuppressClick }
}
