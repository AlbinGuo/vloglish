<script setup lang="ts">
import { computed, nextTick, onUnmounted, ref, watch } from 'vue'
import { aiShadowingFeedback, type AiShadowingResult } from '@/api/aiCoach'

const props = defineProps<{
  open: boolean
  videoId: string
  subtitleId: number | null
  english: string
  chinese?: string
  sentenceIndex?: number
  sentenceTotal?: number
  hasNext?: boolean
}>()

const emit = defineEmits<{ close: []; play: []; next: [] }>()

type Step = 'listen' | 'record' | 'result'

const step = ref<Step>('listen')
const listening = ref(false)
const loading = ref(false)
const error = ref('')
const transcript = ref('')
const result = ref<AiShadowingResult | null>(null)
const showTips = ref(false)
const micUnsupported = ref(false)
const autoSubmitArmed = ref(false)

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let recognition: any = null
let autoPlayTimer: ReturnType<typeof setTimeout> | null = null

const sentenceLabel = computed(() => {
  const total = props.sentenceTotal ?? 0
  const idx = props.sentenceIndex
  if (total > 0 && idx != null && idx >= 0) return `${idx + 1} / ${total}`
  return ''
})

const progressPercent = computed(() => {
  const total = props.sentenceTotal ?? 0
  const idx = props.sentenceIndex
  if (total <= 0 || idx == null || idx < 0) return 0
  return Math.round(((idx + 1) / total) * 100)
})

const scoreTone = computed(() => {
  const s = result.value?.score ?? 0
  if (s >= 80) return 'emerald'
  if (s >= 60) return 'amber'
  return 'rose'
})

const scoreRingStyle = computed(() => {
  const score = Math.max(0, Math.min(100, Number(result.value?.score) || 0))
  const deg = (score / 100) * 360
  const color =
    scoreTone.value === 'emerald'
      ? 'rgb(16 185 129)'
      : scoreTone.value === 'amber'
        ? 'rgb(245 158 11)'
        : 'rgb(244 63 94)'
  return {
    background: `conic-gradient(${color} ${deg}deg, rgb(229 229 229) 0deg)`,
  }
})

const stepMeta = computed(() => {
  if (step.value === 'listen') return { n: 1, label: '听原句' }
  if (step.value === 'record') return { n: 2, label: '跟读' }
  return { n: 3, label: '看点评' }
})

type SpeechRecognitionCtor = new () => {
  lang: string
  interimResults: boolean
  continuous: boolean
  maxAlternatives: number
  start: () => void
  stop: () => void
  abort?: () => void
  onresult: ((event: {
    results: { [i: number]: { [j: number]: { transcript: string }; isFinal?: boolean }; length: number }
  }) => void) | null
  onerror: ((event: { error?: string; message?: string }) => void) | null
  onend: (() => void) | null
}

function getRecognitionCtor(): SpeechRecognitionCtor | null {
  if (typeof window === 'undefined') return null
  const w = window as unknown as {
    SpeechRecognition?: SpeechRecognitionCtor
    webkitSpeechRecognition?: SpeechRecognitionCtor
  }
  return w.SpeechRecognition || w.webkitSpeechRecognition || null
}

function mapRecognitionError(code: string): string {
  switch (code) {
    case 'not-allowed':
    case 'service-not-allowed':
      return '麦克风权限被拒绝，请在浏览器地址栏允许后重试'
    case 'no-speech':
      return '没有听清，请靠近麦克风再说一次'
    case 'audio-capture':
      return '找不到可用麦克风'
    case 'network':
      return '语音识别暂不可用，可直接输入英文后点评'
    case 'language-not-supported':
      return '当前浏览器不支持英语识别，可直接输入英文后点评'
    case 'aborted':
      return ''
    default:
      return '识别失败，可直接输入英文后点评'
  }
}

async function ensureMicPermission(): Promise<string | null> {
  if (typeof window === 'undefined') return '当前环境无法使用麦克风'
  if (!window.isSecureContext) {
    return '语音识别需要 HTTPS 或 localhost'
  }
  if (!navigator.mediaDevices?.getUserMedia) return null
  try {
    const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
    stream.getTracks().forEach((t) => t.stop())
    return null
  } catch (e: unknown) {
    const name = (e as { name?: string })?.name || ''
    if (name === 'NotAllowedError' || name === 'PermissionDeniedError') {
      return '麦克风权限被拒绝，请在浏览器地址栏允许后重试'
    }
    if (name === 'NotFoundError' || name === 'DevicesNotFoundError') {
      return '找不到可用麦克风'
    }
    return '无法打开麦克风'
  }
}

