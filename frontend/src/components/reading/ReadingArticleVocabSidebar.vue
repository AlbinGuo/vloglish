<script setup lang="ts">
import { computed, inject, ref, watch } from 'vue'
import { ARTICLE_VOCABULARY_KEY } from '@/composables/useArticleVocabulary'
import { formatExamTags, asExamTagList, examTagClass } from '@/utils/examTags'
import { playWordPronunciation } from '@/utils/speakWord'
import type { ArticleVocabularyItem } from '@/api/learning'
import AppIcon from '@/components/AppIcon.vue'

const VOCAB_SIDEBAR_KEY = 'reading-vocab-sidebar-visible'

function loadExpanded(): boolean {
  try {
    const stored = localStorage.getItem(VOCAB_SIDEBAR_KEY)
    if (stored === 'false') return false
  } catch {
    /* ignore */
  }
  return true
}

const expanded = ref(loadExpanded())
const vocab = inject(ARTICLE_VOCABULARY_KEY)

const itemList = computed(() => vocab?.items.value ?? [])
const itemCount = computed(() => itemList.value.length)
const isLoading = computed(() => vocab?.loading.value ?? false)

watch(expanded, (value) => {
  try {
    localStorage.setItem(VOCAB_SIDEBAR_KEY, value ? 'true' : 'false')
  } catch {
    /* ignore */
  }
})

function toggleExpanded() {
  expanded.value = !expanded.value
}

function displayIpa(item: ArticleVocabularyItem): string {
  const ipa = item.ipa?.trim() ?? ''
  if (!ipa) return '—'
  if (ipa.startsWith('/') || ipa.startsWith('[')) return ipa
  return `/${ipa}/`
}

function displayMeaning(item: ArticleVocabularyItem): string {
  return item.definition_cn?.trim() || '暂无释义'
}

function speakItem(item: ArticleVocabularyItem) {
  playWordPronunciation(item.word)
}
</script>

<template>
  <div class="hidden lg:block relative shrink-0 min-h-0 self-stretch">
    <button
      type="button"
      class="absolute top-1/2 z-20 left-0 -translate-x-full -translate-y-1/2 flex h-10 w-5 items-center justify-center rounded-l-md border border-r-0 border-black/10 dark:border-white/10 bg-card text-neutral-400 hover:text-ink-soft shadow-sm transition-colors"
      :aria-label="expanded ? '隐藏生词本' : '显示生词本'"
      :aria-expanded="expanded"
      @click="toggleExpanded"
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="14"
        height="14"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        aria-hidden="true"
      >
        <path v-if="expanded" d="m9 18 6-6-6-6" />
        <path v-else d="m15 18-6-6 6-6" />
      </svg>
    </button>

    <aside
      class="flex flex-col h-full min-h-0 border-l border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 overflow-hidden transition-[width] duration-200 ease-out"
      :class="expanded ? 'w-64 xl:w-72' : 'w-0 border-l-0'"
    >
      <div class="w-64 xl:w-72 flex flex-col h-full min-h-0" :class="expanded ? '' : 'invisible'">
        <div class="shrink-0 px-4 py-3 border-b border-black/5 dark:border-white/10">
          <h2 class="text-sm font-semibold text-neutral-900 dark:text-neutral-100">本篇生词本</h2>
          <p class="text-xs text-neutral-500 mt-0.5">{{ itemCount }} 个词汇</p>
        </div>

        <div v-if="!vocab" class="flex-1 flex items-center justify-center px-4 text-sm text-neutral-400">
          加载中…
        </div>
        <div v-else-if="isLoading" class="flex-1 flex items-center justify-center text-sm text-neutral-400">
          加载中…
        </div>
        <div v-else-if="!itemCount" class="flex-1 flex items-center justify-center px-4 text-center">
          <p class="text-sm text-neutral-400 leading-relaxed">
            悬停单词并点击收藏，<br />或从词卡加入生词本
          </p>
        </div>
        <ul
          v-else
          class="flex-1 min-h-0 overflow-y-auto overscroll-contain divide-y divide-black/5 dark:divide-white/10 reading-scroll-hide"
        >
          <li
            v-for="item in itemList"
            :key="item.entry_id"
            class="px-4 py-3 hover:bg-neutral-50 dark:hover:bg-neutral-800/50 transition-colors group"
          >
            <div class="flex items-start justify-between gap-2">
              <div class="min-w-0 flex-1">
                <p class="font-medium text-sm text-neutral-900 dark:text-neutral-100 truncate">{{ item.word }}</p>
                <div v-if="asExamTagList(item.exam_tags).length" class="flex flex-wrap gap-1 mt-1">
                  <span
                    v-for="tag in formatExamTags(item.exam_tags)"
                    :key="tag.key"
                    class="text-[10px] leading-none px-1.5 py-0.5 rounded font-medium"
                    :class="examTagClass(tag.key)"
                  >
                    {{ tag.label }}
                  </span>
                </div>
                <p class="text-xs font-mono text-neutral-500 mt-1.5">{{ displayIpa(item) }}</p>
                <p class="text-xs text-neutral-600 dark:text-neutral-300 mt-0.5 leading-snug line-clamp-3">
                  {{ displayMeaning(item) }}
                </p>
              </div>
              <div class="flex flex-col gap-1 shrink-0">
                <button
                  type="button"
                  class="p-1 rounded text-neutral-300 hover:text-amber-500 opacity-0 group-hover:opacity-100 transition-all"
                  aria-label="朗读"
                  @click="speakItem(item)"
                >
                  <AppIcon name="volume-up" :size="14" />
                </button>
                <button
                  type="button"
                  class="p-1 rounded text-neutral-300 hover:text-red-500 opacity-0 group-hover:opacity-100 transition-all"
                  aria-label="移出生词本"
                  @click="vocab?.remove(item.entry_id)"
                >
                  <AppIcon name="close" :size="14" />
                </button>
              </div>
            </div>
          </li>
        </ul>
      </div>
    </aside>
  </div>
</template>
