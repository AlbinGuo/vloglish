<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
import type { Subtitle } from '@/types'
import {
  dictationWordMatches,
  markDictationSlots,
  splitDictationSlots,
} from '@/utils/dictationCompare'

const LOOP_OPTIONS = [1, 2, 3, 4, 5, 10] as const

const props = defineProps<{
  open: boolean
  subtitle: Subtitle | null
  /** 单句循环次数（播完后再听写） */
  loopCount: number
}>()

const emit = defineEmits<{
  close: []
  replay: []
  next: []
  'update:loopCount': [value: number]
}>()

const STORAGE_HINT = 'teco-dictation-show-reference'

const answers = ref<string[]>([])
const checked = ref(false)
const celebrateNonce = ref(0)
/** 对照字幕默认关闭；开启后显示英文 + 中文 */
const showReference = ref(
  (() => {
    try {
      return localStorage.getItem(STORAGE_HINT) === '1'
    } catch {
      return false
    }
  })(),
)
const inputEls = ref<(HTMLInputElement | null)[]>([])
/** iOS 拼音组字未结束时不要写回 :value / 跳格，否则会强制上屏并跳到下一格 */
const composing = ref(false)

const expected = computed(() => (props.subtitle?.english || '').trim())
const chinese = computed(() => (props.subtitle?.chinese || '').trim())
const expectedWords = computed(() => splitDictationSlots(expected.value))
const wordMarks = computed(() =>
  checked.value ? markDictationSlots(answers.value, expectedWords.value) : [],
)
const isCorrect = computed(
  () =>
    expectedWords.value.length > 0 &&
    expectedWords.value.every((word, i) => dictationWordMatches(answers.value[i] ?? '', word)),
)
const hasAnyInput = computed(() => answers.value.some((w) => w.trim().length > 0))
const normalizedLoopCount = computed(() => {
  const n = props.loopCount
  return n > 0 ? n : 1
})

function setInputRef(el: unknown, index: number) {
  if (!Array.isArray(inputEls.value)) inputEls.value = []
  inputEls.value[index] = (el as HTMLInputElement | null) ?? null
}

function resetAnswers() {
  const n = expectedWords.value.length
  answers.value = Array.from({ length: n }, () => '')
  checked.value = false
  composing.value = false
  inputEls.value = Array.from({ length: n }, () => null)
}

async function focusWord(index: number) {
  await nextTick()
  const el = inputEls.value[index]
  if (!el) return
  el.focus()
  el.select()
}

watch(
  () => [props.open, props.subtitle?.id] as const,
  async ([open]) => {
    if (!open) return
    resetAnswers()
    await focusWord(0)
  },
)

watch(showReference, (on) => {
  try {
    localStorage.setItem(STORAGE_HINT, on ? '1' : '0')
  } catch {
    // ignore
  }
})

function slotWidthCh(expectedWord: string, answer = '') {
  const len = Math.max(expectedWord.length, answer.length, 4)
  return Math.min(22, len + 3)
}

function isImeComposing(event?: Event | KeyboardEvent) {
  if (composing.value) return true
  if (event && 'isComposing' in event && event.isComposing) return true
  return false
}

function commitWordInput(index: number, raw: string, el: HTMLInputElement) {
  const value = /\s/.test(raw) ? raw.replace(/\s+/g, '') : raw
  answers.value[index] = value
  if (el.value !== value) el.value = value
  checked.value = false
}

function onCompositionStart() {
  composing.value = true
}

function onCompositionEnd(index: number, event: CompositionEvent) {
  composing.value = false
  const el = event.target as HTMLInputElement | null
  if (!el) return
  commitWordInput(index, el.value, el)
}

function onWordInput(index: number, event: Event) {
  if (isImeComposing(event)) return
  const el = event.target as HTMLInputElement
  commitWordInput(index, el.value, el)
}

