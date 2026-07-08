import { computed, ref, watch, type Ref } from 'vue'
import { fetchWordLookup, type WordLookupMeta } from '@/composables/useWordLookupCache'
import { extractHighlightTokens } from '@/utils/readingHighlights'
import { firstChineseDefinition, primaryIpa } from '@/utils/entryDisplay'

export interface CoreVocabSource {
  id: string | number
  englishHtml: string
  context: string
  meta?: WordLookupMeta
}

export interface CoreVocabItem {
  word: string
  ipa: string
  meaning: string
  loading: boolean
}

function collectTokens(sources: CoreVocabSource[]) {
  const seen = new Set<string>()
  const tokens: { word: string; type: 1 | 2; context: string; meta?: WordLookupMeta }[] = []

  for (const source of sources) {
    for (const token of extractHighlightTokens(source.englishHtml)) {
      const key = token.word.toLowerCase()
      if (seen.has(key)) continue
      seen.add(key)
      tokens.push({
        word: token.word,
        type: token.type,
        context: source.context,
        meta: source.meta,
      })
    }
  }

  return tokens
}

export function useCoreVocabulary(sources: Ref<CoreVocabSource[]>) {
  const items = ref<CoreVocabItem[]>([])
  const loading = ref(false)

  async function reload() {
    const tokens = collectTokens(sources.value)
    if (tokens.length === 0) {
      items.value = []
      loading.value = false
      return
    }

    loading.value = true
    items.value = tokens.map((token) => ({
      word: token.word,
      ipa: '',
      meaning: '',
      loading: true,
    }))

    await Promise.all(
      tokens.map(async (token, index) => {
        const entry = await fetchWordLookup(token.word, token.type, token.context, token.meta ?? {})
        if (items.value[index]?.word !== token.word) return
        items.value[index] = {
          word: token.word,
          ipa: entry ? primaryIpa(entry) : '',
          meaning: entry ? firstChineseDefinition(entry) || '暂无释义' : '暂无释义',
          loading: false,
        }
      }),
    )

    loading.value = false
  }

  watch(sources, reload, { deep: true, immediate: true })

  const count = computed(() => items.value.length)
  const loadedCount = computed(() => items.value.filter((item) => !item.loading).length)

  return {
    items,
    loading,
    count,
    loadedCount,
    reload,
  }
}
