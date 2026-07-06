<script setup lang="ts">
import SubtitleEnglish from '@/components/SubtitleEnglish.vue'
import ReadingSegmentPlayButton from '@/components/reading/ReadingSegmentPlayButton.vue'
import ReadingBilingualDivider from '@/components/reading/ReadingBilingualDivider.vue'
import ReadingSegmentVocabSection from '@/components/reading/ReadingSegmentVocabSection.vue'
import { preprocessSubtitleHtml, stripSpeakerMarkers } from '@/utils/subtitleHtml'
import type { ArticleSegment } from '@/api/articles'
import { computed } from 'vue'

const props = defineProps<{
  segment: ArticleSegment
  articleId: string
  active?: boolean
}>()

defineEmits<{ click: [event: MouseEvent]; activate: [] }>()

const displayChinese = computed(() => stripSpeakerMarkers(props.segment.chinese))
const englishHtml = computed(() =>
  preprocessSubtitleHtml(props.segment.english_html || props.segment.english),
)
</script>

<template>
  <div
    class="rounded-xl border transition-colors cursor-pointer overflow-hidden hover:border-black/10 dark:hover:border-white/15"
    :class="
      active
        ? 'border-amber-300/70 dark:border-amber-500/40 ring-1 ring-amber-200/60 dark:ring-amber-500/20 bg-white dark:bg-neutral-900'
        : 'border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900'
    "
    :data-reading-segment-id="segment.id"
    :data-reading-context="segment.english"
    @click="$emit('activate')"
  >
    <div class="p-4 min-w-0 flex gap-2 items-start">
      <ReadingSegmentPlayButton :segment-index="segment.index" :has-audio="Boolean(segment.audio_url)" />
      <div class="min-w-0 flex-1">
      <SubtitleEnglish
        v-if="segment.english_html"
        :html="englishHtml"
        align="left"
        @click="$emit('click', $event)"
      />
      <p
        v-else
        class="subtitle-english text-base leading-relaxed font-medium text-neutral-900 dark:text-neutral-100"
        @click="$emit('click', $event)"
      >
        {{ segment.english }}
      </p>
      </div>
    </div>
    <div class="px-4">
      <ReadingBilingualDivider orientation="horizontal" />
    </div>
    <div class="px-4 pb-4 pt-2">
      <p
        v-if="displayChinese"
        class="subtitle-chinese text-base leading-relaxed text-neutral-700 dark:text-neutral-300"
      >
        {{ displayChinese }}
      </p>
      <p v-else class="text-sm leading-relaxed text-neutral-400 dark:text-neutral-500 italic">暂无译文</p>
    </div>
    <ReadingSegmentVocabSection :segment="segment" :article-id="articleId" />
  </div>
</template>
