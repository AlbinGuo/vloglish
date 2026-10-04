<script setup lang="ts">
import { computed } from 'vue'
import type { AudienceNote } from '@/types'

const props = defineProps<{
  notes: AudienceNote[]
}>()

const emit = defineEmits<{
  seek: [seconds: number]
}>()

const KIND_LABEL: Record<string, string> = {
  timestamp: '片中反应',
  culture: '背景补充',
  opinion: '观众看法',
  uploader: '作者回复',
}

const items = computed(() =>
  [...(props.notes || [])].sort((a, b) => (a.sort_order ?? 0) - (b.sort_order ?? 0)),
)

function kindLabel(kind?: string) {
  return KIND_LABEL[kind || ''] || '观众看法'
}

function formatTime(sec?: number | null) {
  if (sec == null || !Number.isFinite(sec) || sec < 0) return ''
  const total = Math.floor(sec)
  const h = Math.floor(total / 3600)
  const m = Math.floor((total % 3600) / 60)
  const s = total % 60
  if (h > 0) return `${h}:${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`
  return `${m}:${String(s).padStart(2, '0')}`
}

function escapeHtml(text: string) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
}

function escapeRegExp(text: string) {
  return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

function tokenizeEnglish(english: string, phrases: { en: string }[]) {
  type Part = { text: string; phrase?: boolean }
  let parts: Part[] = [{ text: english || '' }]
  const sorted = phrases
    .map((p) => (p.en || '').trim())
    .filter(Boolean)
    .sort((a, b) => b.length - a.length)
  for (const phrase of sorted) {
    const next: Part[] = []
    const re = new RegExp(escapeRegExp(phrase), 'ig')
    for (const part of parts) {
      if (part.phrase) {
        next.push(part)
        continue
      }
      let last = 0
      let match: RegExpExecArray | null
      re.lastIndex = 0
      const text = part.text
      while ((match = re.exec(text))) {
        if (match.index > last) next.push({ text: text.slice(last, match.index) })
        next.push({ text: match[0], phrase: true })
        last = match.index + match[0].length
      }
      if (last < text.length) next.push({ text: text.slice(last) })
    }
    parts = next
  }
  return parts
    .map((part) => {
      const inner = escapeHtml(part.text).replace(
        /[A-Za-z][A-Za-z'-]*/g,
        (word) => `<span>${word}</span>`,
      )
      if (part.phrase) return `<span class="phrase-token">${inner}</span>`
      return inner
    })
    .join('')
    .replace(/\n/g, '<br>')
}
</script>

<template>
  <div class="flex-1 min-h-0 overflow-y-auto overscroll-contain px-4 py-4 sm:px-6 sm:py-5">
    <div class="max-w-3xl mx-auto space-y-4">
      <div class="space-y-1">
        <h2 class="text-sm font-semibold text-neutral-800 dark:text-neutral-100">观众怎么说</h2>
        <p class="text-xs text-neutral-500 dark:text-neutral-400 leading-relaxed">
          精选真实观众反应，当片后短阅读。点词可查，带时间的可跳回视频。
        </p>
      </div>

      <article
        v-for="note in items"
        :key="note.id"
        class="rounded-2xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-800/60 p-4 sm:p-5 space-y-2.5"
      >
        <div class="flex flex-wrap items-center gap-2 text-[11px]">
          <span
            class="px-1.5 py-0.5 rounded-full bg-neutral-100 text-neutral-600 dark:bg-neutral-700 dark:text-neutral-200"
          >
            {{ kindLabel(note.kind) }}
          </span>
          <button
            v-if="note.timestamp_sec != null"
            type="button"
            class="px-1.5 py-0.5 rounded-full bg-teal-50 text-teal-700 dark:bg-teal-950/50 dark:text-teal-200"
            @click="emit('seek', Number(note.timestamp_sec))"
          >
            {{ formatTime(note.timestamp_sec) }} 跳到这里
          </button>
          <span
            v-if="(note.like_count || 0) > 0"
            class="ml-auto text-neutral-400 dark:text-neutral-500"
          >
            {{ note.like_count }} 人觉得有用
          </span>
        </div>

        <p
          class="subtitle-english text-[15px] sm:text-base leading-relaxed text-neutral-900 dark:text-neutral-100"
          v-html="tokenizeEnglish(note.english, note.phrases || [])"
        />
        <p
          v-if="note.chinese"
          class="text-sm text-neutral-500 dark:text-neutral-400 leading-relaxed"
        >
          {{ note.chinese }}
        </p>
        <p
          v-if="note.phrases?.length"
          class="text-xs text-neutral-500 dark:text-neutral-400 leading-relaxed"
        >
          口头说法：
          <span
            v-for="(phrase, idx) in note.phrases"
            :key="`${note.id}-${phrase.en}-${idx}`"
          >
            <span class="text-neutral-700 dark:text-neutral-200">{{ phrase.en }}</span>
            <span v-if="phrase.zh">（{{ phrase.zh }}）</span>
            <span v-if="idx < (note.phrases?.length || 0) - 1"> · </span>
          </span>
        </p>
      </article>
    </div>
  </div>
</template>
