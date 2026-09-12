import { fetchMe, loginWithWxCode, wxLoginCode } from './api/auth'
import { sendPresenceHeartbeat } from './api/presence'
import { clearSession, getAccessToken, getDeviceId, getRefreshToken, getStoredUser, setSession } from './utils/auth'

App<IAppOption>({
  globalData: {
    user: null,
    loggingIn: false,
  },

  onLaunch() {
    getDeviceId()
    const cached = getStoredUser()
    if (cached) this.globalData.user = cached
    void this.ensureLogin()
  },

  onShow() {
    if (getAccessToken()) {
      void sendPresenceHeartbeat().catch(() => undefined)
    }
  },

  async ensureLogin() {
    if (this.globalData.loggingIn) {
      return this.globalData.user
    }
    this.globalData.loggingIn = true
    try {
      const token = getAccessToken()
      if (token) {
        try {
          const me = await fetchMe()
          setSession(token, getRefreshToken(), me)
          this.globalData.user = me
          void sendPresenceHeartbeat().catch(() => undefined)
          return me
        } catch {
          clearSession()
          this.globalData.user = null
        }
      }
      const code = await wxLoginCode()
      const tokens = await loginWithWxCode(code)
      setSession(tokens.access, tokens.refresh, tokens.user)
      this.globalData.user = tokens.user
      void sendPresenceHeartbeat().catch(() => undefined)
      return tokens.user
    } catch (e) {
      console.warn('wechat login', e)
      return this.globalData.user
    } finally {
      this.globalData.loggingIn = false
    }
  },
})
