<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { fetchPracticeTts } from '@/api/practiceTts'
import { getPracticeRecord, type PracticeRecord } from '@/api/practiceRecords'
import { useAudioDuration } from '@/composables/useAudioDuration'
import { buildPracticeFeedbackSpeech } from '@/utils/practiceFeedbackSpeech'

const props = defineProps<{
  open: boolean
  recordId: number | null
  sourcePath?: string
  playing?: boolean
}>()

const emit = defineEmits<{
  close: []
  play: [item: PracticeRecord]
  remove: [item: PracticeRecord]
}>()

const MODE_LABEL: Record<string, string> = {
  word: '单词',
  sentence: '句子',
  passage: '篇章',
  shadow: '影子',
}

const loading = ref(false)
const error = ref('')
const detail = ref<PracticeRecord | null>(null)
const feedbackTtsPlaying = ref(false)
const feedbackTtsLoading = ref(false)
let loadToken = 0
let feedbackToken = 0
let feedbackAudio: HTMLAudioElement | null = null
let feedbackObjectUrl: string | null = null

const modeLabel = computed(() => MODE_LABEL[detail.value?.mode || ''] || detail.value?.mode || '')

const scoreTone = computed(() => {
  const s = detail.value?.score ?? 0
  if (s >= 80) return 'good'
  if (s >= 60) return 'mid'
  return 'low'
})

const scoreRingStyle = computed(() => {
  const score = Math.max(0, Math.min(100, Number(detail.value?.score) || 0))
  const deg = (score / 100) * 360
  const color =
    scoreTone.value === 'good'
      ? 'rgb(5 150 105)'
      : scoreTone.value === 'mid'
        ? 'rgb(217 119 6)'
        : 'rgb(225 29 72)'
  return { background: `conic-gradient(${color} ${deg}deg, rgb(229 229 229) 0deg)` }
})

const dimensionItems = computed(() => {
  const r = detail.value
  if (!r) return [] as { key: string; label: string; value: number }[]
  const items: { key: string; label: string; value: number }[] = []
  if (r.accuracy != null) items.push({ key: 'accuracy', label: '准确', value: r.accuracy })
  if (r.fluency != null) items.push({ key: 'fluency', label: '流利', value: r.fluency })
  if (r.mode === 'passage' && r.integrity != null) {
    items.push({ key: 'integrity', label: '完整', value: r.integrity })
  } else if (r.rhythm != null && r.mode !== 'word') {
    items.push({ key: 'rhythm', label: '韵律', value: r.rhythm })
  } else if (r.integrity != null) {
    items.push({ key: 'integrity', label: '完整', value: r.integrity })
  }
  return items
})

const issues = computed(() => (Array.isArray(detail.value?.issues) ? detail.value!.issues! : []).filter(Boolean))
const tips = computed(() => (Array.isArray(detail.value?.tips) ? detail.value!.tips! : []).filter(Boolean))
const words = computed(() => (Array.isArray(detail.value?.words) ? detail.value!.words! : []))

const detailAudioUrl = computed(() =>
  detail.value?.has_audio ? (detail.value.audio_url || '').trim() : '',
)
const { label: durationLabel } = useAudioDuration(detailAudioUrl)

function wordToneClass(score: number) {
  if (score >= 80) return 'bg-emerald-100 text-emerald-900 dark:bg-emerald-900/40 dark:text-emerald-200'
  if (score >= 60) return 'bg-amber-100 text-amber-900 dark:bg-amber-900/40 dark:text-amber-200'
  return 'bg-rose-100 text-rose-900 dark:bg-rose-900/40 dark:text-rose-200'
}

function formatTime(iso: string | null | undefined) {
  if (!iso) return ''
  const d = new Date(iso.endsWith('Z') ? iso : `${iso}Z`)
  if (Number.isNaN(d.getTime())) return ''
  const y = d.getFullYear()
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  const hh = String(d.getHours()).padStart(2, '0')
  const mi = String(d.getMinutes()).padStart(2, '0')
  return `${y}-${mm}-${dd} ${hh}:${mi}`
}

