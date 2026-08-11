<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import {
  getArticleDetail,
  updateArticleProgress,
  type ArticleSegment,
} from '@/api/articles'
import { resolveMediaUrl } from '@/utils/mediaUrl'
import { playWordPronunciation, stopSpeaking } from '@/utils/speakWord'
import {
  playKeyClick,
  playKeyError,
  playSessionDone,
  playWordCorrect,
} from '@/utils/wordPracticeSounds'

type SentenceResult = {
  segment_id: number
  had_wrong: boolean
  skipped: boolean
}

type Summary = {
  total: number
  wrong_count: number
  skipped_count: number
  accuracy: number
  duration_ms: number
}

const route = useRoute()

const loading = ref(true)
const error = ref('')
const title = ref('')
const segments = ref<ArticleSegment[]>([])
const index = ref(0)
const input = ref('')
const started = ref(false)
const wrongFlash = ref(false)
const wrongHint = ref(false)
const showReveal = ref(false)
const hadWrongThisSentence = ref(false)
const charsTyped = ref(0)
const elapsedMs = ref(0)
const results = ref<SentenceResult[]>([])
const summary = ref<Summary | null>(null)

let tickTimer: ReturnType<typeof setInterval> | null = null
let sessionStartedAt = 0
let revealTimer: ReturnType<typeof setTimeout> | null = null
let wrongHintTimer: ReturnType<typeof setTimeout> | null = null
let sentenceAudio: HTMLAudioElement | null = null

const articleId = computed(() => String(route.params.articleId || ''))
const backTo = computed(() => `/english/reading/${articleId.value}`)
const current = computed(() => segments.value[index.value] || null)
const targetText = computed(() => (current.value?.english || '').replace(/\s+/g, ' ').trim())
const letters = computed(() => targetText.value.split(''))
const progressLabel = computed(() =>
  segments.value.length
    ? `${Math.min(index.value + 1, segments.value.length)} / ${segments.value.length}`
    : '',
)
const practiceProgressPct = computed(() => {
  if (!segments.value.length) return 0
  const base = index.value
  const frac = showReveal.value
    ? 1
    : (input.value.length / Math.max(letters.value.length, 1)) * 0.35
  return Math.min(100, ((base + frac) / segments.value.length) * 100)
})
const wpm = computed(() => {
  const mins = elapsedMs.value / 60000
  if (mins <= 0) return 0
  return Math.round(charsTyped.value / 5 / mins)
})
const accuracyLive = computed(() => {
  const done = results.value.filter((r) => !r.skipped)
  if (!done.length) return 100
  const wrong = done.filter((r) => r.had_wrong).length
  return Math.round(((done.length - wrong) / done.length) * 100)
})
const summaryMessage = computed(() => {
  const acc = summary.value?.accuracy ?? 0
  if (acc >= 100) return '全文打对，语感又稳了一分'
  if (acc >= 80) return '很稳。出错的句子可以再过一遍'
  if (acc >= 50) return '继续练，正确比速度更重要'
  return '慢一点也没关系，打对再前进就会越来越顺'
})

function formatTime(ms: number) {
  const s = Math.floor(ms / 1000)
  const m = Math.floor(s / 60)
  const r = s % 60
  return `${String(m).padStart(2, '0')}:${String(r).padStart(2, '0')}`
}

function letterState(i: number): 'idle' | 'ok' | 'cursor' | 'bad' | 'reveal' {
  if (showReveal.value) return 'reveal'
  if (wrongFlash.value && i === input.value.length) return 'bad'
  if (i < input.value.length) return 'ok'
  if (i === input.value.length && started.value) return 'cursor'
  return 'idle'
}

function displayChar(ch: string) {
  // 空格用窄空白占位，避免中间点把词距拉得过开
  return ch === ' ' ? '\u00A0' : ch
}

function charsMatch(typed: string, expected: string) {
  if (typed === expected) return true
  // 字母大小写宽松；空格/标点精确
  if (/[A-Za-z]/.test(expected)) {
    return typed.toLowerCase() === expected.toLowerCase()
  }
  return false
}

