<script setup lang="ts">
import { computed, nextTick, reactive, ref, watch } from 'vue'
import { saveVocabulary } from '@/api/learning'
import type { VocabSummaryGroup, VocabSummaryItem } from '@/utils/vocabSummary'
import {
  countVocabSummaryItems,
  vocabGroupTagClass,
  vocabLevelTagClass,
} from '@/utils/vocabSummary'

const props = withDefaults(
  defineProps<{
    groups: VocabSummaryGroup[]
    videoId?: string
    canSave?: boolean
  }>(),
  {
    videoId: '',
    canSave: false,
  },
)

const selectedKey = ref('')
const tabListRef = ref<HTMLElement | null>(null)
const savedKeys = ref(new Set<string>())
const rowState = reactive<Record<string, { saving: boolean; tip: string; tipTone: 'ok' | 'err' }>>({})

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

function itemKey(item: VocabSummaryItem, index: number) {
  return `${activeGroup.value?.key || ''}-${item.en}-${index}`
}

function ensureRow(key: string) {
  if (!rowState[key]) rowState[key] = { saving: false, tip: '', tipTone: 'ok' }
  return rowState[key]!
}

function isPhrase(en: string) {
  return /\s/.test(en.trim()) || /[^A-Za-z0-9']/i.test(en.replace(/[()]/g, ''))
}

function flashTip(key: string, message: string, tone: 'ok' | 'err' = 'ok', persistMs = 1800) {
  const row = ensureRow(key)
  row.tip = message
  row.tipTone = tone
  if (persistMs <= 0) return
  window.setTimeout(() => {
    if (rowState[key]?.tip === message) rowState[key]!.tip = ''
  }, persistMs)
}

async function onAdd(item: VocabSummaryItem, index: number) {
  if (!props.canSave) return
  const key = itemKey(item, index)
  const row = ensureRow(key)
  const word = item.en.trim()
  const wordKey = word.toLowerCase()
  if (!word) return
  if (savedKeys.value.has(wordKey) || row.saving) {
    flashTip(key, '已在生词本', 'ok')
    return
  }

  // 乐观 UI：立刻标绿 +「加入中…」，不再先走查词（DeepSeek）
  row.saving = true
  savedKeys.value.add(wordKey)
  flashTip(key, '加入中…', 'ok', 0)
  try {
    const tokenType: 1 | 2 = isPhrase(word) ? 2 : 1
    await saveVocabulary({
      word,
      token_type: tokenType,
      video_id: props.videoId || undefined,
      source_type: 'vocab',
    })
    try {
      const { useVocabularyStore } = await import('@/stores/vocabulary')
      useVocabularyStore().invalidate()
    } catch {
      /* ignore */
    }
    flashTip(key, '已加入生词本', 'ok')
  } catch {
    savedKeys.value.delete(wordKey)
    flashTip(key, '收藏失败', 'err')
  } finally {
    row.saving = false
  }
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
          :key="itemKey(item, index)"
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
                <span class="text-neutral-400 dark:text-neutral-500">含义：</span>{{ item.note }}
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
              <p
                v-if="rowState[itemKey(item, index)]?.tip"
                class="text-xs font-medium"
                :class="
                  rowState[itemKey(item, index)]?.tipTone === 'err'
                    ? 'text-red-600 dark:text-red-400'
                    : 'text-emerald-600 dark:text-emerald-400'
                "
              >
                {{ rowState[itemKey(item, index)]?.tip }}
              </p>
            </div>

            <button
              v-if="canSave"
              type="button"
              class="shrink-0 mt-0.5 inline-flex h-8 w-8 items-center justify-center rounded-full border transition-colors"
              :class="
                savedKeys.has(item.en.trim().toLowerCase())
                  ? 'border-emerald-500/40 bg-emerald-500 text-white'
                  : 'border-black/10 dark:border-white/15 bg-neutral-50 dark:bg-neutral-800 text-neutral-700 dark:text-neutral-200 hover:bg-neutral-100 dark:hover:bg-neutral-700'
              "
              :disabled="rowState[itemKey(item, index)]?.saving"
              :title="savedKeys.has(item.en.trim().toLowerCase()) ? '已在生词本' : '加入生词本'"
              :aria-label="
                savedKeys.has(item.en.trim().toLowerCase())
                  ? '已在生词本'
                  : `将 ${item.en} 加入生词本`
              "
              @click.stop="onAdd(item, index)"
            >
              <svg
                v-if="savedKeys.has(item.en.trim().toLowerCase())"
                class="h-3.5 w-3.5"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  fill-rule="evenodd"
                  d="M16.704 5.29a1 1 0 0 1 .006 1.414l-7.25 7.3a1 1 0 0 1-1.432.012l-3.25-3.2a1 1 0 1 1 1.4-1.426l2.53 2.49 6.54-6.58a1 1 0 0 1 1.456-.01Z"
                  clip-rule="evenodd"
                />
              </svg>
              <svg
                v-else
                class="h-3.5 w-3.5"
                viewBox="0 0 20 20"
                fill="none"
                stroke="currentColor"
                stroke-width="2.2"
                aria-hidden="true"
              >
                <path stroke-linecap="round" d="M10 5v10M5 10h10" />
              </svg>
            </button>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>
