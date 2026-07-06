<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink, useRoute } from 'vue-router'

const route = useRoute()

const active = computed(() => {
  if (route.path.startsWith('/english/reading')) return 'reading'
  return 'videos'
})
</script>

<template>
  <nav
    class="flex items-center gap-1 p-1 rounded-xl bg-neutral-100 dark:bg-neutral-800/80 border border-black/5 dark:border-white/10 w-fit"
    aria-label="内容类型"
  >
    <RouterLink
      to="/english"
      class="px-4 py-2 rounded-lg text-sm font-medium transition-colors"
      :class="
        active === 'videos'
          ? 'bg-white dark:bg-neutral-900 text-neutral-900 dark:text-white shadow-sm'
          : 'text-neutral-500 dark:text-neutral-400 hover:text-neutral-800 dark:hover:text-neutral-200'
      "
    >
      Videos
    </RouterLink>
    <RouterLink
      to="/english/reading"
      class="px-4 py-2 rounded-lg text-sm font-medium transition-colors"
      :class="
        active === 'reading'
          ? 'bg-white dark:bg-neutral-900 text-neutral-900 dark:text-white shadow-sm'
          : 'text-neutral-500 dark:text-neutral-400 hover:text-neutral-800 dark:hover:text-neutral-200'
      "
    >
      News Reading
    </RouterLink>
  </nav>
</template>
