import { wxLoginCode } from '../../api/auth'
import { claimPcPaySession, createWxPayOrder } from '../../api/wxpay'
import { getAccessToken, getRefreshToken, setSession } from '../../utils/auth'
import { assertPayReady, classifyPayError, requestVirtualPayment, waitPaid } from '../../utils/virtualPay'

let goHomeTimer: ReturnType<typeof setTimeout> | undefined

function goProfileSoon() {
  if (goHomeTimer) clearTimeout(goHomeTimer)
  goHomeTimer = setTimeout(() => {
    wx.switchTab({ url: '/pages/profile/profile' })
  }, 2800)
}

Page({
  data: {
    phase: 'loading' as 'loading' | 'success' | 'cancel' | 'fail',
    error: '',
    planName: '',
    amount: '',
    token: '',
  },

  async onLoad(query: Record<string, string | undefined>) {
    const token = decodeURIComponent((query.scene || query.token || '').trim())
    this.setData({ token })
    if (!token) {
      this.setData({ phase: 'fail', error: '缺少支付码，请回到网页重新扫码' })
      return
    }
    try {
      await getApp<IAppOption>().ensureLogin()
      const sess = await claimPcPaySession(token)
      setSession(sess.access, sess.refresh, sess.user)
      getApp<IAppOption>().globalData.user = sess.user
      if (sess.paid) {
        this.setData({
          phase: 'success',
          planName: sess.plan_name,
          amount: (sess.amount_cent / 100).toFixed(0),
        })
        goProfileSoon()
        return
      }
      if (sess.status === 'expired') {
        this.setData({ phase: 'fail', error: '支付码已过期，请在网页刷新后再扫' })
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
      this.setData({ phase: 'success' })
      goProfileSoon()
    } catch (e) {
      const kind = classifyPayError(e)
      this.setData({
        phase: kind === 'cancel' ? 'cancel' : 'fail',
        error: e instanceof Error ? e.message : '支付失败',
      })
    }
  },

  onUnload() {
    if (goHomeTimer) {
      clearTimeout(goHomeTimer)
      goHomeTimer = undefined
    }
  },

  onHome() {
    if (goHomeTimer) {
      clearTimeout(goHomeTimer)
      goHomeTimer = undefined
    }
    wx.switchTab({ url: '/pages/profile/profile' })
  },
})