function clearAutoPlay() {
  if (autoPlayTimer != null) {
    clearTimeout(autoPlayTimer)
    autoPlayTimer = null
  }
}

function resetState() {
  clearAutoPlay()
  stopListening(true)
  step.value = 'listen'
  transcript.value = ''
  result.value = null
  error.value = ''
  loading.value = false
  showTips.value = false
  micUnsupported.value = false
  autoSubmitArmed.value = false
}

function stopListening(abort = false) {
  try {
    if (abort) recognition?.abort?.()
    else recognition?.stop?.()
  } catch {
    /* ignore */
  }
  listening.value = false
}

function playOriginal() {
  error.value = ''
  emit('play')
}

function goRecord() {
  error.value = ''
  result.value = null
  step.value = 'record'
}

async function startListening() {
  error.value = ''
  result.value = null
  transcript.value = ''
  autoSubmitArmed.value = true
  step.value = 'record'

  const Ctor = getRecognitionCtor()
  if (!Ctor) {
    micUnsupported.value = true
    error.value = '当前浏览器不支持语音识别，请输入跟读内容后点评'
    return
  }

  const micErr = await ensureMicPermission()
  if (micErr) {
    micUnsupported.value = true
    error.value = micErr
    return
  }

  stopListening(true)
  const rec = new Ctor()
  recognition = rec
  recognition.lang = 'en-US'
  recognition.interimResults = true
  recognition.continuous = false
  recognition.maxAlternatives = 1
  recognition.onresult = (event) => {
    let text = ''
    for (let i = 0; i < event.results.length; i++) {
      text += event.results[i][0]?.transcript || ''
    }
    transcript.value = text.trim()
    if (transcript.value) error.value = ''
  }
  recognition.onerror = (event) => {
    listening.value = false
    const code = String(event?.error || '')
    if (code === 'aborted') return
    if (transcript.value) return
    const msg = mapRecognitionError(code)
    if (msg) {
      error.value = msg
      micUnsupported.value = code === 'network' || code === 'language-not-supported'
    }
    autoSubmitArmed.value = false
  }
  recognition.onend = () => {
    listening.value = false
    const text = transcript.value.trim()
    if (text && autoSubmitArmed.value && !loading.value && !result.value) {
      autoSubmitArmed.value = false
      void submitFeedback()
    }
  }

  try {
    listening.value = true
    recognition.start()
  } catch (e: unknown) {
    listening.value = false
    autoSubmitArmed.value = false
    const name = (e as { name?: string })?.name || ''
    if (name === 'InvalidStateError') {
      try {
        recognition.abort?.()
      } catch {
        /* ignore */
      }
      error.value = '识别尚未结束，请稍后再点'
    } else {
      micUnsupported.value = true
      error.value = '语音识别启动失败，请输入英文后点评'
    }
  }
}

function toggleMic() {
  if (loading.value) return
  if (listening.value) {
    autoSubmitArmed.value = true
    stopListening(false)
    return
  }
  void startListening()
}

function retry() {
  result.value = null
  error.value = ''
  transcript.value = ''
  showTips.value = false
  autoSubmitArmed.value = false
  step.value = 'record'
  void startListening()
}

async function submitFeedback() {
  if (!props.subtitleId) return
  const text = transcript.value.trim()
  if (!text) {
    error.value = '请先跟读或输入英文'
    return
  }
  loading.value = true
  error.value = ''
  stopListening()
  autoSubmitArmed.value = false
  try {
    result.value = await aiShadowingFeedback(props.videoId, props.subtitleId, text)
    step.value = 'result'
    showTips.value = false
    await nextTick()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = typeof msg === 'string' ? msg : '点评失败，请稍后重试'
    step.value = 'record'
  } finally {
    loading.value = false
  }
}

function onNext() {
  stopListening()
  emit('next')
}

function scheduleAutoPlay() {
  clearAutoPlay()
  // 打开后轻量自动听一遍，降低「直接点麦」的失误
  autoPlayTimer = setTimeout(() => {
    autoPlayTimer = null
    if (props.open && step.value === 'listen') emit('play')
  }, 380)
}