function stopFeedbackTts() {
  feedbackToken += 1
  feedbackTtsPlaying.value = false
  feedbackTtsLoading.value = false
  if (feedbackAudio) {
    try {
      feedbackAudio.pause()
      feedbackAudio.onended = null
      feedbackAudio.onerror = null
      feedbackAudio.removeAttribute('src')
      feedbackAudio.load()
    } catch {
      /* ignore */
    }
    feedbackAudio = null
  }
  if (feedbackObjectUrl) {
    URL.revokeObjectURL(feedbackObjectUrl)
    feedbackObjectUrl = null
  }
}

async function playFeedbackTts() {
  const target = detail.value
  if (!target) return
  const speech = buildPracticeFeedbackSpeech(target).trim()
  if (!speech) return

  // 与录音回听互斥
  if (props.playing) emit('play', target)

  const token = ++feedbackToken
  feedbackTtsLoading.value = true
  try {
    const blob = await fetchPracticeTts(speech, 'Katerina', 'sentence')
    if (token !== feedbackToken || !props.open) return
    if (feedbackObjectUrl) {
      URL.revokeObjectURL(feedbackObjectUrl)
      feedbackObjectUrl = null
    }
    if (feedbackAudio) {
      try {
        feedbackAudio.pause()
      } catch {
        /* ignore */
      }
      feedbackAudio = null
    }
    const url = URL.createObjectURL(blob)
    feedbackObjectUrl = url
    const audio = new Audio(url)
    feedbackAudio = audio
    audio.onended = () => {
      if (token === feedbackToken) {
        feedbackTtsPlaying.value = false
        feedbackAudio = null
      }
    }
    audio.onerror = () => {
      if (token === feedbackToken) {
        feedbackTtsPlaying.value = false
        feedbackAudio = null
      }
    }
    feedbackTtsPlaying.value = true
    await audio.play()
  } catch {
    if (token === feedbackToken) feedbackTtsPlaying.value = false
  } finally {
    if (token === feedbackToken) feedbackTtsLoading.value = false
  }
}

function toggleFeedbackTts() {
  if (feedbackTtsLoading.value) return
  if (feedbackTtsPlaying.value) {
    stopFeedbackTts()
    return
  }
  void playFeedbackTts()
}

async function loadDetail(id: number) {
  stopFeedbackTts()
  const token = ++loadToken
  loading.value = true
  error.value = ''
  try {
    const data = await getPracticeRecord(id)
    if (token !== loadToken) return
    detail.value = data
  } catch (e: unknown) {
    if (token !== loadToken) return
    detail.value = null
    error.value = e instanceof Error && e.message.trim() ? e.message.trim() : '加载详情失败'
  } finally {
    if (token === loadToken) loading.value = false
  }
}

watch(
  () => [props.open, props.recordId] as const,
  ([open, id]) => {
    if (!open || id == null) {
      stopFeedbackTts()
      detail.value = null
      error.value = ''
      loading.value = false
      return
    }
    void loadDetail(id)
  },
)

watch(
  () => props.open,
  (open) => {
    if (typeof document === 'undefined') return
    document.body.style.overflow = open ? 'hidden' : ''
    if (!open) stopFeedbackTts()
  },
)

watch(
  () => props.playing,
  (playing) => {
    if (playing) stopFeedbackTts()
  },
)

onUnmounted(() => {
  loadToken += 1
  stopFeedbackTts()
  if (typeof document !== 'undefined') document.body.style.overflow = ''
})

function onPlay() {
  stopFeedbackTts()
  if (detail.value) emit('play', detail.value)
}

