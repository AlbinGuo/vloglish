import {
  displaySource,
  getArticle,
  updateArticleProgress,
  type ArticleSegment,
} from '../../api/articles'
import { ApiError } from '../../utils/request'
import { resolveCoverUrl } from '../../utils/mediaUrl'
import { getStoredUser } from '../../utils/auth'

type SegView = ArticleSegment & {
  no: string
  active: boolean
}

function padNo(n: number): string {
  return String(n + 1).padStart(2, '0')
}

function plainText(text: string, html: string): string {
  const t = (text || '').trim()
  if (t) return t
  return (html || '').replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim()
}

Page({
  data: {
    loading: true,
    error: '',
    limited: false,
    articleId: '',
    title: '',
    coverHttps: '',
    topic: '',
    source: '',
    meta: '',
    showZh: true,
    currentIndex: 0,
    progressLabel: '',
    segments: [] as SegView[],
  },

  onLoad(query: Record<string, string | undefined>) {
    const id = (query.id || '').trim()
    this.setData({ articleId: id })
    void this.load()
  },

  onUnload() {
    this.reportProgress()
  },

  onHide() {
    this.reportProgress()
  },

  async load() {
    const id = this.data.articleId
    if (!id) {
      this.setData({ loading: false, error: '文章不存在' })
      return
    }
    this.setData({ loading: true, error: '', limited: false })
    try {
      const art = await getArticle(id)
      const start = art.progress?.last_segment_index || 0
      const segs = (art.segments || []).map((s) => ({
        ...s,
        english: plainText(s.english, s.english_html),
        no: padNo(s.index),
        active: s.index === start,
      }))
      const source = displaySource(art.source)
      const bits = [
        art.word_count ? `${art.word_count} 词` : '',
        art.segment_count ? `${art.segment_count} 段` : '',
      ].filter(Boolean)
      wx.setNavigationBarTitle({ title: art.title.slice(0, 16) })
      this.setData({
        loading: false,
        title: art.title,
        coverHttps: resolveCoverUrl(art.cover),
        topic: art.topic || '',
        source,
        meta: bits.join(' · '),
        currentIndex: start,
        progressLabel: art.progress
          ? art.progress.is_completed
            ? '已读完'
            : `读到 ${Math.round(art.progress.completion_percent || 0)}%`
          : '',
        segments: segs,
      })
    } catch (e) {
      const limited = e instanceof ApiError && e.status === 403
      this.setData({
        loading: false,
        limited,
        error: e instanceof Error ? e.message : '加载失败',
      })
    }
  },

  reportProgress() {
    const { articleId, currentIndex } = this.data
    if (!articleId || !getStoredUser()) return
    void updateArticleProgress(articleId, currentIndex).catch(() => undefined)
  },

  onTapSeg(e: WechatMiniprogram.TouchEvent) {
    const index = Number(e.currentTarget.dataset.index)
    if (!Number.isFinite(index)) return
    const segments = this.data.segments.map((s) => ({
      ...s,
      active: s.index === index,
    }))
    this.setData({ currentIndex: index, segments })
  },

  onToggleZh() {
    this.setData({ showZh: !this.data.showZh })
  },

  onCoverError() {
    this.setData({ coverHttps: '' })
  },

  onOpenMember() {
    wx.navigateTo({ url: '/pages/membership/membership' })
  },
})
