import { createFeedback } from '../../api/feedback'

Page({
  data: {
    title: '',
    body: '',
    submitting: false,
  },

  onTitle(e: WechatMiniprogram.Input) {
    this.setData({ title: e.detail.value })
  },

  onBody(e: WechatMiniprogram.Input) {
    this.setData({ body: e.detail.value })
  },

  async onSubmit() {
    const title = this.data.title.trim()
    const body = this.data.body.trim()
    if (!title) {
      wx.showToast({ title: '请填写标题', icon: 'none' })
      return
    }
    if (!body) {
      wx.showToast({ title: '请填写内容', icon: 'none' })
      return
    }
    if (this.data.submitting) return
    this.setData({ submitting: true })
    try {
      const out = await createFeedback(title, body)
      wx.showToast({ title: out.message || '已提交', icon: 'success' })
      setTimeout(() => wx.navigateBack(), 600)
    } catch (e) {
      wx.showToast({
        title: e instanceof Error ? e.message : '提交失败',
        icon: 'none',
      })
    } finally {
      this.setData({ submitting: false })
    }
  },
})