function stopSentenceAudio() {
  if (!sentenceAudio) return
  try {
    sentenceAudio.pause()
    sentenceAudio.src = ''
  } catch {
    /* ignore */
  }
  sentenceAudio = null
}

function playCurrentSentence() {
  const seg = current.value
  if (!seg) return
  stopSpeaking()
  stopSentenceAudio()
  const url = resolveMediaUrl(seg.audio_url || '')
  if (url) {
    const el = new Audio(url)
    sentenceAudio = el
    void el.play().catch(() => {
      playWordPronunciation(targetText.value)
    })
    return
  }
  if (targetText.value) playWordPronunciation(targetText.value)
}

function beginTimer() {
  if (tickTimer) return
  sessionStartedAt = Date.now()
  tickTimer = setInterval(() => {
    elapsedMs.value = Date.now() - sessionStartedAt
  }, 200)
}

function flashWrongHint() {
  wrongHint.value = true
  if (wrongHintTimer) clearTimeout(wrongHintTimer)
  wrongHintTimer = setTimeout(() => {
    wrongHint.value = false
    wrongHintTimer = null
  }, 900)
}

function plainEnglish(seg: ArticleSegment) {
  return (seg.english || '').replace(/\s+/g, ' ').trim()
}

function segmentStatus(i: number): 'done' | 'current' | 'todo' {
  if (i < index.value) return 'done'
  if (i === index.value) return 'current'
  return 'todo'
}

async function scrollCurrentIntoView() {
  await nextTick()
  const el = document.querySelector<HTMLElement>(`[data-at-seg="${index.value}"]`)
  el?.scrollIntoView({ behavior: 'smooth', block: 'center' })
}

async function boot() {
  loading.value = true
  error.value = ''
  summary.value = null
  started.value = false
  input.value = ''
  results.value = []
  charsTyped.value = 0
  elapsedMs.value = 0
  showReveal.value = false
  hadWrongThisSentence.value = false
  index.value = 0
  if (tickTimer) {
    clearInterval(tickTimer)
    tickTimer = null
  }
  sessionStartedAt = 0

  try {
    const data = await getArticleDetail(articleId.value)
    title.value = data.title
    segments.value = (data.segments || []).filter((s) => (s.english || '').trim())
    if (!segments.value.length) {
      error.value = '本文暂无可练习的英文段落'
      return
    }
    // 始终从第一段开始练习
    index.value = 0
    void scrollCurrentIntoView()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = typeof msg === 'string' ? msg : '无法加载文章'
  } finally {
    loading.value = false
  }
}

async function syncReadingProgress(seg: ArticleSegment) {
  try {
    await updateArticleProgress(articleId.value, { last_segment_index: seg.index })
  } catch {
    /* ignore */
  }
}

function finishSummary() {
  if (tickTimer) {
    clearInterval(tickTimer)
    tickTimer = null
  }
  elapsedMs.value = sessionStartedAt ? Date.now() - sessionStartedAt : elapsedMs.value
  const practiced = results.value.filter((r) => !r.skipped)
  const wrong = practiced.filter((r) => r.had_wrong).length
  const skipped = results.value.filter((r) => r.skipped).length
  const accuracy = practiced.length
    ? Math.round(((practiced.length - wrong) / practiced.length) * 100)
    : 100
  summary.value = {
    total: results.value.length,
    wrong_count: wrong,
    skipped_count: skipped,
    accuracy,
    duration_ms: elapsedMs.value,
  }
  playSessionDone()
}

function advanceAfterSentence(result: SentenceResult) {
  results.value.push(result)
  if (current.value) void syncReadingProgress(current.value)

  if (revealTimer) clearTimeout(revealTimer)
  showReveal.value = true
  playWordCorrect()

  revealTimer = setTimeout(() => {
    showReveal.value = false
    input.value = ''
    hadWrongThisSentence.value = false
    if (index.value + 1 >= segments.value.length) {
      finishSummary()
      return
    }
    index.value += 1
    playCurrentSentence()
    void scrollCurrentIntoView()
  }, 550)
}

