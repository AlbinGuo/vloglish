import { ref, watch } from 'vue'

export type ThemeMode = 'light' | 'dark' | 'system'

const STORAGE_KEY = 'teco-theme'

function isAdminRoute(): boolean {
  return typeof window !== 'undefined' && window.location.pathname.startsWith('/gnadmin')
}

function getSystemTheme(): 'light' | 'dark' {
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
}

function loadThemeMode(): ThemeMode {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored === 'light' || stored === 'dark' || stored === 'system') return stored
  } catch {
    /* ignore */
  }
  return 'light'
}

function resolveTheme(mode: ThemeMode): 'light' | 'dark' {
  if (isAdminRoute()) return 'light'
  return mode === 'system' ? getSystemTheme() : mode
}

function applyTheme(resolved: 'light' | 'dark') {
  document.documentElement.classList.toggle('dark', resolved === 'dark')
}

const themeMode = ref<ThemeMode>(loadThemeMode())
const resolvedTheme = ref<'light' | 'dark'>(resolveTheme(themeMode.value))

let systemListener: ((e: MediaQueryListEvent) => void) | null = null

function bindSystemListener() {
  if (systemListener) return
  const mq = window.matchMedia('(prefers-color-scheme: dark)')
  systemListener = () => {
    if (themeMode.value === 'system') {
      resolvedTheme.value = resolveTheme('system')
      applyTheme(resolvedTheme.value)
    }
  }
  mq.addEventListener('change', systemListener)
}

function unbindSystemListener() {
  if (!systemListener) return
  window.matchMedia('(prefers-color-scheme: dark)').removeEventListener('change', systemListener)
  systemListener = null
}

function syncTheme() {
  resolvedTheme.value = resolveTheme(themeMode.value)
  applyTheme(resolvedTheme.value)
  if (themeMode.value === 'system') bindSystemListener()
  else unbindSystemListener()
}

watch(
  themeMode,
  (mode) => {
    try {
      localStorage.setItem(STORAGE_KEY, mode)
    } catch {
      /* ignore */
    }
    syncTheme()
  },
  { immediate: true },
)

export function initTheme() {
  syncTheme()
}

export function syncThemeOnRoute() {
  syncTheme()
}

export function useTheme() {
  function setThemeMode(mode: ThemeMode) {
    themeMode.value = mode
  }

  return {
    themeMode,
    resolvedTheme,
    setThemeMode,
  }
}
