<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { getPopularEpisodeTags } from '@/api/episodes'
import { useCatalogStore } from '@/stores/catalog'
import type { Tag } from '@/types'

const store = useCatalogStore()

const tags = ref<Tag[]>([])
const scrollerRef = ref<HTMLElement | null>(null)
const canScrollLeft = ref(false)
const canScrollRight = ref(false)
const allSelected = computed(() => store.filters.tagIds.length === 0)

async function loadTags() {
  try {
    tags.value = await getPopularEpisodeTags()
  } catch {
    tags.value = []
  }
  await nextTick()
  updateScrollState()
}

function updateScrollState() {
  const el = scrollerRef.value
  if (!el) {
    canScrollLeft.value = false
    canScrollRight.value = false
    return
  }
  const maxScroll = el.scrollWidth - el.clientWidth
  canScrollLeft.value = el.scrollLeft > 2
  canScrollRight.value = maxScroll > 2 && el.scrollLeft < maxScroll - 2
}

function scrollByDir(dir: -1 | 1) {
  const el = scrollerRef.value
  if (!el) return
  const delta = Math.max(160, Math.floor(el.clientWidth * 0.7)) * dir
  el.scrollBy({ left: delta, behavior: 'smooth' })
}

/** 将标签滚到可视区域水平居中 */
function scrollTagIntoCenter(btn: HTMLElement) {
  const scroller = scrollerRef.value
  if (!scroller) return
  const scrollerRect = scroller.getBoundingClientRect()
  const btnRect = btn.getBoundingClientRect()
  const delta =
    btnRect.left + btnRect.width / 2 - (scrollerRect.left + scroller.clientWidth / 2)
  if (Math.abs(delta) < 4) return
  scroller.scrollBy({ left: delta, behavior: 'smooth' })
}

function onTagClick(id: number, e: MouseEvent) {
  void store.toggleTag(id)
  const btn = e.currentTarget as HTMLElement
  void nextTick(() => scrollTagIntoCenter(btn))
}

function onAllClick(e: MouseEvent) {
  if (!allSelected.value) {
    store.filters.tagIds = []
    void store.loadEpisodes(true)
  }
  const btn = e.currentTarget as HTMLElement
  void nextTick(() => scrollTagIntoCenter(btn))
}

let resizeObserver: ResizeObserver | null = null

onMounted(async () => {
  await loadTags()
  const el = scrollerRef.value
  if (el && typeof ResizeObserver !== 'undefined') {
    resizeObserver = new ResizeObserver(() => updateScrollState())
    resizeObserver.observe(el)
  }
  window.addEventListener('resize', updateScrollState)
})

onBeforeUnmount(() => {
  resizeObserver?.disconnect()
  window.removeEventListener('resize', updateScrollState)
})

watch(tags, async () => {
  await nextTick()
  updateScrollState()
})
</script>

<template>
  <div
    v-if="tags.length"
    class="flex items-center gap-1 min-w-0 flex-1"
    aria-label="主题标签"
  >
    <button
      type="button"
      class="hidden sm:inline-flex shrink-0 h-8 w-8 items-center justify-center rounded-full border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200 disabled:opacity-30 disabled:pointer-events-none transition"
      aria-label="向左滑动标签"
      :disabled="!canScrollLeft"
      @click="scrollByDir(-1)"
    >
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4" aria-hidden="true">
        <path fill-rule="evenodd" d="M12.79 5.23a.75.75 0 0 1-.02 1.06L8.832 10l3.938 3.71a.75.75 0 1 1-1.04 1.08l-4.5-4.25a.75.75 0 0 1 0-1.08l4.5-4.25a.75.75 0 0 1 1.06.02Z" clip-rule="evenodd" />
      </svg>
    </button>

    <div class="relative flex-1 min-w-0">
      <div
        class="pointer-events-none absolute inset-y-0 left-0 z-10 w-10 sm:w-12 bg-gradient-to-r from-neutral-50 via-neutral-50/85 to-transparent dark:from-neutral-950 dark:via-neutral-950/85 transition-opacity duration-200"
        :class="canScrollLeft ? 'opacity-100' : 'opacity-0'"
        aria-hidden="true"
      />
      <div
        class="pointer-events-none absolute inset-y-0 right-0 z-10 w-10 sm:w-12 bg-gradient-to-l from-neutral-50 via-neutral-50/85 to-transparent dark:from-neutral-950 dark:via-neutral-950/85 transition-opacity duration-200"
        :class="canScrollRight ? 'opacity-100' : 'opacity-0'"
        aria-hidden="true"
      />

      <div
        ref="scrollerRef"
        class="overflow-x-auto overscroll-x-contain reading-scroll-hide scroll-smooth"
        @scroll.passive="updateScrollState"
      >
        <div class="flex items-center gap-1.5 w-max py-0.5 px-1">
          <button
            type="button"
            class="shrink-0 text-xs px-2.5 py-1.5 rounded-full border transition cursor-pointer whitespace-nowrap"
            :class="
              allSelected
                ? 'border-neutral-900 bg-neutral-900 text-white dark:border-neutral-300 dark:bg-neutral-100 dark:text-neutral-900'
                : 'border-black/10 bg-neutral-50 text-neutral-700 hover:border-neutral-300 dark:border-white/10 dark:bg-neutral-800 dark:text-neutral-200 dark:hover:border-neutral-600'
            "
            @click="onAllClick"
          >
            全部
          </button>
          <button
            v-for="t in tags"
            :key="t.id"
            type="button"
            class="shrink-0 text-xs px-2.5 py-1.5 rounded-full border transition cursor-pointer whitespace-nowrap"
            :class="
              store.filters.tagIds.includes(t.id)
                ? 'border-neutral-900 bg-neutral-900 text-white dark:border-neutral-300 dark:bg-neutral-100 dark:text-neutral-900'
                : 'border-black/10 bg-neutral-50 text-neutral-700 hover:border-neutral-300 dark:border-white/10 dark:bg-neutral-800 dark:text-neutral-200 dark:hover:border-neutral-600'
            "
            @click="onTagClick(t.id, $event)"
          >
            {{ t.name }}
          </button>
        </div>
      </div>
    </div>

    <button
      type="button"
      class="shrink-0 h-8 w-8 inline-flex items-center justify-center rounded-full border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200 disabled:opacity-30 disabled:pointer-events-none transition"
      aria-label="向右滑动标签"
      :disabled="!canScrollRight"
      @click="scrollByDir(1)"
    >
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4" aria-hidden="true">
        <path fill-rule="evenodd" d="M7.21 14.77a.75.75 0 0 1 .02-1.06L11.168 10 7.23 6.29a.75.75 0 1 1 1.04-1.08l4.5 4.25a.75.75 0 0 1 0 1.08l-4.5 4.25a.75.75 0 0 1-1.06-.02Z" clip-rule="evenodd" />
      </svg>
    </button>
  </div>
</template>
