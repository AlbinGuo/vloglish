<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import {
  finishWordPractice,
  fetchWordPracticeContextClip,
  startWordPractice,
  translateWordPracticeContext,
  type ContextClipResult,
  type WordPracticeFinishResult,
  type WordPracticeItem,
  type WordPracticeSource,
} from '@/api/wordPractice'
import { playWordPronunciation, stopSpeaking } from '@/utils/speakWord'
import {
  playKeyClick,
  playKeyError,
  playSessionDone,
  playWordCorrect,
} from '@/utils/wordPracticeSounds'
import AppIcon from '@/components/AppIcon.vue'

const route = useRoute()
const router = useRouter()

const loading = ref(true)
const error = ref('')
const started = ref(false)
const finishing = ref(false)
const sessionId = ref(0)
const items = ref<WordPracticeItem[]>([])
const index = ref(0)
const input = ref('')
const wrongFlash = ref(false)
const wrongHint = ref(false)
const showReveal = ref(false)
/** 词内阶段：抄写（看词）→ 默写（藏词） */
const wordPhase = ref<'copy' | 'recall'>('copy')
/** 本词两轮累计是否出过错（用于结算/错词队列） */
const wordHadWrong = ref(false)
const tryCount = ref(1)
const wordStartedAt = ref(0)
const charsTyped = ref(0)
const elapsedMs = ref(0)
const results = ref<
  { entry_id: number; try_count: number; had_wrong: boolean; latency_ms: number }[]
>([])
const summary = ref<WordPracticeFinishResult | null>(null)
/** 开局本局词表预览，默认收起；开始练习后隐藏 */
const previewOpen = ref(false)
/** 例句翻面：false=英文，true=中文 */
const contextFlipped = ref(false)
const contextTranslating = ref(false)
const contextTranslateError = ref('')
let contextTranslateSeq = 0
/** 卡片滑出 */
const cardExiting = ref(false)
/** 滑出中的顶牌快照（下方主卡已切到下一词） */
const exitingCard = ref<WordPracticeItem | null>(null)
/** 本次滑出是否最后一词 */
const exitWasLast = ref(false)
/** 飞出期间冻结叠层深度，避免 index++ 时 ghost 跳位闪动 */
const exitStackDepth = ref<number | null>(null)
/** 抄写完成切默写时的短提示 */
const phaseHint = ref('')
/** 视频语境浮层 */
const clipOpen = ref(false)
const clipLoading = ref(false)
const clipError = ref('')
const clipLoop = ref(true)
const clipRate = ref(1)
const clipData = ref<ContextClipResult | null>(null)
const clipVideoRef = ref<HTMLVideoElement | null>(null)
const CLIP_RATES = [0.5, 0.7, 1] as const

const EXIT_ANIM_MS = 900
const REVEAL_HOLD_MS = 450
const PHASE_HINT_MS = 1200

let tickTimer: ReturnType<typeof setInterval> | null = null
let sessionStartedAt = 0
let revealTimer: ReturnType<typeof setTimeout> | null = null
let exitTimer: ReturnType<typeof setTimeout> | null = null
let wrongHintTimer: ReturnType<typeof setTimeout> | null = null
let phaseHintTimer: ReturnType<typeof setTimeout> | null = null

const source = computed<WordPracticeSource>(() => {
  const s = String(route.query.source || 'vocab')
  if (s === 'episode_vocab' || s === 'vocab_wrong') return s
  return 'vocab'
})
const videoId = computed(() => String(route.query.videoId || ''))
const limit = computed(() => {
  const n = Number(route.query.limit)
  return Number.isFinite(n) && n >= 5 && n <= 50 ? Math.floor(n) : 15
})

const current = computed(() => items.value[index.value] || null)
const letters = computed(() => (current.value?.word || '').split(''))
const isRecall = computed(() => wordPhase.value === 'recall')
const phaseLabel = computed(() => (isRecall.value ? '默写' : '抄写'))
const progressLabel = computed(() => {
  if (!items.value.length) return ''
  const n = Math.min(index.value + 1, items.value.length)
  return `${n} / ${items.value.length} · ${phaseLabel.value}`
})
const progressPct = computed(() => {
  if (!items.value.length) return 0
  const done = summary.value ? items.value.length : Math.min(index.value, items.value.length)
  return Math.round((done / items.value.length) * 100)
})
const practiceProgressPct = computed(() => {
  if (!items.value.length) return 0
  // 每个词两轮：抄写 0.5 + 默写 0.5；当前轮内再按输入比例微调
  const phaseBase = isRecall.value ? 0.5 : 0
  const frac = showReveal.value
    ? 0.5
    : (input.value.length / Math.max(letters.value.length, 1)) * 0.45
  const within = Math.min(0.5, phaseBase + frac * 0.5)
  return Math.min(100, ((index.value + within) / items.value.length) * 100)
})
const wpm = computed(() => {
  const mins = elapsedMs.value / 60000
  if (mins <= 0) return 0
  return Math.round(charsTyped.value / 5 / mins)
})
const accuracyLive = computed(() => {
  const done = results.value.length
  if (!done) return 100
  const wrong = results.value.filter((r) => r.had_wrong).length
  return Math.round(((done - wrong) / done) * 100)
})
const sourceTitle = computed(() => {
  if (source.value === 'episode_vocab') return '本集生词'
  if (source.value === 'vocab_wrong') return '错词复习'
  return '生词本'
})
/** 抽词规则说明：错词复习局本身已是错词队列 */
const pickHint = computed(() => {
  if (source.value === 'vocab_wrong') return '本局来自未解决的错词'
  return '本局优先：错词与未练习 · 已掌握会后排'
})
const nextRoundHint = computed(() => {
  if (source.value === 'vocab_wrong') return '练过并打对的错词会移出队列'
  return '已练过的会后排，下次优先补新词与错词'
})

type ContextPart = { text: string; hit: boolean }

/** 在例句中高亮当前练习词（大小写不敏感） */
function highlightWordInContext(sentence: string, word: string): ContextPart[] {
  const text = (sentence || '').trim()
  const w = (word || '').trim()
  if (!text) return []
  if (!w) return [{ text, hit: false }]
  const escaped = w.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  const re = new RegExp(`(${escaped})`, 'gi')
  const chunks = text.split(re)
  return chunks
    .filter((p) => p.length > 0)
    .map((p) => ({ text: p, hit: p.toLowerCase() === w.toLowerCase() }))
}

/** 默写：例句中目标词只留首字母，其余用下划线 */
function maskWordKeepInitial(text: string): string {
  if (!text) return text
  if (text.length === 1) return text
  const chars = [...text]
  return chars
    .map((ch, i) => {
      if (/\s/.test(ch)) return ch
      if (i === 0) return ch
      return '_'
    })
    .join('')
}