function onWordKeydown(index: number, event: KeyboardEvent) {
  if (isImeComposing(event)) return
  const el = event.target as HTMLInputElement
  if (event.key === ' ' || event.code === 'Space') {
    event.preventDefault()
    if (index < expectedWords.value.length - 1) void focusWord(index + 1)
    return
  }
  if (event.key === 'Backspace' && !answers.value[index] && index > 0) {
    event.preventDefault()
    focusWord(index - 1)
    return
  }
  if (event.key === 'Enter') {
    event.preventDefault()
    if (index >= expectedWords.value.length - 1) onCheck()
    else focusWord(index + 1)
    return
  }
  if (event.key === 'ArrowLeft' && (el.selectionStart ?? 0) === 0 && index > 0) {
    event.preventDefault()
    focusWord(index - 1)
    return
  }
  if (
    event.key === 'ArrowRight' &&
    (el.selectionStart ?? 0) >= el.value.length &&
    index < expectedWords.value.length - 1
  ) {
    event.preventDefault()
    focusWord(index + 1)
  }
}

function onCheck() {
  if (!hasAnyInput.value) return
  checked.value = true
  nextTick(() => {
    if (isCorrect.value) celebrateNonce.value += 1
  })
}

function onClose() {
  emit('close')
}

function onReplay() {
  checked.value = false
  emit('replay')
}

function onNext() {
  emit('next')
}

function onSkip() {
  emit('close')
}

function onLoopCountChange(event: Event) {
  const value = Number((event.target as HTMLSelectElement).value)
  if (!Number.isFinite(value) || value <= 0) return
  emit('update:loopCount', value)
}

