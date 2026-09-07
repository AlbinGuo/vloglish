import { wxLoginCode } from '../../api/auth'
import { claimPcPaySession, createWxPayOrder } from '../../api/wxpay'
import { getAccessToken, getRefreshToken, setSession } from '../../utils/auth'
import { assertPayReady, requestVirtualPayment, waitPaid } from '../../utils/virtualPay'

Page({
  data: {
    busy: true,
    error: '',
    done: false,
    planName: '',
    amount: '',
    token: '',
  },

  async onLoad(query: Record<string, string | undefined>) {
    const token = decodeURIComponent((query.scene || query.token || '').trim())
    this.setData({ token })
    if (!token) {
      this.setData({ busy: false, error: '缺少支付码，请回到网页重新扫码' })
      return
    }
    try {
      await getApp<IAppOption>().ensureLogin()
      const sess = await claimPcPaySession(token)
      setSession(sess.access, sess.refresh, sess.user)
      getApp<IAppOption>().globalData.user = sess.user
      if (sess.paid) {
        this.setData({
          busy: false,
          done: true,
          planName: sess.plan_name,
          amount: (sess.amount_cent / 100).toFixed(0),
        })
        return
      }
      if (sess.status === 'expired') {
        this.setData({ busy: false, error: '支付码已过期，请在网页刷新后再扫' })
        return
      }
      this.setData({
        planName: sess.plan_name,
        amount: (sess.amount_cent / 100).toFixed(0),
      })
      assertPayReady()
      const code = await wxLoginCode()
      const pay = await createWxPayOrder(sess.plan, code, token)
      await requestVirtualPayment(pay)
      const paid = await waitPaid(pay.out_trade_no)
      if (paid?.user) {
        setSession(getAccessToken(), getRefreshToken(), paid.user)
        getApp<IAppOption>().globalData.user = paid.user
      }
      this.setData({ busy: false, done: true })
    } catch (e) {
      const msg = e instanceof Error ? e.message : '支付失败'
      this.setData({ busy: false, error: msg })
    }
  },

  onHome() {
    wx.switchTab({ url: '/pages/profile/profile' })
  },
})
