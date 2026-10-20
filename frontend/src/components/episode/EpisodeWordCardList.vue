<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import type { WordCardExamGroup, WordCardItem } from '@/composables/useEpisodeWordCards'
import { examTagClass } from '@/utils/examTags'
import { playWordPronunciation } from '@/utils/speakWord'
import AppIcon from '@/components/AppIcon.vue'

const props = defineProps<{
  items: WordCardItem[]
  groups?: WordCardExamGroup[]
  loading?: boolean
}>()

const emit = defineEmits<{
  select: [item: WordCardItem]
}>()

const selectedKey = ref('')

const displayGroups = computed(() => {
  if (props.groups?.length) return props.groups
  if (!props.items.length) return [] as WordCardExamGroup[]
  return [
    {
      key: 'ALL',
      label: '全部',
      count: props.items.length,
      items: props.items,
    },
  ]
})

const activeGroup = computed(() => {
  const groups = displayGroups.value
  if (!groups.length) return null
  return groups.find((g) => g.key === selectedKey.value) ?? groups[0]
})

const listItems = computed(() => activeGroup.value?.items ?? [])

watch(
  displayGroups,
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

const typeTagClass: Record<string, string> = {
  核心词汇: 'bg-orange-50 text-orange-600 dark:bg-orange-950/40 dark:text-orange-300',
  单词: 'bg-orange-50 text-orange-600 dark:bg-orange-950/40 dark:text-orange-300',
  短语动词: 'bg-rose-50 text-rose-600 dark:bg-rose-950/40 dark:text-rose-300',
  惯用表达: 'bg-sky-50 text-sky-600 dark:bg-sky-950/40 dark:text-sky-300',
  固定搭配: 'bg-violet-50 text-violet-600 dark:bg-violet-950/40 dark:text-violet-300',
  长难表达: 'bg-fuchsia-50 text-fuchsia-600 dark:bg-fuchsia-950/40 dark:text-fuchsia-300',
  专业词汇: 'bg-blue-50 text-blue-700 dark:bg-blue-950/40 dark:text-blue-300',
  话语标记: 'bg-emerald-50 text-emerald-600 dark:bg-emerald-950/40 dark:text-emerald-300',
  短语: 'bg-sky-50 text-sky-600 dark:bg-sky-950/40 dark:text-sky-300',
}

function tagClass(tag: { key: string; kind: string; label: string }) {
  if (tag.kind === 'exam') {
    const examKey = tag.key.replace(/^exam-/i, '')
    return examTagClass(examKey || tag.label)
  }
  return typeTagClass[tag.label] || 'bg-sunken text-ink-soft'
}

const hlGroupClass: Record<string, string> = {
  'HL-a': 'bg-orange-50 text-orange-700 dark:bg-orange-950/50 dark:text-orange-300',
  'HL-d': 'bg-rose-50 text-rose-700 dark:bg-rose-950/50 dark:text-rose-300',
  'HL-i': 'bg-sky-50 text-info dark:bg-sky-950/50',
  'HL-c': 'bg-violet-50 text-violet-700 dark:bg-violet-950/50 dark:text-violet-300',
  'HL-l': 'bg-fuchsia-50 text-fuchsia-700 dark:bg-fuchsia-950/50 dark:text-fuchsia-300',
  'HL-p': 'bg-blue-50 text-blue-700 dark:bg-blue-950/50 dark:text-blue-300',
  'HL-f': 'bg-emerald-50 text-success dark:bg-emerald-950/50',
}

function tabClass(group: WordCardExamGroup, active: boolean) {
  const color = hlGroupClass[group.key] || examTagClass(group.key)
  if (active) return `${color} ring-1 ring-black/10 dark:ring-white/20`
  return 'bg-sunken text-ink-faint hover:bg-neutral-200/80 dark:hover:bg-neutral-700'
}

function speakItem(item: WordCardItem, event: Event) {
  event.stopPropagation()
  if (item.loading) return
  const pron =
    item.entry?.pronunciations.find((p) => p.is_primary) ?? item.entry?.pronunciations[0]
  playWordPronunciation(item.entry?.headword || item.word, pron?.audio_url)
}
</script>

<template>
  <div class="reading-scroll-hide flex-1 min-h-0 overflow-y-auto overscroll-contain px-3 py-2 lg:px-4 lg:py-3">
    <p v-if="loading && !items.length" class="py-16 text-center text-sm text-neutral-400">加载词卡中…</p>
    <p v-else-if="!items.length" class="py-16 text-center text-sm text-neutral-400">
      本集暂无词卡（需字幕含重点/短语/搭配等高亮标注）
    </p>
    <div v-else class="space-y-3">
      <div class="sticky top-0 z-10 -mx-3 px-3 py-1.5 lg:-mx-4 lg:px-4 bg-neutral-50/95 dark:bg-neutral-950/95 backdrop-blur-sm">
        <div class="flex items-center gap-2">
          <div
            class="flex-1 min-w-0 flex gap-1.5 overflow-x-auto reading-scroll-hide"
            role="tablist"
            aria-label="考试分类"
          >
            <button
              v-for="group in displayGroups"
              :key="group.key"
              type="button"
              role="tab"
              :aria-selected="group.key === activeGroup?.key"
              class="shrink-0 inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium transition-colors"
              :class="tabClass(group, group.key === activeGroup?.key)"
              @click="selectedKey = group.key"
            >
              <span>{{ group.label }}</span>
              <span class="tabular-nums opacity-80">{{ group.count }}</span>
            </button>
          </div>
          <p class="shrink-0 text-xs tabular-nums text-neutral-500 dark:text-neutral-400 whitespace-nowrap">
            {{ activeGroup?.count ?? 0 }} / {{ items.length }} 词
          </p>
        </div>
      </div>

      <ul
        class="rounded-xl border border-line-soft bg-card overflow-hidden divide-y divide-black/5 dark:divide-white/10"
      >
        <li v-for="(item, index) in listItems" :key="`${activeGroup?.key}-${item.word}`">
          <div
            role="button"
            tabindex="0"
            class="w-full flex items-start gap-3 px-3.5 py-3.5 text-left hover:bg-neutral-50 dark:hover:bg-neutral-800/80 transition-colors cursor-pointer"
            @click="emit('select', item)"
            @keydown.enter.prevent="emit('select', item)"
          >
            <span class="w-7 shrink-0 pt-0.5 text-sm text-neutral-400 tabular-nums text-right">
              {{ index + 1 }}
            </span>
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-1.5 min-w-0">
                <span class="text-[15px] font-medium text-neutral-900 dark:text-neutral-100 truncate">
                  {{ item.word }}
                </span>
                <button
                  type="button"
                  class="inline-flex items-center justify-center w-7 h-7 shrink-0 rounded-full text-neutral-400 hover:text-amber-600 hover:bg-amber-50 dark:hover:text-amber-400 dark:hover:bg-amber-950/40 transition-colors disabled:opacity-40 disabled:pointer-events-none"
                  :disabled="item.loading"
                  aria-label="朗读"
                  @click="speakItem(item, $event)"
                >
                  <AppIcon name="volume-up" :size="15" />
                </button>
                <span v-if="item.loading" class="text-[11px] text-neutral-400 shrink-0">…</span>
                <span
                  v-else-if="item.ipa"
                  class="text-xs font-mono text-neutral-500 dark:text-neutral-400 shrink-0 truncate"
                >
                  {{ item.ipa }}
                </span>
              </div>
              <p class="mt-1 text-sm text-neutral-600 dark:text-neutral-300 leading-snug line-clamp-2">
                <template v-if="item.loading">加载释义中…</template>
                <template v-else>{{ item.meaning || '暂无释义' }}</template>
              </p>
              <div
                v-if="!item.loading && item.tags.length"
                class="mt-2 flex flex-wrap items-center gap-1.5"
              >
                <span
                  v-for="tag in item.tags"
                  :key="tag.key"
                  class="text-[11px] px-2 py-0.5 rounded-full font-medium whitespace-nowrap"
                  :class="tagClass(tag)"
                >
                  {{ tag.label }}
                </span>
              </div>
            </div>
            <AppIcon name="chevron-left" class="w-4 h-4 shrink-0 mt-1 text-neutral-300 dark:text-neutral-600" />
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>
