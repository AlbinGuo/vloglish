<script setup lang="ts">
import { computed } from 'vue'
import AppIcon from '@/components/AppIcon.vue'

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
    amber: 'bg-amber-100 text-warning dark:bg-amber-900/40',
    emerald: 'bg-emerald-100 text-emerald-600 dark:bg-emerald-900/40 dark:text-emerald-400',
    blue: 'bg-blue-100 text-blue-600 dark:bg-blue-900/40 dark:text-blue-400',
    orange: 'bg-orange-100 text-orange-600 dark:bg-orange-900/40 dark:text-orange-400',
    sky: 'bg-sky-100 text-sky-600 dark:bg-sky-900/40 dark:text-sky-400',
    violet: 'bg-violet-100 text-violet-600 dark:bg-violet-900/40 dark:text-violet-400',
    rose: 'bg-rose-100 text-rose-600 dark:bg-rose-900/40 dark:text-rose-400',
  }
  return map[props.tone ?? 'amber']
})
</script>

<template>
  <div class="rounded-xl border border-line-soft bg-card p-4">
    <div class="flex items-center gap-2.5 mb-2">
      <div
        class="w-9 h-9 rounded-xl flex items-center justify-center shrink-0"
        :class="toneClass"
      >
        <AppIcon name="clock" v-if="icon === 'clock'" class="w-5 h-5" />
        <AppIcon name="clock" v-else-if="icon === 'check-circle'" class="w-5 h-5" />
        <AppIcon name="play-circle" v-else-if="icon === 'play-circle'" class="w-5 h-5" />
        <AppIcon name="flame" v-else-if="icon === 'fire'" class="w-5 h-5" />
        <AppIcon name="sun" v-else-if="icon === 'sun'" class="w-5 h-5" />
        <AppIcon name="calendar" v-else-if="icon === 'calendar'" class="w-5 h-5" />
        <AppIcon name="search" v-else-if="icon === 'search'" class="w-5 h-5" />
        <AppIcon name="bookmark" v-else-if="icon === 'bookmark'" class="w-5 h-5" />
      </div>
      <p class="text-xs text-neutral-500 leading-snug">{{ label }}</p>
    </div>
    <p class="text-lg font-semibold tabular-nums">{{ value }}</p>
  </div>
</template>