/** 拼写格显示：抄写看全词；默写仅首字母提示 + 已打出的字母 */
function letterGlyph(i: number, ch: string): string {
  if (ch === ' ') return '·'
  if (showReveal.value || wordPhase.value === 'copy') return ch
  if (i < input.value.length) return ch
  if (i === 0) return ch
  return '_'
}

const contextParts = computed(() =>
  current.value ? highlightWordInContext(current.value.context || '', current.value.word) : [],
)
const contextZh = computed(() => (current.value?.context_zh || '').trim())
/** 有英文例句即可翻面；中文可能来自缓存/按需 AI */
const canFlipContext = computed(() => Boolean(contextParts.value.length))
const canWatchClip = computed(() => Boolean(current.value?.source_subtitle_id))
/** 浮层字幕：按当前练习词高亮 */
const clipSubtitleParts = computed(() => {
  if (!clipData.value) return []
  const word = current.value?.word || ''
  return highlightWordInContext(clipData.value.english || '', word)
})
const clipSubtitleZh = computed(() => (clipData.value?.chinese || '').trim())
/** 剩余未练词叠在下方的层数（最多 2）；滑出时主卡已是下一词 */
const stackDepth = computed(() => {
  const left = items.value.length - index.value - 1
  return Math.min(2, Math.max(0, left))
})
/** 飞出中用冻结值，结束后恢复实时 stackDepth */
const visualStackDepth = computed(() =>
  cardExiting.value && exitStackDepth.value != null ? exitStackDepth.value : stackDepth.value,
)
const exitingLetters = computed(() => (exitingCard.value?.word || '').split(''))

function clearExitVisual() {
  cardExiting.value = false
  exitingCard.value = null
  exitWasLast.value = false
  exitStackDepth.value = null
}

async function ensureContextZh(item: WordPracticeItem | null, itemIndex: number) {
  if (!item) return
  const en = (item.context || '').trim()
  if (!en || (item.context_zh || '').trim()) {
    contextTranslating.value = false
    contextTranslateError.value = ''
    return
  }
  const seq = ++contextTranslateSeq
  contextTranslating.value = true
  contextTranslateError.value = ''
  try {
    const result = await translateWordPracticeContext({
      english: en,
      source_subtitle_id: item.source_subtitle_id,
      source_segment_id: item.source_segment_id,
    })
    if (seq !== contextTranslateSeq) return
    const zh = (result.chinese || '').trim()
    if (!zh) {
      contextTranslateError.value = '未拿到翻译'
      return
    }
    const row = items.value[itemIndex]
    if (row && row.entry_id === item.entry_id && (row.context || '').trim() === en) {
      items.value[itemIndex] = { ...row, context_zh: zh }
    }
  } catch (e: unknown) {
    if (seq !== contextTranslateSeq) return
    const detail = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    contextTranslateError.value = typeof detail === 'string' ? detail : '翻译失败，请稍后重试'
  } finally {
    if (seq === contextTranslateSeq) contextTranslating.value = false
  }
}

function toggleContextFlip() {
  if (!canFlipContext.value) return
  contextFlipped.value = !contextFlipped.value
  if (contextFlipped.value && !contextZh.value && !contextTranslating.value) {
    void ensureContextZh(current.value, index.value)
  }
}

watch(
  () => [index.value, current.value?.entry_id, current.value?.context] as const,
  () => {
    contextFlipped.value = false
    void ensureContextZh(current.value, index.value)
  },
)