function boxClass(index: number) {
  if (!checked.value) {
    return 'border-black/15 dark:border-white/15 focus:border-amber-500 focus:ring-2 focus:ring-amber-500/30'
  }
  return wordMarks.value[index]?.ok
    ? 'border-emerald-500 bg-emerald-50 text-emerald-800 dark:bg-emerald-950/40 dark:text-emerald-300'
    : 'border-red-400 bg-red-50 text-danger dark:bg-red-950/40'
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open && subtitle"
      class="fixed inset-0 z-[290] flex items-end sm:items-center justify-center bg-black/45 p-0 sm:p-4"
      role="dialog"
      aria-modal="true"
      aria-label="单句听写"
      @click.self="onClose"
    >
      <div
        class="w-full max-w-xl rounded-t-2xl sm:rounded-2xl bg-card shadow-2xl border border-line-soft pb-[env(safe-area-inset-bottom)]"
        @click.stop
      >
        <div class="flex justify-center pt-3 pb-1 sm:hidden">
          <div class="w-10 h-1 rounded-full bg-neutral-300 dark:bg-neutral-600" />
        </div>

        <div class="px-4 pt-3 pb-2 flex items-start justify-between gap-3">
          <div class="min-w-0">
            <h2 class="text-sm font-medium">听写本句</h2>
            <p class="text-xs text-neutral-400 mt-0.5">按词填写，空格跳到下一格</p>
          </div>
          <button
            type="button"
            class="text-neutral-400 hover:text-ink-soft text-xl leading-none px-1"
            aria-label="关闭"
            @click="onClose"
          >
            ×
          </button>
        </div>

        <div class="px-4 space-y-3 pb-4">
          <div class="flex flex-wrap items-center gap-x-4 gap-y-2 justify-between">
            <label class="inline-flex items-center gap-1.5 text-xs text-neutral-600 dark:text-neutral-300">
              <span class="shrink-0">循环次数</span>
              <select
                class="rounded-lg border border-line bg-card px-2 py-1 text-xs"
                :value="normalizedLoopCount"
                @change="onLoopCountChange"
              >
                <option v-for="n in LOOP_OPTIONS" :key="n" :value="n">{{ n }} 遍</option>
              </select>
            </label>
            <label class="inline-flex items-center gap-2 text-xs text-neutral-500 cursor-pointer select-none">
              <input v-model="showReference" type="checkbox" class="rounded border-neutral-300" />
              对照字幕
            </label>
            <button
              type="button"
              class="text-xs text-amber-700 dark:text-amber-400 hover:underline"
              @click="onReplay"
            >
              播放 {{ normalizedLoopCount }} 遍
            </button>
          </div>

          <p
            v-if="showReference && chinese"
            class="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed rounded-xl bg-neutral-50 dark:bg-neutral-800/80 px-3 py-2"
          >
            {{ chinese }}
          </p>

          <div
            v-if="expectedWords.length"
            class="flex flex-wrap gap-x-2.5 gap-y-3 content-start rounded-xl bg-neutral-50/80 dark:bg-neutral-950/40 px-3 py-3"
          >
            <div
              v-for="(word, index) in expectedWords"
              :key="`${subtitle.id}-${index}-${word}`"
              class="flex flex-col items-center gap-1"
              :style="{ minWidth: '4.5ch' }"
            >
              <input
                :ref="(el) => setInputRef(el, index)"
                :value="answers[index] ?? ''"
                type="text"
                autocomplete="off"
                autocorrect="off"
                autocapitalize="off"
                spellcheck="false"
                :aria-label="`第 ${index + 1} 个词`"
                class="box-content rounded-lg border bg-white dark:bg-neutral-900 px-2.5 py-2.5 text-base text-center focus:outline-none transition-[width,colors] overflow-visible w-full"
                :class="boxClass(index)"
                :style="{ width: `${slotWidthCh(word, answers[index] ?? '')}ch`, minWidth: '4.5ch' }"
                :readonly="checked"
                @compositionstart="onCompositionStart"
                @compositionend="onCompositionEnd(index, $event)"
                @input="onWordInput(index, $event)"
                @keydown="onWordKeydown(index, $event)"
              />
              <span
                v-if="showReference"
                class="text-[11px] leading-tight text-neutral-500 dark:text-neutral-400 text-center max-w-full break-all px-0.5 select-none"
              >
                {{ word }}
              </span>
            </div>
          </div>
          <p v-else class="text-xs text-neutral-400">本句无可听写单词</p>

          <div
            v-if="checked && isCorrect"
            :key="`ok-${celebrateNonce}`"
            class="dictation-celebrate relative flex flex-col items-center justify-center py-5 overflow-hidden rounded-2xl bg-gradient-to-b from-amber-50 via-orange-50 to-white dark:from-amber-950/50 dark:via-neutral-900 dark:to-neutral-900"
            aria-live="polite"
          >
            <span class="dictation-celebrate__ring" aria-hidden="true" />
            <span class="dictation-celebrate__spark dictation-celebrate__spark--1" aria-hidden="true" />
            <span class="dictation-celebrate__spark dictation-celebrate__spark--2" aria-hidden="true" />
            <span class="dictation-celebrate__spark dictation-celebrate__spark--3" aria-hidden="true" />
            <span class="dictation-celebrate__spark dictation-celebrate__spark--4" aria-hidden="true" />
            <div class="dictation-celebrate__thumb relative z-[1] select-none" aria-hidden="true">👍</div>
            <p class="dictation-celebrate__title relative z-[1] mt-1 text-lg font-semibold text-amber-800 dark:text-amber-200">
              太棒了
            </p>
            <p class="relative z-[1] text-xs text-amber-700/80 dark:text-amber-300/70">听写正确</p>
          </div>

          <div
            v-else-if="checked"
            class="rounded-xl border border-black/5 dark:border-white/10 px-3 py-2.5 space-y-2"
          >
            <p class="text-sm font-medium text-amber-700 dark:text-amber-400">再对一下原文</p>
            <p class="text-xs text-neutral-500 leading-relaxed">原文：{{ expected }}</p>
          </div>

          <div class="flex flex-wrap gap-2 pt-1">
            <button
              v-if="!checked"
              type="button"
              class="flex-1 min-w-[7rem] rounded-xl bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900 px-4 py-2.5 text-sm font-medium disabled:opacity-40"
              :disabled="!hasAnyInput"
              @click="onCheck"
            >
              检查
            </button>
            <button
              v-else
              type="button"
              class="flex-1 min-w-[7rem] rounded-xl bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900 px-4 py-2.5 text-sm font-medium"
              @click="onNext"
            >
              下一句
            </button>
            <button
              type="button"
              class="rounded-xl border border-black/10 dark:border-white/10 px-4 py-2.5 text-sm text-neutral-600 dark:text-neutral-300"
              @click="onSkip"
            >
              跳过
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.dictation-celebrate__thumb {
  font-size: 4.25rem;
  line-height: 1;
  transform-origin: 50% 80%;
  animation: dictation-thumb-pop 0.7s cubic-bezier(0.22, 1.4, 0.36, 1) both;
  filter: drop-shadow(0 10px 18px rgba(245, 158, 11, 0.35));
}

.dictation-celebrate__title {
  animation: dictation-fade-up 0.45s ease-out 0.18s both;
}

.dictation-celebrate__ring {
  position: absolute;
  left: 50%;
  top: 42%;
  width: 5.5rem;
  height: 5.5rem;
  margin-left: -2.75rem;
  margin-top: -2.75rem;
  border-radius: 9999px;
  border: 2px solid rgba(245, 158, 11, 0.45);
  animation: dictation-ring 0.85s ease-out both;
}

.dictation-celebrate__spark {
  position: absolute;
  left: 50%;
  top: 42%;
  width: 0.45rem;
  height: 0.45rem;
  margin-left: -0.225rem;
  margin-top: -0.225rem;
  border-radius: 9999px;
  background: #f59e0b;
  opacity: 0;
  animation: dictation-spark 0.7s ease-out 0.08s both;
}

.dictation-celebrate__spark--1 {
  --dx: -42px;
  --dy: -28px;
  background: #f59e0b;
}
.dictation-celebrate__spark--2 {
  --dx: 46px;
  --dy: -22px;
  background: #fb923c;
  animation-delay: 0.12s;
}
.dictation-celebrate__spark--3 {
  --dx: -36px;
  --dy: 26px;
  background: #fbbf24;
  animation-delay: 0.16s;
}
.dictation-celebrate__spark--4 {
  --dx: 40px;
  --dy: 30px;
  background: #ea580c;
  animation-delay: 0.2s;
}

@keyframes dictation-thumb-pop {
  0% {
    opacity: 0;
    transform: scale(0.2) rotate(-28deg) translateY(18px);
  }
  55% {
    opacity: 1;
    transform: scale(1.18) rotate(8deg) translateY(-4px);
  }
  75% {
    transform: scale(0.94) rotate(-4deg) translateY(0);
  }
  100% {
    opacity: 1;
    transform: scale(1) rotate(0deg) translateY(0);
  }
}

@keyframes dictation-fade-up {
  from {
    opacity: 0;
    transform: translateY(8px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes dictation-ring {
  0% {
    opacity: 0.7;
    transform: scale(0.4);
  }
  100% {
    opacity: 0;
    transform: scale(1.85);
  }
}

@keyframes dictation-spark {
  0% {
    opacity: 0;
    transform: translate(0, 0) scale(0.4);
  }
  30% {
    opacity: 1;
  }
  100% {
    opacity: 0;
    transform: translate(var(--dx), var(--dy)) scale(1);
  }
}

@media (prefers-reduced-motion: reduce) {
  .dictation-celebrate__thumb,
  .dictation-celebrate__title,
  .dictation-celebrate__ring,
  .dictation-celebrate__spark {
    animation: none;
    opacity: 1;
    transform: none;
  }
}
</style>
