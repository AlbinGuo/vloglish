import { computed, ref, watch } from 'vue'

const STORAGE_KEY = 'teco-intensive-reading-mode'

function loadIntensiveReadingMode(): boolean {
  try {
    return localStorage.getItem(STORAGE_KEY) === 'true'
  } catch {
    /* ignore */
  }
  return false
}

const intensiveMode = ref(loadIntensiveReadingMode())

watch(intensiveMode, (enabled) => {
  try {
    localStorage.setItem(STORAGE_KEY, enabled ? 'true' : 'false')
  } catch {
    /* ignore */
  }
})

export function useIntensiveReadingMode() {
  const intensivePageClass = computed(() => ({
    'intensive-reading-mode': intensiveMode.value,
  }))

  function setIntensiveMode(enabled: boolean) {
    intensiveMode.value = enabled
  }

  function toggleIntensiveMode() {
    intensiveMode.value = !intensiveMode.value
  }

  return {
    intensiveMode,
    intensivePageClass,
    setIntensiveMode,
    toggleIntensiveMode,
  }
}