const backTo = computed(() => {
  if (source.value === 'episode_vocab' && videoId.value) {
    return `/english/episode/${videoId.value}`
  }
  return '/english/vocabulary'
})
const summaryMessage = computed(() => {
  const acc = summary.value?.accuracy ?? 0
  if (acc >= 100) return '完美一局，拼写肌肉记忆又稳了一分'
  if (acc >= 80) return '很稳。错词再过一遍，记得会更牢'
  if (acc >= 50) return '继续巩固错词，记得比刷题更重要'
  return '慢一点也没关系，整词重打就是在加深印象'
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

async function boot() {
  loading.value = true
  error.value = ''
  summary.value = null
  wrongHint.value = false
  if (tickTimer) {
    clearInterval(tickTimer)
    tickTimer = null
  }
  sessionStartedAt = 0
  try {
    const data = await startWordPractice({
      source: source.value,
      video_id: videoId.value,
      limit: limit.value,
    })
    sessionId.value = data.session_id
    items.value = data.items
    index.value = 0
    input.value = ''
    results.value = []
    charsTyped.value = 0
    elapsedMs.value = 0
    started.value = false
    resetWordState()
    previewOpen.value = false
    contextFlipped.value = false
    contextTranslating.value = false
    contextTranslateError.value = ''
    contextTranslateSeq += 1
    clearExitVisual()
    if (exitTimer) {
      clearTimeout(exitTimer)
      exitTimer = null
    }
    if (phaseHintTimer) {
      clearTimeout(phaseHintTimer)
      phaseHintTimer = null
    }
    closeClipOverlay()
    if (!data.items?.length) {
      error.value =
        source.value === 'vocab_wrong' ? '当前没有可练习的错词' : '本局没有可练习的单词'
    }
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = typeof msg === 'string' ? msg : '无法开始练习'
  } finally {
    loading.value = false
  }
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

function flashPhaseHint(text: string) {
  phaseHint.value = text
  if (phaseHintTimer) clearTimeout(phaseHintTimer)
  phaseHintTimer = setTimeout(() => {
    phaseHint.value = ''
    phaseHintTimer = null
  }, PHASE_HINT_MS)
}

function resetWordState() {
  wordPhase.value = 'copy'
  wordHadWrong.value = false
  tryCount.value = 1
  input.value = ''
  showReveal.value = false
  wrongFlash.value = false
  wrongHint.value = false
  phaseHint.value = ''
}

/** 抄写完成 → 同词进入默写 */
function enterRecallPhase() {
  wordPhase.value = 'recall'
  input.value = ''
  showReveal.value = false
  wrongFlash.value = false
  wrongHint.value = false
  flashPhaseHint('默写：只看首字母')
  if (current.value) void playWordPronunciation(current.value.word)
}

/** 默写完成 → 飞出并切下一词（或结算） */
function advanceToNextWordOrFinish() {
  closeClipOverlay()
  const done = current.value
  if (!done) return
  const isLast = index.value + 1 >= items.value.length
  exitingCard.value = { ...done }
  exitWasLast.value = isLast
  showReveal.value = false
  resetWordState()
  cardExiting.value = true

  if (!isLast) {
    index.value += 1
    wordStartedAt.value = Date.now()
    exitStackDepth.value = Math.min(2, Math.max(0, items.value.length - index.value - 1))
  } else {
    exitStackDepth.value = 0
  }

  if (exitTimer) clearTimeout(exitTimer)
  exitTimer = setTimeout(() => {
    const last = exitWasLast.value
    clearExitVisual()
    exitTimer = null
    if (last) {
      void finish()
      return
    }
    const next = items.value[index.value]
    if (next) void playWordPronunciation(next.word)
  }, EXIT_ANIM_MS)
}

function isTypingIntoControl(e: KeyboardEvent) {
  const t = e.target
  if (!(t instanceof HTMLElement)) return false
  const tag = t.tagName
  if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT' || tag === 'BUTTON' || tag === 'VIDEO') {
    return true
  }
  if (t.isContentEditable) return true
  return Boolean(t.closest('button, a, [role="button"], label, video'))
}

function togglePreview() {
  previewOpen.value = !previewOpen.value
}

function pauseClipVideo() {
  const v = clipVideoRef.value
  if (!v) return
  v.pause()
}

function closeClipOverlay() {
  const v = clipVideoRef.value
  if (v) {
    v.pause()
    v.removeAttribute('src')
    v.load()
  }
  clipOpen.value = false
  clipLoading.value = false
  clipError.value = ''
  clipData.value = null
}

async function openClipOverlay() {
  const sid = current.value?.source_subtitle_id
  if (!sid || clipLoading.value) return
  // 侧栏已开 → 再点收起
  if (clipOpen.value) {
    closeClipOverlay()
    return
  }
  stopSpeaking()
  clipOpen.value = true
  clipLoading.value = true
  clipError.value = ''
  clipData.value = null
  try {
    const data = await fetchWordPracticeContextClip(sid)
    clipData.value = data
    await nextTick()
    const v = clipVideoRef.value
    if (!v) return
    v.src = data.video_url
    v.playbackRate = clipRate.value
    const start = data.start
    const onReady = () => {
      v.currentTime = start
      v.playbackRate = clipRate.value
      void v.play().catch(() => {
        /* 用户手势已打开面板，失败时仍可点播放 */
      })
    }
    if (v.readyState >= 1) onReady()
    else v.addEventListener('loadedmetadata', onReady, { once: true })
  } catch (e: unknown) {
    const detail = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    clipError.value = typeof detail === 'string' ? detail : '原句视频加载失败'
  } finally {
    clipLoading.value = false
  }
}

function onClipTimeUpdate() {
  const v = clipVideoRef.value
  const data = clipData.value
  if (!v || !data || !clipLoop.value) return
  if (v.currentTime >= data.end - 0.04) {
    v.currentTime = data.start
    if (v.paused) void v.play().catch(() => {})
  }
}

function onClipEnded() {
  const v = clipVideoRef.value
  const data = clipData.value
  if (!v || !data) return
  if (clipLoop.value) {
    v.currentTime = data.start
    void v.play().catch(() => {})
  }
}

function replayClipOnce() {
  const v = clipVideoRef.value
  const data = clipData.value
  if (!v || !data) return
  v.currentTime = data.start
  v.playbackRate = clipRate.value
  void v.play().catch(() => {})
}

function setClipRate(rate: number) {
  clipRate.value = rate
  const v = clipVideoRef.value
  if (v) v.playbackRate = rate
}

function onKeydown(e: KeyboardEvent) {
  if (clipOpen.value && e.key === 'Escape') {
    e.preventDefault()
    closeClipOverlay()
    return
  }
  if (summary.value || loading.value || !current.value || showReveal.value || cardExiting.value) return
  if (e.ctrlKey || e.metaKey || e.altKey) return
  if (isTypingIntoControl(e)) return

  if (!started.value) {
    if (e.key.length === 1 || e.key === 'Enter' || e.key === ' ') {
      e.preventDefault()
      started.value = true
      beginTimer()
      wordStartedAt.value = Date.now()
      void playWordPronunciation(current.value.word)
    }
    return
  }

  const word = current.value.word
  if (e.key === 'Backspace') {
    e.preventDefault()
    if (input.value) input.value = input.value.slice(0, -1)
    return
  }
  if (e.key.length !== 1) return
  e.preventDefault()

  const ch = e.key
  const expected = word[input.value.length]
  if (expected == null) return

  charsTyped.value += 1
  const ok =
    ch === expected ||
    (expected.toLowerCase() === expected && ch.toLowerCase() === expected) ||
    ch.toLowerCase() === expected.toLowerCase()

  if (!ok) {
    playKeyError()
    wrongFlash.value = true
    tryCount.value += 1
    wordHadWrong.value = true
    flashWrongHint()
    setTimeout(() => {
      wrongFlash.value = false
      input.value = ''
    }, 180)
    return
  }

  playKeyClick()
  input.value += expected
  if (input.value.length >= word.length) {
    void completeWord()
  }
}

async function completeWord() {
  if (!current.value || cardExiting.value) return
  playWordCorrect()
  showReveal.value = true

  if (revealTimer) clearTimeout(revealTimer)
  if (exitTimer) clearTimeout(exitTimer)

  if (wordPhase.value === 'copy') {
    // 抄写过关 → 同词进入默写（不飞走）
    revealTimer = setTimeout(() => {
      showReveal.value = false
      revealTimer = null
      enterRecallPhase()
    }, REVEAL_HOLD_MS)
    return
  }

  // 默写过关 → 记入结果并飞向下一词
  const latency = Math.max(0, Date.now() - (wordStartedAt.value || Date.now()))
  results.value.push({
    entry_id: current.value.entry_id,
    try_count: tryCount.value,
    had_wrong: wordHadWrong.value || tryCount.value > 1,
    latency_ms: latency,
  })

  revealTimer = setTimeout(() => {
    advanceToNextWordOrFinish()
  }, REVEAL_HOLD_MS)
}

async function finish() {
  if (finishing.value || !sessionId.value) return
  finishing.value = true
  if (tickTimer) {
    clearInterval(tickTimer)
    tickTimer = null
  }
  elapsedMs.value = sessionStartedAt ? Date.now() - sessionStartedAt : elapsedMs.value
  try {
    summary.value = await finishWordPractice(sessionId.value, {
      results: results.value,
      duration_ms: elapsedMs.value,
      chars_typed: charsTyped.value,
    })
    playSessionDone()
  } catch {
    summary.value = {
      session_id: sessionId.value,
      total_count: items.value.length,
      correct_count: results.value.filter((r) => !r.had_wrong).length,
      wrong_count: results.value.filter((r) => r.had_wrong).length,
      duration_ms: elapsedMs.value,
      chars_typed: charsTyped.value,
      accuracy: accuracyLive.value,
    }
  } finally {
    finishing.value = false
  }
}

function retryWrong() {
  // 已在错词模式时 replace 同 query 不会触发路由 watch，需手动重开
  summary.value = null
  const nextQuery: Record<string, string> = {
    source: 'vocab_wrong',
    limit: String(limit.value),
  }
  if (videoId.value) nextQuery.videoId = videoId.value

  const sameRoute =
    String(route.query.source || '') === 'vocab_wrong' &&
    String(route.query.limit || '') === nextQuery.limit &&
    String(route.query.videoId || '') === String(nextQuery.videoId || '')

  if (sameRoute) {
    void boot()
    return
  }
  void router.replace({
    path: '/english/word-practice',
    query: nextQuery,
  })
}

function retrySame() {
  summary.value = null
  void boot()
}

watch(
  () => [route.query.source, route.query.videoId, route.query.limit],
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
  if (exitTimer) clearTimeout(exitTimer)
  if (wrongHintTimer) clearTimeout(wrongHintTimer)
  if (phaseHintTimer) clearTimeout(phaseHintTimer)
  pauseClipVideo()
  stopSpeaking()
})
</script>

<template>
  <div
    class="wp-shell relative min-h-[calc(100dvh-4rem)] text-neutral-900 dark:text-neutral-50 bg-[radial-gradient(ellipse_80%_55%_at_50%_-10%,rgba(20,184,166,0.16),transparent_55%),radial-gradient(ellipse_50%_40%_at_100%_80%,rgba(245,158,11,0.08),transparent_50%),linear-gradient(180deg,#f8fafb_0%,#f1f5f4_100%)] dark:bg-[radial-gradient(ellipse_80%_55%_at_50%_-10%,rgba(45,212,191,0.12),transparent_55%),radial-gradient(ellipse_50%_40%_at_0%_90%,rgba(15,118,110,0.18),transparent_50%),linear-gradient(180deg,#0a0f0e_0%,#0c1211_100%)]"
    :class="cardExiting ? 'overflow-visible' : 'overflow-hidden'"
  >
    <div
      class="relative mx-auto px-4 py-6 sm:py-10 transition-[max-width] duration-300 ease-out"
      :class="clipOpen && current && !summary ? 'max-w-6xl' : 'max-w-3xl'"
    >
      <!-- 顶栏 -->
      <header class="mb-5 sm:mb-7">
        <div class="flex items-center justify-between gap-3 text-sm min-w-0">
          <div class="flex items-center gap-2.5 min-w-0">
            <RouterLink
              :to="backTo"
              class="shrink-0 text-neutral-500 hover:text-teal-700 dark:hover:text-teal-300 transition-colors"
            >
              ← 返回
            </RouterLink>
            <span class="text-neutral-300 dark:text-neutral-700">·</span>
            <span class="font-medium truncate tracking-tight">拼写练习</span>
            <span
              class="shrink-0 text-[11px] px-2 py-0.5 rounded-md bg-teal-500/10 text-teal-800 dark:text-teal-200 dark:bg-teal-400/10"
            >
              {{ sourceTitle }}
            </span>
          </div>
          <span
            v-if="!summary && items.length"
            class="shrink-0 text-xs tabular-nums text-neutral-500 dark:text-neutral-400"
          >
            {{ progressLabel }}
          </span>
        </div>
        <div
          v-if="!summary && items.length"
          class="mt-3 h-1 rounded-full bg-black/5 dark:bg-white/8 overflow-hidden"
        >
          <div
            class="h-full rounded-full bg-teal-500/80 dark:bg-teal-400/70 transition-[width] duration-300 ease-out"
            :style="{ width: `${practiceProgressPct}%` }"
          />
        </div>
        <div
          v-else-if="summary && items.length"
          class="mt-3 h-1 rounded-full bg-black/5 dark:bg-white/8 overflow-hidden"
        >
          <div class="h-full w-full rounded-full bg-teal-500/80 dark:bg-teal-400/70" />
        </div>
      </header>

      <p v-if="loading" class="text-sm text-neutral-500 py-16 text-center">准备题目…</p>
      <p
        v-else-if="error"
        class="rounded-2xl bg-rose-50/90 dark:bg-rose-950/40 px-4 py-3 text-sm text-rose-700 dark:text-rose-200 border border-rose-100 dark:border-rose-900/50"
      >
        {{ error }}
        <RouterLink :to="backTo" class="ml-2 underline">返回</RouterLink>
      </p>

      <!-- 结算 -->
      <section
        v-else-if="summary"
        class="rounded-3xl px-6 py-8 sm:px-10 sm:py-10 space-y-8 animate-[wpFadeUp_0.35s_ease] border border-black/5 dark:border-white/[0.07] bg-white/80 dark:bg-[#141c1a]/80 backdrop-blur-md shadow-[0_18px_50px_-28px_rgba(15,118,110,0.35)] dark:shadow-[0_22px_60px_-30px_rgba(0,0,0,0.65)]"
      >
        <div class="text-center">
          <p class="text-xs font-medium tracking-wider uppercase text-teal-700/80 dark:text-teal-300/80">
            本局完成
          </p>
          <p
            class="mt-3 text-6xl sm:text-7xl font-semibold tabular-nums tracking-tight text-teal-700 dark:text-teal-300"
          >
            {{ summary.accuracy }}<span class="text-3xl sm:text-4xl align-top text-teal-600/70 dark:text-teal-400/70">%</span>
          </p>
          <p class="mt-3 text-sm text-neutral-600 dark:text-neutral-300 max-w-md mx-auto leading-relaxed">
            {{ summaryMessage }}
          </p>
          <p class="mt-2 text-xs text-neutral-400 dark:text-neutral-500">
            {{ nextRoundHint }}
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
            v-if="summary.wrong_count > 0"
            type="button"
            class="px-5 py-2.5 rounded-xl text-sm font-semibold bg-amber-600 text-white hover:bg-amber-500 transition shadow-sm shadow-amber-600/20"
            @click="retryWrong"
          >
            再练错词
          </button>
          <button
            type="button"
            class="px-5 py-2.5 rounded-xl text-sm font-semibold transition"
            :class="
              summary.wrong_count > 0
                ? 'border border-line-strong text-ink-soft hover:bg-black/[0.03] dark:hover:bg-white/[0.05]'
                : 'bg-teal-600 text-white hover:bg-teal-500 shadow-sm shadow-teal-600/20'
            "
            @click="retrySame"
          >
            再来一局
          </button>
          <RouterLink
            :to="backTo"
            class="px-5 py-2.5 rounded-xl text-sm font-medium text-center text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200 transition"
          >
            返回{{ sourceTitle }}
          </RouterLink>
        </div>
        <p v-if="progressPct" class="sr-only">进度 {{ progressPct }}%</p>
      </section>

      <!-- 练习台 -->
      <template v-else-if="current">
        <!-- 开局预览：开始前列出本局词，可折叠 -->
        <section
          v-if="!started"
          class="mb-4 rounded-2xl border border-black/5 dark:border-white/[0.07] bg-white/70 dark:bg-[#141c1a]/70 backdrop-blur-sm overflow-hidden"
        >
          <button
            type="button"
            class="w-full flex items-center justify-between gap-3 px-4 py-3 text-left hover:bg-black/[0.02] dark:hover:bg-white/[0.03] transition-colors"
            :aria-expanded="previewOpen"
            aria-controls="wp-round-preview"
            @click="togglePreview"
          >
            <span class="min-w-0">
              <span class="text-sm font-medium text-neutral-800 dark:text-neutral-100">本局单词</span>
              <span class="ml-2 text-xs tabular-nums text-neutral-400">{{ items.length }} 个</span>
              <span class="ml-2 text-[11px] text-teal-700/75 dark:text-teal-300/65 hidden sm:inline">{{
                pickHint
              }}</span>
            </span>
            <span
              class="shrink-0 inline-flex items-center gap-1 text-xs text-neutral-400"
            >
              {{ previewOpen ? '收起' : '展开' }}
              <AppIcon name="chevron-down-xs" class="h-3.5 w-3.5 transition-transform duration-200" />
            </span>
          </button>
          <div
            v-show="previewOpen"
            id="wp-round-preview"
            class="border-t border-black/5 dark:border-white/[0.06] px-3 py-2.5 max-h-[min(40vh,16rem)] overflow-y-auto overscroll-contain reading-scroll-hide"
          >
            <ol class="space-y-1">
              <li
                v-for="(item, i) in items"
                :key="`${item.entry_id}-${i}`"
                class="flex items-center gap-2 rounded-lg px-2 py-1.5 text-sm"
              >
                <span
                  class="shrink-0 w-5 text-[11px] tabular-nums text-neutral-400 text-right"
                >{{ i + 1 }}</span>
                <span
                  class="shrink-0 font-mono font-semibold text-neutral-900 dark:text-neutral-50 tracking-tight"
                >{{ item.word }}</span>
                <span
                  v-if="item.definition_cn"
                  class="min-w-0 flex-1 truncate text-xs text-neutral-500 dark:text-neutral-400"
                  :title="item.definition_cn"
                >{{ item.definition_cn }}</span>
                <span v-else class="min-w-0 flex-1" />
                <button
                  type="button"
                  class="shrink-0 inline-flex h-7 w-7 items-center justify-center rounded-full text-teal-700 bg-teal-500/10 hover:bg-teal-500/20 dark:text-teal-300 dark:bg-teal-400/10 dark:hover:bg-teal-400/20 transition"
                  :aria-label="`朗读 ${item.word}`"
                  :title="`朗读 ${item.word}`"
                  @click.stop="playWordPronunciation(item.word)"
                >
                  <AppIcon name="volume-up" :size="14" />
                </button>
              </li>
            </ol>
          </div>
        </section>

        <div
          class="wp-practice-row flex flex-col lg:flex-row gap-4 lg:gap-5 lg:items-start"
        >
        <div
          class="wp-deck w-full min-w-0 flex-1"
          :class="
            visualStackDepth === 0 ? 'pt-0 px-0' : visualStackDepth === 1 ? 'pt-8 px-2' : 'pt-12 px-3'
          "
        >
          <div class="wp-deck-stage relative w-full">
          <div
            v-if="visualStackDepth >= 2"
            class="wp-deck-ghost ghost-2"
            aria-hidden="true"
          />
          <div
            v-if="visualStackDepth >= 1"
            class="wp-deck-ghost ghost-1"
            aria-hidden="true"
          />
        <!-- 主卡：滑出时已切到下一词 -->
        <div
          v-show="!(cardExiting && exitWasLast)"
          class="wp-deck-card relative z-[3] rounded-3xl px-4 py-12 sm:px-8 sm:py-16 min-h-[22rem] flex flex-col items-center justify-center select-none border border-black/5 dark:border-white/[0.07] bg-white/90 dark:bg-[#141c1a]/92 backdrop-blur-md shadow-[0_18px_50px_-28px_rgba(15,118,110,0.35)] dark:shadow-[0_22px_60px_-30px_rgba(0,0,0,0.65)]"
          :class="{
            'animate-[wpShake_0.18s_ease]': wrongFlash && !cardExiting,
            'is-reveal': showReveal && !cardExiting,
            'is-under-exit': cardExiting && !exitWasLast,
          }"
        >
          <!-- 开始态：文档流，避免盖住字母 -->
          <div
            v-if="!started"
            class="mb-8 text-center px-4 animate-[wpPulseSoft_2.2s_ease-in-out_infinite]"
          >
            <p class="text-lg sm:text-xl font-medium text-neutral-700 dark:text-neutral-200 tracking-tight">
              按任意键开始
            </p>
            <p class="mt-1.5 text-xs text-neutral-400">
              每词两轮：先抄写，再默写 · 打错整词重来
            </p>
            <p class="mt-2 text-[11px] text-teal-700/80 dark:text-teal-300/70 sm:hidden">
              {{ pickHint }}
            </p>
            <span
              class="mt-4 mx-auto block w-0.5 h-6 rounded-full bg-teal-500 animate-[wpCaret_1s_steps(1)_infinite]"
              aria-hidden="true"
            />
          </div>

          <div
            v-if="started"
            class="mb-5 flex items-center justify-center gap-2"
          >
            <span
              class="text-[11px] font-medium tracking-wide px-2 py-0.5 rounded-md"
              :class="
                isRecall
                  ? 'bg-amber-500/15 text-amber-800 dark:bg-amber-400/15 dark:text-amber-200'
                  : 'bg-brand-soft text-brand-on-soft'
              "
            >
              {{ phaseLabel }}
            </span>
            <span
              v-if="phaseHint"
              class="text-[11px] text-neutral-500 dark:text-neutral-400 animate-[wpFadeUp_0.2s_ease]"
            >
              {{ phaseHint }}
            </span>
          </div>

          <div
            class="flex flex-wrap justify-center gap-x-1 sm:gap-x-1.5 font-mono text-4xl sm:text-5xl font-semibold tracking-wide leading-none transition-[transform,opacity] duration-300"
            :class="[
              showReveal ? 'scale-[1.03]' : '',
              !started ? 'opacity-40' : '',
            ]"
            aria-label="拼写区"
          >
            <span
              v-for="(ch, i) in letters"
              :key="`${current.entry_id}-${wordPhase}-${i}`"
              class="wp-letter inline-flex min-w-[0.85em] justify-center px-0.5 transition-colors duration-75"
              :class="`is-${letterState(i)}`"
            >
              <span
                :class="
                  letterState(i) === 'idle' && started && !(isRecall && i === 0)
                    ? 'opacity-35'
                    : ''
                "
              >{{ letterGlyph(i, ch) }}</span>
            </span>
          </div>

          <div class="mt-9 max-w-lg w-full text-center space-y-2 px-2">
            <div class="flex items-center justify-center gap-2.5">
              <p class="text-base sm:text-lg text-neutral-800 dark:text-neutral-100 leading-relaxed font-medium">
                {{ current.definition_cn || '（暂无释义）' }}
              </p>
              <button
                type="button"
                class="shrink-0 inline-flex h-9 w-9 items-center justify-center rounded-full text-brand bg-brand-soft hover:bg-teal-500/20 dark:hover:bg-teal-400/20 transition"
                :aria-label="`朗读 ${current.word}`"
                :title="`朗读 ${current.word}`"
                @click.stop="playWordPronunciation(current.word)"
              >
                <AppIcon name="volume-up" :size="16" />
              </button>
            </div>
            <p v-if="current.ipa" class="text-sm text-neutral-400 dark:text-neutral-500 tracking-wide">
              /{{ current.ipa.replace(/^\/|\/$/g, '') }}/
            </p>
            <div v-if="canWatchClip && !contextParts.length" class="pt-1">
              <button
                type="button"
                class="text-[11px] px-2 py-0.5 rounded-md transition"
                :class="
                  clipOpen
                    ? 'text-teal-900 bg-teal-500/25 dark:text-teal-100 dark:bg-teal-400/25'
                    : 'text-brand bg-brand-soft hover:bg-teal-500/15 dark:hover:bg-teal-400/15'
                "
                @click.stop="openClipOverlay"
              >
                {{ clipOpen ? '收起视频' : '视频语境' }}
              </button>
            </div>
            <div
              v-if="contextParts.length"
              class="pt-3 mt-1 border-t border-black/5 dark:border-white/[0.06] space-y-2"
            >
              <div class="flex items-center justify-between gap-2">
                <p class="text-[11px] font-medium tracking-wide text-neutral-400 dark:text-neutral-500">
                  例句
                  <span class="ml-1.5 font-normal text-neutral-400/80">
                    · 点卡片看{{ contextFlipped ? '英文' : '中文' }}
                  </span>
                  <span
                    v-if="contextTranslating && !contextZh"
                    class="ml-1.5 font-normal text-teal-600/80 dark:text-teal-300/70"
                  >
                    · AI 翻译中…
                  </span>
                </p>
                <div class="flex items-center gap-1.5 shrink-0">
                  <button
                    v-if="canWatchClip"
                    type="button"
                    class="text-[11px] px-2 py-0.5 rounded-md transition"
                    :class="
                      clipOpen
                        ? 'text-teal-900 bg-teal-500/25 dark:text-teal-100 dark:bg-teal-400/25'
                        : 'text-brand bg-brand-soft hover:bg-teal-500/15 dark:hover:bg-teal-400/15'
                    "
                    @click.stop="openClipOverlay"
                  >
                    {{ clipOpen ? '收起视频' : '视频语境' }}
                  </button>
                  <button
                    type="button"
                    class="text-[11px] px-2 py-0.5 rounded-md text-teal-700 bg-brand-soft hover:bg-teal-500/15 dark:text-teal-300 dark:hover:bg-teal-400/15 transition"
                    @click.stop="toggleContextFlip"
                  >
                    {{ contextFlipped ? '看英文' : '看中文' }}
                  </button>
                </div>
              </div>

              <button
                type="button"
                class="wp-flip w-full text-left rounded-xl focus:outline-none focus-visible:ring-2 focus-visible:ring-teal-500/40"
                :class="{ 'is-flipped': contextFlipped }"
                :aria-pressed="contextFlipped"
                :aria-label="contextFlipped ? '显示英文例句' : '显示中文翻译'"
                @click.stop="toggleContextFlip"
              >
                <span class="wp-flip-inner">
                  <span class="wp-flip-face wp-flip-front">
                    <span
                      class="wp-context-en block text-sm sm:text-[0.95rem] text-neutral-600 dark:text-neutral-300 leading-relaxed"
                    >
                      <template v-for="(part, pi) in contextParts" :key="`${current.entry_id}-ctx-${pi}`">
                        <mark
                          v-if="part.hit"
                          class="bg-teal-500/15 text-teal-800 dark:bg-teal-400/20 dark:text-teal-200 rounded px-0.5 font-semibold not-italic tracking-wide"
                        >{{ isRecall && !showReveal ? maskWordKeepInitial(part.text) : part.text }}</mark>
                        <span v-else>{{ part.text }}</span>
                      </template>
                    </span>
                  </span>
                  <span class="wp-flip-face wp-flip-back">
                    <span
                      v-if="contextZh"
                      class="block text-sm sm:text-[0.95rem] text-neutral-600 dark:text-neutral-300 leading-relaxed"
                    >
                      {{ contextZh }}
                    </span>
                    <span
                      v-else-if="contextTranslating"
                      class="block text-sm text-neutral-400 dark:text-neutral-500"
                    >
                      AI 翻译中…
                    </span>
                    <span
                      v-else-if="contextTranslateError"
                      class="block text-sm text-rose-500 dark:text-rose-300 leading-relaxed"
                    >
                      {{ contextTranslateError }}
                      <button
                        type="button"
                        class="ml-2 underline text-teal-700 dark:text-teal-300"
                        @click.stop="ensureContextZh(current, index)"
                      >
                        重试
                      </button>
                    </span>
                    <span v-else class="block text-sm text-neutral-400">暂无中文</span>
                  </span>
                </span>
              </button>
            </div>
          </div>

          <p
            v-if="wrongHint"
            class="mt-5 text-center text-xs font-medium text-rose-500 dark:text-rose-300 animate-[wpFadeUp_0.2s_ease]"
          >
            打错了，整词重来
          </p>
        </div>

        <!-- 飞走的顶牌：已完成词的快照 -->
        <div
          v-if="exitingCard"
          class="wp-deck-flyaway wp-deck-card is-exiting absolute inset-0 z-[5] rounded-3xl px-4 py-12 sm:px-8 sm:py-16 min-h-[22rem] flex flex-col items-center justify-center select-none border border-teal-500/25 dark:border-teal-400/30 bg-white/95 dark:bg-[#141c1a]/95 backdrop-blur-md pointer-events-none"
          aria-hidden="true"
        >
          <div
            class="wp-deck-flyaway__letters flex flex-wrap justify-center gap-x-1 sm:gap-x-1.5 font-mono text-4xl sm:text-5xl font-semibold tracking-wide leading-none"
          >
            <span
              v-for="(ch, i) in exitingLetters"
              :key="`exit-${exitingCard.entry_id}-${i}`"
              class="wp-letter is-reveal wp-deck-flyaway__ch inline-flex min-w-[0.85em] justify-center px-0.5"
              :style="{ animationDelay: `${40 + i * 28}ms` }"
            >
              {{ ch === ' ' ? '·' : ch }}
            </span>
          </div>
          <div class="mt-9 max-w-lg w-full text-center space-y-2 px-2">
            <p class="text-base sm:text-lg text-neutral-800 dark:text-neutral-100 leading-relaxed font-medium">
              {{ exitingCard.definition_cn || '（暂无释义）' }}
            </p>
            <p
              v-if="exitingCard.ipa"
              class="text-sm text-neutral-400 dark:text-neutral-500 tracking-wide"
            >
              /{{ exitingCard.ipa.replace(/^\/|\/$/g, '') }}/
            </p>
          </div>
        </div>
          </div>
        </div>

        <!-- 视频语境：桌面右侧 / 手机卡片下方，不打断打字 -->
        <aside
          v-if="clipOpen"
          class="wp-clip-panel w-full lg:w-[22rem] xl:w-[24rem] shrink-0 rounded-3xl border border-black/5 dark:border-white/[0.07] bg-[#0f1614] text-neutral-50 shadow-[0_18px_50px_-28px_rgba(15,118,110,0.35)] dark:shadow-[0_22px_60px_-30px_rgba(0,0,0,0.65)] overflow-hidden animate-[wpFadeUp_0.28s_ease]"
          aria-label="视频语境"
        >
          <div class="flex items-center justify-between gap-3 px-4 py-3 border-b border-white/10">
            <div class="min-w-0">
              <p class="text-sm font-medium tracking-tight">视频语境</p>
              <p class="text-[11px] text-neutral-400 truncate">
                {{ current?.word || '' }}
                <span v-if="clipLoop" class="ml-1.5 text-teal-300/80">· 循环</span>
              </p>
            </div>
            <button
              type="button"
              class="shrink-0 h-8 w-8 rounded-full text-neutral-300 hover:bg-white/10 transition"
              aria-label="收起"
              @click="closeClipOverlay"
            >
              ✕
            </button>
          </div>

          <div class="relative aspect-video bg-black">
            <div
              v-if="clipLoading"
              class="absolute inset-0 flex items-center justify-center text-sm text-neutral-400"
            >
              加载中…
            </div>
            <div
              v-else-if="clipError"
              class="absolute inset-0 flex items-center justify-center px-6 text-center text-sm text-rose-300"
            >
              {{ clipError }}
            </div>
            <video
              v-show="clipData && !clipError"
              ref="clipVideoRef"
              class="h-full w-full object-contain"
              playsinline
              controls
              @timeupdate="onClipTimeUpdate"
              @ended="onClipEnded"
            />
          </div>

          <div
            v-if="clipData && !clipError && (clipSubtitleParts.length || clipSubtitleZh)"
            class="px-4 py-3 border-t border-white/10 space-y-1.5"
          >
            <p
              v-if="clipSubtitleParts.length"
              class="text-sm sm:text-[0.95rem] text-neutral-200 leading-relaxed text-center"
            >
              <template v-for="(part, pi) in clipSubtitleParts" :key="`clip-sub-${pi}`">
                <mark
                  v-if="part.hit"
                  class="bg-teal-400/25 text-teal-100 rounded px-0.5 font-semibold not-italic"
                >{{ part.text }}</mark>
                <span v-else>{{ part.text }}</span>
              </template>
            </p>
            <p
              v-if="clipSubtitleZh"
              class="text-xs sm:text-sm text-neutral-400 leading-relaxed text-center"
            >
              {{ clipSubtitleZh }}
            </p>
          </div>

          <div class="flex flex-wrap items-center justify-between gap-2 px-4 py-3 border-t border-white/10">
            <div class="flex flex-wrap items-center gap-3">
              <label class="inline-flex items-center gap-2 text-xs text-neutral-300 select-none cursor-pointer">
                <input v-model="clipLoop" type="checkbox" class="rounded border-white/20 bg-transparent" />
                循环
              </label>
              <div class="inline-flex items-center gap-1" role="group" aria-label="播放倍速">
                <button
                  v-for="rate in CLIP_RATES"
                  :key="rate"
                  type="button"
                  class="text-[11px] px-2 py-1 rounded-md transition"
                  :class="
                    clipRate === rate
                      ? 'bg-teal-500/90 text-neutral-950 font-medium'
                      : 'bg-white/10 text-neutral-300 hover:bg-white/15'
                  "
                  @click="setClipRate(rate)"
                >
                  {{ rate === 1 ? '1×' : `${rate}×` }}
                </button>
              </div>
            </div>
            <button
              type="button"
              class="text-xs px-3 py-1.5 rounded-md bg-white/10 hover:bg-white/15 transition disabled:opacity-40"
              :disabled="!clipData || !!clipError"
              @click="replayClipOnce"
            >
              重播
            </button>
          </div>
        </aside>
        </div>

        <div
          class="mt-4 flex flex-wrap items-center justify-center gap-x-5 gap-y-1.5 text-[11px] text-neutral-400 dark:text-neutral-500"
        >
          <span>
            时间
            <span class="ml-1.5 tabular-nums text-ink-soft">{{ formatTime(elapsedMs) }}</span>
          </span>
          <span class="text-neutral-300 dark:text-neutral-700">·</span>
          <span>
            WPM
            <span class="ml-1.5 tabular-nums text-ink-soft">{{ started ? wpm : 0 }}</span>
          </span>
          <span class="text-neutral-300 dark:text-neutral-700">·</span>
          <span>
            正确率
            <span class="ml-1.5 tabular-nums text-ink-soft">{{ accuracyLive }}%</span>
          </span>
        </div>
      </template>
    </div>
  </div>
