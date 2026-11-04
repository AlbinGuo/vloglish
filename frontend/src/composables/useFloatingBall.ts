import { ref, watch } from 'vue'

const STORAGE_KEY = 'teco-floating-ball-enabled'

/** 默认开启悬浮播放球；显式存为 false 时关闭 */
function loadFloatingBallEnabled(): boolean {
  try {
    const v = localStorage.getItem(STORAGE_KEY)
    if (v === null) return true
    return v === 'true'
  } catch {
    /* ignore */
  }
  return true
}

const floatingBallEnabled = ref(loadFloatingBallEnabled())

watch(floatingBallEnabled, (enabled) => {
  try {
    localStorage.setItem(STORAGE_KEY, enabled ? 'true' : 'false')
  } catch {
    /* ignore */
  }
})

export function useFloatingBall() {
  function setFloatingBallEnabled(enabled: boolean) {
    floatingBallEnabled.value = enabled
  }

  function toggleFloatingBall() {
    floatingBallEnabled.value = !floatingBallEnabled.value
  }

  return {
    floatingBallEnabled,
    setFloatingBallEnabled,
    toggleFloatingBall,
  }
}
