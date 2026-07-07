import { nextTick, onActivated } from 'vue'
import { onBeforeRouteLeave } from 'vue-router'

const STORAGE_KEY = 'vlogish-catalog-scroll-y'

function readScrollY(): number {
  const raw = sessionStorage.getItem(STORAGE_KEY)
  if (!raw) return 0
  const top = Number.parseInt(raw, 10)
  return Number.isFinite(top) && top > 0 ? top : 0
}

function writeScrollY() {
  if (window.scrollY > 0) {
    sessionStorage.setItem(STORAGE_KEY, String(Math.round(window.scrollY)))
  }
}

function applyScrollY(top: number) {
  if (top <= 0) return
  requestAnimationFrame(() => {
    window.scrollTo({ top, left: 0, behavior: 'instant' })
  })
}

/** Remember catalog list scroll when opening an episode; restore when coming back. */
export function useCatalogScrollMemory() {
  onBeforeRouteLeave((to) => {
    if (to.path.startsWith('/english/episode/') || to.path.startsWith('/english/demo/')) {
      writeScrollY()
    } else {
      sessionStorage.removeItem(STORAGE_KEY)
    }
  })

  async function restore() {
    const top = readScrollY()
    if (top <= 0) return
    await nextTick()
    applyScrollY(top)
  }

  onActivated(() => {
    void restore()
  })

  return { restore }
}
