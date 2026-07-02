import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useIsMobile } from './useBreakpoint'

const SCROLL_DELTA = 8
const TOP_ALWAYS_SHOW = 20

/** Mobile catalog (/english): hide header on scroll down, show on scroll up. */
export function useCatalogMobileHeaderHide() {
  const route = useRoute()
  const isMobile = useIsMobile()
  const headerVisible = ref(true)
  const catalogHeaderAutoHide = computed(() => isMobile.value && route.path === '/english')
  let lastY = 0
  let listening = false

  function onScroll() {
    const y = window.scrollY
    if (y <= TOP_ALWAYS_SHOW) {
      headerVisible.value = true
    } else if (y - lastY > SCROLL_DELTA) {
      headerVisible.value = false
    } else if (lastY - y > SCROLL_DELTA) {
      headerVisible.value = true
    }
    lastY = y
  }

  function attach() {
    if (listening) return
    lastY = window.scrollY
    headerVisible.value = lastY <= TOP_ALWAYS_SHOW
    window.addEventListener('scroll', onScroll, { passive: true })
    listening = true
  }

  function detach() {
    if (!listening) return
    window.removeEventListener('scroll', onScroll)
    listening = false
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
