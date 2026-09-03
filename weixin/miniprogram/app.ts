import { fetchMe, loginWithWxCode, wxLoginCode } from './api/auth'
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
      return tokens.user
    } catch (e) {
      console.warn('wechat login', e)
      return this.globalData.user
    } finally {
      this.globalData.loggingIn = false
    }
  },
})
