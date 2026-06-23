<script setup lang="ts">
import { RouterLink } from 'vue-router'
import type { EpisodeSummary } from '@/types'

defineProps<{ episode: EpisodeSummary; to: string }>()

function formatDuration(sec: number) {
  const m = Math.floor(sec / 60)
  const s = Math.floor(sec % 60)
  return `${m}:${String(s).padStart(2, '0')}`
}
</script>

<template>
  <RouterLink :to="to" class="block group">
    <div class="rounded-2xl overflow-hidden border border-black/5 shadow-sm hover:shadow-md transition bg-white">
      <div class="relative aspect-video bg-neutral-200">
        <img :src="episode.cover" :alt="episode.short_title" class="w-full h-full object-cover" loading="lazy" />
        <span class="absolute bottom-2 right-2 text-white text-xs bg-black/60 px-2 py-0.5 rounded">
          {{ formatDuration(episode.clip_length) }}
        </span>
      </div>
      <div class="p-4">
        <div class="flex items-center gap-2 mb-1 text-sm">
          <span>{{ episode.author.nationality }}</span>
          <span class="font-medium">{{ episode.author.name }}</span>
          <span class="text-neutral-400">· {{ episode.author.accent }}</span>
        </div>
        <p class="font-medium mb-1 line-clamp-1">{{ episode.short_title }}</p>
        <p class="text-xs text-neutral-500 line-clamp-2 mb-2">{{ episode.summary }}</p>
        <div class="flex items-center justify-between">
          <div class="flex gap-0.5">
            <span v-for="n in 5" :key="n" class="text-sm" :class="n <= episode.stars ? 'text-amber-400' : 'text-neutral-300'">★</span>
          </div>
          <div class="flex gap-1 flex-wrap justify-end">
            <span v-for="t in episode.tags.slice(0, 2)" :key="t.id" class="text-[10px] bg-neutral-100 px-1.5 py-0.5 rounded">
              {{ t.name }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </RouterLink>
</template>
