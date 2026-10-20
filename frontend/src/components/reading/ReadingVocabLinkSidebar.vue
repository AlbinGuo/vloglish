<script setup lang="ts">
import { computed, inject, nextTick, reactive, ref, watch } from 'vue'
import {
  ARTICLE_VOCABULARY_KEY,
  type ArticleVocabularyContext,
} from '@/composables/useArticleVocabulary'
import { fetchWordLookup } from '@/composables/useWordLookupCache'
import type { VocabSummaryGroup, VocabSummaryItem } from '@/utils/vocabSummary'
import {
  countVocabSummaryItems,
  vocabGroupCardClass,
  vocabGroupTagClass,
  vocabLevelTagClass,
} from '@/utils/vocabSummary'
import AppIcon from '@/components/AppIcon.vue'

const props = withDefaults(
  defineProps<{
    groups: VocabSummaryGroup[]
    activeEn?: string
    /** 段落栏收起时占满分割线右侧剩余宽度 */
    fillRemaining?: boolean
    articleId?: string
    canSave?: boolean
    /** 显式传入，避免仅依赖 inject（HMR / 边界场景会静默失败） */
    vocabulary?: ArticleVocabularyContext | null
  }>(),
  {
    activeEn: '',
    fillRemaining: false,
    articleId: '',
    canSave: false,
    vocabulary: null,
  },
)

const emit = defineEmits<{
  select: [item: VocabSummaryItem, groupTitle: string]
}>()

const injectedVocab = inject(ARTICLE_VOCABULARY_KEY, null)
const articleVocab = computed(() => props.vocabulary ?? injectedVocab)

const expanded = ref(true)
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

watch(
  () => articleVocab.value?.items.value,
  (items) => {
    if (!items?.length) return
    const next = new Set(savedKeys.value)
    for (const row of items) {
      const key = row.word.trim().toLowerCase()
      if (key) next.add(key)
    }
    savedKeys.value = next
  },
  { immediate: true, deep: true },
)

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

function lookupContext(item: VocabSummaryItem) {
  return (item.example || item.note || item.zh || item.en || '').trim()
}

function flashTip(key: string, message: string, tone: 'ok' | 'err' = 'ok') {
  const row = ensureRow(key)
  row.tip = message
  row.tipTone = tone
  window.setTimeout(() => {
    if (rowState[key]?.tip === message) rowState[key]!.tip = ''
  }, 1600)
}

function isSavedWord(en: string) {
  return savedKeys.value.has(en.trim().toLowerCase())
}

