<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from 'vue'
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

const listening = ref(false)
const loading = ref(false)
const error = ref('')
const transcript = ref('')
const result = ref<AiShadowingResult | null>(null)
const showEditor = ref(false)

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let recognition: any = null

const sentenceLabel = computed(() => {
  const total = props.sentenceTotal ?? 0
  const idx = props.sentenceIndex
  if (total > 0 && idx != null && idx >= 0) return `${idx + 1} / ${total}`
  return ''
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

function getRecognition() {
  const SR =
    typeof window !== 'undefined'
      ? (window as unknown as { SpeechRecognition?: new () => unknown; webkitSpeechRecognition?: new () => unknown })
          .SpeechRecognition ||
        (window as unknown as { webkitSpeechRecognition?: new () => unknown }).webkitSpeechRecognition
      : undefined
  return SR ? new SR() : null
}

function resetState() {
  stopListening()
  transcript.value = ''
  result.value = null
  error.value = ''
  loading.value = false
  showEditor.value = false
}

function stopListening() {
  try {
    recognition?.stop?.()
  } catch {
    /* ignore */
  }
  listening.value = false
}

async function startListening() {
  error.value = ''
  result.value = null
  transcript.value = ''
  showEditor.value = true
  const rec = getRecognition()
  if (!rec) {
    error.value = '当前浏览器不支持语音识别，可手动输入跟读内容后点评'
    showEditor.value = true
    return
  }
  recognition = rec
  recognition.lang = 'en-US'
  recognition.interimResults = true
  recognition.continuous = false
  recognition.onresult = (event: {
    results: { [i: number]: { [j: number]: { transcript: string } }; length: number }
  }) => {
    let text = ''
    for (let i = 0; i < event.results.length; i++) {
      text += event.results[i][0]?.transcript || ''
    }
    transcript.value = text.trim()
  }
  recognition.onerror = () => {
    listening.value = false
    if (!transcript.value) error.value = '语音识别失败，请重试或手动输入'
  }
  recognition.onend = () => {
    listening.value = false
  }
  listening.value = true
  recognition.start()
}

function retry() {
  result.value = null
  error.value = ''
  transcript.value = ''
  showEditor.value = false
  void startListening()
}

async function submitFeedback() {
  if (!props.subtitleId) return
  if (!transcript.value.trim()) {
    error.value = '请先跟读或输入内容'
    showEditor.value = true
    return
  }
  loading.value = true
  error.value = ''
  stopListening()
  try {
    result.value = await aiShadowingFeedback(props.videoId, props.subtitleId, transcript.value)
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = typeof msg === 'string' ? msg : '点评失败，请稍后重试'
  } finally {
    loading.value = false
  }
}

function onNext() {
  stopListening()
  emit('next')
}

watch(
  () => props.open,
  (v) => {
    if (typeof document !== 'undefined') {
      document.body.style.overflow = v ? 'hidden' : ''
    }
    if (!v) resetState()
  },
)

watch(
  () => props.subtitleId,
  (id, prev) => {
    if (props.open && id != null && id !== prev) resetState()
  },
)

onUnmounted(() => {
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
        class="w-full sm:max-w-lg max-h-[88dvh] flex flex-col rounded-t-2xl sm:rounded-2xl bg-[#FDFBF7] dark:bg-neutral-900 border border-black/5 dark:border-white/10 shadow-xl overflow-hidden"
      >
        <!-- Header -->
        <div class="shrink-0 flex items-start justify-between gap-3 px-5 pt-4 pb-3 border-b border-black/5 dark:border-white/10">
          <div class="min-w-0">
            <div class="flex items-center gap-2">
              <h2 class="text-base font-semibold tracking-tight">跟读打分</h2>
              <span
                v-if="sentenceLabel"
                class="text-[11px] font-medium px-1.5 py-0.5 rounded-md bg-amber-100 text-amber-900 dark:bg-amber-950/50 dark:text-amber-300"
              >
                {{ sentenceLabel }}
              </span>
            </div>
            <p class="text-xs text-neutral-500 mt-0.5">听原句 → 跟读 → AI 点评 → 下一句</p>
          </div>
          <button
            type="button"
            class="text-sm text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200 shrink-0"
            @click="$emit('close')"
          >
            关闭
          </button>
        </div>

        <div class="flex-1 min-h-0 overflow-y-auto overscroll-contain px-5 py-4 space-y-4">
          <!-- Target sentence -->
          <section class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-800/50 p-3.5 space-y-2.5">
            <p class="text-[15px] sm:text-base font-medium leading-relaxed text-neutral-900 dark:text-neutral-100">
              {{ english }}
            </p>
            <p v-if="chinese" class="text-sm text-neutral-500 dark:text-neutral-400 leading-relaxed">
              {{ chinese }}
            </p>
            <button
              type="button"
              class="inline-flex items-center gap-1.5 text-xs font-medium text-amber-800 dark:text-amber-300 hover:underline"
              @click="$emit('play')"
            >
              <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                <path d="M8 5v14l11-7L8 5z" />
              </svg>
              听原句
            </button>
          </section>

          <!-- Record CTA -->
          <section class="flex flex-col items-center gap-3 py-1">
            <button
              type="button"
              class="relative w-[4.5rem] h-[4.5rem] rounded-full flex items-center justify-center text-white shadow-md transition disabled:opacity-60"
              :class="
                listening
                  ? 'bg-rose-500 shadow-rose-500/30'
                  : 'bg-amber-600 hover:bg-amber-700 shadow-amber-600/25'
              "
              :disabled="loading"
              :aria-label="listening ? '正在识别' : '开始跟读'"
              @click="listening ? stopListening() : startListening()"
            >
              <span
                v-if="listening"
                class="absolute inset-0 rounded-full bg-rose-400/40 animate-ping"
                aria-hidden="true"
              />
              <svg v-if="!listening" width="26" height="26" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                <path
                  d="M12 14a3 3 0 0 0 3-3V6a3 3 0 1 0-6 0v5a3 3 0 0 0 3 3zm5-3a5 5 0 0 1-10 0H5a7 7 0 0 0 6 6.92V21h2v-3.08A7 7 0 0 0 19 11h-2z"
                />
              </svg>
              <svg v-else width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                <rect x="6" y="6" width="12" height="12" rx="2" />
              </svg>
            </button>
            <p class="text-xs text-neutral-500">
              {{ listening ? '正在听你说… 点击停止' : '点击麦克风开始跟读' }}
            </p>
            <div class="flex flex-wrap justify-center gap-2">
              <button
                type="button"
                class="px-3 py-1.5 rounded-lg text-xs border border-black/10 dark:border-white/15 hover:bg-black/5 dark:hover:bg-white/5"
                @click="showEditor = !showEditor"
              >
                {{ showEditor ? '收起文本' : '手输 / 修改' }}
              </button>
              <button
                type="button"
                class="px-3 py-1.5 rounded-lg text-xs font-medium bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900 disabled:opacity-50"
                :disabled="loading || !transcript.trim()"
                @click="submitFeedback"
              >
                {{ loading ? '点评中…' : '提交 AI 点评' }}
              </button>
            </div>
          </section>

          <div v-if="showEditor || transcript" class="space-y-1.5">
            <label class="block text-xs text-neutral-500">识别 / 手输文本</label>
            <textarea
              v-model="transcript"
              rows="2"
              class="w-full rounded-xl border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-800 px-3 py-2 text-sm leading-relaxed"
              placeholder="跟读结果会出现在这里，也可手动修改"
            />
          </div>

          <p v-if="error" class="text-sm text-red-600 dark:text-red-400">{{ error }}</p>

          <!-- Score result -->
          <section
            v-if="result"
            class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-800/40 p-4 space-y-3"
          >
            <div class="flex items-center gap-4">
              <div
                class="relative w-16 h-16 rounded-full shrink-0 p-[3px]"
                :style="scoreRingStyle"
              >
                <div
                  class="w-full h-full rounded-full bg-[#FDFBF7] dark:bg-neutral-900 flex flex-col items-center justify-center"
                >
                  <span class="text-lg font-bold leading-none tabular-nums">{{ result.score }}</span>
                  <span class="text-[10px] text-neutral-400 mt-0.5">分</span>
                </div>
              </div>
              <div class="min-w-0">
                <p
                  class="text-sm font-semibold"
                  :class="{
                    'text-emerald-700 dark:text-emerald-300': scoreTone === 'emerald',
                    'text-amber-800 dark:text-amber-300': scoreTone === 'amber',
                    'text-rose-700 dark:text-rose-300': scoreTone === 'rose',
                  }"
                >
                  {{ result.level || '已点评' }}
                </p>
                <p v-if="result.praise" class="text-sm text-neutral-600 dark:text-neutral-300 mt-1 leading-relaxed">
                  {{ result.praise }}
                </p>
              </div>
            </div>

            <div v-if="result.issues?.length" class="space-y-1">
              <p class="text-[11px] font-medium text-neutral-500">待改进</p>
              <ul class="space-y-1 text-sm text-neutral-700 dark:text-neutral-300">
                <li v-for="(item, i) in result.issues" :key="`i-${i}`" class="flex gap-2">
                  <span class="text-rose-500 shrink-0">·</span>
                  <span>{{ item }}</span>
                </li>
              </ul>
            </div>
            <div v-if="result.tips?.length" class="space-y-1">
              <p class="text-[11px] font-medium text-neutral-500">小建议</p>
              <ul class="space-y-1 text-sm text-neutral-700 dark:text-neutral-300">
                <li v-for="(item, i) in result.tips" :key="`t-${i}`" class="flex gap-2">
                  <span class="text-amber-600 shrink-0">·</span>
                  <span>{{ item }}</span>
                </li>
              </ul>
            </div>
          </section>
        </div>

        <!-- Footer -->
        <div
          class="shrink-0 flex items-center gap-2 px-5 py-3 border-t border-black/5 dark:border-white/10 bg-white/80 dark:bg-neutral-900/90 backdrop-blur-sm pb-[max(0.75rem,env(safe-area-inset-bottom))]"
        >
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
            class="flex-[1.2] px-3 py-2.5 rounded-xl text-sm font-medium bg-amber-600 text-white hover:bg-amber-700 disabled:opacity-50"
            :disabled="loading || listening"
            @click="onNext"
          >
            {{ hasNext === false ? '完成' : '下一句' }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
