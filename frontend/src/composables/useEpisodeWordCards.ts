import { computed, ref, watch, type Ref } from 'vue'
import { getEpisodeWordCards } from '@/api/episodes'
import { cacheWordLookupEntry } from '@/composables/useWordLookupCache'
import { formatExamTags } from '@/utils/examTags'
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
  tags: WordCardTag[]
  ipa: string
  meaning: string
  loading: boolean
  entry: EntryDetail | null
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

export function useEpisodeWordCards(videoId: Ref<string>, enabled: Ref<boolean>) {
  const items = ref<WordCardItem[]>([])
  const loading = ref(false)
  const fromCache = ref(false)

  async function reload() {
    if (!enabled.value) return
    const id = videoId.value?.trim()
    if (!id) {
      items.value = []
      return
    }

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
          tags: buildTags(typeLabel, card.highlight, examTags),
          ipa: card.ipa || '',
          meaning: card.meaning || '暂无释义',
          loading: false,
          entry: card.entry ?? null,
        } satisfies WordCardItem
      })
    } catch {
      items.value = []
      fromCache.value = false
    } finally {
      loading.value = false
    }
  }

  watch(
    [videoId, enabled],
    () => {
      if (enabled.value) void reload()
    },
    { immediate: true },
  )

  const count = computed(() => items.value.length)

  return { items, loading, count, fromCache, reload }
}
