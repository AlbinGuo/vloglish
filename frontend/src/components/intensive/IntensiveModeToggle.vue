<script setup lang="ts">
import { useIntensiveReadingMode } from '@/composables/useIntensiveReadingMode'

const { intensiveMode, toggleIntensiveMode } = useIntensiveReadingMode()
</script>

<template>
  <button
    type="button"
    class="inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-medium border transition-colors shrink-0"
    :class="
      intensiveMode
        ? 'border-red-300 bg-red-50 text-red-700 dark:border-red-800 dark:bg-red-950/40 dark:text-red-200'
        : 'border-black/10 text-neutral-500 hover:border-red-200 hover:text-red-600 dark:border-white/10 dark:text-neutral-400 dark:hover:border-red-900 dark:hover:text-red-300'
    "
    :aria-pressed="intensiveMode"
    @click="toggleIntensiveMode"
  >
    精读
  </button>
</template>
