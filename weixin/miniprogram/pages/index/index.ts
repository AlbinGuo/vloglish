import { SITE_URL } from '../../config'

Page({
  data: {
    siteUrl: `${SITE_URL.replace(/\/$/, '')}/`,
    plans: [
      { name: '季度', price: '29', note: '3 个月' },
      { name: '年度', price: '59', note: '更划算', hot: true },
      { name: '永久', price: '99', note: '一次买断' },
    ],
  },

  onOpenMember() {
    wx.navigateTo({ url: '/pages/membership/membership' })
  },
})
