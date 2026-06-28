import { onMounted, onUnmounted, ref, type Ref } from 'vue'

export function useMediaQuery(query: string): Ref<boolean> {
  const matches = ref(false)
  let mql: MediaQueryList | null = null

  const update = () => {
    matches.value = mql?.matches ?? false
  }

  onMounted(() => {
    mql = window.matchMedia(query)
    update()
    mql.addEventListener('change', update)
  })

  onUnmounted(() => {
    mql?.removeEventListener('change', update)
  })

  return matches
}

/** Tailwind `lg` 以下视为移动端 */
export function useIsMobile() {
  return useMediaQuery('(max-width: 1023px)')
}

/** 手机（< md） */
export function useIsPhone() {
  return useMediaQuery('(max-width: 767px)')
}

/** 平板 / iPad（md ~ 桌面 xl 以下，含 iPad Pro 横屏） */
export function useIsPad() {
  return useMediaQuery('(min-width: 768px) and (max-width: 1439px)')
}

/** 手机横屏（宽度仍小于 lg） */
export function useIsMobileLandscape() {
  return useMediaQuery('(max-width: 1023px) and (orientation: landscape)')
}
