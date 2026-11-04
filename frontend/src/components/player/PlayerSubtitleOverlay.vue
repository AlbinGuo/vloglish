<script setup lang="ts">
import { computed } from 'vue'
import SubtitleBlock from '@/components/SubtitleBlock.vue'
import type { Subtitle } from '@/types'
import type { PlayerSubtitlePosition } from '@/composables/useSubtitleOverlayPosition'

const props = defineProps<{
  sub: Subtitle | null | undefined
  englishHtml: string
  position: PlayerSubtitlePosition
}>()

defineEmits<{ click: [event: MouseEvent] }>()

const en = computed(() => (props.sub?.english || '').trim())
const zh = computed(() => (props.sub?.chinese || '').trim())

const visible = computed(
  () => props.position !== 'off' && Boolean(props.sub) && (en.value.length > 0 || zh.value.length > 0),
)

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
</script>

<template>
  <div
    v-if="visible && sub"
    class="psub-layer pointer-events-none absolute inset-x-0 z-[16] flex justify-center px-3"
    :class="positionClass"
  >
    <div class="psub-box" :data-subtitle-context="sub.english">
      <SubtitleBlock
        :english-html="englishHtml"
        :chinese="sub.chinese"
        :ipa="sub.ipa"
        :show-english="true"
        :show-chinese="true"
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
  font-family: Impact, Haettenschweiler, 'Arial Narrow Bold', 'Arial Black', 'PingFang SC',
    sans-serif !important;
  font-weight: 900 !important;
  letter-spacing: 0.02em;
  line-height: 1.15;
  font-size: clamp(1rem, 3.6vw, 1.75rem);
  text-shadow: 0 0 6px rgba(34, 227, 255, 0.65), 0 0 14px rgba(34, 227, 255, 0.35);
}

.psub-box :deep(.subtitle-chinese) {
  color: #ffffff !important;
  font-family: 'PingFang SC', 'Microsoft YaHei', system-ui, sans-serif;
  font-weight: 500;
  line-height: 1.3;
  margin-top: 0.1em;
  font-size: clamp(0.8rem, 2.8vw, 1.25rem);
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.7);
}
</style>
