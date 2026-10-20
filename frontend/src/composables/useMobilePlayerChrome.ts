import { onUnmounted, ref, watch, type Ref } from 'vue'

const HIDE_DELAY_MS = 3000

export function useMobilePlayerChrome(options: {
  enabled: Ref<boolean>
  isPlaying: Ref<boolean>
  isBlocked?: Ref<boolean>
  /** 是否在播放中自动隐藏控制栏（默认 true）。App 视频页关闭后始终常驻显示 */
  autoHide?: boolean
}) {
  const autoHide = options.autoHide !== false
  const visible = ref(true)
  let hideTimer: ReturnType<typeof setTimeout> | null = null

  function clearHideTimer() {
    if (hideTimer) {
      clearTimeout(hideTimer)
      hideTimer = null
    }
  }

  function scheduleHide() {
    clearHideTimer()
    if (!autoHide) return
    if (!options.enabled.value || !options.isPlaying.value) return
    if (options.isBlocked?.value) return

    hideTimer = setTimeout(() => {
      if (options.enabled.value && options.isPlaying.value && !options.isBlocked?.value) {
        visible.value = false
      }
    }, HIDE_DELAY_MS)
  }

  function reveal() {
    visible.value = true
    scheduleHide()
  }

  function toggle() {
    if (!autoHide) {
      visible.value = true
      return
    }
    if (visible.value) {
      visible.value = false
      clearHideTimer()
      return
    }
    reveal()
  }

  function onChromeInteraction() {
    if (!options.enabled.value) return
    reveal()
  }

  watch(
    () => options.isPlaying.value,
    (playing) => {
      if (!options.enabled.value) return
      if (playing) {
        if (visible.value) scheduleHide()
      } else {
        visible.value = true
        clearHideTimer()
      }
    },
    { immediate: true },
  )

  watch(
    () => options.isBlocked?.value,
    (blocked) => {
      if (!options.enabled.value) return
      if (blocked) {
        visible.value = true
        clearHideTimer()
      } else if (options.isPlaying.value && visible.value) {
        scheduleHide()
      }
    },
  )

  watch(options.enabled, (on) => {
    if (!on) {
      visible.value = true
      clearHideTimer()
      return
    }
    visible.value = true
    if (options.isPlaying.value) scheduleHide()
  })

  onUnmounted(clearHideTimer)

  return { visible, reveal, toggle, onChromeInteraction, scheduleHide, clearHideTimer }
}
