<script setup lang="ts">
import ReadingSegmentDesktopCell from '@/components/reading/ReadingSegmentDesktopCell.vue'
import ReadingBilingualDivider from '@/components/reading/ReadingBilingualDivider.vue'
import ReadingSegmentVocabSection from '@/components/reading/ReadingSegmentVocabSection.vue'
import type { ArticleSegment } from '@/api/articles'

defineProps<{
  segment: ArticleSegment
  articleId: string
  active?: boolean
}>()

defineEmits<{ click: [event: MouseEvent]; activate: [] }>()
</script>

<template>
  <div
    class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 transition-colors cursor-pointer overflow-hidden hover:border-black/10 dark:hover:border-white/15"
    :data-reading-segment="segment.index"
    :data-reading-segment-id="segment.id"
    :data-reading-context="segment.english"
    @click="$emit('activate')"
  >
    <div class="grid grid-cols-[minmax(0,1fr)_auto_minmax(0,1fr)] items-stretch">
      <ReadingSegmentDesktopCell
        embedded
        :segment="segment"
        side="english"
        :active="active"
        @click="$emit('click', $event)"
      />
      <ReadingBilingualDivider orientation="vertical" />
      <ReadingSegmentDesktopCell embedded :segment="segment" side="chinese" :active="active" />
    </div>
    <ReadingSegmentVocabSection :segment="segment" :article-id="articleId" variant="dual" />
  </div>
</template>
