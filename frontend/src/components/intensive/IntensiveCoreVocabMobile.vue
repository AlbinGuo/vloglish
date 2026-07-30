<script setup lang="ts">
import { ref } from 'vue'
import type { CoreVocabItem } from '@/composables/useCoreVocabulary'

defineProps<{
  items: CoreVocabItem[]
  loading?: boolean
}>()

const open = ref(false)
</script>

<template>
  <div class="intensive-core-vocab-mobile lg:hidden">
    <button
      type="button"
      class="fixed right-4 z-30 flex items-center gap-1.5 rounded-full px-3.5 py-2 text-xs font-medium shadow-lg border transition-colors"
      :class="open ? 'intensive-mobile-fab--open' : 'intensive-mobile-fab'"
      :style="{ bottom: 'calc(5.5rem + env(safe-area-inset-bottom))' }"
      @click="open = !open"
    >
      核心词 {{ items.length }}
      <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true">
        <path v-if="open" d="m18 15-6-6-6 6" />
        <path v-else d="m6 9 6 6 6-6" />
      </svg>
    </button>

    <Transition name="intensive-sheet">
      <div
        v-if="open"
        class="fixed inset-x-0 z-20 max-h-[45vh] flex flex-col border-t shadow-2xl intensive-mobile-sheet"
        :style="{ bottom: 'calc(3.5rem + env(safe-area-inset-bottom))' }"
      >
        <div class="shrink-0 px-4 py-2.5 border-b border-red-100 dark:border-red-950/50">
          <p class="text-sm font-semibold text-red-800 dark:text-red-200">核心词汇</p>
          <p class="text-xs text-red-600/70 dark:text-red-300/70">{{ items.length }} 个重点词</p>
        </div>
        <ul class="flex-1 min-h-0 overflow-y-auto overscroll-contain p-3 space-y-2 reading-scroll-hide">
          <li v-if="loading && !items.length" class="text-sm text-neutral-400 text-center py-4">加载中…</li>
          <li v-else-if="!items.length" class="text-sm text-neutral-400 text-center py-4">暂无标注词汇</li>
          <li
            v-for="item in items"
            v-else
            :key="item.word"
            class="intensive-vocab-card rounded-lg px-3 py-2"
          >
            <p class="font-semibold text-sm">{{ item.word }}</p>
            <p v-if="item.loading" class="text-xs text-neutral-400 animate-pulse mt-0.5">加载中…</p>
            <template v-else>
              <p v-if="item.ipa" class="text-[11px] font-mono text-neutral-500 mt-0.5">{{ item.ipa }}</p>
              <p class="text-xs leading-snug mt-0.5">{{ item.meaning }}</p>
            </template>
          </li>
        </ul>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.intensive-sheet-enter-active,
.intensive-sheet-leave-active {
  transition: transform 0.25s ease, opacity 0.25s ease;
}

.intensive-sheet-enter-from,
.intensive-sheet-leave-to {
  transform: translateY(100%);
  opacity: 0;
}
</style>
