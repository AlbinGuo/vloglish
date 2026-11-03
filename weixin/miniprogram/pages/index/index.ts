import { SITE_URL } from '../../config'

Page({
  data: {
    siteUrl: `${SITE_URL.replace(/\/$/, '')}/`,
    plans: [
      { name: '季度', price: '38', note: '3 个月' },
      { name: '年度', price: '78', note: '更划算' },
      { name: '永久', price: '128', note: '一次买断' },
    ],
  },

  onOpenMember() {
    wx.navigateTo({ url: '/pages/membership/membership' })
  },
})
