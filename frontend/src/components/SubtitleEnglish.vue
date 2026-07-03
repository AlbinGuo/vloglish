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
  }>(),
  { align: 'left' },
)

const tokens = computed(() => normalizeWordSpacing(tokenizeSubtitleHtml(props.html)))
const wordCount = computed(() => countSubtitleWords(props.html))

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

function wordProgressClasses() {
  return [
    ...baseTextClasses('subtitle-english-word-progress'),
    'max-w-full',
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
    v-if="wordHighlight"
    :class="wordProgressClasses()"
    @click="$emit('click', $event)"
  >
    <template v-for="(token, i) in tokens" :key="i">
      <span
        v-if="token.kind === 'word'"
        class="subtitle-word-wrap inline"
        :class="{ 'subtitle-word-read': wordRead(token.wordIndex) }"
        v-html="token.html"
      />
      <span v-else class="whitespace-pre">{{ token.text }}</span>
    </template>
  </span>
  <span v-else :class="textClasses()" v-html="html" @click="$emit('click', $event)" />
</template>
