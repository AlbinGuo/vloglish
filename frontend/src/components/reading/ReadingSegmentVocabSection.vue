<script setup lang="ts">
import { computed, ref } from 'vue'
import type { ArticleSegment } from '@/api/articles'
import ReadingSegmentVocabList from '@/components/reading/ReadingSegmentVocabList.vue'
import { extractHighlightTokens } from '@/utils/readingHighlights'
import AppIcon from '@/components/AppIcon.vue'

const props = withDefaults(
  defineProps<{
    segment: ArticleSegment
    articleId: string
    variant?: 'card' | 'dual'
  }>(),
  { variant: 'card' },
)

const expanded = ref(false)

const hasHighlights = computed(() => extractHighlightTokens(props.segment.english_html || '').length > 0)

function toggleExpanded() {
  expanded.value = !expanded.value
}
</script>

<template>
  <div v-if="hasHighlights" @click.stop>
    <template v-if="variant === 'dual'">
      <div class="grid grid-cols-[minmax(0,1fr)_auto_minmax(0,1fr)]">
        <div aria-hidden="true" />
        <div class="flex justify-center py-1.5">
          <button
            type="button"
            class="inline-flex items-center justify-center w-8 h-6 rounded-md text-neutral-400 hover:text-neutral-700 hover:bg-neutral-100 dark:hover:text-neutral-200 dark:hover:bg-neutral-800 transition-colors"
            :aria-label="expanded ? '收起重点词汇' : '展开重点词汇'"
            :aria-expanded="expanded"
            @click="toggleExpanded"
          >
            <AppIcon name="chevron-down" class="transition-transform duration-200" :size="18" />
          </button>
        </div>
        <div aria-hidden="true" />
      </div>
      <ReadingSegmentVocabList
        v-if="expanded"
        :segment="segment"
        :article-id="articleId"
        variant="dual"
        expanded
      />
    </template>

    <template v-else>
      <div class="flex justify-center py-2 border-t border-black/5 dark:border-white/10">
        <button
          type="button"
          class="inline-flex items-center justify-center w-8 h-6 rounded-md text-neutral-400 hover:text-neutral-700 hover:bg-neutral-100 dark:hover:text-neutral-200 dark:hover:bg-neutral-800 transition-colors"
          :aria-label="expanded ? '收起重点词汇' : '展开重点词汇'"
          :aria-expanded="expanded"
          @click="toggleExpanded"
        >
          <AppIcon name="chevron-down" class="transition-transform duration-200" :size="18" />
        </button>
      </div>
      <ReadingSegmentVocabList
        v-if="expanded"
        :segment="segment"
        :article-id="articleId"
        variant="card"
        expanded
      />
    </template>
  </div>
</template>
