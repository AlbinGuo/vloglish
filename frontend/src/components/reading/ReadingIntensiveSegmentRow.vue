<script setup lang="ts">
import IntensiveReadingBlock from '@/components/intensive/IntensiveReadingBlock.vue'
import ReadingSegmentPlayButton from '@/components/reading/ReadingSegmentPlayButton.vue'
import { preprocessSubtitleHtml } from '@/utils/subtitleHtml'
import type { ArticleSegment } from '@/api/articles'
import { computed } from 'vue'

const props = defineProps<{
  segment: ArticleSegment
  articleId: string
  active?: boolean
  emphasizeWord?: string
}>()

defineEmits<{ click: [event: MouseEvent]; activate: [] }>()

const englishHtml = computed(() =>
  preprocessSubtitleHtml(props.segment.english_html || props.segment.english),
)
</script>

<template>
  <div
    class="intensive-segment-card rounded-xl border transition-colors cursor-pointer overflow-hidden"
    :class="
      active
        ? 'border-red-300/80 dark:border-red-700/50 ring-1 ring-red-200/60 dark:ring-red-900/30 bg-white dark:bg-neutral-900'
        : 'border-red-100/80 dark:border-red-950/40 bg-white dark:bg-neutral-900 hover:border-red-200 dark:hover:border-red-900/60'
    "
    :data-reading-segment-id="segment.id"
    :data-reading-context="segment.english"
    @click="$emit('activate')"
  >
    <div class="p-4 min-w-0 flex gap-2 items-start">
      <ReadingSegmentPlayButton :segment-index="segment.index" :has-audio="Boolean(segment.audio_url)" />
      <IntensiveReadingBlock
        class="min-w-0 flex-1"
        :english-html="englishHtml"
        :english="segment.english"
        :chinese="segment.chinese"
        :active="active"
        :emphasize-word="emphasizeWord"
        :lookup-meta="{ article_id: articleId, segment_id: segment.id }"
        @click="$emit('click', $event)"
      />
    </div>
  </div>
</template>