watch(
  () => props.open,
  (v) => {
    if (typeof document !== 'undefined') {
      document.body.style.overflow = v ? 'hidden' : ''
    }
    if (!v) {
      resetState()
      return
    }
    resetState()
    scheduleAutoPlay()
  },
)

watch(
  () => props.subtitleId,
  (id, prev) => {
    if (props.open && id != null && id !== prev) {
      resetState()
      scheduleAutoPlay()
    }
  },
)

onUnmounted(() => {
  clearAutoPlay()
  stopListening()
  if (typeof document !== 'undefined') document.body.style.overflow = ''
})
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[80] flex items-end sm:items-center justify-center bg-black/45 p-0 sm:p-4"
      @click.self="$emit('close')"
    >
      <div
        class="w-full sm:max-w-lg max-h-[90dvh] flex flex-col rounded-t-2xl sm:rounded-2xl bg-[#FDFBF7] dark:bg-neutral-900 border border-black/5 dark:border-white/10 shadow-xl overflow-hidden"
      >
        <!-- Header -->
        <div class="shrink-0 px-5 pt-4 pb-3 border-b border-black/5 dark:border-white/10">
          <div class="flex items-start justify-between gap-3">
            <div class="min-w-0">
              <div class="flex items-center gap-2 flex-wrap">
                <h2 class="text-base font-semibold tracking-tight">AI 跟读</h2>
                <span
                  v-if="sentenceLabel"
                  class="text-[11px] font-medium px-1.5 py-0.5 rounded-md bg-sky-100 text-sky-900 dark:bg-sky-950/50 dark:text-sky-300"
                >
                  {{ sentenceLabel }}
                </span>
                <span
                  class="text-[11px] font-medium px-1.5 py-0.5 rounded-md bg-neutral-100 text-neutral-600 dark:bg-neutral-800 dark:text-neutral-300"
                >
                  第 {{ stepMeta.n }} 步 · {{ stepMeta.label }}
                </span>
              </div>
            </div>
            <button
              type="button"
              class="w-8 h-8 flex items-center justify-center rounded-full text-neutral-400 hover:text-neutral-700 hover:bg-black/5 dark:hover:text-neutral-200 dark:hover:bg-white/10 shrink-0"
              aria-label="关闭"
              @click="$emit('close')"
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M18 6L6 18M6 6l12 12" />
              </svg>
            </button>
          </div>
          <div
            v-if="sentenceTotal && sentenceTotal > 0"
            class="mt-3 h-1 rounded-full bg-neutral-200 dark:bg-neutral-800 overflow-hidden"
          >
            <div
              class="h-full rounded-full bg-sky-500 transition-all duration-300"
              :style="{ width: `${progressPercent}%` }"
            />
          </div>
        </div>

        <div class="flex-1 min-h-0 overflow-y-auto overscroll-contain px-5 py-4 space-y-4">
          <!-- Target sentence (always visible) -->
          <section class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-800/50 p-3.5 space-y-2">
            <p class="text-[15px] sm:text-base font-medium leading-relaxed text-neutral-900 dark:text-neutral-100">
              {{ english }}
            </p>
            <p v-if="chinese" class="text-sm text-neutral-500 dark:text-neutral-400 leading-relaxed">
              {{ chinese }}
            </p>
          </section>

          <!-- Step: listen -->
          <section v-if="step === 'listen'" class="flex flex-col items-center gap-4 py-4">
            <p class="text-sm text-neutral-500 text-center">先听清楚原句，再开始跟读</p>
            <button
              type="button"
              class="inline-flex items-center justify-center gap-2 w-full max-w-xs px-5 py-3.5 rounded-2xl text-sm font-semibold bg-amber-600 text-white hover:bg-amber-700 shadow-md shadow-amber-600/20 transition"
              @click="playOriginal"
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                <path d="M8 5v14l11-7L8 5z" />
              </svg>
              听原句
            </button>
            <button
              type="button"
              class="inline-flex items-center justify-center gap-2 w-full max-w-xs px-5 py-3 rounded-2xl text-sm font-medium border border-sky-300 text-sky-800 bg-sky-50 hover:bg-sky-100 dark:border-sky-700 dark:text-sky-200 dark:bg-sky-950/40 dark:hover:bg-sky-950/60 transition"
              @click="goRecord"
            >
              听完了，开始跟读
            </button>
          </section>

          <!-- Step: record -->
          <section v-else-if="step === 'record'" class="flex flex-col items-center gap-3 py-2">
            <button
              type="button"
              class="relative w-[5rem] h-[5rem] rounded-full flex items-center justify-center text-white shadow-md transition disabled:opacity-60"
              :class="
                listening
                  ? 'bg-rose-500 shadow-rose-500/30'
                  : loading
                    ? 'bg-neutral-400'
                    : 'bg-sky-600 hover:bg-sky-700 shadow-sky-600/25'
              "
              :disabled="loading"
              :aria-label="listening ? '停止跟读' : '开始跟读'"
              @click="toggleMic"
            >
              <span
                v-if="listening"
                class="absolute inset-0 rounded-full bg-rose-400/40 animate-ping"
                aria-hidden="true"
              />
              <svg
                v-if="loading"
                class="animate-spin"
                width="26"
                height="26"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                aria-hidden="true"
              >
                <path d="M12 3a9 9 0 1 0 9 9" stroke-linecap="round" />
              </svg>
              <svg
                v-else-if="!listening"
                width="28"
                height="28"
                viewBox="0 0 24 24"
                fill="currentColor"
                aria-hidden="true"
              >
                <path
                  d="M12 14a3 3 0 0 0 3-3V6a3 3 0 1 0-6 0v5a3 3 0 0 0 3 3zm5-3a5 5 0 0 1-10 0H5a7 7 0 0 0 6 6.92V21h2v-3.08A7 7 0 0 0 19 11h-2z"
                />
              </svg>
              <svg v-else width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                <rect x="6" y="6" width="12" height="12" rx="2" />
              </svg>
            </button>

            <p class="text-sm text-neutral-600 dark:text-neutral-300 text-center min-h-[1.25rem]">
              <template v-if="loading">正在点评…</template>
              <template v-else-if="listening">正在听你说… 说完再点一下停止</template>
              <template v-else-if="micUnsupported">语音识别不可用时，可在下方输入英文</template>
              <template v-else>点击麦克风跟读，停止后自动点评</template>
            </p>

            <button
              type="button"
              class="text-xs text-neutral-500 hover:text-amber-700 dark:hover:text-amber-300 underline underline-offset-2"
              @click="playOriginal"
            >
              再听一遍原句
            </button>

            <div class="w-full space-y-1.5 pt-1">
              <label class="block text-xs text-neutral-500">
                {{ micUnsupported || error ? '输入你跟读的英文' : '识别结果（可修改）' }}
              </label>
              <textarea
                v-model="transcript"
                rows="2"
                class="w-full rounded-xl border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-800 px-3 py-2.5 text-sm leading-relaxed"
                :placeholder="micUnsupported ? '在此输入英文，然后点下方点评' : '跟读内容会出现在这里'"
              />
            </div>

            <p v-if="error" class="w-full text-sm text-amber-800 dark:text-amber-300 bg-amber-50 dark:bg-amber-950/30 rounded-xl px-3 py-2">
              {{ error }}
            </p>
          </section>

          <!-- Step: result -->
          <section v-else-if="step === 'result' && result" class="space-y-3">
            <div
              class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-800/40 p-4"
            >
              <div class="flex items-center gap-4">
                <div class="relative w-[4.5rem] h-[4.5rem] rounded-full shrink-0 p-[3px]" :style="scoreRingStyle">
                  <div
                    class="w-full h-full rounded-full bg-[#FDFBF7] dark:bg-neutral-900 flex flex-col items-center justify-center"
                  >
                    <span class="text-xl font-bold leading-none tabular-nums">{{ result.score }}</span>
                    <span class="text-[10px] text-neutral-400 mt-0.5">分</span>
                  </div>
                </div>
                <div class="min-w-0">
                  <p
                    class="text-base font-semibold"
                    :class="{
                      'text-emerald-700 dark:text-emerald-300': scoreTone === 'emerald',
                      'text-amber-800 dark:text-amber-300': scoreTone === 'amber',
                      'text-rose-700 dark:text-rose-300': scoreTone === 'rose',
                    }"
                  >
                    {{ result.level || '已点评' }}
                  </p>
                  <p
                    v-if="result.praise"
                    class="text-sm text-neutral-600 dark:text-neutral-300 mt-1 leading-relaxed"
                  >
                    {{ result.praise }}
                  </p>
                </div>
              </div>
            </div>

            <div
              v-if="(result.issues?.length || result.tips?.length)"
              class="rounded-xl border border-black/5 dark:border-white/10 bg-white/70 dark:bg-neutral-800/30 overflow-hidden"
            >
              <button
                type="button"
                class="w-full flex items-center justify-between px-3.5 py-2.5 text-sm text-neutral-600 dark:text-neutral-300"
                @click="showTips = !showTips"
              >
                <span>{{ showTips ? '收起改进建议' : '查看改进建议' }}</span>
                <svg
                  width="16"
                  height="16"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                  class="transition-transform"
                  :class="showTips ? 'rotate-180' : ''"
                >
                  <path d="m6 9 6 6 6-6" />
                </svg>
              </button>
              <div v-if="showTips" class="px-3.5 pb-3 space-y-3 border-t border-black/5 dark:border-white/10 pt-3">
                <div v-if="result.issues?.length" class="space-y-1">
                  <p class="text-[11px] font-medium text-neutral-500">待改进</p>
                  <ul class="space-y-1 text-sm text-neutral-700 dark:text-neutral-300">
                    <li v-for="(item, i) in result.issues.slice(0, 2)" :key="`i-${i}`" class="flex gap-2">
                      <span class="text-rose-500 shrink-0">·</span>
                      <span>{{ item }}</span>
                    </li>
                  </ul>
                </div>
                <div v-if="result.tips?.length" class="space-y-1">
                  <p class="text-[11px] font-medium text-neutral-500">小建议</p>
                  <ul class="space-y-1 text-sm text-neutral-700 dark:text-neutral-300">
                    <li v-for="(item, i) in result.tips.slice(0, 2)" :key="`t-${i}`" class="flex gap-2">
                      <span class="text-amber-600 shrink-0">·</span>
                      <span>{{ item }}</span>
                    </li>
                  </ul>
                </div>
              </div>
            </div>

            <p v-if="transcript" class="text-xs text-neutral-400 px-0.5">
              你说的：{{ transcript }}
            </p>
          </section>
        </div>

        <!-- Footer：随阶段变化 -->
        <div
          class="shrink-0 flex items-center gap-2 px-5 py-3 border-t border-black/5 dark:border-white/10 bg-white/80 dark:bg-neutral-900/90 backdrop-blur-sm pb-[max(0.75rem,env(safe-area-inset-bottom))]"
        >
          <template v-if="step === 'listen'">
            <button
              type="button"
              class="flex-1 px-3 py-2.5 rounded-xl text-sm text-neutral-500 hover:bg-black/5 dark:hover:bg-white/5"
              @click="$emit('close')"
            >
              稍后再练
            </button>
            <button
              type="button"
              class="flex-[1.4] px-3 py-2.5 rounded-xl text-sm font-medium bg-sky-600 text-white hover:bg-sky-700"
              @click="goRecord"
            >
              开始跟读
            </button>
          </template>

          <template v-else-if="step === 'record'">
            <button
              type="button"
              class="flex-1 px-3 py-2.5 rounded-xl text-sm border border-black/10 dark:border-white/15 hover:bg-black/5 dark:hover:bg-white/5 disabled:opacity-40"
              :disabled="loading || listening"
              @click="step = 'listen'"
            >
              返回听原句
            </button>
            <button
              type="button"
              class="flex-[1.2] px-3 py-2.5 rounded-xl text-sm font-medium bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900 disabled:opacity-40"
              :disabled="loading || listening || !transcript.trim()"
              @click="submitFeedback"
            >
              {{ loading ? '点评中…' : '提交点评' }}
            </button>
          </template>

          <template v-else>
            <button
              type="button"
              class="flex-1 px-3 py-2.5 rounded-xl text-sm border border-black/10 dark:border-white/15 hover:bg-black/5 dark:hover:bg-white/5 disabled:opacity-40"
              :disabled="loading || listening"
              @click="retry"
            >
              再试一次
            </button>
            <button
              type="button"
              class="flex-[1.3] px-3 py-2.5 rounded-xl text-sm font-medium bg-amber-600 text-white hover:bg-amber-700"
              @click="onNext"
            >
              {{ hasNext === false ? '完成' : '下一句' }}
            </button>
          </template>
        </div>
      </div>
    </div>
  </Teleport>
</template>
