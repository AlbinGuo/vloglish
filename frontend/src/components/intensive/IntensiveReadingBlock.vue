<script setup lang="ts">
import { computed } from 'vue'
import IntensiveEnglishText from '@/components/intensive/IntensiveEnglishText.vue'
import type { WordLookupMeta } from '@/composables/useWordLookupCache'
import { stripSpeakerMarkers, type SubtitleAlign } from '@/utils/subtitleHtml'

const props = withDefaults(
  defineProps<{
    englishHtml: string
    english: string
    chinese: string
    ipa?: string
    active?: boolean
    large?: boolean
    align?: SubtitleAlign
    showEnglish?: boolean
    showChinese?: boolean
    showIpa?: boolean
    lookupMeta?: WordLookupMeta
    emphasizeWord?: string
  }>(),
  {
    align: 'left',
    showEnglish: true,
    showChinese: true,
    showIpa: false,
  },
)

defineEmits<{ click: [event: MouseEvent] }>()

const displayChinese = computed(() => stripSpeakerMarkers(props.chinese))
</script>

<template>
  <div
    class="intensive-reading-block flex flex-col w-full gap-2"
    :class="align === 'left' ? 'items-start text-left' : 'items-center text-center'"
  >
    <p
      v-if="showIpa && ipa"
      class="intensive-ipa text-sm font-serif tracking-wide text-neutral-500 dark:text-neutral-400 max-w-full break-words"
    >
      {{ ipa }}
    </p>

    <IntensiveEnglishText
      v-if="showEnglish && englishHtml"
      :html="englishHtml"
      :context="english"
      :lookup-meta="lookupMeta"
      :active="active"
      :large="large"
      :align="align"
      :emphasize-word="emphasizeWord"
      @click="$emit('click', $event)"
    />
    <p
      v-else-if="showEnglish"
      class="intensive-english-plain text-base leading-relaxed font-medium text-neutral-900 dark:text-neutral-100"
      @click="$emit('click', $event)"
    >
      {{ english }}
    </p>

    <div
      v-if="showChinese && displayChinese"
      class="intensive-chinese-block w-full rounded-lg px-3 py-2.5 text-sm leading-relaxed"
    >
      {{ displayChinese }}
    </div>
  </div>
</template>
