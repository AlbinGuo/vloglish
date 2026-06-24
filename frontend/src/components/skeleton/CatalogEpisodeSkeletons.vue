<script setup lang="ts">
import EpisodeCardSkeleton from '@/components/skeleton/EpisodeCardSkeleton.vue'
import EpisodeListRowSkeleton from '@/components/skeleton/EpisodeListRowSkeleton.vue'
import { useCatalogViewMode } from '@/composables/useCatalogViewMode'

const { viewMode } = useCatalogViewMode()

withDefaults(
  defineProps<{
    count?: number
  }>(),
  { count: 8 },
)
</script>

<template>
  <div v-if="viewMode === 'card'" class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
    <EpisodeCardSkeleton v-for="n in count" :key="n" />
  </div>

  <div v-else class="rounded-xl border border-black/5 overflow-hidden bg-white">
    <div
      class="flex flex-wrap items-center gap-3 px-4 py-3 border-b border-black/5 bg-neutral-50/80 rounded-t-xl"
    >
      <div class="h-9 flex-1 min-w-[12rem] bg-neutral-200/70 rounded-lg animate-pulse" />
      <div class="flex items-center gap-1.5 shrink-0">
        <div class="w-9 h-9 rounded-lg bg-neutral-200/70 animate-pulse" />
        <div class="w-9 h-9 rounded-lg bg-neutral-200/70 animate-pulse" />
      </div>
    </div>
    <EpisodeListRowSkeleton v-for="n in count" :key="n" />
  </div>
</template>
