import { listArticles, type ArticleListItem } from '../../api/articles'

function starsLabel(n: number): string {
  const s = Math.max(0, Math.min(5, n || 0))
  return '★'.repeat(s) + '☆'.repeat(5 - s)
}

Page({
  data: {
    loading: true,
    error: '',
    articles: [] as Array<ArticleListItem & { starsLabel: string }>,
    empty: false,
  },

  onShow() {
    if (!this.data.articles.length) void this.reload()
  },

  onPullDownRefresh() {
    void this.reload().finally(() => wx.stopPullDownRefresh())
  },

  async reload() {
    this.setData({ loading: true, error: '' })
    try {
      const out = await listArticles(1, 30)
      const articles = (out.results || []).map((a) => ({
        ...a,
        starsLabel: starsLabel(a.stars),
      }))
      this.setData({
        articles,
        empty: articles.length === 0,
        loading: false,
      })
    } catch (e) {
      this.setData({
        loading: false,
        error: e instanceof Error ? e.message : '加载失败',
      })
    }
  },

  onOpenArticle(e: WechatMiniprogram.TouchEvent) {
    const id = e.currentTarget.dataset.id as string
    if (!id) return
    wx.showToast({ title: '阅读页下一期开放', icon: 'none' })
  },
})
