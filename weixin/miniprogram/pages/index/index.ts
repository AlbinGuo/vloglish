Page({
  data: {
    demos: [
      {
        en: 'The more you speak, the more natural it becomes.',
        zh: '说得越多，就会越自然。',
      },
      {
        en: 'Let me think about that for a second.',
        zh: '让我想一下。',
      },
      {
        en: 'That actually makes a lot of sense.',
        zh: '这其实很说得通。',
      },
      {
        en: 'I see what you mean.',
        zh: '我明白你的意思了。',
      },
      {
        en: "I'm not sure I follow. Could you say that again?",
        zh: '我没太跟上，你能再说一遍吗？',
      },
      {
        en: "That's a good point. I hadn't thought of it that way.",
        zh: '说得对，我之前没这么想过。',
      },
      {
        en: "Give me a minute. I'll get back to you.",
        zh: '给我一分钟，我稍后回复你。',
      },
      {
        en: "To be honest, I'm still working on it.",
        zh: '说实话，我还在做这件事。',
      },
    ],
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
