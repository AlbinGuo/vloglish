<script setup lang="ts">
import { computed } from 'vue'
import { useTheme } from '@/composables/useTheme'
import AppIcon from '@/components/AppIcon.vue'

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
    <AppIcon name="moon" v-if="isDark" class="w-5 h-5" />
    <AppIcon name="sun" class="w-5 h-5" />
  </button>
</template>
