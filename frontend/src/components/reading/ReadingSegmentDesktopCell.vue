<script setup lang="ts">
import SubtitleEnglish from '@/components/SubtitleEnglish.vue'
import { preprocessSubtitleHtml, stripSpeakerMarkers } from '@/utils/subtitleHtml'
import type { ArticleSegment } from '@/api/articles'
import { computed } from 'vue'

const props = defineProps<{
  segment: ArticleSegment
  active?: boolean
  side: 'english' | 'chinese'
  embedded?: boolean
}>()

defineEmits<{ click: [event: MouseEvent]; activate: [] }>()

const displayChinese = computed(() => stripSpeakerMarkers(props.segment.chinese))
const englishHtml = computed(() =>
  preprocessSubtitleHtml(props.segment.english_html || props.segment.english),
)

const cellClass = computed(() => {
  if (props.embedded) {
    return 'min-w-0'
  }
  const base =
    'min-w-0 p-4 lg:p-5 border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 transition-colors cursor-pointer hover:border-black/10 dark:hover:border-white/15'
  const radius =
    props.side === 'english'
      ? 'rounded-l-xl rounded-r-none'
      : 'rounded-r-xl rounded-l-none'
  return [base, radius]
})
</script>

<template>
  <div
    :class="cellClass"
    :data-reading-segment="!embedded && side === 'english' ? segment.index : undefined"
    @click="embedded ? undefined : $emit('activate')"
  >
    <template v-if="side === 'english'">
      <SubtitleEnglish
        v-if="segment.english_html"
        :html="englishHtml"
        align="left"
        @click="$emit('click', $event)"
      />
      <p
        v-else
        class="subtitle-english text-base leading-relaxed font-medium text-neutral-900 dark:text-neutral-100 break-words"
        @click="$emit('click', $event)"
      >
        {{ segment.english }}
      </p>
    </template>
    <template v-else>
      <p
        v-if="displayChinese"
        class="subtitle-chinese text-base leading-relaxed text-neutral-700 dark:text-neutral-300 break-words p-4"
      >
        {{ displayChinese }}
      </p>
      <p v-else class="text-sm leading-relaxed text-neutral-400 dark:text-neutral-500 italic">暂无译文</p>
    </template>
  </div>
</template>
