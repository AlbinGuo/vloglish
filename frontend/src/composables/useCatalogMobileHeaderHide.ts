import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useIsMobile } from './useBreakpoint'

/** 有效滑动阈值：过小易被惯性/回弹误触发 */
const SCROLL_DELTA = 16
const TOP_ALWAYS_SHOW = 24
/** 占位高度变化后忽略滚动事件，避免 scrollY 跳变导致 header 闪烁 */
const IGNORE_AFTER_TOGGLE_MS = 380

/** Mobile catalog (/english): hide header on scroll down, show on scroll up. */
export function useCatalogMobileHeaderHide() {
  const route = useRoute()
  const isMobile = useIsMobile()
  const headerVisible = ref(true)
  const catalogHeaderAutoHide = computed(() => isMobile.value && route.path === '/english')
  let lastY = 0
  let listening = false
  let ignoreUntil = 0
  let rafSync: number | null = null

  function syncLastY() {
    lastY = window.scrollY || window.pageYOffset || 0
  }

  function armIgnore() {
    ignoreUntil = performance.now() + IGNORE_AFTER_TOGGLE_MS
    if (rafSync != null) cancelAnimationFrame(rafSync)
    // 等布局（spacer 高度）结算后再对齐 lastY，吞掉跳变产生的假滚动
    rafSync = requestAnimationFrame(() => {
      rafSync = requestAnimationFrame(() => {
        rafSync = null
        syncLastY()
      })
    })
  }

  function setVisible(next: boolean) {
    if (headerVisible.value === next) return
    headerVisible.value = next
    armIgnore()
  }

  function onScroll() {
    const y = window.scrollY || window.pageYOffset || 0
    if (performance.now() < ignoreUntil) {
      lastY = y
      return
    }

    if (y <= TOP_ALWAYS_SHOW) {
      setVisible(true)
      lastY = y
      return
    }

    const delta = y - lastY
    if (delta > SCROLL_DELTA) {
      setVisible(false)
    } else if (delta < -SCROLL_DELTA) {
      setVisible(true)
    }
    lastY = y
  }

  function attach() {
    if (listening) return
    syncLastY()
    headerVisible.value = lastY <= TOP_ALWAYS_SHOW
    window.addEventListener('scroll', onScroll, { passive: true })
    listening = true
  }

  function detach() {
    if (!listening) return
    window.removeEventListener('scroll', onScroll)
    listening = false
    ignoreUntil = 0
    if (rafSync != null) {
      cancelAnimationFrame(rafSync)
      rafSync = null
    }
    headerVisible.value = true
  }

  function syncListener() {
    if (catalogHeaderAutoHide.value) attach()
    else detach()
  }

  watch(catalogHeaderAutoHide, syncListener)
  onMounted(syncListener)
  onUnmounted(detach)

  return { headerVisible, catalogHeaderAutoHide }
}
