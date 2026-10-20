<script setup lang="ts">
import { computed } from 'vue'
import { useTheme } from '@/composables/useTheme'

const { resolvedTheme, setThemeMode } = useTheme()

const isDark = computed(() => resolvedTheme.value === 'dark')

const ariaLabel = computed(() => (isDark.value ? '当前：深色，点击切换浅色' : '当前：浅色，点击切换深色'))

function toggleTheme() {
  setThemeMode(isDark.value ? 'light' : 'dark')
}
</script>

<template>
  <button
    type="button"
    class="inline-flex items-center justify-center w-8 h-8 rounded-lg text-ink-soft hover:text-black hover:bg-sunken dark:hover:text-white transition-colors"
    :title="ariaLabel"
    :aria-label="ariaLabel"
    @click="toggleTheme"
  >
    <svg
      v-if="isDark"
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.75"
      class="w-5 h-5"
      aria-hidden="true"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M21 14.5A7.5 7.5 0 0 1 9.5 3 6.5 6.5 0 1 0 21 14.5Z"
      />
    </svg>
    <svg
      v-else
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.75"
      class="w-5 h-5"
      aria-hidden="true"
    >
      <circle cx="12" cy="12" r="4" />
      <path stroke-linecap="round" d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4" />
    </svg>
  </button>
</template>
