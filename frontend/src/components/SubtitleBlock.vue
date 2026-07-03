<script setup lang="ts">
import { computed } from 'vue'
import SubtitleEnglish from './SubtitleEnglish.vue'
import { stripSpeakerMarkers, type SubtitleAlign } from '@/utils/subtitleHtml'
import type { SubtitleWordHighlight } from '@/utils/subtitleWordProgress'

const props = withDefaults(
  defineProps<{
    englishHtml: string
    chinese: string
    ipa: string
    active?: boolean
    showEnglish?: boolean
    showChinese?: boolean
    showIpa?: boolean
    large?: boolean
    align?: SubtitleAlign
    chineseFocus?: boolean
    wordHighlight?: SubtitleWordHighlight
  }>(),
  { align: 'left', chineseFocus: false },
)

defineEmits<{ click: [event: MouseEvent] }>()

const displayChinese = computed(() => stripSpeakerMarkers(props.chinese))

function ipaClasses() {
  if (props.active) {
    return 'text-neutral-600 dark:text-neutral-700'
  }
  return 'text-neutral-500 dark:text-neutral-300'
}

function chineseClasses() {
  if (props.chineseFocus) {
    return props.active
      ? 'text-base sm:text-lg leading-relaxed font-bold text-inherit'
      : 'text-base sm:text-lg leading-relaxed text-neutral-800 dark:text-neutral-100'
  }
  if (props.active) {
    return [
      props.large ? 'text-base sm:text-lg' : 'text-sm',
      'leading-relaxed text-neutral-700 dark:text-neutral-800',
    ]
  }
  return [
    props.large ? 'text-base sm:text-lg' : 'text-sm',
    'leading-relaxed text-neutral-600 dark:text-neutral-200',
  ]
}
</script>

<template>
  <div
    class="flex flex-col w-full gap-1"
    :class="align === 'left' ? 'items-start text-left' : 'items-center text-center'"
  >
    <p
      v-if="showIpa && ipa"
      class="subtitle-ipa font-serif tracking-wide max-w-full break-words"
      :class="[large ? 'text-base sm:text-lg' : 'text-sm', ipaClasses()]"
    >
      {{ ipa }}
    </p>
    <SubtitleEnglish
      v-if="showEnglish"
      :html="englishHtml"
      :active="active"
      :large="large"
      :align="align"
      :word-highlight="wordHighlight"
      @click="$emit('click', $event)"
    />
    <p v-if="showChinese && displayChinese" class="subtitle-chinese max-w-full break-words" :class="chineseClasses()">
      {{ displayChinese }}
    </p>
  </div>
</template>
