/**
 * 移动端下拉刷新（基于 window 滚动）。自绘顶部指示器，无需改页面模板。
 *
 * - 仅在页面滚动到顶部时触发；
 * - 下拉超过阈值松手即触发 onRefresh()，期间显示"刷新中…"；
 * - enabled() 返回 false 时忽略手势（用于 KeepAlive 页面在非激活时禁用）。
 */
import { onMounted, onUnmounted } from 'vue'

export function usePullToRefresh(
  onRefresh: () => Promise<void> | void,
  opts: { enabled?: () => boolean; threshold?: number; maxPull?: number } = {},
) {
  const threshold = opts.threshold ?? 60
  const maxPull = opts.maxPull ?? 90
  const enabled = opts.enabled ?? (() => true)

  let el: HTMLDivElement | null = null
  let label: HTMLDivElement | null = null
  let startY = 0
  let pulling = false
  let distance = 0
  let refreshing = false

  function ensureEl() {
    if (el) return
    el = document.createElement('div')
    el.style.cssText = [
      'position:fixed',
      'left:0',
      'right:0',
      'top:0',
      'height:0',
      'z-index:2147483000',
      'display:flex',
      'align-items:flex-end',
      'justify-content:center',
      'overflow:hidden',
      'pointer-events:none',
      'transition:height .2s ease',
      'padding-bottom:8px',
      'box-sizing:border-box',
    ].join(';')
    label = document.createElement('div')
    label.style.cssText =
      'font-size:12px;color:#666;background:rgba(255,255,255,.95);border-radius:999px;padding:5px 14px;box-shadow:0 2px 10px rgba(0,0,0,.1)'
    el.appendChild(label)
    document.body.appendChild(el)
  }

  function setHeight(h: number) {
    ensureEl()
    if (el) el.style.height = h + 'px'
  }
  function setLabel(t: string) {
    if (label) label.textContent = t
  }
  function hide() {
    if (el) {
      el.style.transition = 'height .2s ease'
      el.style.height = '0px'
    }
    distance = 0
  }

  function onStart(e: TouchEvent) {
    if (!enabled() || refreshing) return
    if ((window.scrollY || document.documentElement.scrollTop || 0) > 0) return
    startY = e.touches[0].clientY
    pulling = true
    distance = 0
    if (el) el.style.transition = 'none'
  }

  function onMove(e: TouchEvent) {
    if (!pulling || refreshing) return
    const dy = e.touches[0].clientY - startY
    if (dy <= 0) {
      distance = 0
      setHeight(0)
      setLabel('')
      return
    }
    distance = Math.min(maxPull, dy * 0.5)
    setHeight(distance)
    setLabel(distance >= threshold ? '松开刷新' : '下拉刷新')
  }

  async function onEnd() {
    if (!pulling) return
    pulling = false
    if (distance >= threshold) {
      refreshing = true
      setHeight(threshold)
      setLabel('刷新中…')
      try {
        await onRefresh()
      } finally {
        refreshing = false
        hide()
        setLabel('')
      }
    } else {
      hide()
      setLabel('')
    }
  }

  onMounted(() => {
    window.addEventListener('touchstart', onStart, { passive: true })
    window.addEventListener('touchmove', onMove, { passive: true })
    window.addEventListener('touchend', onEnd, { passive: true })
    window.addEventListener('touchcancel', onEnd, { passive: true })
  })

  onUnmounted(() => {
    window.removeEventListener('touchstart', onStart)
    window.removeEventListener('touchmove', onMove)
    window.removeEventListener('touchend', onEnd)
    window.removeEventListener('touchcancel', onEnd)
    if (el && el.parentNode) el.parentNode.removeChild(el)
    el = null
    label = null
  })
}