<script setup lang="ts">
import SubtitleEnglish from './SubtitleEnglish.vue'
import type { SubtitleAlign } from '@/utils/subtitleHtml'

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
    readProgress?: number
  }>(),
  { align: 'center', chineseFocus: false },
)

defineEmits<{ click: [event: MouseEvent] }>()

function chineseClasses() {
  if (props.chineseFocus) {
    return props.active
      ? 'text-base sm:text-lg leading-relaxed font-bold text-white'
      : 'text-base sm:text-lg leading-relaxed text-neutral-800'
  }
  return [
    props.large ? 'text-base sm:text-lg' : 'text-sm',
    props.active ? 'text-white/80' : 'text-neutral-600 opacity-70',
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
      class="subtitle-ipa font-serif tracking-wide opacity-60 max-w-full break-words"
      :class="[
        large ? 'text-base sm:text-lg' : 'text-base',
        chineseFocus && !active ? 'text-neutral-500' : '',
      ]"
    >
      {{ ipa }}
    </p>
    <SubtitleEnglish
      v-if="showEnglish"
      :html="englishHtml"
      :active="active"
      :large="large"
      :align="align"
      :read-progress="readProgress"
      @click="$emit('click', $event)"
    />
    <p v-if="showChinese && chinese" class="subtitle-chinese max-w-full" :class="chineseClasses()">
      {{ chinese }}
    </p>
  </div>
</template>
