import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { adminFetchMe, adminLogin, type AdminUser } from '@/api/admin'
import {
  clearAdminTokens,
  getAdminAccessToken,
  getAdminRefreshToken,
  setAdminTokens,
} from '@/api/adminTokens'

export const useAdminAuthStore = defineStore('adminAuth', () => {
  const accessToken = ref<string | null>(getAdminAccessToken())
  const user = ref<AdminUser | null>(null)
  const ready = ref(false)

  const isLoggedIn = computed(() => Boolean(accessToken.value && user.value?.is_staff))

  async function login(email: string, password: string) {
    const data = await adminLogin(email, password)
    accessToken.value = data.access
    setAdminTokens(data.access, data.refresh)
    user.value = data.user
    return data.user
  }

  async function fetchMe() {
    if (!accessToken.value) {
      user.value = null
      return null
    }
    const me = await adminFetchMe()
    user.value = me
    return me
  }

  async function hydrate() {
    try {
      // access 过期时 adminApi 会自动用 refresh 续期；勿在 /me 失败时直接清会话
      if (accessToken.value || getAdminRefreshToken()) {
        if (!accessToken.value) {
          // 仅有 refresh 时先占位，真正 token 由拦截器写入 localStorage
          accessToken.value = 'pending'
        }
        const me = await fetchMe()
        accessToken.value = getAdminAccessToken()
        if (!me?.is_staff) logout()
      }
    } catch {
      logout()
    } finally {
      ready.value = true
    }
  }

  /** 登录页：跳过远端校验，清理残留 token，避免过期 token 触发 /me、/refresh 报错 */
  function resetForGuest() {
    logout()
    ready.value = true
  }

  function logout() {
    accessToken.value = null
    user.value = null
    clearAdminTokens()
  }

  return { accessToken, user, ready, isLoggedIn, login, fetchMe, hydrate, resetForGuest, logout }
})
