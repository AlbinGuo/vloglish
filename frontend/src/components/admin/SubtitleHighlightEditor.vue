<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { fetchWordLookup } from '@/composables/useWordLookupCache'
import { firstChineseDefinition } from '@/utils/entryDisplay'
import {
  HIGHLIGHT_TYPE_OPTIONS,
  applyHighlightToRange,
  clearHighlightAt,
  countHighlights,
  parseEnglishHtmlTokens,
  plainFromEnglishHtml,
  resyncTokensPreservingHighlights,
  tokensToEnglishHtml,
  type HighlightEditToken,
  type HighlightTypeKey,
} from '@/utils/subtitleHighlightEdit'

const props = defineProps<{
  english: string
  modelValue: string
}>()

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const tokens = ref<HighlightEditToken[]>([])
const selectStart = ref<number | null>(null)
const selectEnd = ref<number | null>(null)
const pickType = ref<HighlightTypeKey>('a')
const glossInput = ref('')
const lookingUp = ref(false)
const syncing = ref(false)

const highlightCount = computed(() => countHighlights(tokens.value))

const selectionLabel = computed(() => {
  if (selectStart.value == null) return ''
  const start = Math.min(selectStart.value, selectEnd.value ?? selectStart.value)
  const end = Math.max(selectStart.value, selectEnd.value ?? selectStart.value)
  return tokens.value
    .slice(start, end + 1)
    .map((t) => t.text)
    .join(' ')
})

function commitHtml() {
  syncing.value = true
  emit('update:modelValue', tokensToEnglishHtml(tokens.value))
  queueMicrotask(() => {
    syncing.value = false
  })
}

function loadFromProps() {
  const english = (props.english || '').trim()
  const html = props.modelValue || ''
  const plain = plainFromEnglishHtml(html)
  if (html && plain && english && plain !== english.replace(/\s+/g, ' ').trim()) {
    tokens.value = resyncTokensPreservingHighlights(english, parseEnglishHtmlTokens(html, english))
  } else {
    tokens.value = parseEnglishHtmlTokens(html, english)
  }
  selectStart.value = null
  selectEnd.value = null
  glossInput.value = ''
}

watch(
  () => [props.english, props.modelValue] as const,
  () => {
    if (syncing.value) return
    loadFromProps()
  },
  { immediate: true },
)

function onTokenClick(index: number, event: MouseEvent) {
  if (event.shiftKey && selectStart.value != null) {
    selectEnd.value = index
    return
  }
  if (selectStart.value === index && selectEnd.value == null) {
    selectStart.value = null
    glossInput.value = ''
    return
  }
  selectStart.value = index
  selectEnd.value = null
  const token = tokens.value[index]
  if (token?.highlight) {
    pickType.value = token.highlight
    glossInput.value = token.gloss
  } else {
    glossInput.value = ''
  }
}

function isSelected(index: number): boolean {
  if (selectStart.value == null) return false
  const start = Math.min(selectStart.value, selectEnd.value ?? selectStart.value)
  const end = Math.max(selectStart.value, selectEnd.value ?? selectStart.value)
  return index >= start && index <= end
}

function tokenClass(token: HighlightEditToken, index: number): string {
  const base =
    'inline-flex items-center gap-1 px-1.5 py-0.5 rounded text-[13px] border cursor-pointer select-none transition-colors'
  const selected = isSelected(index)
    ? 'ring-2 ring-amber-400 ring-offset-1'
    : ''
  if (token.highlight) {
    const colors: Record<string, string> = {
      a: 'bg-amber-50 border-amber-200 text-amber-900',
      d: 'bg-violet-50 border-violet-200 text-violet-900',
      i: 'bg-cyan-50 border-cyan-200 text-cyan-900',
      c: 'bg-emerald-50 border-emerald-200 text-emerald-900',
      l: 'bg-pink-50 border-pink-200 text-pink-900',
      f: 'bg-lime-50 border-lime-200 text-lime-900',
    }
    return `${base} ${colors[token.highlight] || 'bg-neutral-50 border-neutral-200'} ${selected}`
  }
  return `${base} bg-white border-black/10 text-neutral-800 hover:border-black/25 ${selected}`
}

function applyHighlight() {
  if (selectStart.value == null) return
  const start = Math.min(selectStart.value, selectEnd.value ?? selectStart.value)
  const end = Math.max(selectStart.value, selectEnd.value ?? selectStart.value)
  tokens.value = applyHighlightToRange(tokens.value, start, end, pickType.value, glossInput.value)
  selectStart.value = start
  selectEnd.value = null
  commitHtml()
}

