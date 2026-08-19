<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  remainingMs: number
  durationMs: number
  kind: 'repeat' | 'next' | ''
}>()

const emit = defineEmits<{
  skip: []
}>()

const R = 42
const CIRCUM = 2 * Math.PI * R

const seconds = computed(() => Math.max(1, Math.ceil(props.remainingMs / 1000)))

const progress = computed(() => {
  if (props.durationMs <= 0) return 0
  return Math.min(1, Math.max(0, props.remainingMs / props.durationMs))
})

const dashOffset = computed(() => CIRCUM * (1 - progress.value))

const caption = computed(() => (props.kind === 'repeat' ? '再听一遍' : '下一句'))
</script>

<template>
  <div
    class="absolute inset-0 z-40 flex items-center justify-center bg-black/40 backdrop-blur-[2px]"
    role="timer"
    :aria-label="`间隔倒计时 ${seconds} 秒，点击跳过`"
    @click.stop="emit('skip')"
  >
    <div class="relative flex h-[7.25rem] w-[7.25rem] items-center justify-center">
      <svg class="absolute inset-0 -rotate-90" viewBox="0 0 100 100" aria-hidden="true">
        <circle
          cx="50"
          cy="50"
          :r="R"
          fill="none"
          class="stroke-white/20"
          stroke-width="5"
        />
        <circle
          cx="50"
          cy="50"
          :r="R"
          fill="none"
          class="stroke-amber-400"
          stroke-width="5"
          stroke-linecap="round"
          :stroke-dasharray="CIRCUM"
          :stroke-dashoffset="dashOffset"
          style="transition: stroke-dashoffset 80ms linear"
        />
      </svg>
      <div
        class="relative flex h-[5.5rem] w-[5.5rem] flex-col items-center justify-center rounded-full bg-neutral-950/75 ring-1 ring-white/15 shadow-xl"
      >
        <span class="text-[2.35rem] font-semibold leading-none tabular-nums tracking-tight text-white">
          {{ seconds }}
        </span>
        <span class="mt-1 text-[11px] font-medium text-amber-200/90">{{ caption }}</span>
      </div>
    </div>
    <p class="pointer-events-none absolute bottom-[18%] text-[11px] text-white/55">点击跳过</p>
  </div>
</template>
