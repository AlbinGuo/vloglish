Page({
  data: {
    heading: '',
    paragraphs: [] as string[],
  },

  onLoad(query: Record<string, string | undefined>) {
    const type = query.type === 'privacy' ? 'privacy' : 'terms'
    if (type === 'privacy') {
      wx.setNavigationBarTitle({ title: '隐私政策' })
      this.setData({
        heading: '隐私政策',
        paragraphs: [
          '本小程序仅用于账号识别、会员开通与服务维护，不会出售给第三方。支付通过微信或网站支付通道处理，我们不保存完整支付密码。',
          '你可随时退出登录。',
          '继续使用即表示你知悉本政策。政策更新后会在本页公布。',
        ],
      })
      return
    }
    wx.setNavigationBarTitle({ title: '用户协议' })
    this.setData({
      heading: '用户协议',
      paragraphs: [
        '欢迎使用 Vloglish。',
        '请合理使用服务，勿利用本产品从事违法或侵权活动。',
        '会员权益以开通时页面说明为准。激活码仅限本人账号使用，不可转让倒卖。',
        '我们可能因维护或不可抗力暂停服务。如有争议，应友好协商；协商不成的，适用中华人民共和国法律。',
      ],
    })
  },
})
