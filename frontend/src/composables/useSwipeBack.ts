import { onMounted, onUnmounted } from 'vue'

type Options = {
  /** 是否启用（例如只在一级页以外的页面启用） */
  enabled?: () => boolean
  /** 判定为返回后的回调 */
  onBack: () => void
  /** 触发返回的水平位移阈值（px） */
  threshold?: number
  /** 限制只能从左侧边缘起手（px）；默认 Infinity 表示屏幕任意位置 */
  edgeWidth?: number
}

const CHEVRON_SVG =
  '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" ' +
  'stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">' +
  '<path d="m15 18-6-6 6-6"/></svg>'

/**
 * 移动端右滑返回。
 *
 * - 默认在屏幕任意位置起手，也可通过 edgeWidth 限制在左侧边缘；
 * - 横向右滑且位移超过阈值后触发 onBack()；
 * - 输入控件、滑块、可横向滚动区域、拖拽手柄等会自动忽略；
 * - 跟随手指显示一个小箭头作为反馈（不移动页面本身，避免 fixed 元素错位）。
 */
export function useSwipeBack(opts: Options) {
  const threshold = opts.threshold ?? 72
  const edgeWidth = opts.edgeWidth ?? Number.POSITIVE_INFINITY
  const enabled = opts.enabled ?? (() => true)

  let hintEl: HTMLDivElement | null = null
  let tracking = false
  let decided: 'horizontal' | 'vertical' | null = null
  let startX = 0
  let startY = 0
  let dx = 0
  let lastY = 0
  let startTime = 0
  let cooldownUntil = 0

  function ensureHint() {
    if (hintEl) return
    const el = document.createElement('div')
    el.innerHTML = CHEVRON_SVG
    el.setAttribute('aria-hidden', 'true')
    el.style.cssText = [
      'position:fixed',
      'left:0',
      'top:0',
      'width:40px',
      'height:40px',
      'display:flex',
      'align-items:center',
      'justify-content:center',
      'border-radius:9999px',
      'background:rgba(17,24,39,.52)',
      'color:#fff',
      'backdrop-filter:blur(6px)',
      '-webkit-backdrop-filter:blur(6px)',
      'box-shadow:0 6px 18px rgba(0,0,0,.22)',
      'pointer-events:none',
      'z-index:2147482500',
      'opacity:0',
      'will-change:transform,opacity',
      'transition:opacity .16s ease, transform .16s ease',
    ].join(';')
    document.body.appendChild(el)
    hintEl = el
  }

  function paintHint() {
    if (!hintEl) return
    const x = Math.min(46, 8 + dx * 0.32)
    const y = Math.max(8, Math.min(window.innerHeight - 48, lastY - 20))
    const opacity = Math.min(1, dx / 34)
    const scale = 0.86 + Math.min(0.22, dx / 280)
    hintEl.style.transition = 'none'
    hintEl.style.opacity = String(opacity)
    hintEl.style.transform = `translate(${x}px, ${y}px) scale(${scale})`
  }

  function hideHint(animated: boolean) {
    if (!hintEl) return
    hintEl.style.transition = animated
      ? 'opacity .18s ease, transform .18s ease'
      : 'none'
    hintEl.style.opacity = '0'
    hintEl.style.transform = 'translate(8px, 0) scale(.86)'
  }

  function reset() {
    tracking = false
    decided = null
    dx = 0
  }

  /** 输入控件、滑块、拖拽区域、可横向滚动区域等不参与返回手势 */
  function shouldIgnoreTarget(target: EventTarget | null): boolean {
    if (!(target instanceof Element)) return false
    if (
      target.closest(
        '[data-swipe-back-ignore], input, textarea, select, [role="slider"], [contenteditable="true"]',
      )
    ) {
      return true
    }
    let el: Element | null = target
    while (el && el !== document.body) {
      const style = window.getComputedStyle(el)
      if (
        style.cursor === 'col-resize' ||
        style.cursor === 'ns-resize' ||
        style.cursor === 'grab' ||
        style.cursor === 'grabbing'
      ) {
        return true
      }
      if (
        (style.overflowX === 'auto' || style.overflowX === 'scroll') &&
        el.scrollWidth > el.clientWidth + 1
      ) {
        return true
      }
      el = el.parentElement
    }
    return false
  }

  /** 正在选中文字时不触发返回，避免和长按选词/划词冲突 */
  function hasActiveSelection(): boolean {
    const selection = window.getSelection()
    return Boolean(selection && !selection.isCollapsed && selection.toString().trim())
  }

  function onStart(e: TouchEvent) {
    if (Date.now() < cooldownUntil) return
    if (!enabled() || e.touches.length !== 1) return
    // 有弹层/抽屉锁定了页面滚动时，优先让用户操作弹层
    if (document.body.style.overflow === 'hidden') return
    const touch = e.touches[0]
    if (!touch) return
    if (touch.clientX > edgeWidth) return
    if (shouldIgnoreTarget(e.target)) return
    if (hasActiveSelection()) return
    ensureHint()
    hideHint(false)
    tracking = true
    decided = null
    startX = touch.clientX
    startY = touch.clientY
    lastY = touch.clientY
    startTime = Date.now()
    dx = 0
  }

  function onMove(e: TouchEvent) {
    if (!tracking) return
    const touch = e.touches[0]
    if (!touch) return
    const mx = touch.clientX - startX
    const my = touch.clientY - startY
    lastY = touch.clientY

    if (!decided) {
      if (Math.abs(my) > 16 && Math.abs(my) > Math.abs(mx)) {
        decided = 'vertical'
        tracking = false
        hideHint(false)
        return
      }
      if (mx > 14) {
        decided = 'horizontal'
      } else if (mx < -10) {
        tracking = false
        return
      } else {
        return
      }
    }

    if (decided === 'horizontal') {
      if (hasActiveSelection()) {
        tracking = false
        hideHint(false)
        return
      }
      dx = Math.max(0, mx)
      paintHint()
    }
  }

  function onEnd() {
    if (!tracking) {
      hideHint(false)
      return
    }
    const elapsed = Date.now() - startTime
    const verticalDrift = Math.abs(lastY - startY)
    const triggered =
      decided === 'horizontal' &&
      verticalDrift <= 80 &&
      !hasActiveSelection() &&
      (dx >= threshold || (dx >= 48 && elapsed < 240))
    tracking = false
    decided = null
    hideHint(true)
    dx = 0
    if (triggered) {
      cooldownUntil = Date.now() + 700
      navigator.vibrate?.(10)
      opts.onBack()
    }
  }

  function onCancel() {
    reset()
    hideHint(true)
  }

  onMounted(() => {
    window.addEventListener('touchstart', onStart, { passive: true })
    window.addEventListener('touchmove', onMove, { passive: true })
    window.addEventListener('touchend', onEnd, { passive: true })
    window.addEventListener('touchcancel', onCancel, { passive: true })
  })

  onUnmounted(() => {
    window.removeEventListener('touchstart', onStart)
    window.removeEventListener('touchmove', onMove)
    window.removeEventListener('touchend', onEnd)
    window.removeEventListener('touchcancel', onCancel)
    if (hintEl && hintEl.parentNode) hintEl.parentNode.removeChild(hintEl)
    hintEl = null
  })
}
