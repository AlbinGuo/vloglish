import { loginWithWxCode, wxLoginCode } from '../../api/auth'
import { clearSession, displayName, getStoredUser, setSession, type AuthUser } from '../../utils/auth'

Page({
  data: {
    loggedIn: false,
    name: '未登录',
    memberLabel: '',
    loading: false,
  },

  onShow() {
    this.syncUser(getApp<IAppOption>().globalData.user || getStoredUser())
  },

  syncUser(user: AuthUser | null) {
    this.setData({
      loggedIn: Boolean(user),
      name: displayName(user),
      memberLabel: user ? (user.is_member ? '会员已开通' : '普通学员') : '登录后同步学习进度',
    })
  },

  async onLogin() {
    if (this.data.loading) return
    this.setData({ loading: true })
    try {
      const code = await wxLoginCode()
      const tokens = await loginWithWxCode(code)
      setSession(tokens.access, tokens.refresh, tokens.user)
      getApp<IAppOption>().globalData.user = tokens.user
      this.syncUser(tokens.user)
      wx.showToast({ title: '已登录', icon: 'success' })
    } catch (e) {
      wx.showToast({
        title: e instanceof Error ? e.message : '登录失败',
        icon: 'none',
      })
    } finally {
      this.setData({ loading: false })
    }
  },

  onLogout() {
    clearSession()
    getApp<IAppOption>().globalData.user = null
    this.syncUser(null)
    wx.showToast({ title: '已退出', icon: 'none' })
  },
})
