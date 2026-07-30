<script setup lang="ts">
import ReadingSegmentDesktopCell from '@/components/reading/ReadingSegmentDesktopCell.vue'
import ReadingSegmentPlayButton from '@/components/reading/ReadingSegmentPlayButton.vue'
import ReadingBilingualDivider from '@/components/reading/ReadingBilingualDivider.vue'
import ReadingSegmentVocabSection from '@/components/reading/ReadingSegmentVocabSection.vue'
import type { ArticleSegment } from '@/api/articles'

defineProps<{
  segment: ArticleSegment
  articleId: string
  active?: boolean
  vocabLinkHtml?: string
}>()

defineEmits<{ click: [event: MouseEvent]; activate: [] }>()
</script>

<template>
  <div
    class="rounded-xl border transition-colors cursor-pointer overflow-hidden hover:border-black/10 dark:hover:border-white/15"
    :class="
      active
        ? 'border-amber-300/70 dark:border-amber-500/40 ring-1 ring-amber-200/60 dark:ring-amber-500/20 bg-white dark:bg-neutral-900'
        : 'border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900'
    "
    :data-reading-segment="segment.index"
    :data-reading-segment-id="segment.id"
    :data-reading-context="segment.english"
    @click="$emit('activate')"
  >
    <div class="grid grid-cols-[minmax(0,1fr)_auto_minmax(0,1fr)] items-stretch">
      <div class="min-w-0 p-4 lg:p-5 flex gap-2 items-start">
        <ReadingSegmentPlayButton :segment-index="segment.index" :has-audio="Boolean(segment.audio_url)" />
        <ReadingSegmentDesktopCell
          embedded
          :segment="segment"
          side="english"
          :active="active"
          :vocab-link-html="vocabLinkHtml"
          class="min-w-0 flex-1"
          @click="$emit('click', $event)"
        />
      </div>
      <ReadingBilingualDivider orientation="vertical" />
      <ReadingSegmentDesktopCell embedded :segment="segment" side="chinese" :active="active" />
    </div>
    <ReadingSegmentVocabSection :segment="segment" :article-id="articleId" variant="dual" />
  </div>
</template>
