<script setup lang="ts">
import { computed } from 'vue'
import SubtitleEnglish from '@/components/SubtitleEnglish.vue'
import { useReadingSettings } from '@/composables/useReadingSettings'
import { preprocessSubtitleHtml, stripSpeakerMarkers } from '@/utils/subtitleHtml'
import { resolveMediaUrl } from '@/utils/mediaUrl'
import type { ArticleSegment } from '@/api/articles'

const props = defineProps<{
  segments: ArticleSegment[]
  currentIndex: number
  cover?: string
  title?: string
  vocabLinkHtmlMap?: Record<number, string | undefined>
}>()

defineEmits<{
  activate: [index: number]
  click: [event: MouseEvent, segment: ArticleSegment]
}>()

const { showChinese } = useReadingSettings()

const coverUrl = computed(() => {
  const raw = (props.cover || '').trim()
  return raw ? resolveMediaUrl(raw) : ''
})

function englishHtml(segment: ArticleSegment) {
  const link = props.vocabLinkHtmlMap?.[segment.id]
  if (link) return link
  return preprocessSubtitleHtml(segment.english_html || segment.english)
}

function useHtml(segment: ArticleSegment) {
  return Boolean(props.vocabLinkHtmlMap?.[segment.id] || segment.english_html)
}

function displayChinese(segment: ArticleSegment) {
  return stripSpeakerMarkers(segment.chinese)
}

const blocks = computed(() => props.segments)
</script>

<template>
  <article class="px-4 sm:px-6 py-5 max-w-3xl mx-auto">
    <header v-if="coverUrl || title" class="mb-5">
      <div
        v-if="coverUrl"
        class="overflow-hidden rounded-xl bg-neutral-100 dark:bg-neutral-800 ring-1 ring-black/5 dark:ring-white/10"
      >
        <img
          :src="coverUrl"
          :alt="title || '文章封面'"
          class="w-full aspect-[16/9] object-cover"
          loading="lazy"
        />
      </div>
      <h1
        v-if="title"
        class="mt-4 text-xl sm:text-2xl font-semibold leading-snug text-neutral-900 dark:text-neutral-50"
      >
        {{ title }}
      </h1>
    </header>

    <div
      v-for="segment in blocks"
      :key="segment.id"
      class="reading-continuous-block cursor-pointer rounded-lg px-2 py-2.5 -mx-2 transition-colors"
      :class="
        segment.index === currentIndex
          ? 'bg-amber-50/90 dark:bg-amber-950/35 ring-1 ring-amber-200/60 dark:ring-amber-500/25'
          : 'hover:bg-black/[0.02] dark:hover:bg-white/[0.03]'
      "
      :data-reading-segment="segment.index"
      :data-reading-segment-id="segment.id"
      :data-reading-context="segment.english"
      @click="$emit('activate', segment.index)"
    >
      <SubtitleEnglish
        v-if="useHtml(segment)"
        :html="englishHtml(segment)"
        align="left"
        @click="$emit('click', $event, segment)"
      />
      <p
        v-else
        class="subtitle-english text-[15px] sm:text-base leading-[1.75] font-medium text-neutral-900 dark:text-neutral-100"
        @click="$emit('click', $event, segment)"
      >
        {{ segment.english }}
      </p>
      <template v-if="showChinese">
        <p
          v-if="displayChinese(segment)"
          class="subtitle-chinese mt-1.5 text-[14px] sm:text-[15px] leading-relaxed text-neutral-600 dark:text-neutral-400"
        >
          {{ displayChinese(segment) }}
        </p>
        <p
          v-else
          class="mt-1.5 text-sm leading-relaxed text-neutral-400 dark:text-neutral-500 italic"
        >
          暂无译文
        </p>
      </template>
    </div>
  </article>
</template>
