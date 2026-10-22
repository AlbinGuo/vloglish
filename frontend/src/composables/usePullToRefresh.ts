/**
 * 移动端"分离式"下拉刷新（基于 window 滚动）。
 *
 * 效果：在页面顶部下拉时，页面内容相对顶部 header 下移、露出两者之间的间隙，
 * 刷新图标出现在这条间隙里；下拉带橡皮筋阻尼 + 图标随下拉旋转/缩放，松手带弹性回弹。
 * 自绘指示器，无需改页面模板，仅需传入"要下移的内容元素"。
 *
 * - 仅在页面滚动到顶部时触发；
 * - 下拉超过阈值松手即触发 onRefresh()；
 * - enabled() 返回 false 时忽略手势（KeepAlive 页面非激活时禁用）。
 */
import { onMounted, onUnmounted } from 'vue'

export function usePullToRefresh(
  onRefresh: () => Promise<void> | void,
  opts: {
    enabled?: () => boolean
    getContentEl?: () => HTMLElement | null
    threshold?: number
    maxPull?: number
  } = {},
) {
  const threshold = opts.threshold ?? 64
  const maxPull = opts.maxPull ?? 120
  const enabled = opts.enabled ?? (() => true)
  const getContentEl = opts.getContentEl ?? (() => null)

  let gapEl: HTMLDivElement | null = null
  let iconEl: HTMLDivElement | null = null
  let startY = 0
  let gapTop = 0
  let pulling = false
  let distance = 0
  let refreshing = false
  let styleInjected = false

  function injectStyle() {
    if (styleInjected) return
    styleInjected = true
    const s = document.createElement('style')
    s.textContent =
      '@keyframes ptr-spin{to{transform:rotate(360deg)}}' +
      '.ptr-icon.ptr-spinning{animation:ptr-spin .72s linear infinite}'
    document.head.appendChild(s)
  }

  function ensureEl() {
    if (gapEl) return
    injectStyle()
    gapEl = document.createElement('div')
    gapEl.style.cssText = [
      'position:fixed',
      'left:0',
      'right:0',
      'top:0',
      'height:0',
      'z-index:2147482000',
      'overflow:hidden',
      'pointer-events:none',
      'display:flex',
      'align-items:center',
      'justify-content:center',
      'transition:height .3s cubic-bezier(.22,1,.36,1)',
    ].join(';')
    iconEl = document.createElement('div')
    iconEl.className = 'ptr-icon'
    iconEl.style.cssText = [
      'width:26px',
      'height:26px',
      'border-radius:50%',
      'border:2.5px solid rgba(130,130,130,.25)',
      'border-top-color:#888',
      'box-sizing:border-box',
      'will-change:transform,opacity',
      'opacity:0',
    ].join(';')
    gapEl.appendChild(iconEl)
    document.body.appendChild(gapEl)
  }

  /** 橡皮筋阻尼：越拉越费力，手感不生硬 */
  function damp(dy: number): number {
    return maxPull * (1 - Math.exp(-dy / 78))
  }

  function resetContent(el: HTMLElement | null, animated: boolean) {
    if (!el) return
    el.style.transition = animated
      ? 'transform .42s cubic-bezier(.22,1.3,.36,1), box-shadow .42s ease'
      : 'none'
    el.style.transform = 'translateY(0px)'
    el.style.boxShadow = ''
  }

  function onStart(e: TouchEvent) {
    if (!enabled() || refreshing) return
    if ((window.scrollY || document.documentElement.scrollTop || 0) > 0) return
    const el = getContentEl()
    if (!el) return
    ensureEl()
    startY = e.touches[0].clientY
    gapTop = el.getBoundingClientRect().top // header 底部（页面原始起始位置）
    pulling = true
    distance = 0
    el.style.transition = 'none'
  }

  function onMove(e: TouchEvent) {
    if (!pulling || refreshing) return
    const el = getContentEl()
    if (!el) return
    const dy = e.touches[0].clientY - startY
    if (dy <= 0) {
      distance = 0
      if (gapEl) gapEl.style.height = '0px'
      if (iconEl) iconEl.style.opacity = '0'
      el.style.transform = 'translateY(0px)'
      el.style.boxShadow = ''
      return
    }
    distance = damp(dy)
    el.style.transform = 'translateY(' + distance + 'px)'
    el.style.boxShadow = distance > 4 ? '0 12px 28px -10px rgba(0,0,0,.22)' : ''
    if (gapEl) {
      gapEl.style.top = gapTop + 'px'
      gapEl.style.height = distance + 'px'
    }
    if (iconEl) {
      iconEl.style.opacity = String(Math.min(1, distance / 42))
      iconEl.style.transform =
        'rotate(' + distance * 3.4 + 'deg) scale(' + (0.7 + Math.min(0.4, distance / maxPull)) + ')'
      iconEl.classList.toggle('ptr-spinning', distance >= threshold)
    }
  }

  async function onEnd() {
    if (!pulling || refreshing) return
    pulling = false
    const el = getContentEl()
    if (distance >= threshold && el) {
      refreshing = true
      if (gapEl) gapEl.style.height = threshold + 'px'
      if (iconEl) {
        iconEl.style.opacity = '1'
        iconEl.style.transform = 'scale(0.92)'
        iconEl.classList.add('ptr-spinning')
      }
      el.style.transition = 'transform .3s cubic-bezier(.22,1,.36,1)'
      el.style.transform = 'translateY(' + threshold + 'px)'
      try {
        await onRefresh()
      } finally {
        refreshing = false
        if (gapEl) gapEl.style.height = '0px'
        if (iconEl) {
          iconEl.classList.remove('ptr-spinning')
          iconEl.style.opacity = '0'
        }
        resetContent(el, true)
      }
    } else {
      if (gapEl) gapEl.style.height = '0px'
      if (iconEl) {
        iconEl.classList.remove('ptr-spinning')
        iconEl.style.opacity = '0'
      }
      resetContent(el, true)
    }
    distance = 0
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
    if (gapEl && gapEl.parentNode) gapEl.parentNode.removeChild(gapEl)
    gapEl = null
    iconEl = null
  })
}