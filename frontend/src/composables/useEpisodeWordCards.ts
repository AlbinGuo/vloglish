import { computed, ref, watch, type Ref } from 'vue'
import { getEpisodeWordCards } from '@/api/episodes'
import { cacheWordLookupEntry } from '@/composables/useWordLookupCache'
import {
  EXAM_TAG_DISPLAY_ORDER,
  EXAM_TAG_LABELS,
  formatExamTags,
  primaryExamTag,
} from '@/utils/examTags'
import type { EntryDetail } from '@/types'

export interface WordCardTag {
  key: string
  label: string
  kind: 'type' | 'exam'
}

export interface WordCardItem {
  word: string
  type: 1 | 2
  context: string
  meta?: { video_id?: string; subtitle_id?: number }
  highlight: string | null
  typeLabel: string
  examTags: { key: string; label: string }[]
  /** 分组用主考试标签 */
  primaryExam: { key: string; label: string } | null
  tags: WordCardTag[]
  ipa: string
  meaning: string
  loading: boolean
  entry: EntryDetail | null
}

export interface WordCardExamGroup {
  key: string
  label: string
  count: number
  items: WordCardItem[]
}

/** @deprecated 保留类型兼容；词卡已改为服务端整集缓存 */
export interface WordCardSource {
  id: string | number
  englishHtml: string
  context: string
  meta?: { video_id?: string; subtitle_id?: number }
}

function buildTags(
  typeLabel: string,
  highlight: string | null,
  examTags: { key: string; label: string }[],
): WordCardTag[] {
  const tags: WordCardTag[] = [
    {
      key: `type-${highlight || typeLabel}`,
      label: typeLabel,
      kind: 'type',
    },
  ]
  for (const exam of examTags) {
    tags.push({ key: `exam-${exam.key}`, label: exam.label, kind: 'exam' })
  }
  return tags
}

function groupWordCards(items: WordCardItem[]): WordCardExamGroup[] {
  const bucket = new Map<string, WordCardItem[]>()
  for (const item of items) {
    const key = item.primaryExam?.key || 'OTHER'
    const list = bucket.get(key)
    if (list) list.push(item)
    else bucket.set(key, [item])
  }

  const groups: WordCardExamGroup[] = []
  for (const key of EXAM_TAG_DISPLAY_ORDER) {
    const list = bucket.get(key)
    if (!list?.length) continue
    groups.push({
      key,
      label: EXAM_TAG_LABELS[key] ?? key,
      count: list.length,
      items: list,
    })
    bucket.delete(key)
  }
  for (const [key, list] of bucket) {
    if (!list.length) continue
    groups.push({
      key,
      label: key === 'OTHER' ? '其他' : EXAM_TAG_LABELS[key] ?? key,
      count: list.length,
      items: list,
    })
  }
  return groups
}

export function useEpisodeWordCards(videoId: Ref<string>, enabled: Ref<boolean>) {
  const items = ref<WordCardItem[]>([])
  const loading = ref(false)
  const fromCache = ref(false)
  /** 已成功请求过的 videoId（含 0 条结果），同页切回词卡不重复打接口 */
  const loadedVideoId = ref('')

  async function reload(force = false) {
    const id = videoId.value?.trim()
    if (!id) {
      items.value = []
      loadedVideoId.value = ''
      return
    }
    if (!force && loadedVideoId.value === id) return

    loading.value = true
    try {
      const data = await getEpisodeWordCards(id)
      fromCache.value = data.from_cache
      items.value = (data.cards || []).map((card) => {
        const examTags = formatExamTags(card.exam_tags ?? card.entry?.exam_tags ?? [])
        const typeLabel = card.type_label || '单词'
        if (card.entry) {
          cacheWordLookupEntry(card.entry, card.word, card.type, card.context)
        }
        return {
          word: card.word,
          type: card.type,
          context: card.context,
          meta: {
            video_id: id,
            subtitle_id: card.subtitle_id ?? undefined,
          },
          highlight: card.highlight,
          typeLabel,
          examTags,
          primaryExam: primaryExamTag(examTags),
          tags: buildTags(typeLabel, card.highlight, examTags),
          ipa: card.ipa || '',
          meaning: card.meaning || '暂无释义',
          loading: false,
          entry: card.entry ?? null,
        } satisfies WordCardItem
      })
      loadedVideoId.value = id
    } catch {
      items.value = []
      fromCache.value = false
      loadedVideoId.value = ''
    } finally {
      loading.value = false
    }
  }

  watch(
    [videoId, enabled],
    () => {
      if (!enabled.value) return
      const vid = videoId.value?.trim()
      if (!vid) return
      if (loadedVideoId.value === vid) return
      void reload()
    },
    { immediate: true },
  )

  const count = computed(() => items.value.length)
  const groups = computed(() => groupWordCards(items.value))

  return { items, groups, loading, count, fromCache, reload }
}