function onRemove() {
  stopFeedbackTts()
  if (detail.value) emit('remove', detail.value)
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[520] flex items-end sm:items-center justify-center bg-neutral-950/50 p-0 sm:p-4 backdrop-blur-[2px]"
      @click.self="emit('close')"
    >
      <div
        class="w-full sm:max-w-lg max-h-[92dvh] flex flex-col rounded-t-[1.75rem] sm:rounded-[1.75rem] bg-[#FBF8F3] dark:bg-neutral-950 border border-black/5 dark:border-white/10 overflow-hidden"
      >
        <div class="shrink-0 px-5 pt-4 pb-3">
          <div class="mx-auto mb-3 h-1 w-10 rounded-full bg-neutral-300/80 dark:bg-neutral-700 sm:hidden" />
          <div class="flex items-start justify-between gap-3">
            <div class="min-w-0">
              <h2 class="text-[17px] font-semibold tracking-tight text-neutral-900 dark:text-neutral-50">
                练习详情
              </h2>
              <p class="mt-1 text-[12px] text-neutral-500 dark:text-neutral-400">
                <span v-if="modeLabel">{{ modeLabel }}</span>
                <span v-if="detail?.level" class="mx-1 opacity-40">·</span>
                <span v-if="detail?.level">{{ detail.level }}</span>
                <span v-if="formatTime(detail?.created_at)" class="mx-1 opacity-40">·</span>
                <span v-if="formatTime(detail?.created_at)">{{ formatTime(detail?.created_at) }}</span>
              </p>
            </div>
            <button
              type="button"
              class="w-9 h-9 flex items-center justify-center rounded-full text-neutral-400 hover:text-neutral-700 hover:bg-black/5 dark:hover:text-neutral-200 dark:hover:bg-white/10 shrink-0"
              aria-label="关闭"
              @click="emit('close')"
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M18 6L6 18M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        <div class="flex-1 min-h-0 overflow-y-auto overscroll-contain px-5 pb-[max(1.25rem,env(safe-area-inset-bottom))] space-y-3.5">
          <div v-if="loading" class="py-16 text-center text-sm text-neutral-400">加载中…</div>
          <div v-else-if="error" class="py-10 text-center text-sm text-rose-600 dark:text-rose-400">{{ error }}</div>

          <template v-else-if="detail">
            <!-- Cover + score -->
            <section class="rounded-2xl border border-black/[0.06] dark:border-white/10 bg-white dark:bg-neutral-900 overflow-hidden">
              <div class="relative aspect-[2.2/1] sm:aspect-[16/9] bg-neutral-200 dark:bg-neutral-800">
                <img
                  v-if="detail.cover_url"
                  :src="detail.cover_url"
                  alt=""
                  class="h-full w-full object-cover"
                />
                <div
                  v-else
                  class="flex h-full w-full items-center justify-center bg-gradient-to-br from-amber-100 to-orange-50 dark:from-amber-950/40 dark:to-orange-950/30 text-sm text-neutral-500"
                >
                  {{ detail.title || modeLabel || '练习' }}
                </div>
              </div>
              <div class="p-4">
                <div class="flex items-center gap-4">
                  <div class="relative w-[4.75rem] h-[4.75rem] rounded-full shrink-0 p-[3px]" :style="scoreRingStyle">
                    <div
                      class="w-full h-full rounded-full bg-[#FBF8F3] dark:bg-neutral-950 flex flex-col items-center justify-center"
                    >
                      <span class="text-2xl font-bold leading-none tabular-nums">{{ detail.score }}</span>
                      <span class="text-[10px] text-neutral-400 mt-0.5">分</span>
                    </div>
                  </div>
                  <div class="min-w-0">
                    <p
                      class="text-lg font-semibold"
                      :class="{
                        'text-emerald-700 dark:text-emerald-300': scoreTone === 'good',
                        'text-amber-700 dark:text-amber-300': scoreTone === 'mid',
                        'text-rose-700 dark:text-rose-300': scoreTone === 'low',
                      }"
                    >
                      {{ detail.level || '已点评' }}
                    </p>
                    <p v-if="detail.title" class="mt-1 text-sm text-neutral-500 dark:text-neutral-400 truncate">
                      {{ detail.title }}
                    </p>
                    <p v-if="detail.praise" class="mt-1.5 text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
                      {{ detail.praise }}
                    </p>
                  </div>
                </div>

                <div class="mt-3.5">
                  <button
                    type="button"
                    class="relative inline-flex items-center gap-1.5 h-9 pl-1.5 pr-3 rounded-full text-[12px] font-semibold transition active:scale-[0.97] touch-manipulation disabled:opacity-60"
                    :class="
                      feedbackTtsPlaying
                        ? 'bg-violet-600 text-white shadow-[0_6px_16px_rgba(124,58,237,0.3)]'
                        : 'bg-violet-500 text-white shadow-[0_6px_14px_rgba(124,58,237,0.22)] hover:bg-violet-400'
                    "
                    :disabled="feedbackTtsLoading"
                    :aria-label="feedbackTtsPlaying ? '停止点评播报' : '听点评'"
                    @click="toggleFeedbackTts"
                  >
                    <span
                      class="relative flex h-6 w-6 items-center justify-center rounded-full bg-white/20"
                      aria-hidden="true"
                    >
                      <svg
                        v-if="feedbackTtsLoading"
                        class="animate-spin"
                        width="12"
                        height="12"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2.2"
                      >
                        <path d="M12 3a9 9 0 1 0 9 9" stroke-linecap="round" />
                      </svg>
                      <svg
                        v-else-if="feedbackTtsPlaying"
                        width="11"
                        height="11"
                        viewBox="0 0 24 24"
                        fill="currentColor"
                      >
                        <rect x="6" y="5" width="4" height="14" rx="1" />
                        <rect x="14" y="5" width="4" height="14" rx="1" />
                      </svg>
                      <svg v-else class="ml-0.5" width="12" height="12" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M8 5v14l11-7L8 5z" />
                      </svg>
                    </span>
                    <span>
                      {{
                        feedbackTtsLoading
                          ? '合成中…'
                          : feedbackTtsPlaying
                            ? '播报中'
                            : '听点评'
                      }}
                    </span>
                  </button>
                </div>

                <div
                  v-if="dimensionItems.length"
                  class="mt-4 grid gap-2"
                  :class="dimensionItems.length === 3 ? 'grid-cols-3' : 'grid-cols-2'"
                >
                  <div
                    v-for="d in dimensionItems"
                    :key="d.key"
                    class="rounded-xl bg-[#F7F3EC] dark:bg-neutral-800/80 px-2 py-2.5 text-center"
                  >
                    <p class="text-base font-semibold tabular-nums text-neutral-900 dark:text-neutral-100">
                      {{ d.value }}
                    </p>
                    <p class="text-[10px] text-neutral-500 mt-0.5">{{ d.label }}</p>
                  </div>
                </div>
              </div>
            </section>

            <!-- Text -->
            <section class="rounded-2xl border border-black/[0.06] dark:border-white/10 bg-white dark:bg-neutral-900 px-4 py-3.5">
              <p class="text-[11px] font-medium text-neutral-500 mb-1.5">练习文本</p>
              <p class="text-[15px] font-medium leading-relaxed text-neutral-900 dark:text-neutral-50">
                {{ detail.ref_text }}
              </p>
              <p
                v-if="detail.transcript && detail.transcript !== detail.ref_text"
                class="mt-2 text-sm text-neutral-500 dark:text-neutral-400 leading-relaxed"
              >
                识别：{{ detail.transcript }}
              </p>
            </section>

            <!-- Words -->
            <section
              v-if="words.length"
              class="rounded-2xl border border-black/[0.06] dark:border-white/10 bg-white/90 dark:bg-neutral-900/80 px-3.5 py-3"
            >
              <p class="text-[11px] font-medium text-neutral-500 mb-2">词级发音</p>
              <div class="flex flex-wrap gap-1.5">
                <span
                  v-for="(w, i) in words"
                  :key="`${w.char}-${i}`"
                  class="inline-flex items-center rounded-lg px-2 py-1 text-[13px] font-medium"
                  :class="wordToneClass(w.score)"
                  :title="`${w.char}: ${w.score}`"
                >
                  {{ w.char }}
                </span>
              </div>
            </section>

            <!-- Issues / tips -->
            <section
              v-if="issues.length || tips.length"
              class="rounded-2xl border border-black/[0.06] dark:border-white/10 bg-white dark:bg-neutral-900 px-4 py-3.5 space-y-3"
            >
              <div v-if="issues.length">
                <p class="text-[11px] font-medium text-neutral-500 mb-1.5">需要注意</p>
                <ul class="space-y-1.5">
                  <li
                    v-for="(issue, i) in issues"
                    :key="`issue-${i}`"
                    class="text-sm text-neutral-700 dark:text-neutral-300 leading-relaxed pl-3 border-l-2 border-amber-300/80 dark:border-amber-700/60"
                  >
                    {{ issue }}
                  </li>
                </ul>
              </div>
              <div v-if="tips.length">
                <p class="text-[11px] font-medium text-neutral-500 mb-1.5">练习建议</p>
                <ul class="space-y-1.5">
                  <li
                    v-for="(tip, i) in tips"
                    :key="`tip-${i}`"
                    class="text-sm text-neutral-700 dark:text-neutral-300 leading-relaxed pl-3 border-l-2 border-sky-300/80 dark:border-sky-700/60"
                  >
                    {{ tip }}
                  </li>
                </ul>
              </div>
            </section>

            <!-- Actions：手机上主按钮占满一行，避免文案被挤 -->
            <div class="flex flex-col gap-2 pt-1 pb-2 sm:flex-row sm:items-center">
              <button
                v-if="detail.has_audio"
                type="button"
                class="relative w-full sm:flex-[1.4] h-12 sm:h-11 rounded-2xl text-sm font-semibold text-white transition active:scale-[0.98] inline-flex items-center justify-center gap-2 overflow-hidden touch-manipulation"
                :class="
                  playing
                    ? 'bg-emerald-600 shadow-[0_10px_24px_rgba(16,185,129,0.35)]'
                    : 'bg-emerald-500 shadow-[0_10px_24px_rgba(16,185,129,0.28)] hover:bg-emerald-400'
                "
                @click="onPlay"
              >
                <span
                  v-if="playing"
                  class="absolute inset-0 bg-emerald-400/30 animate-pulse"
                  aria-hidden="true"
                />
                <span class="relative flex h-7 w-7 items-center justify-center rounded-full bg-white/20">
                  <svg v-if="playing" width="14" height="14" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                    <rect x="6" y="5" width="4" height="14" rx="1" />
                    <rect x="14" y="5" width="4" height="14" rx="1" />
                  </svg>
                  <svg v-else class="ml-0.5" width="15" height="15" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                    <path d="M8 5v14l11-7L8 5z" />
                  </svg>
                </span>
                <span class="relative">{{ playing ? '正在播放…' : '听一听自己的发音' }}</span>
                <span
                  v-if="durationLabel"
                  class="relative tabular-nums text-white/90 font-medium"
                >{{ durationLabel }}</span>
              </button>
              <div class="flex items-center gap-2">
                <RouterLink
                  v-if="sourcePath"
                  :to="sourcePath"
                  class="flex-1 h-11 rounded-2xl text-sm font-semibold bg-amber-50 text-amber-900 border border-amber-200/80 dark:bg-amber-950/40 dark:text-amber-200 dark:border-amber-800/50 inline-flex items-center justify-center touch-manipulation"
                  @click="emit('close')"
                >
                  回看来源
                </RouterLink>
                <button
                  type="button"
                  class="h-11 px-4 rounded-2xl text-sm text-neutral-500 border border-black/10 dark:border-white/15 hover:text-rose-600 hover:border-rose-200 dark:hover:text-rose-400 touch-manipulation"
                  @click="onRemove"
                >
                  删除
                </button>
              </div>
            </div>
          </template>
        </div>
      </div>
    </div>
  </Teleport>
</template>
