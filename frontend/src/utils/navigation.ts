import type { Router } from 'vue-router'

/** 当前页面是否有可回退的历史记录 */
export function canNavigateBack(): boolean {
  if (typeof window === 'undefined') return false
  const state = window.history.state as { back?: string | null } | null
  if (state && Object.prototype.hasOwnProperty.call(state, 'back')) {
    return Boolean(state.back)
  }
  return window.history.length > 1
}

/** 返回上一页；没有历史时跳到兜底路由 */
export function navigateBack(router: Router, fallback = '/english'): void {
  if (canNavigateBack()) {
    router.back()
  } else {
    void router.replace(fallback)
  }
}
