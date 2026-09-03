import { confirmBindWechat } from '../../api/auth'
import { setSession } from '../../utils/auth'

Page({
  data: {
    token: '',
    busy: true,
    error: '',
    done: false,
  },

  async onLoad(query: Record<string, string | undefined>) {
    const token = (query.scene || query.token || '').trim()
    this.setData({ token })
    if (!token) {
      this.setData({ busy: false, error: '缺少绑定码，请回到网页重新扫码' })
      return
    }
    try {
      await getApp<IAppOption>().ensureLogin()
      const tokens = await confirmBindWechat(token)
      setSession(tokens.access, tokens.refresh, tokens.user)
      getApp<IAppOption>().globalData.user = tokens.user
      this.setData({ busy: false, done: true, error: '' })
    } catch (e) {
      this.setData({
        busy: false,
        error: e instanceof Error ? e.message : '绑定失败',
      })
    }
  },

  onHome() {
    wx.switchTab({ url: '/pages/profile/profile' })
  },
})
