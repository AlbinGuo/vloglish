import { loginWithWxCode, wxLoginCode } from '../../api/auth'
import { continueReading } from '../../api/articles'
import { getLearningSummary } from '../../api/learning'
import { clearSession, displayName, getStoredUser, setSession, type AuthUser } from '../../utils/auth'

Page({
  data: {
    loggedIn: false,
    name: '未登录',
    initial: '?',
    isMember: false,
    memberLabel: '登录后同步学习进度',
    loading: false,
    vocabCount: 0,
    continueTitle: '',
    continueId: '',
    wechatOnly: false,
    wxBound: false,
    emailLabel: '',
    showBindAccount: false,
  },

  onShow() {
    this.syncUser(getApp<IAppOption>().globalData.user || getStoredUser())
    void this.refreshExtras()
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
        : '登录后同步学习进度',
      wechatOnly: Boolean(user?.wechat_only),
      wxBound: Boolean(user?.wx_bound),
      emailLabel: user && !user.wechat_only ? user.email : '',
    })
  },

  async refreshExtras() {
    const user = getApp<IAppOption>().globalData.user || getStoredUser()
    if (!user) {
      this.setData({ vocabCount: 0, continueTitle: '', continueId: '' })
      return
    }

    const [summary, cont] = await Promise.allSettled([
      getLearningSummary(),
      continueReading(),
    ])

    this.setData({
      vocabCount: summary.status === 'fulfilled' ? summary.value.vocabulary_count || 0 : 0,
      continueTitle:
        cont.status === 'fulfilled' && cont.value.results?.[0]
          ? cont.value.results[0].title
          : '',
      continueId:
        cont.status === 'fulfilled' && cont.value.results?.[0]
          ? cont.value.results[0].article_id
          : '',
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
      await this.refreshExtras()
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
    this.setData({ vocabCount: 0, continueTitle: '', continueId: '' })
    void this.refreshExtras()
    wx.showToast({ title: '已退出', icon: 'none' })
  },

  requireLogin(): boolean {
    if (this.data.loggedIn) return true
    wx.showToast({ title: '请先登录', icon: 'none' })
    return false
  },

  onContinue() {
    if (!this.requireLogin()) return
    if (!this.data.continueTitle) {
      wx.showToast({ title: '还没有阅读进度', icon: 'none' })
      return
    }
    if (!this.data.continueId) {
      wx.showToast({ title: '还没有阅读进度', icon: 'none' })
      return
    }
    wx.navigateTo({
      url: `/pages/article/article?id=${encodeURIComponent(this.data.continueId)}`,
    })
  },

  onVocab() {
    if (!this.requireLogin()) return
    wx.navigateTo({ url: '/pages/vocabulary/vocabulary' })
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
