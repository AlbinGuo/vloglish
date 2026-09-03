import { bindEmail } from '../../api/auth'
import { setSession } from '../../utils/auth'

Page({
  data: {
    email: '',
    password: '',
    submitting: false,
  },

  onEmail(e: WechatMiniprogram.Input) {
    this.setData({ email: e.detail.value })
  },

  onPassword(e: WechatMiniprogram.Input) {
    this.setData({ password: e.detail.value })
  },

  async onSubmit() {
    const email = this.data.email.trim()
    const password = this.data.password
    if (!email || !password) {
      wx.showToast({ title: '请填写邮箱和密码', icon: 'none' })
      return
    }
    if (this.data.submitting) return
    this.setData({ submitting: true })
    try {
      const tokens = await bindEmail(email, password)
      setSession(tokens.access, tokens.refresh, tokens.user)
      getApp<IAppOption>().globalData.user = tokens.user
      wx.showToast({ title: '已关联网页账号', icon: 'success' })
      setTimeout(() => wx.navigateBack(), 500)
    } catch (e) {
      wx.showToast({
        title: e instanceof Error ? e.message : '关联失败',
        icon: 'none',
      })
    } finally {
      this.setData({ submitting: false })
    }
  },
})
