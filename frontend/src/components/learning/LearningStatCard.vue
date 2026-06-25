<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  label: string
  value: string
  icon:
    | 'clock'
    | 'check-circle'
    | 'play-circle'
    | 'fire'
    | 'sun'
    | 'calendar'
    | 'search'
    | 'bookmark'
  tone?: 'amber' | 'emerald' | 'blue' | 'orange' | 'sky' | 'violet' | 'rose'
}>()

const toneClass = computed(() => {
  const map = {
    amber: 'bg-amber-100 text-amber-600',
    emerald: 'bg-emerald-100 text-emerald-600',
    blue: 'bg-blue-100 text-blue-600',
    orange: 'bg-orange-100 text-orange-600',
    sky: 'bg-sky-100 text-sky-600',
    violet: 'bg-violet-100 text-violet-600',
    rose: 'bg-rose-100 text-rose-600',
  }
  return map[props.tone ?? 'amber']
})
</script>

<template>
  <div class="rounded-xl border border-black/5 bg-white p-4">
    <div class="flex items-center gap-2.5 mb-2">
      <div
        class="w-9 h-9 rounded-xl flex items-center justify-center shrink-0"
        :class="toneClass"
      >
        <svg
          v-if="icon === 'clock'"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="1.75"
          class="w-5 h-5"
        >
          <circle cx="12" cy="12" r="9" />
          <path stroke-linecap="round" d="M12 7v5l3 2" />
        </svg>
        <svg
          v-else-if="icon === 'check-circle'"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="1.75"
          class="w-5 h-5"
        >
          <circle cx="12" cy="12" r="9" />
          <path stroke-linecap="round" stroke-linejoin="round" d="M8 12l2.5 2.5L16 9" />
        </svg>
        <svg
          v-else-if="icon === 'play-circle'"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="1.75"
          class="w-5 h-5"
        >
          <circle cx="12" cy="12" r="9" />
          <path fill="currentColor" stroke="none" d="M10 8.5v7l5.5-3.5L10 8.5Z" />
        </svg>
        <svg
          v-else-if="icon === 'fire'"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="currentColor"
          class="w-5 h-5"
        >
          <path
            d="M12 2c1.2 2.8 3.6 4.2 3.6 7.2 0 2.2-1.4 3.8-3.2 3.8-1.8 0-3.2-1.6-3.2-3.8 0-1.4.6-2.4 1.4-3.4C9.8 5.2 10.8 3.8 12 2Zm0 20c3.6 0 6.5-2.6 6.5-6.1 0-2.8-1.2-4.4-2.6-5.9-.4-.4-1-.1-1 .4.2 1.4-.4 2.8-1.6 3.6-1 .7-1.6 1.8-1.6 3 0 2.2 1.8 4 4 4Z"
          />
        </svg>
        <svg
          v-else-if="icon === 'sun'"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="1.75"
          class="w-5 h-5"
        >
          <circle cx="12" cy="12" r="4" />
          <path stroke-linecap="round" d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" />
        </svg>
        <svg
          v-else-if="icon === 'calendar'"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="1.75"
          class="w-5 h-5"
        >
          <rect x="3" y="5" width="18" height="16" rx="2" />
          <path stroke-linecap="round" d="M8 3v4M16 3v4M3 10h18" />
        </svg>
        <svg
          v-else-if="icon === 'search'"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="1.75"
          class="w-5 h-5"
        >
          <circle cx="11" cy="11" r="6" />
          <path stroke-linecap="round" d="M20 20l-3.5-3.5" />
        </svg>
        <svg
          v-else-if="icon === 'bookmark'"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="1.75"
          class="w-5 h-5"
        >
          <path
            stroke-linejoin="round"
            d="M6 4.5A1.5 1.5 0 0 1 7.5 3h9A1.5 1.5 0 0 1 18 4.5V19l-6-3.5L6 19V4.5Z"
          />
        </svg>
      </div>
      <p class="text-xs text-neutral-500 leading-snug">{{ label }}</p>
    </div>
    <p class="text-lg font-semibold tabular-nums">{{ value }}</p>
  </div>
</template>
