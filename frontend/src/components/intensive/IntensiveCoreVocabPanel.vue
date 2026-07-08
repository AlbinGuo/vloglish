<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import type { CoreVocabItem } from '@/composables/useCoreVocabulary'

const PANEL_KEY = 'intensive-core-vocab-visible'

function loadExpanded(): boolean {
  try {
    const stored = localStorage.getItem(PANEL_KEY)
    if (stored === 'false') return false
  } catch {
    /* ignore */
  }
  return true
}

const props = defineProps<{
  items: CoreVocabItem[]
  loading?: boolean
  title?: string
}>()

const expanded = ref(loadExpanded())

watch(expanded, (value) => {
  try {
    localStorage.setItem(PANEL_KEY, value ? 'true' : 'false')
  } catch {
    /* ignore */
  }
})

const itemCount = computed(() => props.items.length)
const panelTitle = computed(() => props.title ?? '核心词汇')

function toggleExpanded() {
  expanded.value = !expanded.value
}
</script>

<template>
  <div class="intensive-core-vocab hidden lg:block relative shrink-0 min-h-0 self-stretch">
    <button
      type="button"
      class="absolute top-1/2 z-20 left-0 -translate-x-full -translate-y-1/2 flex h-10 w-5 items-center justify-center rounded-l-md border border-r-0 border-red-200/80 dark:border-red-900/50 bg-white dark:bg-neutral-900 text-red-400 hover:text-red-600 dark:hover:text-red-300 shadow-sm transition-colors"
      :aria-label="expanded ? '隐藏核心词汇' : '显示核心词汇'"
      :aria-expanded="expanded"
      @click="toggleExpanded"
    >
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
        <path v-if="expanded" d="m9 18 6-6-6-6" />
        <path v-else d="m15 18-6-6 6-6" />
      </svg>
    </button>

    <aside
      class="flex flex-col h-full min-h-0 border-l border-red-100 dark:border-red-950/50 bg-white dark:bg-neutral-900 overflow-hidden transition-[width] duration-200 ease-out"
      :class="expanded ? 'w-64 xl:w-72' : 'w-0 border-l-0'"
    >
      <div class="w-64 xl:w-72 flex flex-col h-full min-h-0" :class="expanded ? '' : 'invisible'">
        <div class="shrink-0 px-4 py-3 border-b border-red-100 dark:border-red-950/50 bg-red-50/60 dark:bg-red-950/20">
          <h2 class="text-sm font-semibold text-red-800 dark:text-red-200">{{ panelTitle }}</h2>
          <p class="text-xs text-red-600/70 dark:text-red-300/70 mt-0.5">{{ itemCount }} 个重点词</p>
        </div>

        <div v-if="loading && !itemCount" class="flex-1 flex items-center justify-center text-sm text-neutral-400">
          加载中…
        </div>
        <div v-else-if="!itemCount" class="flex-1 flex items-center justify-center px-4 text-center">
          <p class="text-sm text-neutral-400 leading-relaxed">本篇暂无标注词汇</p>
        </div>
        <ul
          v-else
          class="flex-1 min-h-0 overflow-y-auto overscroll-contain reading-scroll-hide p-3 space-y-2"
        >
          <li
            v-for="item in items"
            :key="item.word"
            class="intensive-vocab-card rounded-lg px-3 py-2.5"
          >
            <p class="font-semibold text-sm leading-snug">{{ item.word }}</p>
            <template v-if="item.loading">
              <p class="text-xs text-neutral-400 animate-pulse mt-1">加载中…</p>
            </template>
            <template v-else>
              <p v-if="item.ipa" class="text-[11px] font-mono text-neutral-500 dark:text-neutral-400 mt-1">{{ item.ipa }}</p>
              <p class="text-xs leading-snug mt-0.5 opacity-90">{{ item.meaning }}</p>
            </template>
          </li>
        </ul>
      </div>
    </aside>
  </div>
</template>
