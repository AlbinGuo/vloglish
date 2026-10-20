<script setup lang="ts">
import { nextTick, ref, watch } from 'vue'
import type { EpisodeSummary } from '@/types'
import type { WordLookupRecord } from '@/api/learning'
import EpisodeAccessBadge from '@/components/EpisodeAccessBadge.vue'
import { isOpenToFreeUsers } from '@/utils/episodeAccess'
import { resolveMediaUrl } from '@/utils/mediaUrl'
import AppIcon from '@/components/AppIcon.vue'

const props = defineProps<{
  tab: 'related' | 'lookup'
  relatedEpisodes: EpisodeSummary[]
  relatedLoading: boolean
  lookupHistory: WordLookupRecord[]
  lookupLoading: boolean
  showLookupTab: boolean
  relatedLabel?: string
  currentVideoId?: string
  /** 底部抽屉内全高展示 */
  drawer?: boolean
}>()

const emit = defineEmits<{
  'update:tab': [value: 'related' | 'lookup']
  reopenLookup: [record: WordLookupRecord]
  selectEpisode: [videoId: string]
  close: []
}>()

const listScrollRef = ref<HTMLElement | null>(null)

function formatDuration(sec: number) {
  const m = Math.floor(sec / 60)
  const s = Math.floor(sec % 60)
  return `${m}:${String(s).padStart(2, '0')}`
}

function scrollCurrentToCenter(smooth = true) {
  if (!props.currentVideoId || props.tab !== 'related') return
  void nextTick(() => {
    const scroller = listScrollRef.value
    if (!scroller) return
    const item = scroller.querySelector(
      `[data-series-ep="${CSS.escape(props.currentVideoId!)}"]`,
    ) as HTMLElement | null
    if (!item) return

    const scrollerRect = scroller.getBoundingClientRect()
    const itemRect = item.getBoundingClientRect()
    const delta =
      itemRect.top + itemRect.height / 2 - (scrollerRect.top + scrollerRect.height / 2)
    const maxTop = Math.max(0, scroller.scrollHeight - scroller.clientHeight)
    const nextTop = Math.min(Math.max(0, scroller.scrollTop + delta), maxTop)

    if (smooth && typeof scroller.scrollTo === 'function') {
      scroller.scrollTo({ top: nextTop, behavior: 'smooth' })
    } else {
      scroller.scrollTop = nextTop
    }
  })
}

watch(
  () => [props.currentVideoId, props.relatedEpisodes.length, props.tab, props.relatedLoading] as const,
  ([, , , loading]) => {
    if (!loading) scrollCurrentToCenter(true)
  },
)
</script>

