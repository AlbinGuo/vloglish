<script setup lang="ts">
import { RouterLink } from 'vue-router'
import type { EpisodeSummary } from '@/types'
import type { WordLookupRecord } from '@/api/learning'

defineProps<{
  tab: 'related' | 'lookup'
  relatedEpisodes: EpisodeSummary[]
  relatedLoading: boolean
  lookupHistory: WordLookupRecord[]
  lookupLoading: boolean
  showLookupTab: boolean
  episodePath: (videoId: string) => string
}>()

const emit = defineEmits<{
  'update:tab': [value: 'related' | 'lookup']
  reopenLookup: [record: WordLookupRecord]
  close: []
}>()

function formatDuration(sec: number) {
  const m = Math.floor(sec / 60)
  const s = Math.floor(sec % 60)
  return `${m}:${String(s).padStart(2, '0')}`
}
</script>

<template>
  <aside class="shrink-0 w-full lg:w-72 xl:w-80 border-t lg:border-t-0 lg:border-l border-black/5 bg-white flex flex-col max-h-56 lg:max-h-none">
    <div class="shrink-0 px-3 py-2.5 border-b border-black/5 flex items-center gap-1">
      <button
        type="button"
        class="flex-1 text-xs py-1.5 rounded-lg transition-colors"
        :class="tab === 'related' ? 'bg-neutral-900 text-white' : 'text-neutral-500 hover:bg-neutral-50'"
        @click="emit('update:tab', 'related')"
      >
        同标签视频
      </button>
      <button
        v-if="showLookupTab"
        type="button"
        class="flex-1 text-xs py-1.5 rounded-lg transition-colors"
        :class="tab === 'lookup' ? 'bg-neutral-900 text-white' : 'text-neutral-500 hover:bg-neutral-50'"
        @click="emit('update:tab', 'lookup')"
      >
        查词历史
      </button>
      <button
        type="button"
        class="shrink-0 w-7 h-7 rounded-lg text-neutral-400 hover:text-neutral-700 hover:bg-neutral-100 transition-colors flex items-center justify-center"
        aria-label="隐藏侧栏"
        title="隐藏侧栏"
        @click="emit('close')"
      >
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M18 6L6 18M6 6l12 12" />
        </svg>
      </button>
    </div>

    <div class="side-panel-scroll-hide flex-1 min-h-0 overflow-y-auto overscroll-contain">
      <!-- 同标签视频 -->
      <div v-if="tab === 'related'" class="p-3 space-y-2">
        <p v-if="relatedLoading" class="text-xs text-neutral-400 text-center py-8">加载中...</p>
        <p v-else-if="!relatedEpisodes.length" class="text-xs text-neutral-400 text-center py-8">暂无同标签视频</p>
        <RouterLink
          v-for="ep in relatedEpisodes"
          :key="ep.video_id"
          :to="episodePath(ep.video_id)"
          class="flex gap-2.5 rounded-lg border border-black/5 p-2 hover:bg-neutral-50 transition group"
        >
          <div class="relative w-20 shrink-0 aspect-video rounded-md overflow-hidden bg-neutral-200">
            <img :src="ep.cover" :alt="ep.short_title" class="w-full h-full object-cover" loading="lazy" />
            <span class="absolute bottom-0.5 right-0.5 text-[9px] text-white bg-black/60 px-1 rounded">
              {{ formatDuration(ep.clip_length) }}
            </span>
            <span
              v-if="ep.is_new"
              class="absolute top-0.5 left-0.5 text-[9px] px-1 py-0.5 rounded bg-red-500 text-white font-bold leading-none"
            >
              新
            </span>
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-[11px] text-neutral-400 mb-0.5">第 {{ ep.index }} 期 · @{{ ep.author.name }}</p>
            <p class="text-sm font-medium leading-snug line-clamp-2 group-hover:text-amber-800 transition-colors">
              {{ ep.short_title }}
            </p>
            <div v-if="ep.tags.length" class="flex flex-wrap gap-1 mt-1">
              <span
                v-for="t in ep.tags.slice(0, 2)"
                :key="t.id"
                class="text-[10px] px-1.5 py-0.5 rounded bg-neutral-100 text-neutral-500"
              >
                {{ t.name }}
              </span>
            </div>
          </div>
        </RouterLink>
      </div>

      <!-- 查词历史 -->
      <div v-else class="p-3 space-y-2">
        <p v-if="lookupLoading" class="text-xs text-neutral-400 text-center py-8">加载中...</p>
        <p v-else-if="!lookupHistory.length" class="text-xs text-neutral-400 text-center py-8">暂无查词记录</p>
        <button
          v-for="item in lookupHistory"
          :key="item.id"
          type="button"
          class="w-full text-left rounded-lg border border-black/5 px-3 py-2 hover:bg-neutral-50 transition"
          @click="emit('reopenLookup', item)"
        >
          <div class="flex items-center justify-between gap-2">
            <span class="font-medium text-sm">{{ item.word }}</span>
            <span v-if="item.is_saved" class="text-[10px] text-amber-700">生词</span>
          </div>
          <p class="text-xs text-neutral-400 line-clamp-2 mt-0.5">{{ item.context }}</p>
        </button>
      </div>
    </div>
  </aside>
</template>

<style scoped>
.side-panel-scroll-hide {
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.side-panel-scroll-hide::-webkit-scrollbar {
  display: none;
}
</style>
