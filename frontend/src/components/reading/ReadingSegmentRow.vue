<script setup lang="ts">
import SubtitleEnglish from '@/components/SubtitleEnglish.vue'
import ReadingSegmentPlayButton from '@/components/reading/ReadingSegmentPlayButton.vue'
import ReadingBilingualDivider from '@/components/reading/ReadingBilingualDivider.vue'
import ReadingSegmentVocabSection from '@/components/reading/ReadingSegmentVocabSection.vue'
import { useReadingSettings } from '@/composables/useReadingSettings'
import { preprocessSubtitleHtml, stripSpeakerMarkers } from '@/utils/subtitleHtml'
import type { ArticleSegment } from '@/api/articles'
import { computed } from 'vue'

const props = defineProps<{
  segment: ArticleSegment
  articleId: string
  active?: boolean
  /** 生词回看：短暂高亮匹配词 */
  emphasizeWord?: string
  /** 词文对照模式下的高亮 HTML（优先于 english_html） */
  vocabLinkHtml?: string
}>()

const emit = defineEmits<{
  click: [event: MouseEvent]
  activate: []
  'oral-practice': []
}>()

const { showChinese } = useReadingSettings()

const displayChinese = computed(() => stripSpeakerMarkers(props.segment.chinese))
const englishHtml = computed(() => {
  if (props.vocabLinkHtml) return props.vocabLinkHtml
  return preprocessSubtitleHtml(props.segment.english_html || props.segment.english)
})
const useHtml = computed(() =>
  Boolean(props.vocabLinkHtml || props.segment.english_html || props.segment.english),
)
</script>

<template>
  <div
    class="rounded-xl border transition-colors cursor-pointer overflow-hidden hover:border-black/10 dark:hover:border-white/15"
    :class="
      active
        ? 'border-amber-300/70 dark:border-amber-500/40 ring-1 ring-amber-200/60 dark:ring-amber-500/20 bg-card'
        : 'border-line-soft bg-card'
    "
    :data-reading-segment-id="segment.id"
    :data-reading-context="segment.english"
    @click="$emit('activate')"
  >
    <div class="p-4 min-w-0 flex gap-2 items-start">
      <ReadingSegmentPlayButton :segment-index="segment.index" :has-audio="Boolean(segment.audio_url)" />
      <div class="min-w-0 flex-1">
      <SubtitleEnglish
        v-if="useHtml"
        :html="englishHtml"
        align="left"
        :emphasize-word="emphasizeWord"
        @click="$emit('click', $event)"
      />
      <p
        v-else
        class="subtitle-english text-base leading-relaxed font-medium text-neutral-900 dark:text-neutral-100"
        @click="$emit('click', $event)"
      >
        {{ segment.english }}
      </p>
      <div class="mt-2.5 flex flex-wrap gap-1.5">
        <button
          type="button"
          class="inline-flex items-center gap-1 px-2 h-7 rounded-full text-[11px] font-medium border border-black/10 bg-white/90 text-neutral-600 hover:border-sky-400 hover:text-sky-700 dark:bg-neutral-800/90 dark:border-white/10 dark:text-neutral-300 dark:hover:border-sky-500 dark:hover:text-sky-300"
          @click.stop="emit('oral-practice')"
        >
          跟读评分
        </button>
      </div>
      </div>
    </div>
    <template v-if="showChinese">
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
    </template>
    <ReadingSegmentVocabSection :segment="segment" :article-id="articleId" />
  </div>
</template>
