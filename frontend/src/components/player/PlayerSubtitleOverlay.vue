<script setup lang="ts">
import { computed } from 'vue'
import SubtitleBlock from '@/components/SubtitleBlock.vue'
import type { Subtitle } from '@/types'
import type { PlayerSubtitlePosition } from '@/composables/useSubtitleOverlayPosition'
import type { PlayerSubtitleSize } from '@/composables/usePlayerSubtitlePrefs'
import type { FullscreenCaptionMode } from '@/utils/subtitleHtml'

const props = withDefaults(
  defineProps<{
    sub: Subtitle | null | undefined
    englishHtml: string
    position: PlayerSubtitlePosition
    mode?: FullscreenCaptionMode
    size?: PlayerSubtitleSize
  }>(),
  { mode: 'both', size: 'medium' },
)

defineEmits<{ click: [event: MouseEvent] }>()

const en = computed(() => (props.sub?.english || '').trim())
const zh = computed(() => (props.sub?.chinese || '').trim())

const showEnglish = computed(() => props.mode === 'both' || props.mode === 'en')
const showChinese = computed(() => props.mode === 'both')

const visible = computed(() => {
  if (props.position === 'off' || props.mode === 'blind' || !props.sub) return false
  if (showEnglish.value && en.value.length) return true
  if (showChinese.value && zh.value.length) return true
  return false
})

const positionClass = computed(() => {
  switch (props.position) {
    case 'top':
      return 'top-0 pt-2 sm:pt-3'
    case 'middle':
      return 'top-1/2 -translate-y-1/2'
    default:
      return 'bottom-0 pb-3 sm:pb-12'
  }
})

const sizeClass = computed(() => `is-${props.size}`)
</script>

<template>
  <div
    v-if="visible && sub"
    class="psub-layer pointer-events-none absolute inset-x-0 z-[16] flex justify-center px-3"
    :class="positionClass"
  >
    <div class="psub-box" :class="sizeClass" :data-subtitle-context="sub.english">
      <SubtitleBlock
        :english-html="englishHtml"
        :chinese="sub.chinese"
        :ipa="sub.ipa"
        :show-english="showEnglish"
        :show-chinese="showChinese"
        :show-ipa="false"
        align="center"
        @click="$emit('click', $event)"
      />
    </div>
  </div>
</template>

<style scoped>
.psub-box {
  /* 空白处点击穿透到播放器分区（单词 span 自带 pointer-events-auto 仍可点击查词） */
  pointer-events: none;
  max-width: min(94%, 60rem);
  background: rgba(0, 0, 0, 0.55);
  border-radius: 10px;
  padding: 0.3em 0.85em;
  text-align: center;
  -webkit-backdrop-filter: blur(2px);
  backdrop-filter: blur(2px);
}

.psub-box :deep(.subtitle-english) {
  color: #22e3ff !important;
  font-weight: 900 !important;
  letter-spacing: 0.02em;
  line-height: 1.15;
  text-shadow: 0 0 6px rgba(34, 227, 255, 0.65), 0 0 14px rgba(34, 227, 255, 0.35);
}

.psub-box :deep(.subtitle-chinese) {
  color: #ffffff !important;
  font-weight: 500;
  line-height: 1.3;
  margin-top: 0.1em;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.7);
}

.psub-box.is-small :deep(.subtitle-english) {
  font-size: clamp(0.8rem, 2.8vw, 1.3rem);
}
.psub-box.is-small :deep(.subtitle-chinese) {
  font-size: clamp(0.68rem, 2.2vw, 1rem);
}

.psub-box.is-medium :deep(.subtitle-english) {
  font-size: clamp(1rem, 3.6vw, 1.75rem);
}
.psub-box.is-medium :deep(.subtitle-chinese) {
  font-size: clamp(0.8rem, 2.8vw, 1.25rem);
}

.psub-box.is-large :deep(.subtitle-english) {
  font-size: clamp(1.2rem, 4.6vw, 2.2rem);
}
.psub-box.is-large :deep(.subtitle-chinese) {
  font-size: clamp(0.95rem, 3.4vw, 1.5rem);
}
</style>
