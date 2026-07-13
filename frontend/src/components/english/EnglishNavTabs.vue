<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { getEnglishNavCounts } from '@/api/episodes'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const auth = useAuthStore()

const counts = ref<{ videos: number; series: number; articles: number } | null>(null)

const active = computed(() => {
  if (route.path.startsWith('/english/reading')) return 'reading'
  if (route.path.startsWith('/english/series')) return 'series'
  return 'videos'
})

async function loadCounts() {
  try {
    counts.value = await getEnglishNavCounts()
  } catch {
    counts.value = null
  }
}

onMounted(loadCounts)
watch(
  () => [auth.isLoggedIn, auth.isMember],
  () => {
    void loadCounts()
  },
)
</script>

<template>
  <nav
    class="flex items-center gap-1 p-1 rounded-xl bg-neutral-100 dark:bg-neutral-800/80 border border-black/5 dark:border-white/10 w-fit"
    aria-label="内容类型"
  >
    <RouterLink
      to="/english"
      class="relative px-4 py-2 pr-5 rounded-lg text-sm font-medium transition-colors"
      :class="
        active === 'videos'
          ? 'bg-white dark:bg-neutral-900 text-neutral-900 dark:text-white shadow-sm'
          : 'text-neutral-500 dark:text-neutral-400 hover:text-neutral-800 dark:hover:text-neutral-200'
      "
    >
      视频
      <span
        v-if="counts"
        class="absolute top-0.5 right-0.5 min-w-[1.1rem] h-[1.1rem] px-1 rounded-full text-[10px] font-semibold leading-[1.1rem] text-center tabular-nums"
        :class="
          active === 'videos'
            ? 'bg-amber-500 text-white'
            : 'bg-neutral-300/90 text-neutral-700 dark:bg-neutral-600 dark:text-neutral-100'
        "
      >
        {{ counts.videos }}
      </span>
    </RouterLink>
    <RouterLink
      to="/english/series"
      class="relative px-4 py-2 pr-5 rounded-lg text-sm font-medium transition-colors"
      :class="
        active === 'series'
          ? 'bg-white dark:bg-neutral-900 text-neutral-900 dark:text-white shadow-sm'
          : 'text-neutral-500 dark:text-neutral-400 hover:text-neutral-800 dark:hover:text-neutral-200'
      "
    >
      合集
      <span
        v-if="counts"
        class="absolute top-0.5 right-0.5 min-w-[1.1rem] h-[1.1rem] px-1 rounded-full text-[10px] font-semibold leading-[1.1rem] text-center tabular-nums"
        :class="
          active === 'series'
            ? 'bg-amber-500 text-white'
            : 'bg-neutral-300/90 text-neutral-700 dark:bg-neutral-600 dark:text-neutral-100'
        "
      >
        {{ counts.series }}
      </span>
    </RouterLink>
    <RouterLink
      to="/english/reading"
      class="relative px-4 py-2 pr-5 rounded-lg text-sm font-medium transition-colors"
      :class="
        active === 'reading'
          ? 'bg-white dark:bg-neutral-900 text-neutral-900 dark:text-white shadow-sm'
          : 'text-neutral-500 dark:text-neutral-400 hover:text-neutral-800 dark:hover:text-neutral-200'
      "
    >
      新闻阅读
      <span
        v-if="counts"
        class="absolute top-0.5 right-0.5 min-w-[1.1rem] h-[1.1rem] px-1 rounded-full text-[10px] font-semibold leading-[1.1rem] text-center tabular-nums"
        :class="
          active === 'reading'
            ? 'bg-amber-500 text-white'
            : 'bg-neutral-300/90 text-neutral-700 dark:bg-neutral-600 dark:text-neutral-100'
        "
      >
        {{ counts.articles }}
      </span>
    </RouterLink>
  </nav>
</template>
