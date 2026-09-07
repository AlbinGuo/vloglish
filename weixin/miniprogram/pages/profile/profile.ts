import { loginWithWxCode, wxLoginCode } from '../../api/auth'
import { clearSession, displayName, getStoredUser, setSession, type AuthUser } from '../../utils/auth'

Page({
  data: {
    loggedIn: false,
    name: '未登录',
    initial: '?',
    isMember: false,
    memberLabel: '请先登录',
    loading: false,
    wechatOnly: false,
    wxBound: false,
    emailLabel: '',
    showBindAccount: false,
  },

  onShow() {
    this.syncUser(getApp<IAppOption>().globalData.user || getStoredUser())
  },

  syncUser(user: AuthUser | null) {
    const name = displayName(user)
    this.setData({
      loggedIn: Boolean(user),
      name,
      initial: user ? name.slice(0, 1) : '?',
      isMember: Boolean(user?.is_member),
      memberLabel: user
        ? user.is_member
          ? user.member_until
            ? `会员至 ${user.member_until}`
            : '会员已开通 · 永久'
          : '普通学员'
        : '请先登录',
      wechatOnly: Boolean(user?.wechat_only),
      wxBound: Boolean(user?.wx_bound),
      emailLabel: user && !user.wechat_only ? user.email : '',
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

  requireLogin(): boolean {
    if (this.data.loggedIn) return true
    wx.showToast({ title: '请先登录', icon: 'none' })
    return false
  },

  onBindEmail() {
    if (!this.requireLogin()) return
    wx.navigateTo({ url: '/pages/bind-email/bind-email' })
  },

  onMembership() {
    wx.navigateTo({ url: '/pages/membership/membership' })
  },

  onFeedback() {
    if (!this.requireLogin()) return
    wx.navigateTo({ url: '/pages/feedback/feedback' })
  },

  onLegal(e: WechatMiniprogram.TouchEvent) {
    const type = e.currentTarget.dataset.type as string
    wx.navigateTo({ url: `/pages/legal/legal?type=${type}` })
  },
})
