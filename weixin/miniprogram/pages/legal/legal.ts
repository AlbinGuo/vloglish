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
          'Vloglish 小程序由运营方提供英语读报与学习服务。我们会收集微信登录所需的 openid，以及你主动产生的学习数据（阅读进度、生词、反馈内容）。',
          '这些信息用于账号识别、同步进度和改善产品，不会出售给第三方。支付若在后续开通，将通过微信或网站支付通道处理，我们不保存完整支付密码。',
          '你可随时退出登录。若需删除账号或导出数据，请通过「意见反馈」或网站 en.yunankexun.com 联系我们。',
          '继续使用即表示你知悉本政策。政策更新后会在本页公布。',
        ],
      })
      return
    }
    wx.setNavigationBarTitle({ title: '用户协议' })
    this.setData({
      heading: '用户协议',
      paragraphs: [
        '欢迎使用 Vloglish。本小程序提供英语读报及相关学习功能，部分内容需开通会员后使用。',
        '请合理使用服务，勿利用本产品从事违法或侵权活动。学习内容的版权归原作者或平台所有，仅供个人学习。',
        '会员权益以开通时页面说明为准。激活码仅限本人账号使用，不可转让倒卖。',
        '我们可能因维护或不可抗力暂停服务。如有争议，应友好协商；协商不成的，适用中华人民共和国法律。',
      ],
    })
  },
})
