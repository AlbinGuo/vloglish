import { loginWithWxCode, wxLoginCode } from '../../api/auth'
import { continueReading, listArticles } from '../../api/articles'
import { getAiQuota } from '../../api/ai'
import { getLearningSummary } from '../../api/learning'
import { SITE_URL } from '../../config'
import { clearSession, displayName, getStoredUser, setSession, type AuthUser } from '../../utils/auth'

Page({
  data: {
    loggedIn: false,
    name: '未登录',
    initial: '?',
    isMember: false,
    memberLabel: '登录后同步学习进度',
    loading: false,
    readQuota: '',
    aiQuota: '',
    vocabCount: 0,
    continueTitle: '',
    continueId: '',
    wechatOnly: false,
    wxBound: false,
    emailLabel: '',
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
    try {
      const list = await listArticles(1, 1)
      const q = list.quota
      let readQuota = ''
      if (q) {
        if (q.remaining == null) readQuota = '读报不限量'
        else readQuota = `本月还可读 ${q.remaining} 篇`
      }
      this.setData({ readQuota })
    } catch {
      this.setData({ readQuota: '' })
    }

    const user = getApp<IAppOption>().globalData.user || getStoredUser()
    if (!user) {
      this.setData({ aiQuota: '', vocabCount: 0, continueTitle: '', continueId: '' })
      return
    }

    const [summary, ai, cont] = await Promise.allSettled([
      getLearningSummary(),
      getAiQuota(),
      continueReading(),
    ])

    let aiQuota = ''
    if (ai.status === 'fulfilled') {
      aiQuota = ai.value.remaining == null ? 'AI 不限量' : `AI 今日剩 ${ai.value.remaining} 次`
    }

    this.setData({
      vocabCount: summary.status === 'fulfilled' ? summary.value.vocabulary_count || 0 : 0,
      aiQuota,
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
    this.setData({ aiQuota: '', vocabCount: 0, continueTitle: '', continueId: '' })
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

  onSoon() {
    if (!this.requireLogin()) return
    wx.showToast({ title: '小程序下一期开放', icon: 'none' })
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

  onContact() {
    wx.setClipboardData({
      data: SITE_URL,
      success: () => wx.showToast({ title: '已复制网站地址', icon: 'none' }),
    })
  },

  onLegal(e: WechatMiniprogram.TouchEvent) {
    const type = e.currentTarget.dataset.type as string
    wx.navigateTo({ url: `/pages/legal/legal?type=${type}` })
  },
})