function skipSentence() {
  if (summary.value || loading.value || !current.value || showReveal.value) return
  if (!started.value) {
    started.value = true
    beginTimer()
  }
  advanceAfterSentence({
    segment_id: current.value.id,
    had_wrong: false,
    skipped: true,
  })
}

function onKeydown(e: KeyboardEvent) {
  if (summary.value || loading.value || !current.value || showReveal.value) return
  if (e.ctrlKey || e.metaKey || e.altKey) return

  if (!started.value) {
    if (e.key.length === 1 || e.key === 'Enter' || e.key === ' ') {
      e.preventDefault()
      started.value = true
      beginTimer()
      playCurrentSentence()
    }
    return
  }

  const word = targetText.value
  if (!word) return

  if (e.key === 'Backspace') {
    e.preventDefault()
    if (input.value) input.value = input.value.slice(0, -1)
    return
  }
  if (e.key.length !== 1) return
  e.preventDefault()

  const expected = word[input.value.length]
  if (expected == null) return

  charsTyped.value += 1
  if (!charsMatch(e.key, expected)) {
    playKeyError()
    wrongFlash.value = true
    hadWrongThisSentence.value = true
    flashWrongHint()
    setTimeout(() => {
      wrongFlash.value = false
    }, 160)
    return
  }

  playKeyClick()
  input.value += expected
  if (input.value.length >= word.length) {
    advanceAfterSentence({
      segment_id: current.value.id,
      had_wrong: hadWrongThisSentence.value,
      skipped: false,
    })
  }
}

function retryFromStart() {
  summary.value = null
  void boot()
}

watch(
  () => route.params.articleId,
  () => {
    void boot()
  },
)

onMounted(() => {
  window.addEventListener('keydown', onKeydown)
  void boot()
})

onUnmounted(() => {
  window.removeEventListener('keydown', onKeydown)
  if (tickTimer) clearInterval(tickTimer)
  if (revealTimer) clearTimeout(revealTimer)
  if (wrongHintTimer) clearTimeout(wrongHintTimer)
  stopSentenceAudio()
  stopSpeaking()
})
</script>

