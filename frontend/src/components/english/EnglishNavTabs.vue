<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { getEnglishNavCounts, getEnglishNavNew } from '@/api/episodes'
import { useAuthStore } from '@/stores/auth'

withDefaults(
  defineProps<{
    /** 手机首页：占满一行并均分三个 Tab */
    stretch?: boolean
  }>(),
  { stretch: false },
)

const route = useRoute()
const auth = useAuthStore()

const counts = ref<{ videos: number; series: number; articles: number } | null>(null)
/** 2 天内是否有新上架内容（进列表不清除） */
const hasNew = ref<{ series: boolean; articles: boolean }>({ series: false, articles: false })

const active = computed(() => {
  if (route.path.startsWith('/english/study')) return 'study'
  if (route.path.startsWith('/english/reading')) return 'reading'
  if (route.path.startsWith('/english/series')) return 'series'
  return 'videos'
})

function badgeClass(isActive: boolean) {
  return isActive
    ? 'bg-amber-500 text-white'
    : 'bg-neutral-300/90 text-neutral-700 dark:bg-neutral-600 dark:text-neutral-100'
}

async function refresh() {
  try {
    const data = await getEnglishNavCounts()
    counts.value = {
      videos: data.videos,
      series: data.series,
      articles: data.articles,
    }
  } catch {
    counts.value = null
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
    class="flex items-center gap-1 p-1 rounded-xl bg-neutral-100 dark:bg-neutral-800/80 border border-black/5 dark:border-white/10"
    :class="stretch ? 'w-full' : 'w-fit'"
    aria-label="主导航"
  >
    <RouterLink
      to="/english"
      class="relative px-3 sm:px-4 py-2 pr-5 rounded-lg text-sm font-medium transition-colors"
      :class="[
        stretch ? 'flex-1 text-center' : '',
        active === 'videos'
          ? 'bg-white dark:bg-neutral-900 text-neutral-900 dark:text-white shadow-sm'
          : 'text-neutral-500 dark:text-neutral-400 hover:text-neutral-800 dark:hover:text-neutral-200',
      ]"
    >
      视频
      <span
        v-if="counts"
        class="absolute top-0.5 right-0.5 min-w-[1.1rem] h-[1.1rem] px-1 rounded-full text-[10px] font-semibold leading-[1.1rem] text-center tabular-nums"
        :class="badgeClass(active === 'videos')"
      >
        {{ counts.videos }}
      </span>
    </RouterLink>
    <RouterLink
      to="/english/series"
      class="relative px-3 sm:px-4 py-2 pr-5 rounded-lg text-sm font-medium transition-colors"
      :class="[
        stretch ? 'flex-1 text-center' : '',
        active === 'series'
          ? 'bg-white dark:bg-neutral-900 text-neutral-900 dark:text-white shadow-sm'
          : 'text-neutral-500 dark:text-neutral-400 hover:text-neutral-800 dark:hover:text-neutral-200',
      ]"
    >
      合集
      <span
        v-if="counts"
        class="absolute top-0.5 right-0.5 min-w-[1.1rem] h-[1.1rem] px-1 rounded-full text-[10px] font-semibold leading-[1.1rem] text-center tabular-nums"
        :class="badgeClass(active === 'series')"
      >
        {{ counts.series }}
      </span>
      <span
        v-if="hasNew.series"
        class="absolute -top-1 -left-1 px-1.5 py-0.5 rounded-md text-xs font-bold leading-none bg-red-500 text-white shadow-sm"
      >
        新
      </span>
    </RouterLink>
    <RouterLink
      to="/english/reading"
      class="relative px-3 sm:px-4 py-2 pr-5 rounded-lg text-sm font-medium transition-colors"
      :class="[
        stretch ? 'flex-1 text-center' : '',
        active === 'reading'
          ? 'bg-white dark:bg-neutral-900 text-neutral-900 dark:text-white shadow-sm'
          : 'text-neutral-500 dark:text-neutral-400 hover:text-neutral-800 dark:hover:text-neutral-200',
      ]"
    >
      月刊
      <span
        v-if="counts"
        class="absolute top-0.5 right-0.5 min-w-[1.1rem] h-[1.1rem] px-1 rounded-full text-[10px] font-semibold leading-[1.1rem] text-center tabular-nums"
        :class="badgeClass(active === 'reading')"
      >
        {{ counts.articles }}
      </span>
      <span
        v-if="hasNew.articles"
        class="absolute -top-1 -left-1 px-1.5 py-0.5 rounded-md text-xs font-bold leading-none bg-red-500 text-white shadow-sm"
      >
        新
      </span>
    </RouterLink>
    <RouterLink
      to="/english/study"
      class="relative px-3 sm:px-4 py-2 rounded-lg text-sm font-medium transition-colors"
      :class="[
        stretch ? 'flex-1 text-center' : '',
        active === 'study'
          ? 'bg-white dark:bg-neutral-900 text-teal-800 dark:text-teal-200 shadow-sm'
          : 'text-teal-700 dark:text-teal-300 hover:text-teal-900 dark:hover:text-teal-100',
      ]"
    >
      怎么学
    </RouterLink>
  </nav>
</template>