<template>
  <aside
    class="shrink-0 w-full lg:w-72 xl:w-80 border-t lg:border-t-0 lg:border-l border-black/5 dark:border-white/10 bg-card flex flex-col"
    :class="drawer ? 'h-full max-h-none' : 'max-h-56 lg:max-h-none'"
  >
    <div class="shrink-0 px-3 py-2.5 border-b border-black/5 dark:border-white/10 flex items-center gap-1">
      <button
        type="button"
        class="flex-1 text-xs py-1.5 rounded-lg transition-colors cursor-pointer"
        :class="tab === 'related' ? 'bg-ink text-ink-inverse' : 'text-ink-faint hover:bg-sunken'"
        @click="emit('update:tab', 'related')"
      >
        {{ relatedLabel || '相似视频' }}
      </button>
      <button
        v-if="showLookupTab"
        type="button"
        class="flex-1 text-xs py-1.5 rounded-lg transition-colors cursor-pointer"
        :class="tab === 'lookup' ? 'bg-ink text-ink-inverse' : 'text-ink-faint hover:bg-sunken'"
        @click="emit('update:tab', 'lookup')"
      >
        查词历史
      </button>
      <button
        type="button"
        class="shrink-0 w-7 h-7 rounded-lg text-neutral-400 hover:text-neutral-700 hover:bg-neutral-100 dark:hover:text-neutral-200 dark:hover:bg-neutral-800 transition-colors flex items-center justify-center"
        aria-label="隐藏侧栏"
        title="隐藏侧栏"
        @click="emit('close')"
      >
        <AppIcon name="close" :size="14" />
      </button>
    </div>

    <div
      ref="listScrollRef"
      class="side-panel-scroll-hide flex-1 min-h-0 overflow-y-auto overscroll-contain"
    >
      <!-- 相似视频 / 同合集 -->
      <div v-if="tab === 'related'" class="p-3 space-y-2">
        <p v-if="relatedLoading" class="text-xs text-neutral-400 text-center py-8">加载中...</p>
        <p v-else-if="!relatedEpisodes.length" class="text-xs text-neutral-400 text-center py-8">
          {{ relatedLabel === '同合集' ? '暂无合集视频' : '暂无相似视频' }}
        </p>
        <button
          v-for="ep in relatedEpisodes"
          :key="ep.video_id"
          type="button"
          :data-series-ep="ep.video_id"
          class="w-full flex gap-2.5 rounded-lg border p-2 transition group text-left cursor-pointer"
          :class="
            ep.video_id === currentVideoId
              ? 'border-amber-500 bg-amber-50/80 dark:border-amber-400 dark:bg-amber-950/40 ring-1 ring-amber-500/30'
              : 'border-line-soft hover:bg-sunken'
          "
          @click="emit('selectEpisode', ep.video_id)"
        >
          <div class="relative w-20 shrink-0 aspect-video rounded-md overflow-hidden bg-neutral-200 dark:bg-neutral-700">
            <img :src="resolveMediaUrl(ep.cover)" :alt="ep.short_title" class="w-full h-full object-cover" loading="lazy" />
            <span class="absolute bottom-0.5 right-0.5 text-[9px] text-white bg-black/60 px-1 rounded">
              {{ formatDuration(ep.clip_length) }}
            </span>
            <span
              v-if="ep.video_id === currentVideoId"
              class="absolute top-0.5 left-0.5 text-[9px] px-1 py-0.5 rounded bg-amber-500 text-white font-bold leading-none"
            >
              播放中
            </span>
            <EpisodeAccessBadge
              v-else
              class="absolute top-0.5 left-0.5"
              :free="isOpenToFreeUsers(ep)"
              compact
            />
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-[11px] text-neutral-400 mb-0.5">
              <template v-if="ep.series_index != null">第 {{ ep.series_index }} 集</template>
              <template v-else>第 {{ ep.index }} 期</template>
              · @{{ ep.author.name }}
            </p>
            <p
              class="text-sm font-medium leading-snug line-clamp-2 transition-colors"
              :class="
                ep.video_id === currentVideoId
                  ? 'text-warning'
                  : 'group-hover:text-amber-800 dark:group-hover:text-amber-400'
              "
            >
              {{ ep.short_title }}
            </p>
            <div v-if="ep.tags.length" class="flex flex-wrap gap-1 mt-1">
              <span
                v-for="t in ep.tags.slice(0, 2)"
                :key="t.id"
                class="text-[10px] px-1.5 py-0.5 rounded bg-neutral-100 text-neutral-500 dark:bg-neutral-800 dark:text-neutral-400"
              >
                {{ t.name }}
              </span>
            </div>
          </div>
        </button>
      </div>

      <!-- 查词历史 -->
      <div v-else class="p-3 space-y-2">
        <p v-if="lookupLoading" class="text-xs text-neutral-400 text-center py-8">加载中...</p>
        <p v-else-if="!lookupHistory.length" class="text-xs text-neutral-400 text-center py-8">暂无查词记录</p>
        <button
          v-for="item in lookupHistory"
          :key="item.id"
          type="button"
          class="w-full text-left rounded-lg border border-black/5 dark:border-white/10 px-3 py-2 hover:bg-neutral-50 dark:hover:bg-neutral-800 transition cursor-pointer"
          @click="emit('reopenLookup', item)"
        >
          <div class="flex items-center justify-between gap-2">
            <span class="font-medium text-sm">{{ item.word }}</span>
            <span v-if="item.is_saved" class="text-[10px] text-amber-700 dark:text-amber-400">生词</span>
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
