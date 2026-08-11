import type { InjectionKey, Ref } from 'vue'
import { computed, ref, watch, type ComputedRef } from 'vue'
import { getArticleVocabulary, removeVocabulary, saveVocabulary, type ArticleVocabularyItem } from '@/api/learning'
import { getCachedEntryById, fetchEntryById } from '@/composables/useWordLookupCache'
import type { EntryDetail } from '@/types'
import { firstChineseDefinition, primaryIpa } from '@/utils/entryDisplay'
import { asExamTagList } from '@/utils/examTags'

export interface ArticleVocabToggleMeta {
  segmentId?: number
  tokenType?: 1 | 2
}

export interface ArticleVocabularyContext {
  items: ComputedRef<ArticleVocabularyItem[]>
  loading: Ref<boolean>
  isSaved: (entryId: number) => boolean
  toggle: (entry: EntryDetail, meta?: ArticleVocabToggleMeta) => Promise<boolean>
  remove: (entryId: number) => Promise<void>
  syncSavedMarks: () => void
  reload: () => Promise<void>
}

/** Symbol.for：避免 HMR 后 Symbol 身份变化导致 inject 拿不到 provide */
export const ARTICLE_VOCABULARY_KEY: InjectionKey<ArticleVocabularyContext> =
  Symbol.for('vloglish.article-vocabulary')

function wordKey(word: string) {
  return word.trim().replace(/\s+/g, ' ').toLowerCase()
}

function pickExamTags(entry: EntryDetail | null, row: ArticleVocabularyItem): string[] {
  const fromEntry = asExamTagList(entry?.exam_tags)
  const fromRow = asExamTagList(row.exam_tags)
  if (fromEntry.length) return fromEntry
  if (fromRow.length) return fromRow
  return []
}

async function resolveEntryForMerge(entry: EntryDetail): Promise<EntryDetail> {
  let merged: EntryDetail = getCachedEntryById(entry.id) ?? entry
  if (asExamTagList(merged.exam_tags).length) return merged
  const detail = await fetchEntryById(entry.id)
  if (!detail) return merged
  return {
    ...merged,
    ...detail,
    exam_tags: asExamTagList(detail.exam_tags).length ? detail.exam_tags : merged.exam_tags,
    favorite: entry.favorite,
  }
}

function mergeVocabItem(row: ArticleVocabularyItem, entry: EntryDetail | null): ArticleVocabularyItem {
  return {
    ...row,
    exam_tags: pickExamTags(entry, row),
    ipa: row.ipa || (entry ? primaryIpa(entry) : ''),
    definition_cn: row.definition_cn || (entry ? firstChineseDefinition(entry) : ''),
  }
}

async function enrichVocabRow(row: ArticleVocabularyItem): Promise<ArticleVocabularyItem> {
  const cached = getCachedEntryById(row.entry_id)
  if (cached && asExamTagList(cached.exam_tags).length && row.ipa && row.definition_cn) {
    return mergeVocabItem(row, cached)
  }
  if (asExamTagList(row.exam_tags).length && row.ipa && row.definition_cn) return row
  const entry = cached ?? (await fetchEntryById(row.entry_id))
  return mergeVocabItem(row, entry)
}

export function useArticleVocabulary(
  articleId: Ref<string>,
  options: { enabled: Ref<boolean> },
): ArticleVocabularyContext {
  const itemsMap = ref(new Map<number, ArticleVocabularyItem>())
  const loading = ref(false)

  const items = computed(() =>
    Array.from(itemsMap.value.values()).sort(
      (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime(),
    ),
  )

  const savedWordKeys = computed(() => new Set(items.value.map((item) => wordKey(item.word))))

  function isSaved(entryId: number) {
    return itemsMap.value.has(entryId)
  }

  function syncSavedMarks() {
    const root = document.querySelector('.reading-page')
    if (!root) return
    const keys = savedWordKeys.value
    root.querySelectorAll('.subtitle-english span.highlight').forEach((node) => {
      const span = node as HTMLElement
      const key = wordKey(span.textContent ?? '')
      if (keys.has(key)) span.classList.add('reading-vocab-saved')
      else span.classList.remove('reading-vocab-saved')
    })
  }

  async function reload() {
    if (!options.enabled.value || !articleId.value) {
      itemsMap.value = new Map()
      syncSavedMarks()
      return
    }
    loading.value = true
    try {
      const rows = await getArticleVocabulary(articleId.value)
      const enriched = await Promise.all(rows.map(enrichVocabRow))
      itemsMap.value = new Map(enriched.map((row) => [row.entry_id, row]))
    } catch {
      itemsMap.value = new Map()
    } finally {
      loading.value = false
      syncSavedMarks()
    }
  }

  async function toggle(entry: EntryDetail, meta: ArticleVocabToggleMeta = {}): Promise<boolean> {
    if (!options.enabled.value) return false

    if (isSaved(entry.id)) {
      await removeVocabulary(entry.id)
      const next = new Map(itemsMap.value)
      next.delete(entry.id)
      itemsMap.value = next
      syncSavedMarks()
      return false
    }

    try {
      const row = await saveVocabulary({
        entry_id: entry.id,
        word: entry.headword,
        token_type: meta.tokenType ?? (entry.category === '短语' ? 2 : 1),
        article_ref: articleId.value,
        segment_id: meta.segmentId,
        source_type: 'article',
      })

      // 先用当前词条立刻回写侧栏，再后台补全标签/音标（不阻塞「已加入」提示）
      const next = new Map(itemsMap.value)
      next.set(entry.id, mergeVocabItem(row, entry))
      itemsMap.value = next
      syncSavedMarks()

      void resolveEntryForMerge(entry).then((mergeEntry) => {
        const cur = itemsMap.value.get(entry.id)
        if (!cur) return
        const patched = new Map(itemsMap.value)
        patched.set(entry.id, mergeVocabItem(cur, mergeEntry))
        itemsMap.value = patched
      })
      return true
    } catch {
      await reload()
      throw new Error('生词本保存失败')
    }
  }

  async function remove(entryId: number) {
    if (!isSaved(entryId)) return
    await removeVocabulary(entryId)
    const next = new Map(itemsMap.value)
    next.delete(entryId)
    itemsMap.value = next
    syncSavedMarks()
  }

  watch([articleId, options.enabled], () => {
    reload()
  }, { immediate: true })

  return {
    items,
    loading,
    isSaved,
    toggle,
    remove,
    syncSavedMarks,
    reload,
  }
}
