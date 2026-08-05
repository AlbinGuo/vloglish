<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { getSeriesList } from '@/api/episodes'
import EnglishCatalogNavBar from '@/components/english/EnglishCatalogNavBar.vue'
import EnglishNavTabs from '@/components/english/EnglishNavTabs.vue'
import SeriesStackCard from '@/components/catalog/SeriesStackCard.vue'
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
  <div>
    <EnglishCatalogNavBar />

    <div class="page-container pt-3 pb-6 sm:py-6">
      <EnglishNavTabs class="hidden sm:block mb-6" />

      <p v-if="loading" class="py-24 text-center text-neutral-500">加载中...</p>
      <p v-else-if="error" class="py-24 text-center text-red-600">{{ error }}</p>
      <p v-else-if="!seriesList.length" class="py-24 text-center text-neutral-500">暂无合集</p>

      <div
        v-else
        class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3"
      >
        <SeriesStackCard v-for="item in seriesList" :key="item.id" :series="item" />
      </div>
    </div>
  </div>
</template>
