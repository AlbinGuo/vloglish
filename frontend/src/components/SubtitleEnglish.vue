<script setup lang="ts">
import { computed } from 'vue'
import {
  countSubtitleWords,
  isSubtitleWordRead,
  tokenizeSubtitleHtml,
  type SubtitleWordHighlight,
} from '@/utils/subtitleWordProgress'

defineEmits<{ click: [event: MouseEvent] }>()

const props = withDefaults(
  defineProps<{
    html: string
    active?: boolean
    large?: boolean
    align?: 'left' | 'center'
    /** 设置后按词逐个点亮 #0fbb35 */
    wordHighlight?: SubtitleWordHighlight
    /** 生词回看：短暂高亮匹配词 */
    emphasizeWord?: string
  }>(),
  { align: 'left' },
)

const tokens = computed(() => normalizeWordSpacing(tokenizeSubtitleHtml(props.html)))
const wordCount = computed(() => countSubtitleWords(props.html))
const useTokenRender = computed(() => Boolean(props.wordHighlight || props.emphasizeWord?.trim()))

const emphasizeParts = computed(() => {
  const raw = (props.emphasizeWord || '').trim().toLowerCase()
  if (!raw) return [] as string[]
  return raw
    .split(/\s+/)
    .map((w) => w.replace(/[^a-z0-9'-]/gi, ''))
    .filter(Boolean)
})

function normalizeWordSpacing(items: ReturnType<typeof tokenizeSubtitleHtml>) {
  const out: typeof items = []
  for (let i = 0; i < items.length; i++) {
    const token = items[i]
    out.push(token)
    const next = items[i + 1]
    if (token.kind === 'word' && next?.kind === 'word') {
      out.push({ kind: 'space', text: ' ' })
    }
  }
  return out
}

function plainWord(html: string) {
  return html
    .replace(/<[^>]+>/g, '')
    .replace(/&nbsp;/gi, ' ')
    .replace(/&amp;/gi, '&')
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9'-]/gi, '')
}

function isEmphasized(tokenHtml: string) {
  const parts = emphasizeParts.value
  if (!parts.length) return false
  const word = plainWord(tokenHtml)
  return Boolean(word && parts.includes(word))
}

function baseTextClasses(extra?: string) {
  return [
    'subtitle-english',
    'pointer-events-auto leading-relaxed tracking-wide font-medium',
    props.large ? 'text-xl sm:text-2xl' : 'text-base',
    props.active ? 'subtitle-english--active' : '',
    extra ?? '',
  ]
}

function textClasses(extra?: string) {
  return [
    ...baseTextClasses(extra),
    'flex flex-wrap items-center gap-x-1.5 gap-y-0.5',
    props.align === 'left' ? 'justify-start w-full' : 'justify-center',
  ]
}

/** 回看强调：保持与普通 v-html 字幕相同的自然词距，不要用 flex gap */
function emphasizeClasses() {
  return [
    ...baseTextClasses(),
    'max-w-full min-w-0',
    props.align === 'left' ? 'text-left w-full' : 'text-center w-full',
  ]
}

function wordProgressClasses() {
  return [
    ...baseTextClasses('subtitle-english-word-progress'),
    'max-w-full min-w-0',
    props.align === 'left' ? 'text-left w-full' : 'text-center w-full',
  ]
}

function wordRead(wordIndex: number): boolean {
  const h = props.wordHighlight
  if (!h) return false
  return isSubtitleWordRead(wordIndex, wordCount.value, h.time, h.start, h.end)
}
</script>

<template>
  <span
    v-if="useTokenRender"
    :class="wordHighlight ? wordProgressClasses() : emphasizeClasses()"
    @click="$emit('click', $event)"
  >
    <template v-for="(token, i) in tokens" :key="i">
      <span
        v-if="token.kind === 'word'"
        class="subtitle-word-wrap inline"
        :class="{
          'subtitle-word-read': wordHighlight ? wordRead(token.wordIndex) : false,
          'source-focus-word': isEmphasized(token.html),
        }"
        v-html="token.html"
      />
      <span v-else class="whitespace-pre">{{ token.text }}</span>
    </template>
  </span>
  <span v-else :class="textClasses()" v-html="html" @click="$emit('click', $event)" />
</template>