</template>

<style scoped>
.wp-deck {
  perspective: 1200px;
  overflow: visible;
}
.wp-deck-stage {
  overflow: visible;
}
.wp-deck-ghost {
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  top: 0;
  border-radius: 1.5rem;
  border: 1.5px solid rgba(15, 118, 110, 0.22);
  background: linear-gradient(
    180deg,
    rgba(255, 255, 255, 0.98) 0%,
    rgba(236, 242, 240, 0.96) 55%,
    rgba(226, 234, 232, 0.94) 100%
  );
  box-shadow:
    0 8px 24px -12px rgba(15, 118, 110, 0.35),
    0 1px 0 rgba(255, 255, 255, 0.75) inset;
  pointer-events: none;
}
:global(html.dark) .wp-deck-ghost {
  border-color: rgba(45, 212, 191, 0.28);
  background: linear-gradient(
    180deg,
    rgba(36, 48, 44, 0.98) 0%,
    rgba(22, 30, 28, 0.96) 55%,
    rgba(14, 20, 18, 0.95) 100%
  );
  box-shadow:
    0 10px 28px -10px rgba(0, 0, 0, 0.65),
    0 1px 0 rgba(255, 255, 255, 0.06) inset;
}
/* 错落叠牌：统一向右上错开（同一方向递进） */
.wp-deck-ghost.ghost-1 {
  z-index: 2;
  transform: translate(12px, -18px) rotate(1.6deg) scale(0.94);
}
.wp-deck-ghost.ghost-2 {
  z-index: 1;
  transform: translate(22px, -34px) rotate(2.8deg) scale(0.88);
  opacity: 0.92;
}
/* 顶边高光条：强化「上面还有牌」的感知 */
.wp-deck-ghost::before {
  content: '';
  position: absolute;
  left: 14%;
  right: 14%;
  top: 11px;
  height: 3px;
  border-radius: 999px;
  background: rgba(20, 184, 166, 0.4);
  opacity: 0.9;
}
:global(html.dark) .wp-deck-ghost::before {
  background: rgba(45, 212, 191, 0.45);
}
.wp-deck-ghost.ghost-2::before {
  top: 10px;
  opacity: 0.6;
  background: rgba(15, 118, 110, 0.3);
}
.wp-deck-card {
  will-change: transform, opacity;
  transition:
    transform 0.55s cubic-bezier(0.22, 1, 0.36, 1),
    box-shadow 0.25s ease;
}
.wp-deck-card.is-reveal {
  box-shadow: 0 18px 50px -24px rgba(20, 184, 166, 0.45);
}
.wp-deck-card.is-under-exit {
  /* 滑出期间主卡已是下一词，轻量从叠层位顶上来（不改 opacity，避免闪） */
  transform: translateY(0) scale(1);
  animation: wpCardRise 0.85s cubic-bezier(0.22, 1, 0.36, 1);
}
.wp-deck-flyaway.is-exiting {
  animation: wpCardOut 0.9s cubic-bezier(0.2, 0.85, 0.25, 1) forwards;
  pointer-events: none;
  transform-origin: 70% 40%;
  will-change: transform, opacity, filter, box-shadow;
}
.wp-deck-flyaway.is-exiting::after {
  content: '';
  position: absolute;
  inset: -2px;
  border-radius: inherit;
  pointer-events: none;
  z-index: -1;
  background: radial-gradient(
    ellipse 70% 55% at 55% 40%,
    rgba(45, 212, 191, 0.35),
    rgba(20, 184, 166, 0.08) 55%,
    transparent 75%
  );
  animation: wpCardGlow 0.9s ease-out forwards;
}
.wp-deck-flyaway__ch {
  animation: wpLetterPop 0.55s cubic-bezier(0.22, 1.4, 0.36, 1) both;
}
@keyframes wpCardOut {
  0% {
    transform: translate(0, 0) rotate(0deg) scale(1);
    opacity: 1;
    filter: blur(0);
    box-shadow:
      0 18px 50px -24px rgba(20, 184, 166, 0.45),
      0 0 0 0 rgba(45, 212, 191, 0);
  }
  18% {
    /* 先轻抬、微亮，像被弹出 */
    transform: translate(2%, -6%) rotate(-2deg) scale(1.04);
    opacity: 1;
    filter: blur(0);
    box-shadow:
      0 28px 60px -20px rgba(20, 184, 166, 0.55),
      0 0 36px 2px rgba(45, 212, 191, 0.28);
  }
  55% {
    transform: translate(18%, -14%) rotate(7deg) scale(1.01);
    opacity: 0.92;
    filter: blur(0.2px);
    box-shadow:
      0 32px 70px -18px rgba(20, 184, 166, 0.4),
      0 0 28px 0 rgba(45, 212, 191, 0.18);
  }
  100% {
    /* 右上甩出并缩小淡出 */
    transform: translate(42%, -32%) rotate(16deg) scale(0.86);
    opacity: 0;
    filter: blur(2.5px);
    box-shadow:
      0 40px 80px -10px rgba(20, 184, 166, 0.15),
      0 0 0 0 rgba(45, 212, 191, 0);
  }
}
@keyframes wpCardGlow {
  0% {
    opacity: 0;
    transform: scale(0.96);
  }
  22% {
    opacity: 1;
    transform: scale(1.02);
  }
  100% {
    opacity: 0;
    transform: scale(1.12);
  }
}
@keyframes wpLetterPop {
  0% {
    transform: translateY(0) scale(1);
  }
  35% {
    transform: translateY(-3px) scale(1.08);
  }
  100% {
    transform: translateY(0) scale(1);
  }
}
@keyframes wpCardRise {
  from {
    transform: translateY(-8px) scale(0.97);
  }
  to {
    transform: translateY(0) scale(1);
  }
}

