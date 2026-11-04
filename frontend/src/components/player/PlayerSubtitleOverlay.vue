<script setup lang="ts">
import { computed } from 'vue'
import type { Subtitle } from '@/types'
import type { PlayerSubtitlePosition } from '@/composables/useSubtitleOverlayPosition'

const props = defineProps<{
  sub: Subtitle | null | undefined
  position: PlayerSubtitlePosition
}>()

const en = computed(() => (props.sub?.english || '').trim())
const zh = computed(() => (props.sub?.chinese || '').trim())
const show = computed(() => (en.value.length > 0 || zh.value.length > 0))
</script>

<template>
  <div
    v-if="show"
    class="pointer-events-none absolute inset-x-0 z-[15] flex justify-center px-3"
    :class="{
      'top-0 pt-2 sm:pt-3': position === 'top',
      'top-1/2 -translate-y-1/2': position === 'middle',
      'bottom-0 pb-3 sm:pb-12': position === 'bottom',
    }"
    aria-hidden="true"
  >
    <div class="psub">
      <p v-if="en" class="psub-en">{{ en }}</p>
      <p v-if="zh" class="psub-zh">{{ zh }}</p>
    </div>
  </div>
</template>

<style scoped>
.psub {
  max-width: min(94%, 60rem);
  background: rgba(0, 0, 0, 0.55);
  border-radius: 10px;
  padding: 0.3em 0.8em;
  text-align: center;
  -webkit-backdrop-filter: blur(2px);
  backdrop-filter: blur(2px);
}

.psub-en {
  color: #22e3ff;
  font-family: Impact, Haettenschweiler, 'Arial Narrow Bold', 'Arial Black', 'PingFang SC',
    sans-serif;
  font-weight: 900;
  letter-spacing: 0.02em;
  line-height: 1.15;
  font-size: clamp(1rem, 3.6vw, 1.75rem);
  text-shadow: 0 0 6px rgba(34, 227, 255, 0.65), 0 0 14px rgba(34, 227, 255, 0.35);
  overflow-wrap: anywhere;
}

.psub-zh {
  margin-top: 0.15em;
  color: #ffffff;
  font-family: 'PingFang SC', 'Microsoft YaHei', system-ui, sans-serif;
  font-weight: 500;
  line-height: 1.3;
  font-size: clamp(0.8rem, 2.8vw, 1.25rem);
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.7);
  overflow-wrap: anywhere;
}
</style>
