import { activateMembership, wxLoginCode } from '../../api/auth'
import { createWxPayOrder } from '../../api/wxpay'
import { getStoredUser, setSession, getAccessToken, getRefreshToken, type AuthUser } from '../../utils/auth'
import { assertPayReady, classifyPayError, requestVirtualPayment, waitPaid } from '../../utils/virtualPay'

type PlanId = 'quarter' | 'year' | 'forever'

type Plan = {
  id: PlanId
  name: string
  price: string
  period: string
  note: string
  recommended: boolean
  selected: boolean
}

const PLANS: Omit<Plan, 'selected'>[] = [
  {
    id: 'quarter',
    name: '季度会员',
    price: '29',
    period: '3 个月',
    note: '约 ¥9.7 / 月',
    recommended: false,
  },
  {
    id: 'year',
    name: '年度会员',
    price: '59',
    period: '12 个月',
    note: '约 ¥4.9 / 月 · 更划算',
    recommended: true,
  },
  {
    id: 'forever',
    name: '永久会员',
    price: '99',
    period: '一次买断',
    note: '不再续费',
    recommended: false,
  },
]

function withSelection(id: PlanId): Plan[] {
  return PLANS.map((p) => ({ ...p, selected: p.id === id }))
}

Page({
  data: {
    isMember: false,
    memberHint: '',
    selectedId: 'year' as PlanId,
    plans: withSelection('year'),
    code: '',
    submitting: false,
    paying: false,
    result: '' as '' | 'success' | 'pending' | 'cancel' | 'fail',
    resultMsg: '',
  },

  onShow() {
    this.syncMember(getApp<IAppOption>().globalData.user || getStoredUser())
  },

  syncMember(user: AuthUser | null) {
    let memberHint = ''
    if (user?.is_member) {
      memberHint = user.member_until ? `会员有效期至 ${user.member_until}` : '当前账号已是永久会员'
    }
    this.setData({
      isMember: Boolean(user?.is_member),
      memberHint,
    })
  },

  applyUser(user: AuthUser) {
    setSession(getAccessToken(), getRefreshToken(), user)
    getApp<IAppOption>().globalData.user = user
    this.syncMember(user)
  },

  onSelect(e: WechatMiniprogram.TouchEvent) {
    const id = e.currentTarget.dataset.id as PlanId
    if (!id) return
    this.setData({ selectedId: id, plans: withSelection(id) })
  },

  async onBuy() {
    const plan = this.data.plans.find((p) => p.selected)
    if (!plan || this.data.paying) return
    if (!getStoredUser() && !getApp<IAppOption>().globalData.user) {
      wx.showToast({ title: '请先登录', icon: 'none' })
      return
    }
    this.setData({ paying: true })
    try {
      assertPayReady()
      const code = await wxLoginCode()
      const pay = await createWxPayOrder(plan.id, code)
      await requestVirtualPayment(pay)
      const paid = await waitPaid(pay.out_trade_no)
      if (paid?.user) this.applyUser(paid.user)
      this.setData({
        paying: false,
        result: paid?.paid ? 'success' : 'pending',
        resultMsg: paid?.paid ? `${plan.name}已开通` : '支付已完成，权益开通中',
      })
    } catch (e) {
      const kind = classifyPayError(e)
      this.setData({
        paying: false,
        result: kind === 'cancel' ? 'cancel' : 'fail',
        resultMsg: e instanceof Error ? e.message : '支付失败',
      })
    }
  },

  onClearResult() {
    this.setData({ result: '', resultMsg: '' })
  },

  onBackMine() {
    wx.switchTab({ url: '/pages/profile/profile' })
  },

  onCode(e: WechatMiniprogram.Input) {
    this.setData({ code: e.detail.value })
  },

  async onActivate() {
    const code = this.data.code.trim()
    if (!code) {
      wx.showToast({ title: '请输入激活码', icon: 'none' })
      return
    }
    if (this.data.submitting) return
    this.setData({ submitting: true })
    try {
      const user = await activateMembership(code)
      this.applyUser(user)
      this.setData({
        code: '',
        result: 'success',
        resultMsg: '会员已开通',
      })
    } catch (e) {
      wx.showToast({
        title: e instanceof Error ? e.message : '激活失败',
        icon: 'none',
      })
    } finally {
      this.setData({ submitting: false })
    }
  },
})
