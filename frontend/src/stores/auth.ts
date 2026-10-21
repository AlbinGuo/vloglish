import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import {
  activateMembership as activateMembershipApi,
  appleLogin as appleLoginApi,
  deleteAccount as deleteAccountApi,
  fetchCurrentUser,
  setUserAvatar,
  login as loginApi,
  logout as logoutApi,
  refreshAuthToken,
  register as registerApi,
} from '@/api/auth'
import { clearTokens, getAccessToken, getRefreshToken, isRemoteLoginDetail, setRemoteLoginNotice, setTokens } from '@/api/tokens'
import type { User } from '@/types'

export const useAuthStore = defineStore('auth', () => {
  const accessToken = ref<string | null>(getAccessToken())
  const refreshToken = ref<string | null>(getRefreshToken())
  const user = ref<User | null>(null)
  const ready = ref(false)

  const isLoggedIn = computed(() => Boolean(accessToken.value && user.value))
  const isMember = computed(() => Boolean(user.value?.is_member))

  function setSession(access: string, refresh: string, nextUser: User) {
    accessToken.value = access
    refreshToken.value = refresh
    user.value = nextUser
    setTokens(access, refresh)
  }

  function clearSession() {
    accessToken.value = null
    refreshToken.value = null
    user.value = null
    clearTokens()
  }

  async function register(email: string, password: string, activationCode?: string) {
    const data = await registerApi(email, password, activationCode)
    setSession(data.access, data.refresh, data.user)
    return data.user
  }

  async function login(email: string, password: string) {
    const data = await loginApi(email, password)
    setSession(data.access, data.refresh, data.user)
    return data.user
  }

  async function loginWithApple(payload: {
    identity_token: string
    authorization_code?: string
    full_name?: string
  }) {
    const data = await appleLoginApi(payload)
    setSession(data.access, data.refresh, data.user)
    return data.user
  }

  async function refreshAccess() {
    const token = refreshToken.value
    if (!token) throw new Error('No refresh token')
    const data = await refreshAuthToken(token)
    setSession(data.access, data.refresh, data.user)
    return data.access
  }

  async function fetchMe() {
    if (!accessToken.value) {
      user.value = null
      return null
    }
    const me = await fetchCurrentUser()
    user.value = me
    return me
  }

  async function activateMembership(activationCode: string) {
    const me = await activateMembershipApi(activationCode)
    user.value = me
    return me
  }

  async function cycleAvatar() {
    const me = await setUserAvatar({ cycle: true })
    user.value = me
    return me
  }

  async function logout() {
    const token = refreshToken.value
    if (token) {
      try {
        await logoutApi(token)
      } catch {
        /* ignore */
      }
    }
    clearSession()
  }

  async function deleteAccount(password = '') {
    await deleteAccountApi({ password, confirmation: '注销' })
    clearSession()
  }

  async function hydrate() {
    try {
      if (accessToken.value) {
        await fetchMe()
      } else if (refreshToken.value) {
        await refreshAccess()
        await fetchMe()
      }
    } catch (e: unknown) {
      const detail = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
      if (isRemoteLoginDetail(detail)) {
        setRemoteLoginNotice()
      }
      clearSession()
    } finally {
      ready.value = true
    }
  }

  return {
    accessToken,
    refreshToken,
    user,
    ready,
    isLoggedIn,
    isMember,
    register,
    login,
    loginWithApple,
    refreshAccess,
    fetchMe,
    activateMembership,
    cycleAvatar,
    logout,
    deleteAccount,
    hydrate,
    clearSession,
  }
})
