/**
 * 移动端"分离式"下拉刷新（基于 window 滚动）。
 *
 * 效果：页面内容相对顶部（header/标签）下移、露出两者之间的间隙，
 * 间隙带渐变底色，中间显示一个自定义"星芒"图标；下拉带橡皮筋阻尼 +
 * 图标随下拉旋转/放大，松手弹性回弹；刷新时星芒持续旋转。
 *
 * - 仅在页面滚动到顶部时触发；下拉超过阈值松手触发 onRefresh()；
 * - enabled() 返回 false 时忽略手势（KeepAlive 页面非激活时禁用）。
 */
import { onMounted, onUnmounted } from 'vue'

const SPARKLE_SVG =
  '<svg viewBox="0 0 24 20" width="22" height="22" fill="none">' +
  '<path d="M12 2C12.8 7.2 14.8 9.2 20 10C14.8 10.8 12.8 12.8 12 18C11.2 12.8 9.2 10.8 4 10C9.2 9.2 11.2 7.2 12 2Z" fill="#c9a24a"/>' +
  '</svg>'

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
      '.ptr-icon.ptr-spinning{animation:ptr-spin .8s linear infinite}'
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
      'background:linear-gradient(180deg, rgba(201,162,74,0.20) 0%, rgba(201,162,74,0.06) 55%, rgba(201,162,74,0) 100%)',
      'transition:height .3s cubic-bezier(.22,1,.36,1)',
    ].join(';')
    iconEl = document.createElement('div')
    iconEl.className = 'ptr-icon'
    iconEl.style.cssText = [
      'display:flex',
      'align-items:center',
      'justify-content:center',
      'width:24px',
      'height:24px',
      'will-change:transform,opacity',
      'opacity:0',
      'filter:drop-shadow(0 1px 2px rgba(201,162,74,.35))',
    ].join(';')
    iconEl.innerHTML = SPARKLE_SVG
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
    gapTop = el.getBoundingClientRect().top
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
    el.style.boxShadow = distance > 4 ? '0 14px 30px -12px rgba(0,0,0,.22)' : ''
    if (gapEl) {
      gapEl.style.top = gapTop + 'px'
      gapEl.style.height = distance + 'px'
    }
    if (iconEl) {
      iconEl.style.opacity = String(Math.min(1, distance / 36))
      const deg = distance * 2.2
      const scale = 0.6 + Math.min(0.6, distance / maxPull)
      iconEl.style.transform = 'rotate(' + deg + 'deg) scale(' + scale + ')'
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
        iconEl.style.transform = 'scale(1)'
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