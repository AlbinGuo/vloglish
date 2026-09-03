import { getVocabulary, removeVocabulary, type VocabularyItem } from '../../api/learning'

type Row = VocabularyItem & { meaning: string; source: string }

Page({
  data: {
    loading: true,
    error: '',
    empty: false,
    items: [] as Row[],
  },

  onShow() {
    void this.reload()
  },

  async reload() {
    this.setData({ loading: true, error: '' })
    try {
      const rows = await getVocabulary()
      const items = (rows || []).map((r) => ({
        ...r,
        meaning: (r.definition_cn || '').trim() || (r.ipa ? `/${r.ipa}/` : '暂无释义'),
        source: (r.source_episode_title || '').trim(),
      }))
      this.setData({ items, empty: items.length === 0, loading: false })
    } catch (e) {
      this.setData({
        loading: false,
        error: e instanceof Error ? e.message : '加载失败',
      })
    }
  },

  onRemove(e: WechatMiniprogram.TouchEvent) {
    const entryId = Number(e.currentTarget.dataset.id)
    const word = String(e.currentTarget.dataset.word || '')
    if (!entryId) return
    wx.showModal({
      title: '移出生词本',
      content: word ? `移除「${word}」？` : '确认移除？',
      confirmColor: '#b45309',
      success: async (res) => {
        if (!res.confirm) return
        try {
          await removeVocabulary(entryId)
          this.setData({
            items: this.data.items.filter((i) => i.entry_id !== entryId),
          })
          this.setData({ empty: this.data.items.length === 0 })
        } catch (err) {
          wx.showToast({
            title: err instanceof Error ? err.message : '删除失败',
            icon: 'none',
          })
        }
      },
    })
  },
})
