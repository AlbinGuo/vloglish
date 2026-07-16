<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { getSeriesList } from '@/api/episodes'
import EnglishNavTabs from '@/components/english/EnglishNavTabs.vue'
import { resolveMediaUrl } from '@/utils/mediaUrl'
import type { SeriesSummary } from '@/types'

defineOptions({ name: 'SeriesListPage' })

const loading = ref(true)
const error = ref('')
const seriesList = ref<SeriesSummary[]>([])

onMounted(async () => {
  loading.value = true
  error.value = ''
  try {
    const data = await getSeriesList()
    seriesList.value = data.results
  } catch {
    error.value = '加载失败，请稍后重试'
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="page-container py-6">
    <EnglishNavTabs class="mb-6" />

    <p v-if="loading" class="py-24 text-center text-neutral-500">加载中...</p>
    <p v-else-if="error" class="py-24 text-center text-red-600">{{ error }}</p>
    <p v-else-if="!seriesList.length" class="py-24 text-center text-neutral-500">暂无合集</p>

    <div v-else class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
      <RouterLink
        v-for="item in seriesList"
        :key="item.id"
        :to="`/english/series/${item.slug}`"
        class="group rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 overflow-hidden hover:shadow-md transition"
      >
        <div class="aspect-video bg-neutral-200 dark:bg-neutral-800">
          <img
            v-if="item.cover"
            :src="resolveMediaUrl(item.cover)"
            :alt="item.title"
            class="w-full h-full object-cover"
            loading="lazy"
          />
        </div>
        <div class="p-4">
          <h2 class="font-semibold leading-snug group-hover:text-amber-800 dark:group-hover:text-amber-400 transition-colors">
            {{ item.title }}
          </h2>
          <p class="mt-1 text-xs text-neutral-500">共 {{ item.episode_count }} 集 · 按序学习</p>
          <p v-if="item.summary" class="mt-2 text-sm text-neutral-600 dark:text-neutral-400 line-clamp-2">
            {{ item.summary }}
          </p>
        </div>
      </RouterLink>
    </div>
  </div>
</template>
