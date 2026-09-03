import { displaySource, listArticles, type ArticleListItem } from '../../api/articles'
import { resolveCoverUrl } from '../../utils/mediaUrl'

type Card = ArticleListItem & {
  starsLabel: string
  coverHttps: string
  metaLine: string
  progressLabel: string
  done: boolean
  countLabel: string
}

function starsLabel(n: number): string {
  const s = Math.max(0, Math.min(5, n || 0))
  return '★'.repeat(s) + '☆'.repeat(5 - s)
}

function mapCard(a: ArticleListItem): Card {
  const words = a.word_count ? `${a.word_count} 词` : ''
  const segs = a.segment_count ? `${a.segment_count} 段` : ''
  const summary = (a.summary || '').trim()
  return {
    ...a,
    source: displaySource(a.source),
    starsLabel: starsLabel(a.stars),
    coverHttps: resolveCoverUrl(a.cover),
    metaLine: summary || [words, segs].filter(Boolean).join(' · '),
    progressLabel: a.progress
      ? a.progress.is_completed
        ? '已读完'
        : `读到 ${Math.round(a.progress.completion_percent || 0)}%`
      : '',
    done: Boolean(a.progress?.is_completed),
    countLabel: [words, segs].filter(Boolean).join(' · '),
  }
}

Page({
  data: {
    loading: true,
    error: '',
    articles: [] as Card[],
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
      const articles = (out.results || []).map(mapCard)
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

  onCoverError(e: WechatMiniprogram.TouchEvent) {
    const id = e.currentTarget.dataset.id as string
    if (!id) return
    const articles = this.data.articles.map((a) =>
      a.article_id === id ? { ...a, coverHttps: '' } : a,
    )
    this.setData({ articles })
  },

  onOpenArticle(e: WechatMiniprogram.TouchEvent) {
    const id = e.currentTarget.dataset.id as string
    if (!id) return
    const item = this.data.articles.find((a) => a.article_id === id)
    if (item && !item.accessible) {
      wx.navigateTo({ url: '/pages/membership/membership' })
      return
    }
    wx.navigateTo({ url: `/pages/article/article?id=${encodeURIComponent(id)}` })
  },
})