<template>
  <div
    class="relative h-full min-h-0 overflow-hidden flex flex-col text-neutral-900 dark:text-neutral-50 bg-[radial-gradient(ellipse_80%_55%_at_50%_-10%,rgba(20,184,166,0.16),transparent_55%),radial-gradient(ellipse_50%_40%_at_100%_80%,rgba(245,158,11,0.08),transparent_50%),linear-gradient(180deg,#f8fafb_0%,#f1f5f4_100%)] dark:bg-[radial-gradient(ellipse_80%_55%_at_50%_-10%,rgba(45,212,191,0.12),transparent_55%),radial-gradient(ellipse_50%_40%_at_0%_90%,rgba(15,118,110,0.18),transparent_50%),linear-gradient(180deg,#0a0f0e_0%,#0c1211_100%)]"
  >
    <div
      class="relative mx-auto w-full max-w-7xl px-4 sm:px-6 lg:px-10 pt-5 sm:pt-7 pb-3 sm:pb-4 flex-1 min-h-0 flex flex-col"
    >
      <header class="shrink-0 mb-4 sm:mb-5">
        <div class="flex items-center justify-between gap-3 text-sm min-w-0">
          <div class="flex items-center gap-2.5 min-w-0">
            <RouterLink
              :to="backTo"
              class="shrink-0 text-neutral-500 hover:text-teal-700 dark:hover:text-teal-300 transition-colors"
            >
              ← 返回
            </RouterLink>
            <span class="text-neutral-300 dark:text-neutral-700">·</span>
            <span class="font-medium truncate tracking-tight">打字练习</span>
            <span
              v-if="title"
              class="hidden sm:inline shrink-0 max-w-[12rem] truncate text-[11px] px-2 py-0.5 rounded-md bg-teal-500/10 text-teal-800 dark:text-teal-200 dark:bg-teal-400/10"
              :title="title"
            >
              {{ title }}
            </span>
          </div>
          <div v-if="!summary && segments.length" class="flex items-center gap-2 shrink-0">
            <button
              v-if="started && current"
              type="button"
              class="text-xs text-neutral-400 hover:text-neutral-700 dark:hover:text-neutral-200 transition"
              @click="skipSentence"
            >
              跳过
            </button>
            <span class="text-xs tabular-nums text-neutral-500 dark:text-neutral-400">{{ progressLabel }}</span>
          </div>
        </div>
        <div
          v-if="!summary && segments.length"
          class="mt-3 h-1 rounded-full bg-black/5 dark:bg-white/8 overflow-hidden"
        >
          <div
            class="h-full rounded-full bg-teal-500/80 dark:bg-teal-400/70 transition-[width] duration-300 ease-out"
            :style="{ width: `${practiceProgressPct}%` }"
          />
        </div>
        <div
          v-else-if="summary && segments.length"
          class="mt-3 h-1 rounded-full bg-black/5 dark:bg-white/8 overflow-hidden"
        >
          <div class="h-full w-full rounded-full bg-teal-500/80 dark:bg-teal-400/70" />
        </div>
      </header>

      <p v-if="loading" class="text-sm text-neutral-500 py-16 text-center">准备段落…</p>
      <p
        v-else-if="error"
        class="rounded-2xl bg-rose-50/90 dark:bg-rose-950/40 px-4 py-3 text-sm text-rose-700 dark:text-rose-200 border border-rose-100 dark:border-rose-900/50"
      >
        {{ error }}
        <RouterLink :to="backTo" class="ml-2 underline">返回文章</RouterLink>
      </p>

      <section
        v-else-if="summary"
        class="rounded-3xl px-6 py-8 sm:px-10 sm:py-10 space-y-8 animate-[atFadeUp_0.35s_ease] border border-black/5 dark:border-white/[0.07] bg-white/80 dark:bg-[#141c1a]/80 backdrop-blur-md shadow-[0_18px_50px_-28px_rgba(15,118,110,0.35)] dark:shadow-[0_22px_60px_-30px_rgba(0,0,0,0.65)]"
      >
        <div class="text-center">
          <p class="text-xs font-medium tracking-wider uppercase text-teal-700/80 dark:text-teal-300/80">
            本局完成
          </p>
          <p
            class="mt-3 text-6xl sm:text-7xl font-semibold tabular-nums tracking-tight text-teal-700 dark:text-teal-300"
          >
            {{ summary.accuracy
            }}<span class="text-3xl sm:text-4xl align-top text-teal-600/70 dark:text-teal-400/70">%</span>
          </p>
          <p class="mt-3 text-sm text-neutral-600 dark:text-neutral-300 max-w-md mx-auto leading-relaxed">
            {{ summaryMessage }}
          </p>
        </div>

        <div class="grid grid-cols-3 gap-3 max-w-md mx-auto">
          <div class="text-center rounded-2xl bg-black/[0.03] dark:bg-white/[0.04] px-2 py-3">
            <p class="text-[11px] text-neutral-500">用时</p>
            <p class="mt-1 text-lg font-semibold tabular-nums">{{ formatTime(summary.duration_ms) }}</p>
          </div>
          <div class="text-center rounded-2xl bg-black/[0.03] dark:bg-white/[0.04] px-2 py-3">
            <p class="text-[11px] text-neutral-500">WPM</p>
            <p class="mt-1 text-lg font-semibold tabular-nums">{{ wpm }}</p>
          </div>
          <div class="text-center rounded-2xl bg-black/[0.03] dark:bg-white/[0.04] px-2 py-3">
            <p class="text-[11px] text-neutral-500">曾出错</p>
            <p class="mt-1 text-lg font-semibold tabular-nums text-amber-700 dark:text-amber-300">
              {{ summary.wrong_count }}
            </p>
          </div>
        </div>

        <div class="flex flex-col sm:flex-row flex-wrap items-stretch sm:items-center justify-center gap-2.5">
          <button
            type="button"
            class="px-5 py-2.5 rounded-xl text-sm font-semibold bg-teal-600 text-white hover:bg-teal-500 transition shadow-sm shadow-teal-600/20"
            @click="retryFromStart"
          >
            再来一局
          </button>
          <RouterLink
            :to="backTo"
            class="px-5 py-2.5 rounded-xl text-sm font-medium text-center text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200 transition"
          >
            返回文章
          </RouterLink>
        </div>
      </section>

      <template v-else-if="current">
        <div
          v-if="!started"
          class="shrink-0 mb-3 text-center px-4 animate-[atPulseSoft_2.2s_ease-in-out_infinite]"
        >
          <p class="text-base sm:text-lg font-medium text-neutral-700 dark:text-neutral-200 tracking-tight">
            按任意键开始 · 从第 1 段练起
          </p>
          <p class="mt-1 text-xs text-neutral-400">建议使用实体键盘 · 打对才前进 · 完成本段自动下一段</p>
        </div>

        <div
          class="relative flex-1 min-h-0 rounded-3xl border border-black/5 dark:border-white/[0.07] bg-white/85 dark:bg-[#141c1a]/85 backdrop-blur-md shadow-[0_18px_50px_-28px_rgba(15,118,110,0.35)] dark:shadow-[0_22px_60px_-30px_rgba(0,0,0,0.65)] overflow-y-auto overscroll-contain reading-scroll-hide"
          :class="{
            'animate-[atShake_0.18s_ease]': wrongFlash,
            'shadow-[0_18px_50px_-24px_rgba(20,184,166,0.45)]': showReveal,
          }"
        >
          <ol class="px-5 py-6 sm:px-8 sm:py-8 lg:px-10 space-y-5 sm:space-y-6">
            <li
              v-for="(seg, i) in segments"
              :key="seg.id"
              :data-at-seg="i"
              class="at-seg"
              :class="`is-${segmentStatus(i)}`"
            >
              <div class="flex items-start gap-3">
                <span
                  class="shrink-0 mt-1 w-6 h-6 rounded-md text-[11px] font-semibold tabular-nums inline-flex items-center justify-center"
                  :class="
                    segmentStatus(i) === 'current'
                      ? 'bg-teal-500 text-white'
                      : segmentStatus(i) === 'done'
                        ? 'bg-teal-500/15 text-teal-700 dark:text-teal-300'
                        : 'bg-neutral-100 text-neutral-400 dark:bg-neutral-800 dark:text-neutral-500'
                  "
                >
                  {{ i + 1 }}
                </span>
                <div class="min-w-0 flex-1">
                  <!-- 已完成：整段绿色 -->
                  <p
                    v-if="segmentStatus(i) === 'done'"
                    class="at-typing-line text-[1.2rem] sm:text-[1.35rem] md:text-[1.45rem] font-medium leading-[1.65] text-teal-700 dark:text-teal-300"
                  >
                    {{ plainEnglish(seg) }}
                  </p>

                  <!-- 当前段：逐字练习 -->
                  <div v-else-if="segmentStatus(i) === 'current'" class="select-none">
                    <div
                      class="at-typing-line flex flex-wrap gap-x-0 gap-y-1 text-[1.25rem] sm:text-[1.45rem] md:text-[1.6rem] font-medium leading-[1.6] w-full"
                      :class="[!started ? 'opacity-50' : '', showReveal ? 'scale-[1.005]' : '']"
                      aria-label="当前打字段"
                    >
                      <span
                        v-for="(ch, ci) in letters"
                        :key="`${seg.id}-${ci}`"
                        class="at-letter inline-flex justify-center transition-colors duration-75"
                        :class="[`is-${letterState(ci)}`, ch === ' ' ? 'is-space' : '']"
                      >
                        <span :class="letterState(ci) === 'idle' && started ? 'opacity-35' : ''">{{
                          displayChar(ch)
                        }}</span>
                      </span>
                    </div>
                    <p
                      v-if="seg.chinese"
                      class="mt-2.5 text-sm sm:text-base text-neutral-600 dark:text-neutral-300 leading-relaxed"
                    >
                      {{ seg.chinese }}
                    </p>
                    <div class="mt-3 flex items-center gap-3">
                      <button
                        v-if="started"
                        type="button"
                        class="inline-flex items-center justify-center w-9 h-9 rounded-full text-teal-700 bg-teal-500/10 hover:bg-teal-500/20 dark:text-teal-300 dark:bg-teal-400/10 dark:hover:bg-teal-400/20 transition"
                        aria-label="朗读本段"
                        title="朗读本段"
                        @click="playCurrentSentence"
                      >
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                          <path
                            d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02z"
                          />
                        </svg>
                      </button>
                      <p
                        v-if="wrongHint"
                        class="text-xs font-medium text-rose-500 dark:text-rose-300 animate-[atFadeUp_0.2s_ease]"
                      >
                        打错了，请输入正确字符
                      </p>
                    </div>
                  </div>

                  <!-- 未练：淡显全文 -->
                  <template v-else>
                    <p
                      class="at-typing-line text-[1.15rem] sm:text-[1.3rem] md:text-[1.4rem] font-medium leading-[1.65] text-neutral-400 dark:text-neutral-500"
                    >
                      {{ plainEnglish(seg) }}
                    </p>
                    <p
                      v-if="seg.chinese"
                      class="mt-1.5 text-xs sm:text-sm text-neutral-400/80 dark:text-neutral-600 leading-relaxed"
                    >
                      {{ seg.chinese }}
                    </p>
                  </template>
                </div>
              </div>
            </li>
          </ol>
        </div>

        <div
          class="shrink-0 mt-3 flex flex-wrap items-center justify-center gap-x-5 gap-y-1.5 text-[11px] text-neutral-400 dark:text-neutral-500"
        >
          <span>
            时间
            <span class="ml-1.5 tabular-nums text-neutral-600 dark:text-neutral-300">{{
              formatTime(elapsedMs)
            }}</span>
          </span>
          <span class="text-neutral-300 dark:text-neutral-700">·</span>
          <span>
            WPM
            <span class="ml-1.5 tabular-nums text-neutral-600 dark:text-neutral-300">{{
              started ? wpm : 0
            }}</span>
          </span>
          <span class="text-neutral-300 dark:text-neutral-700">·</span>
          <span>
            正确率
            <span class="ml-1.5 tabular-nums text-neutral-600 dark:text-neutral-300"
              >{{ accuracyLive }}%</span
            >
          </span>
        </div>
      </template>
    </div>
  </div>
