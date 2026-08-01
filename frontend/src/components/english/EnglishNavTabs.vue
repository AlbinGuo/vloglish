<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { getEnglishNavCounts, getEnglishNavNew } from '@/api/episodes'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const auth = useAuthStore()

const videoCount = ref<number | null>(null)
/** 2 天内是否有新上架内容（进列表不清除） */
const hasNew = ref<{ series: boolean; articles: boolean }>({ series: false, articles: false })

const active = computed(() => {
  if (route.path.startsWith('/english/reading')) return 'reading'
  if (route.path.startsWith('/english/series')) return 'series'
  return 'videos'
})

async function refresh() {
  try {
    const counts = await getEnglishNavCounts()
    videoCount.value = counts.videos
  } catch {
    videoCount.value = null
  }
  try {
    const data = await getEnglishNavNew()
    hasNew.value = {
      series: Boolean(data.has_series_new ?? data.series > 0),
      articles: Boolean(data.has_articles_new ?? data.articles > 0),
    }
  } catch {
    hasNew.value = { series: false, articles: false }
  }
}

onMounted(refresh)
watch(
  () => [auth.isLoggedIn, auth.isMember, route.fullPath],
  () => {
    void refresh()
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
        v-if="videoCount != null"
        class="absolute top-0.5 right-0.5 min-w-[1.1rem] h-[1.1rem] px-1 rounded-full text-[10px] font-semibold leading-[1.1rem] text-center tabular-nums"
        :class="
          active === 'videos'
            ? 'bg-amber-500 text-white'
            : 'bg-neutral-300/90 text-neutral-700 dark:bg-neutral-600 dark:text-neutral-100'
        "
      >
        {{ videoCount }}
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
        v-if="hasNew.series"
        class="absolute -top-1 -right-1 px-1.5 py-0.5 rounded-md text-xs font-bold leading-none bg-red-500 text-white shadow-sm"
      >
        新
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
      文章阅读
      <span
        v-if="hasNew.articles"
        class="absolute -top-1 -right-1 px-1.5 py-0.5 rounded-md text-xs font-bold leading-none bg-red-500 text-white shadow-sm"
      >
        新
      </span>
    </RouterLink>
  </nav>
</template>
