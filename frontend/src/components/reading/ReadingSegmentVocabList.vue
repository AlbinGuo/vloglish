<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import type { ArticleSegment } from '@/api/articles'
import { fetchWordLookup } from '@/composables/useWordLookupCache'
import { extractHighlightTokens } from '@/utils/readingHighlights'
import { firstChineseDefinition, primaryIpa } from '@/utils/entryDisplay'

const props = withDefaults(
  defineProps<{
    segment: ArticleSegment
    articleId: string
    variant?: 'card' | 'dual'
    expanded?: boolean
  }>(),
  { variant: 'card', expanded: true },
)

interface VocabRow {
  word: string
  ipa: string
  meaning: string
  loading: boolean
}

const tokens = computed(() => extractHighlightTokens(props.segment.english_html || ''))
const rows = ref<VocabRow[]>([])

watch(
  () => [props.expanded, props.segment.id, props.segment.english_html, props.segment.english] as const,
  async ([expanded]) => {
    if (!expanded) {
      rows.value = []
      return
    }

    const list = tokens.value
    if (list.length === 0) {
      rows.value = []
      return
    }

    rows.value = list.map((token) => ({
      word: token.word,
      ipa: '',
      meaning: '',
      loading: true,
    }))

    await Promise.all(
      list.map(async (token, index) => {
        const entry = await fetchWordLookup(token.word, token.type, props.segment.english, {
          article_id: props.articleId,
          segment_id: props.segment.id,
        })

        if (rows.value[index]?.word !== token.word) return

        rows.value[index] = {
          word: token.word,
          ipa: entry ? primaryIpa(entry) : '',
          meaning: entry ? firstChineseDefinition(entry) || '暂无释义' : '暂无释义',
          loading: false,
        }
      }),
    )
  },
  { immediate: true },
)

const rootClass = computed(() => {
  if (props.variant === 'dual') {
    return 'px-4 lg:px-5 pb-4 pt-1'
  }
  return 'mx-4 mb-4 rounded-lg border border-line-soft bg-neutral-50/80 dark:bg-neutral-800/40 px-3 py-2.5'
})
</script>

<template>
  <div v-if="tokens.length > 0" :class="rootClass">
    <p class="text-xs font-medium text-neutral-500 dark:text-neutral-400 mb-2">本段重点词汇</p>
    <ul class="space-y-1.5">
      <li
        v-for="row in rows"
        :key="row.word"
        class="flex flex-wrap items-baseline gap-x-2 gap-y-0.5 text-sm leading-snug"
      >
        <span class="font-medium text-ink">{{ row.word }}</span>
        <template v-if="row.loading">
          <span class="text-xs text-neutral-400 animate-pulse">加载中…</span>
        </template>
        <template v-else>
          <span v-if="row.ipa" class="text-xs text-neutral-500 dark:text-neutral-400 font-mono">{{ row.ipa }}</span>
          <span class="text-ink-soft">{{ row.meaning }}</span>
        </template>
      </li>
    </ul>
  </div>
</template>