async function onAdd(item: VocabSummaryItem, index: number) {
  const key = itemKey(item, index)
  const row = ensureRow(key)
  const wordKey = item.en.trim().toLowerCase()
  if (!wordKey || row.saving) return

  if (!props.canSave) {
    flashTip(key, '请先登录', 'err')
    return
  }
  if (!props.articleId) {
    flashTip(key, '文章未就绪', 'err')
    return
  }
  const vocab = articleVocab.value
  if (!vocab) {
    flashTip(key, '生词本未就绪', 'err')
    return
  }
  if (isSavedWord(item.en)) {
    flashTip(key, '已在生词本', 'ok')
    return
  }

  row.saving = true
  try {
    const tokenType: 1 | 2 = isPhrase(item.en) ? 2 : 1
    const entry = await fetchWordLookup(item.en.trim(), tokenType, lookupContext(item), {
      article_id: props.articleId,
    })
    if (!entry) {
      flashTip(key, '查词失败', 'err')
      return
    }
    // 仅以本篇生词本为准；全局 favorite 不代表已加入本篇
    if (vocab.isSaved(entry.id)) {
      savedKeys.value = new Set(savedKeys.value).add(wordKey)
      flashTip(key, '已在生词本', 'ok')
      return
    }
    const saved = await vocab.toggle(
      { ...entry, favorite: false },
      { tokenType: entry.category === '短语' || entry.category === 'phrase' ? 2 : tokenType },
    )
    if (saved) {
      savedKeys.value = new Set(savedKeys.value).add(wordKey)
      try {
        const { useVocabularyStore } = await import('@/stores/vocabulary')
        useVocabularyStore().invalidate()
      } catch {
        /* ignore */
      }
      flashTip(key, '已加入', 'ok')
    } else {
      flashTip(key, '已移出', 'ok')
    }
  } catch {
    flashTip(key, '加入失败', 'err')
  } finally {
    row.saving = false
  }
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
            <p class="text-xs text-neutral-500 mt-0.5">
              与「词汇与表达汇总」同组 · {{ total }} 条
              <span v-if="canSave" class="text-neutral-400"> · 点 + 加入生词本</span>
            </p>
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

            <ul class="space-y-2 pt-5 pb-3">
              <li
                v-for="(item, index) in activeGroup?.items ?? []"
                :key="itemKey(item, index)"
              >
                <div
                  class="w-full text-left rounded-xl border px-3 py-2.5 transition-shadow hover:shadow-sm"
                  :class="[
                    vocabGroupCardClass(activeGroup?.title || ''),
                    isActiveItem(item) ? 'ring-2 ring-neutral-800/25 dark:ring-white/30' : '',
                  ]"
                >
                  <div class="flex items-start gap-2">
                    <button
                      type="button"
                      class="min-w-0 flex-1 text-left flex items-start gap-2"
                      @click="onSelect(item)"
                    >
                      <span
                        class="shrink-0 mt-0.5 w-5 h-5 rounded text-[11px] font-semibold tabular-nums inline-flex items-center justify-center bg-white/70 dark:bg-black/20 text-neutral-600 dark:text-neutral-300"
                      >
                        {{ index + 1 }}
                      </span>
                      <div class="min-w-0 flex-1 space-y-1">
                        <div class="flex flex-wrap items-center gap-1.5">
                          <p class="reading-vocab-en text-sm font-semibold text-neutral-900 dark:text-neutral-50 leading-snug">
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
                    </button>

                    <div v-if="canSave" class="relative shrink-0 mt-0.5">
                      <span
                        v-if="rowState[itemKey(item, index)]?.tip"
                        class="pointer-events-none absolute left-1/2 bottom-full z-20 mb-1 -translate-x-1/2 whitespace-nowrap rounded-md px-1.5 py-0.5 text-[10px] font-medium shadow-sm animate-[vocabTipIn_0.18s_ease]"
                        :class="
                          rowState[itemKey(item, index)]?.tipTone === 'err'
                            ? 'bg-rose-600 text-white'
                            : 'bg-emerald-600 text-white'
                        "
                        role="status"
                      >
                        {{ rowState[itemKey(item, index)]?.tip }}
                      </span>
                      <button
                        type="button"
                        class="inline-flex h-8 w-8 items-center justify-center rounded-full border transition-colors"
                        :class="
                          isSavedWord(item.en)
                            ? 'border-emerald-500/40 bg-emerald-500 text-white'
                            : 'border-line-strong bg-white/80 dark:bg-neutral-800 text-ink-soft hover:bg-neutral-100 dark:hover:bg-neutral-700'
                        "
                        :disabled="rowState[itemKey(item, index)]?.saving"
                        :title="isSavedWord(item.en) ? '已在生词本' : '加入生词本'"
                        :aria-label="isSavedWord(item.en) ? '已在生词本' : `将 ${item.en} 加入生词本`"
                        @click.stop="onAdd(item, index)"
                      >
                        <AppIcon name="loader-circle" v-if="rowState[itemKey(item, index)]?.saving" class="h-3.5 w-3.5 animate-spin" />
                        <AppIcon name="check-xs" v-else-if="isSavedWord(item.en)" class="h-3.5 w-3.5" />
                        <AppIcon v-else name="plus" class="h-3.5 w-3.5" />
                      </button>
                    </div>
                  </div>
                </div>
              </li>
            </ul>
          </template>
        </div>
      </div>
    </aside>
  </div>
</template>

<style scoped>
@keyframes vocabTipIn {
  from {
    opacity: 0;
    transform: translate(-50%, 4px);
  }
  to {
    opacity: 1;
    transform: translate(-50%, 0);
  }
}
</style>
