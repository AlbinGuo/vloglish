<script setup lang="ts">
import { computed } from 'vue'
import type { VocabSummaryGroup, VocabSummaryItem } from '@/utils/vocabSummary'
import {
  countVocabSummaryItems,
  vocabGroupTagClass,
  vocabLevelTagClass,
} from '@/utils/vocabSummary'

const props = defineProps<{
  groups: VocabSummaryGroup[]
}>()

const total = computed(() => countVocabSummaryItems(props.groups))

type FlatItem = {
  index: number
  groupTitle: string
  item: VocabSummaryItem
}

const flatItems = computed<FlatItem[]>(() => {
  const rows: FlatItem[] = []
  let n = 0
  for (const group of props.groups) {
    for (const item of group.items) {
      n += 1
      rows.push({ index: n, groupTitle: group.title, item })
    }
  }
  return rows
})

function tagLabel(row: FlatItem): string {
  return (row.item.level || '').trim() || row.groupTitle
}

function tagClass(row: FlatItem): string {
  const level = (row.item.level || '').trim()
  if (level) return vocabLevelTagClass(level)
  return vocabGroupTagClass(row.groupTitle)
}
</script>

<template>
  <div class="reading-scroll-hide flex-1 min-h-0 overflow-y-auto overscroll-contain px-3 py-2 lg:px-4 lg:py-3">
    <p v-if="!groups.length" class="py-16 text-center text-sm text-neutral-400 px-4">
      本集暂无词汇与表达汇总<br />
      <span class="text-xs mt-2 inline-block leading-relaxed">
        请到管理端本集编辑页确认「词汇与表达汇总」保存后仍有内容，然后强制刷新本页（Ctrl+F5）。
      </span>
    </p>
    <div v-else class="space-y-3">
      <p class="text-xs text-neutral-400">共 {{ total }} 条</p>
      <ul class="space-y-3">
        <li
          v-for="row in flatItems"
          :key="`${row.index}-${row.item.en}`"
          class="rounded-xl px-3.5 py-3 bg-white dark:bg-neutral-900/60 border border-black/[0.04] dark:border-white/[0.06]"
        >
          <div class="flex items-start gap-2.5">
            <span
              class="shrink-0 mt-0.5 w-6 h-6 rounded-md bg-neutral-100 dark:bg-neutral-800 text-xs font-semibold text-neutral-500 dark:text-neutral-400 inline-flex items-center justify-center tabular-nums"
            >
              {{ row.index }}
            </span>
            <div class="min-w-0 flex-1 space-y-1.5">
              <div class="flex flex-wrap items-center gap-2">
                <p class="text-[15px] leading-snug text-neutral-900 dark:text-neutral-50 font-medium">
                  {{ row.item.en }}
                </p>
                <span
                  class="shrink-0 inline-flex items-center px-1.5 py-0.5 rounded text-[11px] font-medium leading-none"
                  :class="tagClass(row)"
                >
                  {{ tagLabel(row) }}
                </span>
              </div>
              <p
                v-if="row.item.note"
                class="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300"
              >
                <span class="text-neutral-400 dark:text-neutral-500">剧中含义：</span>{{ row.item.note }}
              </p>
              <p
                v-if="row.item.example"
                class="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300"
              >
                <span class="text-neutral-400 dark:text-neutral-500">例句：</span>{{ row.item.example }}
              </p>
              <p
                v-if="row.item.zh"
                class="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300"
              >
                <span class="text-neutral-400 dark:text-neutral-500">释义：</span>{{ row.item.zh }}
              </p>
            </div>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>