</template>

<style scoped>
.at-typing-line,
.at-letter {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New',
    monospace;
  letter-spacing: 0;
}

.at-letter {
  border-bottom: 2px solid transparent;
  padding-bottom: 0.1em;
  min-width: 0.58em;
  padding-left: 0;
  padding-right: 0;
}
.at-letter.is-space {
  min-width: 0.35em;
  width: 0.35em;
  margin: 0;
}
.at-letter.is-idle {
  color: inherit;
  border-color: transparent;
}
.at-letter.is-ok {
  color: #0d9488;
  border-color: transparent;
}
.at-letter.is-cursor {
  color: inherit;
  border-color: #14b8a6;
  animation: atCaret 1s steps(1) infinite;
}
.at-letter.is-bad {
  color: #f43f5e;
  border-color: #fb7185;
}
.at-letter.is-reveal {
  color: #0d9488;
  border-color: transparent;
}
:global(html.dark) .at-letter.is-ok,
:global(html.dark) .at-letter.is-reveal {
  color: #5eead4;
}

@keyframes atShake {
  0%,
  100% {
    transform: translateX(0);
  }
  25% {
    transform: translateX(-3px);
  }
  75% {
    transform: translateX(3px);
  }
}
@keyframes atCaret {
  50% {
    opacity: 0;
  }
}
@keyframes atPulseSoft {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.72;
  }
}
@keyframes atFadeUp {
  from {
    opacity: 0;
    transform: translateY(6px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
