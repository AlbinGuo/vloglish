<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useCatalogViewMode } from '@/composables/useCatalogViewMode'
import { useCatalogStore } from '@/stores/catalog'
import CatalogCalendar from '@/components/catalog/CatalogCalendar.vue'
import CatalogFilters from '@/components/catalog/CatalogFilters.vue'
import CatalogListToolbar from '@/components/catalog/CatalogListToolbar.vue'
import CatalogViewSettings from '@/components/catalog/CatalogViewSettings.vue'
import CatalogEpisodeSkeletons from '@/components/skeleton/CatalogEpisodeSkeletons.vue'
import EpisodeCard from '@/components/EpisodeCard.vue'
import EpisodeListRow from '@/components/EpisodeListRow.vue'

const store = useCatalogStore()
const { viewMode } = useCatalogViewMode()

const totalPages = computed(() => Math.max(1, Math.ceil(store.total / store.filters.page_size)))

const pageRowOffset = computed(() => (store.filters.page - 1) * store.filters.page_size)

const skeletonCount = computed(() => Math.min(store.filters.page_size, 12))

onMounted(async () => {
  await store.loadFilters()
  await store.loadEpisodes()
})

function prevPage() {
  if (store.filters.page <= 1) return
  store.filters.page--
  store.loadEpisodes()
}

function nextPage() {
  if (store.filters.page >= totalPages.value) return
  store.filters.page++
  store.loadEpisodes()
}
</script>

<template>
  <div class="max-w-[1600px] mx-auto px-4 sm:px-6 py-6">
    <div class="flex flex-col lg:flex-row gap-6 lg:gap-8">
      <aside class="w-full lg:w-72 xl:w-80 shrink-0 space-y-4">
        <CatalogCalendar />
        <CatalogFilters />
        <CatalogViewSettings />
      </aside>

      <section class="flex-1 min-w-0">
        <CatalogEpisodeSkeletons v-if="store.loading" :count="skeletonCount" />

        <div v-else-if="viewMode === 'card'">
          <div v-if="!store.episodes.length" class="text-center py-24 text-neutral-500">没有匹配的内容</div>
          <div v-else class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
            <EpisodeCard
              v-for="ep in store.episodes"
              :key="ep.video_id"
              :episode="ep"
              :to="`/english/episode/${ep.video_id}`"
            />
          </div>
        </div>

        <div v-else class="rounded-xl border border-black/5 overflow-hidden bg-white">
          <CatalogListToolbar />
          <div v-if="!store.episodes.length" class="text-center py-16 text-neutral-500">没有匹配的内容</div>
          <EpisodeListRow
            v-for="(ep, i) in store.episodes"
            :key="ep.video_id"
            :episode="ep"
            :row-index="pageRowOffset + i + 1"
            :to="`/english/episode/${ep.video_id}`"
          />
        </div>

        <div v-if="!store.loading && totalPages > 1" class="flex justify-center items-center gap-3 mt-10">
          <button
            type="button"
            class="px-4 py-1.5 text-sm border rounded-lg disabled:opacity-40 hover:bg-neutral-50"
            :disabled="store.filters.page <= 1"
            @click="prevPage"
          >
            上一页
          </button>
          <span class="text-sm text-neutral-500">{{ store.filters.page }} / {{ totalPages }}</span>
          <button
            type="button"
            class="px-4 py-1.5 text-sm border rounded-lg disabled:opacity-40 hover:bg-neutral-50"
            :disabled="store.filters.page >= totalPages"
            @click="nextPage"
          >
            下一页
          </button>
        </div>
      </section>
    </div>
  </div>
</template>
