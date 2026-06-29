import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { adminFetchMe, adminLogin, type AdminUser } from '@/api/admin'
import { clearAdminTokens, getAdminAccessToken, setAdminTokens } from '@/api/adminTokens'

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
      if (accessToken.value) await fetchMe()
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