async function lookupGloss() {
  const word = selectionLabel.value.trim()
  if (!word) return
  lookingUp.value = true
  try {
    const isPhrase = /\s/.test(word)
    const entry = await fetchWordLookup(word, isPhrase ? 2 : 1, props.english)
    const cn = entry ? firstChineseDefinition(entry) : ''
    if (cn) glossInput.value = cn
  } finally {
    lookingUp.value = false
  }
}

function clearSelected() {
  if (selectStart.value == null) return
  const start = Math.min(selectStart.value, selectEnd.value ?? selectStart.value)
  const end = Math.max(selectStart.value, selectEnd.value ?? selectStart.value)
  // 从后往前清，避免索引错位
  let next = tokens.value
  for (let i = end; i >= start; i--) {
    next = clearHighlightAt(next, i)
  }
  tokens.value = next
  selectStart.value = null
  selectEnd.value = null
  glossInput.value = ''
  commitHtml()
}

function clearAll() {
  tokens.value = tokens.value.flatMap((token) => {
    if (!token.highlight && !token.gloss) return [token]
    if (token.phrase || /\s/.test(token.text)) {
      return token.text.split(/\s+/).filter(Boolean).map((text) => ({
        text,
        highlight: null as HighlightTypeKey | null,
        gloss: '',
        phrase: false,
      }))
    }
    return [{ ...token, highlight: null, gloss: '', phrase: false }]
  })
  selectStart.value = null
  selectEnd.value = null
  glossInput.value = ''
  commitHtml()
}
</script>

<template>
  <div class="rounded-lg border border-dashed border-amber-200/80 bg-amber-50/40 p-2.5 space-y-2">
    <div class="flex items-center justify-between gap-2 flex-wrap">
      <p class="text-xs text-neutral-600">
        点击选词，Shift+点击选范围；设类型与翻译后点「应用」
        <span v-if="highlightCount" class="text-amber-700">· 已标 {{ highlightCount }} 处</span>
      </p>
      <button
        v-if="highlightCount"
        type="button"
        class="text-[11px] text-neutral-500 hover:text-red-600"
        @click="clearAll"
      >
        清除全部高亮
      </button>
    </div>

    <div v-if="!tokens.length" class="text-xs text-neutral-400 py-1">请先填写英文字幕</div>
    <div v-else class="flex flex-wrap gap-1">
      <button
        v-for="(token, index) in tokens"
        :key="`${index}-${token.text}`"
        type="button"
        :class="tokenClass(token, index)"
        :title="token.gloss || undefined"
        @click="onTokenClick(index, $event)"
      >
        <span>{{ token.text }}</span>
        <span v-if="token.gloss" class="text-[10px] opacity-70 max-w-[6rem] truncate">{{ token.gloss }}</span>
      </button>
    </div>

    <div
      v-if="selectStart != null"
      class="flex flex-wrap items-end gap-2 pt-1 border-t border-amber-200/60"
    >
      <div class="min-w-0">
        <p class="text-[11px] text-neutral-500 mb-1">
          已选：<span class="font-medium text-neutral-800">{{ selectionLabel }}</span>
        </p>
        <div class="flex flex-wrap gap-1">
          <button
            v-for="opt in HIGHLIGHT_TYPE_OPTIONS"
            :key="opt.key"
            type="button"
            class="px-2 py-0.5 rounded-full text-[11px] border transition-colors"
            :class="
              pickType === opt.key
                ? 'bg-neutral-900 text-white border-neutral-900'
                : 'bg-white text-neutral-600 border-black/10 hover:border-black/25'
            "
            :title="opt.hint"
            @click="pickType = opt.key"
          >
            {{ opt.label }}
          </button>
        </div>
      </div>

      <div class="flex-1 min-w-[12rem]">
        <label class="block text-[11px] text-neutral-500 mb-0.5">中文翻译（悬停显示）</label>
        <div class="flex gap-1">
          <input
            v-model="glossInput"
            type="text"
            class="flex-1 min-w-0 rounded border border-black/10 px-2 py-1 text-xs bg-white"
            placeholder="如：寻找；指望"
            @keydown.enter.prevent="applyHighlight"
          />
          <button
            type="button"
            class="shrink-0 px-2 py-1 rounded border border-black/10 text-[11px] bg-white hover:bg-neutral-50 disabled:opacity-50"
            :disabled="lookingUp || !selectionLabel"
            @click="lookupGloss"
          >
            {{ lookingUp ? '…' : '查词典' }}
          </button>
        </div>
      </div>

      <div class="flex gap-1.5">
        <button
          type="button"
          class="px-2.5 py-1 rounded bg-amber-600 text-white text-xs hover:bg-amber-700"
          @click="applyHighlight"
        >
          应用
        </button>
        <button
          type="button"
          class="px-2.5 py-1 rounded border border-black/10 text-xs bg-white hover:bg-neutral-50"
          @click="clearSelected"
        >
          取消高亮
        </button>
      </div>
    </div>
  </div>
</template>
