<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
import type { VocabSummaryGroup, VocabSummaryItem } from '@/utils/vocabSummary'
import {
  countVocabSummaryItems,
  vocabGroupTagClass,
  vocabLevelTagClass,
} from '@/utils/vocabSummary'

const props = defineProps<{
  groups: VocabSummaryGroup[]
}>()

const selectedKey = ref('')
const tabListRef = ref<HTMLElement | null>(null)

const total = computed(() => countVocabSummaryItems(props.groups))

const tabGroups = computed(() =>
  props.groups
    .map((g, i) => ({
      key: `${i}-${g.title}`,
      title: g.title,
      count: g.items.length,
      items: g.items,
    }))
    .filter((g) => g.count > 0),
)

const activeGroup = computed(() => {
  const groups = tabGroups.value
  if (!groups.length) return null
  return groups.find((g) => g.key === selectedKey.value) ?? groups[0]
})

const listItems = computed(() => activeGroup.value?.items ?? [])

watch(
  tabGroups,
  (groups) => {
    if (!groups.length) {
      selectedKey.value = ''
      return
    }
    if (!groups.some((g) => g.key === selectedKey.value)) {
      selectedKey.value = groups[0].key
    }
  },
  { immediate: true },
)

watch(selectedKey, () => {
  void nextTick(() => scrollActiveTabIntoView())
})

/** 把选中 Tab 滚到偏左位置，让后面的分类也能露出来 */
function scrollActiveTabIntoView() {
  const container = tabListRef.value
  if (!container || !selectedKey.value) return
  const el = container.querySelector<HTMLElement>(`[data-tab-key="${CSS.escape(selectedKey.value)}"]`)
  if (!el) return

  const cRect = container.getBoundingClientRect()
  const eRect = el.getBoundingClientRect()
  // 选中项靠左约 20%，右侧留出空间给后续分类
  const idealLeft = cRect.left + Math.min(cRect.width * 0.2, 48)
  const delta = eRect.left - idealLeft
  if (Math.abs(delta) < 4) return
  container.scrollBy({ left: delta, behavior: 'smooth' })
}

function selectGroup(key: string) {
  selectedKey.value = key
}

function tabClass(title: string, active: boolean) {
  // 用 border 代替 ring，避免 overflow-x 把描边裁掉
  const color = vocabGroupTagClass(title)
  if (active) {
    return `${color} border border-black/20 dark:border-white/30`
  }
  return `${color} border border-transparent opacity-85 hover:opacity-100`
}

function itemTagLabel(item: VocabSummaryItem): string {
  return (item.level || '').trim() || (activeGroup.value?.title ?? '')
}

function itemTagClass(item: VocabSummaryItem): string {
  const level = (item.level || '').trim()
  if (level) return vocabLevelTagClass(level)
  return vocabGroupTagClass(activeGroup.value?.title || '')
}
</script>

<template>
  <div class="reading-scroll-hide flex-1 min-h-0 overflow-y-auto overscroll-contain px-3 pt-0 pb-2 lg:px-4 lg:pb-3">
    <p v-if="!groups.length" class="py-16 text-center text-sm text-neutral-400 px-4">
      本集暂无词汇与表达汇总<br />
      <span class="text-xs mt-2 inline-block leading-relaxed">
        请到管理端本集编辑页确认「词汇与表达汇总」保存后仍有内容，然后强制刷新本页（Ctrl+F5）。
      </span>
    </p>
    <div v-else class="space-y-2">
      <!-- 紧挨一级「汇总」工具栏：同色底 + 无上边距，避免中间空隙 -->
      <div
        class="sticky top-0 z-10 -mx-3 px-3 py-2 lg:-mx-4 lg:px-4 bg-white dark:bg-neutral-900 border-b border-black/5 dark:border-white/10"
      >
        <div class="flex items-center gap-2 min-h-[28px]">
          <div
            ref="tabListRef"
            class="flex-1 min-w-0 flex items-center gap-1.5 overflow-x-auto reading-scroll-hide scroll-smooth py-0.5"
            role="tablist"
            aria-label="汇总分类"
          >
            <button
              v-for="group in tabGroups"
              :key="group.key"
              type="button"
              role="tab"
              :data-tab-key="group.key"
              :aria-selected="group.key === activeGroup?.key"
              class="shrink-0 inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium transition-colors box-border"
              :class="tabClass(group.title, group.key === activeGroup?.key)"
              @click="selectGroup(group.key)"
            >
              <span>{{ group.title }}</span>
              <span class="tabular-nums opacity-80">{{ group.count }}</span>
            </button>
          </div>
          <p class="shrink-0 text-xs tabular-nums text-neutral-500 dark:text-neutral-400 whitespace-nowrap">
            {{ activeGroup?.count ?? 0 }} / {{ total }} 条
          </p>
        </div>
      </div>

      <ul class="space-y-3 pt-1">
        <li
          v-for="(item, index) in listItems"
          :key="`${activeGroup?.key}-${item.en}-${index}`"
          class="rounded-xl px-3.5 py-3 bg-white dark:bg-neutral-900/60 border border-black/[0.04] dark:border-white/[0.06]"
        >
          <div class="flex items-start gap-2.5">
            <span
              class="shrink-0 mt-0.5 w-6 h-6 rounded-md bg-neutral-100 dark:bg-neutral-800 text-xs font-semibold text-neutral-500 dark:text-neutral-400 inline-flex items-center justify-center tabular-nums"
            >
              {{ index + 1 }}
            </span>
            <div class="min-w-0 flex-1 space-y-1.5">
              <div class="flex flex-wrap items-center gap-2">
                <p class="text-[15px] leading-snug text-neutral-900 dark:text-neutral-50 font-medium">
                  {{ item.en }}
                </p>
                <span
                  class="shrink-0 inline-flex items-center px-1.5 py-0.5 rounded text-[11px] font-medium leading-none"
                  :class="itemTagClass(item)"
                >
                  {{ itemTagLabel(item) }}
                </span>
              </div>
              <p
                v-if="item.note"
                class="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300"
              >
                <span class="text-neutral-400 dark:text-neutral-500">剧中含义：</span>{{ item.note }}
              </p>
              <p
                v-if="item.example"
                class="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300"
              >
                <span class="text-neutral-400 dark:text-neutral-500">例句：</span>{{ item.example }}
              </p>
              <p
                v-if="item.zh"
                class="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300"
              >
                <span class="text-neutral-400 dark:text-neutral-500">释义：</span>{{ item.zh }}
              </p>
            </div>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>