.wp-context-en {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, Courier New,
    monospace;
}

.wp-flip {
  perspective: 900px;
}
.wp-flip-inner {
  display: grid;
  width: 100%;
  transform-style: preserve-3d;
  transition: transform 0.45s cubic-bezier(0.22, 1, 0.36, 1);
}
.wp-flip.is-flipped .wp-flip-inner {
  transform: rotateY(180deg);
}
.wp-flip-face {
  grid-area: 1 / 1;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  min-height: 3.25rem;
  padding: 0.65rem 0.75rem;
  border-radius: 0.75rem;
  background: rgba(0, 0, 0, 0.025);
  backface-visibility: hidden;
  -webkit-backface-visibility: hidden;
  box-sizing: border-box;
}
:global(html.dark) .wp-flip-face {
  background: rgba(255, 255, 255, 0.04);
}
.wp-flip-back {
  transform: rotateY(180deg);
}
.wp-letter {
  border-bottom: 2px solid transparent;
  padding-bottom: 0.12em;
}
.wp-letter.is-idle {
  color: inherit;
  border-color: transparent;
}
.wp-letter.is-ok {
  color: #0d9488;
  border-color: transparent;
}
.wp-letter.is-cursor {
  color: inherit;
  border-color: #14b8a6;
  animation: wpCaret 1s steps(1) infinite;
}
.wp-letter.is-bad {
  color: #f43f5e;
  border-color: #fb7185;
}
.wp-letter.is-reveal {
  color: #0d9488;
  border-color: transparent;
}
:global(html.dark) .wp-letter.is-ok,
:global(html.dark) .wp-letter.is-reveal {
  color: #5eead4;
}

@keyframes wpShake {
  0%,
  100% {
    transform: translateX(0);
  }
  25% {
    transform: translateX(-4px);
  }
  75% {
    transform: translateX(4px);
  }
}
@keyframes wpCaret {
  50% {
    opacity: 0;
  }
}
@keyframes wpPulseSoft {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.72;
  }
}
@keyframes wpFadeUp {
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
