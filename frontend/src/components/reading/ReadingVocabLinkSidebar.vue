<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
import type { VocabSummaryGroup, VocabSummaryItem } from '@/utils/vocabSummary'
import {
  countVocabSummaryItems,
  vocabGroupCardClass,
  vocabGroupTagClass,
  vocabLevelTagClass,
} from '@/utils/vocabSummary'

const props = defineProps<{
  groups: VocabSummaryGroup[]
  activeEn?: string
  /** 段落栏收起时占满分割线右侧剩余宽度 */
  fillRemaining?: boolean
}>()

const emit = defineEmits<{
  select: [item: VocabSummaryItem, groupTitle: string]
}>()

const expanded = ref(true)
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

function toggleExpanded() {
  expanded.value = !expanded.value
}

function scrollActiveTabIntoView() {
  const container = tabListRef.value
  if (!container || !selectedKey.value) return
  const el = container.querySelector<HTMLElement>(`[data-tab-key="${CSS.escape(selectedKey.value)}"]`)
  if (!el) return
  const cRect = container.getBoundingClientRect()
  const eRect = el.getBoundingClientRect()
  const idealLeft = cRect.left + Math.min(cRect.width * 0.2, 48)
  const delta = eRect.left - idealLeft
  if (Math.abs(delta) < 4) return
  container.scrollBy({ left: delta, behavior: 'smooth' })
}

function selectGroup(key: string) {
  selectedKey.value = key
}

function tabClass(title: string, active: boolean) {
  const color = vocabGroupTagClass(title)
  if (active) return `${color} border border-black/20 dark:border-white/30`
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

function isActiveItem(item: VocabSummaryItem): boolean {
  const a = (props.activeEn || '').trim().toLowerCase()
  if (!a) return false
  return item.en.trim().toLowerCase() === a
}

function onSelect(item: VocabSummaryItem) {
  emit('select', item, activeGroup.value?.title || '')
}

defineExpose({ expanded })
</script>

<template>
  <div
    class="relative min-h-0 self-stretch flex"
    :class="expanded && fillRemaining ? 'flex-1 min-w-0' : 'shrink-0'"
  >
    <aside
      class="flex flex-col h-full min-h-0 border-l border-black/5 dark:border-white/10 bg-neutral-50/80 dark:bg-neutral-950/40 overflow-hidden transition-[width] duration-200 ease-out"
      :class="
        expanded
          ? fillRemaining
            ? 'flex-1 min-w-0 w-auto'
            : 'w-[min(20rem,32vw)]'
          : 'w-10'
      "
    >
      <div
        class="flex flex-col h-full min-h-0"
        :class="expanded ? (fillRemaining ? 'w-full' : 'w-[min(20rem,32vw)]') : 'w-10'"
      >
        <div
          class="shrink-0 flex items-start gap-2 border-b border-black/5 dark:border-white/10"
          :class="expanded ? 'px-3 pt-3 pb-2' : 'px-1 pt-2 pb-2 justify-center'"
        >
          <div v-if="expanded" class="min-w-0 flex-1 pr-1">
            <p class="text-sm font-semibold text-neutral-800 dark:text-neutral-100">词文对照</p>
            <p class="text-xs text-neutral-500 mt-0.5">与「词汇与表达汇总」同组 · {{ total }} 条</p>
          </div>
          <button
            type="button"
            class="shrink-0 flex h-7 w-7 items-center justify-center rounded-md text-neutral-400 hover:text-neutral-700 dark:hover:text-neutral-200 hover:bg-black/5 dark:hover:bg-white/10 transition-colors"
            :class="expanded ? 'mt-0.5 ml-auto' : ''"
            :aria-label="expanded ? '收起词文对照' : '展开词文对照'"
            :aria-expanded="expanded"
            @click="toggleExpanded"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
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
        </div>

        <div
          v-show="expanded"
          class="flex-1 min-h-0 overflow-y-auto overscroll-contain reading-scroll-hide px-3 py-2"
        >
          <p v-if="!groups.length" class="py-12 text-center text-sm text-neutral-400 px-2 leading-relaxed">
            本篇暂无词汇与表达汇总<br />
            <span class="text-xs mt-2 inline-block">请到管理端文章编辑页填写后保存</span>
          </p>

          <template v-else>
            <div
              ref="tabListRef"
              class="flex items-center gap-1.5 overflow-x-auto reading-scroll-hide scroll-smooth py-1 mb-2"
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

            <ul class="space-y-2 pb-3">
              <li
                v-for="(item, index) in activeGroup?.items ?? []"
                :key="`${activeGroup?.key}-${item.en}-${index}`"
              >
                <button
                  type="button"
                  class="w-full text-left rounded-xl border px-3 py-2.5 transition-shadow hover:shadow-sm"
                  :class="[
                    vocabGroupCardClass(activeGroup?.title || ''),
                    isActiveItem(item) ? 'ring-2 ring-neutral-800/25 dark:ring-white/30' : '',
                  ]"
                  @click="onSelect(item)"
                >
                  <div class="flex items-start gap-2">
                    <span
                      class="shrink-0 mt-0.5 w-5 h-5 rounded text-[11px] font-semibold tabular-nums inline-flex items-center justify-center bg-white/70 dark:bg-black/20 text-neutral-600 dark:text-neutral-300"
                    >
                      {{ index + 1 }}
                    </span>
                    <div class="min-w-0 flex-1 space-y-1">
                      <div class="flex flex-wrap items-center gap-1.5">
                        <p class="text-sm font-semibold text-neutral-900 dark:text-neutral-50 leading-snug">
                          {{ item.en }}
                        </p>
                        <span
                          class="shrink-0 inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-medium leading-none"
                          :class="itemTagClass(item)"
                        >
                          {{ itemTagLabel(item) }}
                        </span>
                      </div>
                      <p
                        v-if="item.note || item.zh"
                        class="text-xs leading-relaxed text-neutral-700 dark:text-neutral-300"
                      >
                        {{ item.note || item.zh }}
                      </p>
                    </div>
                  </div>
                </button>
              </li>
            </ul>
          </template>
        </div>
      </div>
    </aside>
  </div>
</template>
