<script setup lang="ts">
import { computed, inject, nextTick, onUnmounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { aiShadowingFeedback, type AiShadowingResult } from '@/api/aiCoach'
import {
  aiOralEvalFeedback,
  aiShadowingOralFeedback,
  aiShadowingTextFeedback,
  coreTypeForMode,
  type OralPracticeMode,
} from '@/api/oralEval'
import { fetchPracticeTts, type PracticeTtsVoice } from '@/api/practiceTts'
import { fetchOralRemoteAudio } from '@/api/oralEvalAudio'
import { getPracticeRecord, uploadPracticeAudio } from '@/api/practiceRecords'
import { READING_TTS_KEY } from '@/composables/useReadingTts'
import { useOralEvalEngine } from '@/composables/useOralEvalEngine'
import { playWordPronunciation, stopSpeaking } from '@/utils/speakWord'
import { buildPracticeFeedbackSpeech } from '@/utils/practiceFeedbackSpeech'
import { formatAudioClock, probeAudioDuration } from '@/utils/audioDuration'
import { highlightVocabLinkText, type VocabSummaryGroup } from '@/utils/vocabSummary'
import AppIcon from '@/components/AppIcon.vue'

/** 篇章评测：按段落展示，播放中随语音切换浅底 */
export type PassagePracticeBlock = {
  english: string
  chinese?: string
  /** 初始当前句（未播放时） */
  focus?: boolean
  /** 文章段落 index，用于原声连播与同步 */
  segmentIndex?: number
}

const props = withDefaults(
  defineProps<{
    open: boolean
    /** word=单词打分 sentence=字幕跟读 passage=篇章评测 */
    mode?: OralPracticeMode
    /** 评测文本；未传时用 english */
    refText?: string
    videoId?: string
    subtitleId?: number | null
    articleId?: string
    segmentId?: number | null
    sourceType?: 'video' | 'article' | 'vocab' | 'other'
    english?: string
    chinese?: string
    /** 单词打分：音标 */
    ipa?: string
    title?: string
    sentenceIndex?: number
    sentenceTotal?: number
    hasNext?: boolean
    /** 文章难词表：篇章评测内高亮重点词 */
    vocabGroups?: VocabSummaryGroup[]
    /** 篇章分段；有则按段渲染（当前段浅底 + 词高亮） */
    passageBlocks?: PassagePracticeBlock[]
  }>(),
  {
    mode: 'sentence',
    subtitleId: null,
    segmentId: null,
    hasNext: true,
    vocabGroups: () => [],
    passageBlocks: () => [],
  },
)

const emit = defineEmits<{
  close: []
  play: [rate: number]
  pause: []
  next: []
  recording: [on: boolean]
}>()

const router = useRouter()

type Step = 'listen' | 'record' | 'result'
type EngineMode = 'oral' | 'llm' | 'unknown'

const step = ref<Step>('listen')
const listening = ref(false)
const loading = ref(false)
const error = ref('')
const transcript = ref('')
const result = ref<AiShadowingResult | null>(null)
const showTips = ref(false)
const micUnsupported = ref(false)
const autoSubmitArmed = ref(false)
const engineMode = ref<EngineMode>('unknown')
const fallbackHint = ref('')
/** 示范音倍速：0.5 慢速 / 1 正常 */
const demoRate = ref<0.5 | 1>(1)
/** original = 词典音（单词）/ 视频原声（句子） */
type DemoVoice = 'original' | PracticeTtsVoice
const demoVoice = ref<DemoVoice>('original')
const demoLoading = ref(false)
const demoPlaying = ref(false)
/** 结果页可播放地址（优先七牛 https；http 口语云会代理成 blob） */
const playbackUrl = ref('')
const playbackError = ref(false)
const playbackLoading = ref(false)
const playbackPlaying = ref(false)
const playbackProgress = ref(0)
const playbackCurrentLabel = ref('0:00')
const playbackDurationLabel = ref('')
/** 原始远程地址（http/https），供重试 */
const playbackRemoteUrl = ref('')
/** 与学习列表相同：用 JS Audio 直链播放，避免 hidden <audio :src> 预加载误报 error */
let playbackAudio: HTMLAudioElement | null = null
let playbackObjectUrl: string | null = null

/** 结果点评 TTS（Katerina） */
const FEEDBACK_TTS_MUTE_KEY = 'vloglish_feedback_tts_muted'
const feedbackTtsMuted = ref(
  typeof localStorage !== 'undefined' && localStorage.getItem(FEEDBACK_TTS_MUTE_KEY) === '1',
)
const feedbackTtsPlaying = ref(false)
const feedbackTtsLoading = ref(false)
let feedbackAudio: HTMLAudioElement | null = null
let feedbackObjectUrl: string | null = null
let feedbackAutoTimer: ReturnType<typeof setTimeout> | null = null
let feedbackToken = 0

const oral = useOralEvalEngine()

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let recognition: any = null
let autoPlayTimer: ReturnType<typeof setTimeout> | null = null
let demoPlayingTimer: ReturnType<typeof setTimeout> | null = null
let demoAudio: HTMLAudioElement | null = null
let demoObjectUrl: string | null = null

const practiceMode = computed<OralPracticeMode>(() => props.mode || 'sentence')
const targetText = computed(() => (props.refText || props.english || '').trim())
const coreType = computed(() => coreTypeForMode(practiceMode.value))
const readingTts = inject(READING_TTS_KEY, null)

const passageBlocksView = computed(() =>
  (props.passageBlocks || [])
    .map((b) => ({
      english: (b.english || '').trim(),
      chinese: (b.chinese || '').trim(),
      focus: Boolean(b.focus),
      segmentIndex: typeof b.segmentIndex === 'number' ? b.segmentIndex : null,
    }))
    .filter((b) => b.english),
)

const showPassageBlocks = computed(
  () => practiceMode.value === 'passage' && passageBlocksView.value.length > 0,
)

/** 播放中高亮的段落下标；未播放时用初始 focus */
const playingBlockIndex = ref<number | null>(null)
/** 示范音会话未结束（可暂停后继续） */
const demoSessionActive = ref(false)
let ttsSeqToken = 0
let ttsSeqResume: (() => void) | null = null
let ttsSeqWaitPause: Promise<void> | null = null

const activeBlockIndex = computed(() => {
  if (playingBlockIndex.value != null) return playingBlockIndex.value
  const fi = passageBlocksView.value.findIndex((b) => b.focus)
  return fi >= 0 ? fi : 0
})

function passageBlockHtml(english: string) {
  return highlightVocabLinkText(english, props.vocabGroups || [])
}

const highlightedTargetHtml = computed(() => {
  if (practiceMode.value !== 'passage' || !targetText.value) return ''
  if (!props.vocabGroups?.length) return ''
  return highlightVocabLinkText(targetText.value, props.vocabGroups)
})

const demoActionLabel = computed(() => {
  if (demoLoading.value) return '示范音合成中…'
  if (demoPlaying.value) return '点击暂停'
  if (demoSessionActive.value) return '继续播放'
  return playDemoLabel.value
})

const sheetTitle = computed(() => {
  if (props.title) return props.title
  if (practiceMode.value === 'word') return '单词打分'
  if (practiceMode.value === 'passage') return '篇章评测'
  return 'AI 跟读'
})

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
  if (s >= 80) return 'good'
  if (s >= 60) return 'mid'
  return 'low'
})

const scoreRingStyle = computed(() => {
  const score = Math.max(0, Math.min(100, Number(result.value?.score) || 0))
  const deg = (score / 100) * 360
  const color =
    scoreTone.value === 'good'
      ? 'rgb(5 150 105)'
      : scoreTone.value === 'mid'
        ? 'rgb(217 119 6)'
        : 'rgb(225 29 72)'
  return { background: `conic-gradient(${color} ${deg}deg, rgb(238 238 238) 0deg)` }
})

const useOral = computed(() => engineMode.value === 'oral')

const engineLabel = computed(() => {
  if (engineMode.value === 'oral') return '发音评测'
  if (engineMode.value === 'llm') return '识别点评'
  return '准备中'
})

const listenHint = computed(() => {
  if (practiceMode.value === 'word') return '先听示范音，再跟读这个单词'
  if (practiceMode.value === 'passage') return '先听/看清段落，再开始朗读'
  return '先听清楚原句，再开始跟读'
})

const originalVoiceLabel = computed(() => (practiceMode.value === 'word' ? '词典' : '原声'))
const showDemoSource = computed(
  () =>
    practiceMode.value === 'word' ||
    practiceMode.value === 'sentence' ||
    practiceMode.value === 'passage',
)
const playDemoLabel = computed(() => {
  if (demoVoice.value !== 'original') return '听示范音'
  if (practiceMode.value === 'word') return '听示范音'
  if (practiceMode.value === 'passage') return '听本段'
  return '听原句'
})

const recordHint = computed(() => {
  if (loading.value) return '正在评分…'
  if (listening.value && useOral.value) return '正在录音… 说完点一下结束'
  if (listening.value) return '正在听你说… 说完再点停止'
  if (micUnsupported.value) return '可用下方输入框提交英文'
  if (useOral.value && practiceMode.value === 'word') return '点麦克风读出这个单词'
  if (useOral.value && practiceMode.value === 'passage') return '点麦克风朗读整段'
  if (useOral.value) return '点麦克风跟读，系统直接评发音'
  return '点麦克风跟读，停止后自动点评'
})

const dimensionItems = computed(() => {
  const r = result.value
  if (!r || r.engine !== 'oral') return []
  const items: { key: string; label: string; value: number }[] = []
  if (r.accuracy != null) items.push({ key: 'a', label: '准确', value: r.accuracy })
  if (r.fluency != null) items.push({ key: 'f', label: '流利', value: r.fluency })
  if (practiceMode.value === 'passage' && r.integrity != null) {
    items.push({ key: 'i', label: '完整', value: r.integrity })
  } else if (r.rhythm != null && practiceMode.value !== 'word') {
    items.push({ key: 'r', label: '韵律', value: r.rhythm })
  }
  return items
})

function wordToneClass(score: number) {
  if (score >= 85) return 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950/50 dark:text-emerald-300'
  if (score >= 75) return 'bg-sky-100 text-sky-800 dark:bg-sky-950/50 dark:text-sky-300'
  if (score >= 55) return 'bg-sunken text-ink-soft'
  return 'bg-rose-100 text-rose-800 dark:bg-rose-950/50 dark:text-rose-300'
}

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
  if (!window.isSecureContext) return '需要 HTTPS 或 localhost 才能录音'
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
    if (name === 'NotFoundError' || name === 'DevicesNotFoundError') return '找不到可用麦克风'
    return '无法打开麦克风'
  }
}

function clearAutoPlay() {
  if (autoPlayTimer != null) {
    clearTimeout(autoPlayTimer)
    autoPlayTimer = null
  }
}

function clearDemoPlayingTimer() {
  if (demoPlayingTimer != null) {
    clearTimeout(demoPlayingTimer)
    demoPlayingTimer = null
  }
}

function markDemoPlaying(ms?: number) {
  clearDemoPlayingTimer()
  demoPlaying.value = true
  const duration = ms ?? estimateDemoMs(targetText.value, demoRate.value)
  demoPlayingTimer = setTimeout(() => {
    demoPlayingTimer = null
    demoPlaying.value = false
  }, duration)
}

function estimateDemoMs(text: string, rate: number) {
  const words = text.trim().split(/\s+/).filter(Boolean).length
  const base =
    practiceMode.value === 'word'
      ? 1400
      : practiceMode.value === 'passage'
        ? Math.max(3200, words * 380)
        : Math.max(1800, words * 420)
  return Math.round(base / Math.max(0.5, rate)) + 350
}

function endDemoSession() {
  demoSessionActive.value = false
  demoPlaying.value = false
  playingBlockIndex.value = null
  ttsSeqToken += 1
  ttsSeqResume = null
  ttsSeqWaitPause = null
}

function clearFeedbackAutoTimer() {
  if (feedbackAutoTimer != null) {
    clearTimeout(feedbackAutoTimer)
    feedbackAutoTimer = null
  }
}

function stopFeedbackTts() {
  clearFeedbackAutoTimer()
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

function setFeedbackTtsMuted(muted: boolean) {
  feedbackTtsMuted.value = muted
  try {
    localStorage.setItem(FEEDBACK_TTS_MUTE_KEY, muted ? '1' : '0')
  } catch {
    /* ignore */
  }
  if (muted) stopFeedbackTts()
}

async function playFeedbackTts(r?: AiShadowingResult | null) {
  const target = r || result.value
  if (!target) return
  const speech = buildPracticeFeedbackSpeech(target).trim()
  if (!speech) return

  // 互斥：点评播报时停示范音 / 回听
  stopSpeaking()
  stopDemoAudio()
  stopPlaybackAudio()

  const token = ++feedbackToken
  feedbackTtsLoading.value = true
  try {
    const blob = await fetchPracticeTts(speech, 'Katerina', 'sentence')
    if (token !== feedbackToken || !props.open || step.value !== 'result') return
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
    if (token === feedbackToken) {
      feedbackTtsPlaying.value = false
    }
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

function scheduleFeedbackTts(r: AiShadowingResult) {
  clearFeedbackAutoTimer()
  if (feedbackTtsMuted.value) return
  feedbackAutoTimer = setTimeout(() => {
    feedbackAutoTimer = null
    if (!props.open || step.value !== 'result' || !result.value) return
    void playFeedbackTts(r)
  }, 420)
}

function silencePlaybackForMic() {
  stopSpeaking()
  stopDemoAudio()
  stopFeedbackTts()
  stopPlaybackAudio()
  emit('pause')
}

function stopDemoAudio() {
  clearDemoPlayingTimer()
  endDemoSession()
  emit('pause')
  if (demoAudio) {
    try {
      demoAudio.pause()
      demoAudio.onended = null
      demoAudio.onpause = null
      demoAudio.onplay = null
      demoAudio.removeAttribute('src')
      demoAudio.load()
    } catch {
      /* ignore */
    }
    demoAudio = null
  }
  if (demoObjectUrl) {
    URL.revokeObjectURL(demoObjectUrl)
    demoObjectUrl = null
  }
  if (practiceMode.value === 'passage' && readingTts) {
    readingTts.stop()
  }
}

function pauseDemoAudio() {
  clearDemoPlayingTimer()
  if (demoAudio && !demoAudio.paused) {
    demoAudio.pause()
    demoPlaying.value = false
    return true
  }
  if (practiceMode.value === 'passage' && readingTts?.isPlaying.value) {
    readingTts.pause()
    demoPlaying.value = false
    return true
  }
  return false
}

function resumeDemoAudio() {
  if (demoAudio && demoAudio.paused && !demoAudio.ended && demoSessionActive.value) {
    void demoAudio.play().then(() => {
      demoPlaying.value = true
    }).catch(() => {
      endDemoSession()
    })
    return true
  }
  if (ttsSeqWaitPause && ttsSeqResume) {
    ttsSeqResume()
    ttsSeqResume = null
    ttsSeqWaitPause = null
    demoPlaying.value = true
    return true
  }
  if (practiceMode.value === 'passage' && readingTts && demoSessionActive.value) {
    readingTts.resume()
    return true
  }
  return false
}

function formatPlaybackTime(sec: number) {
  return formatAudioClock(sec)
}

function stopPlaybackAudio() {
  if (playbackAudio) {
    try {
      playbackAudio.pause()
      playbackAudio.onended = null
      playbackAudio.onerror = null
      playbackAudio.ontimeupdate = null
      playbackAudio.onloadedmetadata = null
    } catch {
      /* ignore */
    }
    playbackAudio = null
  }
  playbackPlaying.value = false
}

function revokePlaybackObjectUrl() {
  if (playbackObjectUrl) {
    try {
      URL.revokeObjectURL(playbackObjectUrl)
    } catch {
      /* ignore */
    }
    playbackObjectUrl = null
  }
}

function clearPlayback() {
  stopPlaybackAudio()
  revokePlaybackObjectUrl()
  playbackUrl.value = ''
  playbackRemoteUrl.value = ''
  playbackError.value = false
  playbackLoading.value = false
  playbackProgress.value = 0
  playbackCurrentLabel.value = '0:00'
  playbackDurationLabel.value = ''
}

function normalizePlayableUrl(raw: string): string {
  const url = (raw || '').trim()
  if (!url) return ''
  if (url.startsWith('//')) return `https:${url}`
  if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('blob:')) return url
  // 七牛域名有时未带协议
  if (/^[\w.-]+\.[a-z]{2,}\//i.test(url) || /^[\w.-]+\.[a-z]{2,}$/i.test(url)) {
    return `https://${url.replace(/^\/+/, '')}`
  }
  return url
}

/** 口语云临时候选地址（后端代理白名单仅 ssapi）；七牛转存不在此列 */
function isOralCloudAudioUrl(url: string): boolean {
  try {
    const host = new URL(url).hostname.toLowerCase()
    return host === 'ssapi.cn' || host.endsWith('.ssapi.cn')
  } catch {
    return false
  }
}

/**
 * 解析为可播 URL：
 * - https：直链
 * - http 口语云（ssapi）：后端代理成 blob（避免混合内容被拦）
 * - 其它 http（七牛转存等）：与学习记录页一致，直链播
 */
async function preparePlaybackUrl(remote: string): Promise<string | null> {
  const url = normalizePlayableUrl(remote)
  if (!url || url.startsWith('blob:')) return url || null

  if (url.startsWith('https://')) return url

  if (url.startsWith('http://')) {
    if (!isOralCloudAudioUrl(url)) {
      // 学习页：new Audio(item.audio_url) 原样播七牛 http，此处对齐
      return url
    }
    const blob = await fetchOralRemoteAudio(url)
    revokePlaybackObjectUrl()
    const obj = URL.createObjectURL(blob)
    playbackObjectUrl = obj
    return obj
  }
  return null
}

async function loadRemotePlayback(remote: string): Promise<boolean> {
  const raw = (remote || '').trim()
  if (!raw || raw.startsWith('blob:')) return false
  playbackLoading.value = true
  playbackError.value = false
  try {
    const playable = await preparePlaybackUrl(raw)
    if (!playable) return false
    playbackUrl.value = playable
    void probePlaybackDuration(playable)
    return true
  } catch {
    return false
  } finally {
    playbackLoading.value = false
  }
}

async function probePlaybackDuration(url: string) {
  if (playbackDurationLabel.value) return
  const sec = await probeAudioDuration(url)
  if (sec != null && !playbackDurationLabel.value) {
    playbackDurationLabel.value = formatPlaybackTime(sec)
  }
}

/** 与学习记录列表同源：拉取已落库的 audio_url（最可靠） */
async function loadPlaybackFromPracticeRecord(retries = 2): Promise<boolean> {
  const id = result.value?.practice_record_id
  if (!id) return false
  playbackLoading.value = true
  playbackError.value = false
  try {
    for (let i = 0; i <= retries; i++) {
      try {
        const row = await getPracticeRecord(id)
        const url = normalizePlayableUrl(row.audio_url || '')
        if (url) {
          if (url.startsWith('http://') || url.startsWith('https://')) {
            playbackRemoteUrl.value = url
          }
          const ok = await loadRemotePlayback(url)
          if (ok) return true
        }
      } catch {
        /* 下一轮重试 */
      }
      if (i < retries) await new Promise((r) => setTimeout(r, 450))
    }
    return false
  } finally {
    playbackLoading.value = false
  }
}

function goLearningRecords() {
  stopPlaybackAudio()
  stopFeedbackTts()
  emit('close')
  void router.push('/english/learning')
}

async function startPlaybackFromUrl(url: string, allowRecordFallback = true): Promise<boolean> {
  stopSpeaking()
  stopDemoAudio()
  stopFeedbackTts()
  stopPlaybackAudio()

  const audio = new Audio(url)
  playbackAudio = audio
  audio.ontimeupdate = () => {
    if (!audio.duration) return
    playbackProgress.value = Math.min(100, (audio.currentTime / audio.duration) * 100)
    playbackCurrentLabel.value = formatPlaybackTime(audio.currentTime)
  }
  audio.onloadedmetadata = () => {
    playbackError.value = false
    if (Number.isFinite(audio.duration) && audio.duration > 0) {
      playbackDurationLabel.value = formatPlaybackTime(audio.duration)
    }
  }
  audio.onended = () => {
    playbackPlaying.value = false
    playbackProgress.value = 0
    playbackCurrentLabel.value = '0:00'
    playbackAudio = null
  }
  audio.onerror = () => {
    playbackPlaying.value = false
    playbackAudio = null
    if (!allowRecordFallback) {
      playbackError.value = true
      return
    }
    void (async () => {
      const fromRecord = await loadPlaybackFromPracticeRecord(1)
      if (fromRecord && playbackUrl.value) {
        playbackError.value = false
        const ok = await startPlaybackFromUrl(playbackUrl.value, false)
        if (!ok) playbackError.value = true
        return
      }
      playbackError.value = true
    })()
  }

  try {
    await audio.play()
    playbackPlaying.value = true
    playbackError.value = false
    return true
  } catch {
    playbackPlaying.value = false
    playbackAudio = null
    if (!allowRecordFallback) return false
    const fromRecord = await loadPlaybackFromPracticeRecord(1)
    if (fromRecord && playbackUrl.value) {
      return startPlaybackFromUrl(playbackUrl.value, false)
    }
    playbackError.value = true
    return false
  }
}

async function togglePlayback() {
  if (playbackLoading.value) return

  if (playbackPlaying.value) {
    stopPlaybackAudio()
    playbackProgress.value = 0
    playbackCurrentLabel.value = '0:00'
    return
  }

  // 出错或尚无地址：先对齐学习列表的落库地址，再回退其它源
  if (playbackError.value || !playbackUrl.value) {
    playbackError.value = false
    let ok = await loadPlaybackFromPracticeRecord(1)
    if (!ok && playbackRemoteUrl.value) {
      ok = await loadRemotePlayback(playbackRemoteUrl.value)
    }
    if (!ok) {
      const local = oral.localAudioUrl.value
      if (local) playbackUrl.value = local
      else {
        playbackError.value = true
        return
      }
    }
  }

  const url = playbackUrl.value
  if (!url) {
    playbackError.value = true
    return
  }

  await startPlaybackFromUrl(url, true)
}

async function resolvePlayback(remoteUrl?: string | null) {
  clearPlayback()
  const remote = normalizePlayableUrl(remoteUrl || '')
  const local = oral.localAudioUrl.value
  if (remote.startsWith('http://') || remote.startsWith('https://')) {
    playbackRemoteUrl.value = remote
  }

  // 1) 学习记录落库地址（与列表「听一听」同源，优先）
  if (await loadPlaybackFromPracticeRecord(2)) return

  // 2) 接口/SDK 返回的远程地址
  if (playbackRemoteUrl.value) {
    const ok = await loadRemotePlayback(playbackRemoteUrl.value)
    if (ok) return
  }

  // 3) 本地分片（常不可播）：有练习记录时直接提示去学习页
  if (local) {
    playbackUrl.value = local
    void probePlaybackDuration(local)
    if (result.value?.practice_record_id) playbackError.value = true
    return
  }
  if (remote.startsWith('blob:')) {
    playbackUrl.value = remote
    void probePlaybackDuration(remote)
    if (result.value?.practice_record_id) playbackError.value = true
    return
  }
  if (result.value?.practice_record_id) {
    playbackError.value = true
  }
}

const showPlaybackBlock = computed(
  () =>
    Boolean(
      playbackUrl.value ||
        playbackLoading.value ||
        playbackError.value ||
        playbackRemoteUrl.value ||
        result.value?.practice_record_id,
    ),
)

function resetState() {
  clearAutoPlay()
  stopListening(true)
  oral.cancel()
  oral.revokeLocalAudio()
  stopSpeaking()
  stopDemoAudio()
  stopFeedbackTts()
  clearPlayback()
  step.value = 'listen'
  transcript.value = ''
  result.value = null
  error.value = ''
  loading.value = false
  demoLoading.value = false
  demoPlaying.value = false
  showTips.value = false
  micUnsupported.value = false
  autoSubmitArmed.value = false
  fallbackHint.value = ''
  demoRate.value = 1
  demoVoice.value = 'original'
}

function stopListening(abort = false) {
  try {
    if (abort) recognition?.abort?.()
    else recognition?.stop?.()
  } catch {
    /* ignore */
  }
  listening.value = false
  if (useOral.value) {
    if (abort) oral.cancel()
    else oral.stop()
  }
}

function passageRange() {
  const blocks = passageBlocksView.value
  const indexes = blocks
    .map((b) => b.segmentIndex)
    .filter((n): n is number => typeof n === 'number')
  if (!indexes.length) return null
  return { start: Math.min(...indexes), end: Math.max(...indexes) }
}

function playOriginalSource() {
  const rate = demoRate.value
  if (practiceMode.value === 'word') {
    demoSessionActive.value = true
    markDemoPlaying()
    void playWordPronunciation(targetText.value, null, rate)
    return
  }

  if (practiceMode.value === 'passage' && readingTts) {
    const range = passageRange()
    demoSessionActive.value = true
    demoPlaying.value = true
    if (range) {
      playingBlockIndex.value = 0
      readingTts.playRange(range.start, range.end, rate)
    } else {
      markDemoPlaying()
      emit('play', rate)
    }
    return
  }

  demoSessionActive.value = true
  markDemoPlaying()
  emit('play', rate)
}

function playAudioElement(audio: HTMLAudioElement) {
  return new Promise<void>((resolve, reject) => {
    const onEnded = () => {
      cleanup()
      resolve()
    }
    const onError = () => {
      cleanup()
      reject(new Error('示范音播放失败'))
    }
    const cleanup = () => {
      audio.removeEventListener('ended', onEnded)
      audio.removeEventListener('error', onError)
    }
    audio.addEventListener('ended', onEnded)
    audio.addEventListener('error', onError)
    void audio.play().catch((e) => {
      cleanup()
      reject(e)
    })
  })
}

async function waitIfTtsPaused(token: number) {
  if (demoPlaying.value || token !== ttsSeqToken) return
  if (!demoSessionActive.value) return
  ttsSeqWaitPause = new Promise<void>((resolve) => {
    ttsSeqResume = resolve
  })
  await ttsSeqWaitPause
}

async function playPassageTtsSequential(voice: PracticeTtsVoice) {
  const blocks = passageBlocksView.value
  if (!blocks.length) {
    await playTtsDemoWhole(voice)
    return
  }

  const token = ++ttsSeqToken
  demoSessionActive.value = true
  demoPlaying.value = true

  for (let i = 0; i < blocks.length; i++) {
    if (token !== ttsSeqToken || !demoSessionActive.value) return
    await waitIfTtsPaused(token)
    if (token !== ttsSeqToken || !demoSessionActive.value) return

    playingBlockIndex.value = i
    demoLoading.value = true
    let blob: Blob
    try {
      blob = await fetchPracticeTts(blocks[i].english, voice, 'passage')
    } finally {
      demoLoading.value = false
    }
    if (token !== ttsSeqToken || !demoSessionActive.value) return

    if (demoObjectUrl) {
      URL.revokeObjectURL(demoObjectUrl)
      demoObjectUrl = null
    }
    if (demoAudio) {
      try {
        demoAudio.pause()
      } catch {
        /* ignore */
      }
      demoAudio = null
    }

    const url = URL.createObjectURL(blob)
    demoObjectUrl = url
    const audio = new Audio(url)
    demoAudio = audio
    audio.playbackRate = demoRate.value
    demoPlaying.value = true
    try {
      await playAudioElement(audio)
    } catch {
      if (token === ttsSeqToken) endDemoSession()
      return
    }
    if (demoAudio === audio) demoAudio = null
  }

  if (token === ttsSeqToken) endDemoSession()
}

async function playTtsDemoWhole(voice: PracticeTtsVoice) {
  if (!targetText.value) return
  const blob = await fetchPracticeTts(targetText.value, voice, practiceMode.value)
  if (demoObjectUrl) {
    URL.revokeObjectURL(demoObjectUrl)
    demoObjectUrl = null
  }
  const url = URL.createObjectURL(blob)
  demoObjectUrl = url
  const audio = new Audio(url)
  demoAudio = audio
  audio.playbackRate = demoRate.value
  audio.onended = () => {
    endDemoSession()
    if (demoObjectUrl) {
      URL.revokeObjectURL(demoObjectUrl)
      demoObjectUrl = null
    }
    demoAudio = null
  }
  clearDemoPlayingTimer()
  demoSessionActive.value = true
  demoPlaying.value = true
  await audio.play()
}

async function playTtsDemo(voice: PracticeTtsVoice) {
  if (practiceMode.value === 'passage' && passageBlocksView.value.length > 1) {
    await playPassageTtsSequential(voice)
    return
  }
  if (practiceMode.value === 'passage' && passageBlocksView.value.length === 1) {
    playingBlockIndex.value = 0
  }
  await playTtsDemoWhole(voice)
}

async function playDemo() {
  error.value = ''
  stopFeedbackTts()

  // 播放中 → 暂停；已暂停 → 继续
  if (demoPlaying.value) {
    if (!pauseDemoAudio()) {
      // 段落间隙（如下一段合成中）：先进入暂停，等恢复后再继续
      demoPlaying.value = false
    }
    return
  }
  if (demoSessionActive.value && resumeDemoAudio()) {
    return
  }

  stopSpeaking()
  // 重新开播前清掉旧音频/连播
  clearDemoPlayingTimer()
  if (demoAudio) {
    try {
      demoAudio.pause()
      demoAudio.removeAttribute('src')
      demoAudio.load()
    } catch {
      /* ignore */
    }
    demoAudio = null
  }
  if (demoObjectUrl) {
    URL.revokeObjectURL(demoObjectUrl)
    demoObjectUrl = null
  }
  if (practiceMode.value === 'passage' && readingTts) readingTts.stop()
  endDemoSession()

  if (demoVoice.value === 'original') {
    playOriginalSource()
    return
  }

  demoLoading.value = true
  try {
    await playTtsDemo(demoVoice.value)
  } catch (e: unknown) {
    const raw = e instanceof Error ? e.message : ''
    const friendly =
      /API[-\s]?[Kk]ey|401|未配置|无效|失效/.test(raw)
        ? '示范 TTS 密钥无效或未配置'
        : raw || '示范音暂不可用'
    fallbackHint.value = `${friendly}，已改用${originalVoiceLabel.value}`
    demoVoice.value = 'original'
    playOriginalSource()
  } finally {
    demoLoading.value = false
  }
}

function setDemoVoice(voice: DemoVoice) {
  stopDemoAudio()
  demoVoice.value = voice
  void playDemo()
}

function setDemoRate(rate: 0.5 | 1) {
  demoRate.value = rate
  if (demoAudio) demoAudio.playbackRate = rate
  // 原声连播进行中只改速率；已结束则重播
  if (demoSessionActive.value && demoPlaying.value && readingTts && demoVoice.value === 'original') {
    return
  }
  if (demoSessionActive.value && demoPlaying.value && demoAudio) {
    return
  }
  stopDemoAudio()
  void playDemo()
}

function goRecord() {
  silencePlaybackForMic()
  error.value = ''
  result.value = null
  step.value = 'record'
}

async function resolveEngine() {
  engineMode.value = 'unknown'
  const ok = await oral.probe()
  engineMode.value = ok ? 'oral' : 'llm'
}

function feedbackContext() {
  const source =
    props.sourceType ||
    (props.articleId ? 'article' : props.videoId ? 'video' : practiceMode.value === 'word' ? 'vocab' : 'other')
  return {
    source_type: source,
    video_id: props.videoId || '',
    subtitle_id: props.subtitleId,
    article_id: props.articleId || '',
    segment_id: props.segmentId,
    title: props.title || sheetTitle.value,
    mode: practiceMode.value,
  }
}

async function maybeUploadLocalPracticeAudio(res: AiShadowingResult) {
  const recordId = res.practice_record_id
  if (!recordId) return
  if ((res.practice_audio_url || res.audio_url || '').trim()) return
  const local = oral.localAudioUrl.value
  if (!local || !local.startsWith('blob:')) return
  try {
    const blob = await fetch(local).then((r) => r.blob())
    if (!blob.size) return
    const uploaded = await uploadPracticeAudio(recordId, blob)
    if (uploaded.audio_url) {
      result.value = {
        ...res,
        audio_url: uploaded.audio_url,
        practice_audio_url: uploaded.audio_url,
      }
    }
  } catch {
    /* 补传失败不影响本次点评展示 */
  }
}

async function submitOralResult(oralRaw: Record<string, unknown>) {
  if (props.videoId && props.subtitleId != null && practiceMode.value === 'sentence') {
    return aiShadowingOralFeedback(props.videoId, props.subtitleId, oralRaw, {
      title: props.title || '',
    })
  }
  return aiOralEvalFeedback(targetText.value, oralRaw, coreType.value, feedbackContext())
}

async function startOralRecording() {
  if (!targetText.value) return
  error.value = ''
  result.value = null
  transcript.value = ''
  fallbackHint.value = ''
  autoSubmitArmed.value = true
  step.value = 'record'
  silencePlaybackForMic()
  emit('recording', true)
  oral.resetEngine()

  // 口语 SDK 自己申请麦克风；不要先 getUserMedia 再 stop，否则易抢占/弄死 stream
  if (typeof window !== 'undefined' && !window.isSecureContext) {
    engineMode.value = 'llm'
    micUnsupported.value = true
    error.value = '需要 HTTPS 或 localhost 才能录音'
    emit('recording', false)
    return
  }
  try {
    if (navigator.permissions?.query) {
      const status = await navigator.permissions.query({ name: 'microphone' as PermissionName })
      if (status.state === 'denied') {
        engineMode.value = 'llm'
        micUnsupported.value = true
        error.value = '麦克风权限被拒绝，请在浏览器地址栏允许后重试'
        emit('recording', false)
        return
      }
    }
  } catch {
    /* Permissions API 不支持 microphone 时忽略，交给 SDK */
  }

  listening.value = true
  loading.value = false
  let handedToLlm = false
  try {
    // 等视频/示范音释放音频会话，否则回声消除常把跟读声抹掉
    await new Promise((r) => setTimeout(r, 280))
    const oralRaw = await oral.evaluate(targetText.value, coreType.value)
    listening.value = false
    loading.value = true
    const remoteFromSdk = String(oralRaw.audioUrl || oralRaw.audio_url || '').trim()
    result.value = await submitOralResult(oralRaw)
    transcript.value = result.value.transcript || ''
    step.value = 'result'
    showTips.value = Boolean(result.value.issues?.length || result.value.tips?.length)
    await maybeUploadLocalPracticeAudio(result.value)
    // 与学习列表同一优先序：转存后的七牛地址 > 接口 audio_url > SDK 临时链
    const bestAudio =
      result.value.practice_audio_url ||
      result.value.audio_url ||
      remoteFromSdk ||
      ''
    await resolvePlayback(bestAudio)
    await nextTick()
    scheduleFeedbackTts(result.value)
  } catch (e: unknown) {
    engineMode.value = 'llm'
    const detail = e instanceof Error ? e.message.trim() : ''
    fallbackHint.value = detail
      ? `发音评测暂不可用（${detail.slice(0, 80)}），已切换为识别点评`
      : '发音评测暂不可用，已切换为识别点评'
    error.value = ''
    handedToLlm = true
    await startListening()
  } finally {
    if (!handedToLlm) {
      autoSubmitArmed.value = false
      listening.value = false
      loading.value = false
      emit('recording', false)
    }
  }
}

async function startListening() {
  error.value = ''
  result.value = null
  transcript.value = ''
  autoSubmitArmed.value = true
  step.value = 'record'
  silencePlaybackForMic()
  emit('recording', true)

  const Ctor = getRecognitionCtor()
  if (!Ctor) {
    micUnsupported.value = true
    error.value = '当前浏览器不支持语音识别，请输入内容后点评'
    emit('recording', false)
    return
  }

  const micErr = await ensureMicPermission()
  if (micErr) {
    micUnsupported.value = true
    error.value = micErr
    emit('recording', false)
    return
  }

  stopListening(true)
  const rec = new Ctor()
  recognition = rec
  recognition.lang = 'en-US'
  recognition.interimResults = true
  recognition.continuous = false
  recognition.maxAlternatives = 1
  recognition.onresult = (event: any) => {
    let text = ''
    for (let i = 0; i < event.results.length; i++) {
      text += event.results[i][0]?.transcript || ''
    }
    transcript.value = text.trim()
    if (transcript.value) error.value = ''
  }
  recognition.onerror = (event: any) => {
    listening.value = false
    emit('recording', false)
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
    emit('recording', false)
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
    emit('recording', false)
    autoSubmitArmed.value = false
    const name = (e as { name?: string })?.name || ''
    if (name === 'InvalidStateError') {
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
    emit('recording', false)
    return
  }
  if (useOral.value) {
    void startOralRecording()
    return
  }
  void startListening()
}

function retry() {
  if (loading.value || listening.value) return
  result.value = null
  error.value = ''
  transcript.value = ''
  showTips.value = false
  autoSubmitArmed.value = false
  fallbackHint.value = ''
  clearPlayback()
  loading.value = false
  listening.value = false
  step.value = 'record'
  if (useOral.value) void startOralRecording()
  else void startListening()
}

async function submitFeedback() {
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
    if (props.videoId && props.subtitleId != null && practiceMode.value === 'sentence') {
      result.value = await aiShadowingFeedback(props.videoId, props.subtitleId, text)
    } else {
      result.value = await aiShadowingTextFeedback(targetText.value, text, feedbackContext())
    }
    step.value = 'result'
    showTips.value = Boolean(result.value.issues?.length || result.value.tips?.length)
    await nextTick()
    scheduleFeedbackTts(result.value)
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
  if (practiceMode.value === 'passage') return
  autoPlayTimer = setTimeout(() => {
    autoPlayTimer = null
    if (props.open && step.value === 'listen') void playDemo()
  }, 420)
}

watch(
  () => props.open,
  async (v) => {
    if (typeof document !== 'undefined') {
      document.body.style.overflow = v ? 'hidden' : ''
    }
    if (!v) {
      resetState()
      return
    }
    resetState()
    await resolveEngine()
    scheduleAutoPlay()
  },
)

watch(
  () => props.subtitleId,
  async (id, prev) => {
    if (props.open && id != null && id !== prev) {
      resetState()
      await resolveEngine()
      scheduleAutoPlay()
    }
  },
)

watch(
  () => props.refText || props.english,
  async (text, prev) => {
    if (props.open && text && text !== prev) {
      resetState()
      await resolveEngine()
      scheduleAutoPlay()
    }
  },
)

watch(
  () => readingTts?.playingIndex.value ?? null,
  (idx) => {
    if (practiceMode.value !== 'passage' || demoVoice.value !== 'original') return
    if (!demoSessionActive.value) return
    if (idx == null) {
      if (!readingTts?.isPlaying.value) {
        demoSessionActive.value = false
        demoPlaying.value = false
      }
      return
    }
    const i = passageBlocksView.value.findIndex((b) => b.segmentIndex === idx)
    if (i >= 0) playingBlockIndex.value = i
  },
)

watch(
  () => readingTts?.isPlaying.value ?? false,
  (playing) => {
    if (practiceMode.value !== 'passage' || demoVoice.value !== 'original') return
    if (!demoSessionActive.value && !playing) return
    if (playing) {
      demoSessionActive.value = true
      demoPlaying.value = true
    } else {
      demoPlaying.value = false
    }
  },
)

watch(activeBlockIndex, async (idx) => {
  if (!showPassageBlocks.value || !props.open) return
  await nextTick()
  const el = document.querySelector(`[data-practice-block="${idx}"]`)
  el?.scrollIntoView({ block: 'nearest', behavior: 'smooth' })
})

onUnmounted(() => {
  clearAutoPlay()
  stopListening(true)
  oral.cancel()
  oral.revokeLocalAudio()
  stopSpeaking()
  stopDemoAudio()
  stopFeedbackTts()
  clearPlayback()
  if (typeof document !== 'undefined') document.body.style.overflow = ''
})
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[500] flex items-end sm:items-center justify-center bg-neutral-950/50 p-0 sm:p-4 backdrop-blur-[2px]"
      @click.self="$emit('close')"
    >
      <div
        class="w-full max-h-[92dvh] sm:max-h-[90dvh] flex flex-col rounded-t-[1.75rem] sm:rounded-[1.75rem] bg-[#FBF8F3] dark:bg-neutral-950 border border-black/5 dark:border-white/10 overflow-hidden"
        :class="practiceMode === 'passage' ? 'sm:max-w-4xl' : 'sm:max-w-2xl'"
      >
        <!-- Header -->
        <div class="shrink-0 px-5 pt-4 pb-3">
          <div class="mx-auto mb-3 h-1 w-10 rounded-full bg-neutral-300/80 dark:bg-neutral-700 sm:hidden" />
          <div class="flex items-start justify-between gap-3">
            <div class="min-w-0 space-y-1">
              <div class="flex items-center gap-2 flex-wrap">
                <h2 class="text-[17px] font-semibold tracking-tight text-neutral-900 dark:text-neutral-50">
                  {{ sheetTitle }}
                </h2>
                <span
                  v-if="sentenceLabel"
                  class="text-[11px] font-medium px-1.5 py-0.5 rounded-md bg-sky-100/90 text-sky-900 dark:bg-sky-950/50 dark:text-sky-300"
                >
                  {{ sentenceLabel }}
                </span>
              </div>
              <p class="text-[12px] text-neutral-500 dark:text-neutral-400">
                <span
                  class="font-medium"
                  :class="useOral ? 'text-emerald-700 dark:text-emerald-400' : 'text-warning'"
                >{{ engineLabel }}</span>
                <span class="mx-1 opacity-40">·</span>
                <span>{{ step === 'listen' ? '听示范' : step === 'record' ? '跟读录音' : '查看结果' }}</span>
              </p>
            </div>
            <button
              type="button"
              class="w-9 h-9 flex items-center justify-center rounded-full text-neutral-400 hover:text-ink-soft hover:bg-black/5 dark:hover:bg-white/10 shrink-0"
              aria-label="关闭"
              @click="$emit('close')"
            >
              <AppIcon name="close" :size="18" />
            </button>
          </div>

          <!-- Steps -->
          <div class="mt-3.5 flex items-center gap-1.5">
            <div
              v-for="(s, i) in (['listen', 'record', 'result'] as Step[])"
              :key="s"
              class="h-1 flex-1 rounded-full transition-colors duration-300"
              :class="
                step === s
                  ? 'bg-amber-500'
                  : i < (['listen', 'record', 'result'] as Step[]).indexOf(step)
                    ? 'bg-amber-300/80 dark:bg-amber-700/60'
                    : 'bg-sunken'
              "
            />
          </div>
          <div
            v-if="sentenceTotal && sentenceTotal > 0"
            class="mt-2 h-1 rounded-full bg-neutral-200/80 dark:bg-neutral-800 overflow-hidden"
          >
            <div
              class="h-full rounded-full bg-sky-500 transition-all duration-300"
              :style="{ width: `${progressPercent}%` }"
            />
          </div>
        </div>

        <div
          class="flex-1 min-h-0 overflow-y-auto overscroll-contain px-5 space-y-3.5"
          :class="step === 'listen' ? 'pb-[max(1.25rem,env(safe-area-inset-bottom))]' : 'pb-4'"
        >
          <!-- Target card -->
          <section
            class="relative rounded-2xl border border-black/[0.06] dark:border-white/10 bg-white dark:bg-neutral-900 px-4 py-3.5"
            :class="practiceMode === 'passage' ? 'sm:px-5 sm:py-4' : 'overflow-hidden'"
          >
            <div
              :class="
                practiceMode === 'passage'
                  ? 'max-h-[min(48vh,30rem)] overflow-y-auto overscroll-contain pr-0.5'
                  : ''
              "
            >
              <!-- 篇章：按段展示，当前句浅底 + 文章难词高亮 -->
              <div v-if="showPassageBlocks" class="space-y-2 practice-passage-text">
                <div
                  v-for="(block, i) in passageBlocksView"
                  :key="i"
                  :data-practice-block="i"
                  class="rounded-xl px-2.5 py-2 transition-colors"
                  :class="
                    i === activeBlockIndex
                      ? 'bg-warning-soft ring-1 ring-amber-200/80 dark:ring-amber-800/50'
                      : 'bg-transparent'
                  "
                >
                  <p
                    class="text-[15px] sm:text-[17px] font-medium leading-[1.75] text-neutral-900 dark:text-neutral-50"
                    v-html="passageBlockHtml(block.english)"
                  />
                  <p
                    v-if="block.chinese"
                    class="mt-1.5 text-sm sm:text-[15px] text-neutral-500 dark:text-neutral-400 leading-[1.65]"
                  >
                    {{ block.chinese }}
                  </p>
                </div>
              </div>

              <template v-else>
                <p
                  v-if="highlightedTargetHtml"
                  class="text-neutral-900 dark:text-neutral-50 practice-passage-text text-[15px] sm:text-[17px] font-medium leading-[1.75]"
                  v-html="highlightedTargetHtml"
                />
                <p
                  v-else
                  class="text-neutral-900 dark:text-neutral-50"
                  :class="
                    practiceMode === 'word'
                      ? 'text-2xl font-semibold tracking-wide leading-relaxed'
                      : practiceMode === 'passage'
                        ? 'text-[15px] sm:text-[17px] font-medium leading-[1.75]'
                        : 'text-[15px] sm:text-base font-medium leading-relaxed'
                  "
                >
                  {{ targetText }}
                </p>
                <p
                  v-if="ipa"
                  class="mt-1.5 text-sm text-neutral-400 dark:text-neutral-500 font-serif leading-relaxed"
                >
                  {{ ipa }}
                </p>
                <p
                  v-if="chinese"
                  class="mt-2 text-sm text-neutral-500 dark:text-neutral-400 leading-relaxed"
                  :class="practiceMode === 'passage' ? 'sm:text-[15px] leading-[1.65]' : ''"
                >
                  {{ chinese }}
                </p>
              </template>
            </div>
          </section>

          <!-- 示范源 + 语速：单词打分 + AI 跟读 -->
          <div
            v-if="showDemoSource"
            class="rounded-2xl border border-black/[0.05] dark:border-white/10 bg-white/70 dark:bg-neutral-900/60 px-3 py-2 space-y-2"
          >
            <div class="flex items-center justify-between gap-3">
              <span class="text-xs text-neutral-500 shrink-0">示范音</span>
              <div class="inline-flex flex-wrap justify-end gap-1 rounded-xl bg-neutral-100 dark:bg-neutral-800 p-0.5">
                <button
                  type="button"
                  class="min-w-[3.25rem] h-8 px-2.5 rounded-[0.65rem] text-xs font-medium transition"
                  :class="
                    demoVoice === 'original'
                      ? 'bg-white text-amber-800 shadow-sm dark:bg-neutral-700 dark:text-amber-200'
                      : 'text-ink-faint hover:text-neutral-700'
                  "
                  @click="setDemoVoice('original')"
                >
                  {{ originalVoiceLabel }}
                </button>
                <button
                  type="button"
                  class="min-w-[3.25rem] h-8 px-2.5 rounded-[0.65rem] text-xs font-medium transition"
                  :class="
                    demoVoice === 'Ryan'
                      ? 'bg-white text-amber-800 shadow-sm dark:bg-neutral-700 dark:text-amber-200'
                      : 'text-ink-faint hover:text-neutral-700'
                  "
                  @click="setDemoVoice('Ryan')"
                >
                  Ryan
                </button>
                <button
                  type="button"
                  class="min-w-[3.75rem] h-8 px-2.5 rounded-[0.65rem] text-xs font-medium transition"
                  :class="
                    demoVoice === 'Katerina'
                      ? 'bg-white text-amber-800 shadow-sm dark:bg-neutral-700 dark:text-amber-200'
                      : 'text-ink-faint hover:text-neutral-700'
                  "
                  @click="setDemoVoice('Katerina')"
                >
                  Katerina
                </button>
              </div>
            </div>
            <div class="flex items-center justify-between gap-3">
              <span class="text-xs text-neutral-500 shrink-0">示范语速</span>
              <div class="inline-flex rounded-xl bg-neutral-100 dark:bg-neutral-800 p-0.5">
                <button
                  type="button"
                  class="min-w-[4.25rem] h-8 rounded-[0.65rem] text-xs font-medium transition"
                  :class="
                    demoRate === 0.5
                      ? 'bg-white text-amber-800 shadow-sm dark:bg-neutral-700 dark:text-amber-200'
                      : 'text-ink-faint hover:text-neutral-700'
                  "
                  @click="setDemoRate(0.5)"
                >
                  0.5×
                </button>
                <button
                  type="button"
                  class="min-w-[4.25rem] h-8 rounded-[0.65rem] text-xs font-medium transition"
                  :class="
                    demoRate === 1
                      ? 'bg-white text-amber-800 shadow-sm dark:bg-neutral-700 dark:text-amber-200'
                      : 'text-ink-faint hover:text-neutral-700'
                  "
                  @click="setDemoRate(1)"
                >
                  正常
                </button>
              </div>
            </div>
          </div>

          <p
            v-if="fallbackHint"
            class="text-xs text-amber-800 dark:text-amber-300 bg-amber-50 dark:bg-amber-950/30 rounded-xl px-3 py-2"
          >
            {{ fallbackHint }}
          </p>

          <!-- Listen -->
          <section v-if="step === 'listen'" class="flex flex-col items-center gap-4 pt-3 pb-2">
            <p class="text-sm text-neutral-500 text-center px-2 leading-relaxed">{{ listenHint }}</p>

            <div
              class="w-full space-y-3"
              :class="practiceMode === 'passage' ? 'sm:max-w-2xl mx-auto' : 'sm:max-w-lg mx-auto'"
            >
              <!-- 听示范：大圆形播放，播放中有声波动效 -->
              <button
                type="button"
                class="group relative w-full overflow-hidden rounded-[1.35rem] border text-left transition duration-200 active:scale-[0.985] disabled:opacity-60"
                :class="
                  demoPlaying || demoSessionActive
                    ? 'border-amber-300/80 bg-gradient-to-br from-amber-50 to-orange-50 shadow-[0_10px_28px_rgba(217,119,6,0.18)] dark:border-amber-700/50 dark:from-amber-950/40 dark:to-orange-950/30'
                    : 'border-black/[0.06] bg-white hover:border-amber-200 hover:shadow-[0_8px_24px_rgba(0,0,0,0.06)] dark:border-white/10 dark:bg-neutral-900 dark:hover:border-amber-800/60'
                "
                :disabled="demoLoading && !demoSessionActive"
                @click="playDemo"
              >
                <div class="flex items-center gap-3.5 px-4 py-3.5">
                  <span
                    class="relative flex h-12 w-12 shrink-0 items-center justify-center rounded-full text-white transition"
                    :class="
                      demoLoading
                        ? 'bg-amber-400'
                        : demoPlaying
                          ? 'bg-amber-500 shadow-[0_0_0_6px_rgba(245,158,11,0.22)]'
                          : 'bg-amber-600 group-hover:bg-amber-500 group-hover:scale-105'
                    "
                  >
                    <span
                      v-if="demoPlaying"
                      class="absolute inset-0 rounded-full bg-amber-400/40 animate-ping"
                      aria-hidden="true"
                    />
                    <AppIcon name="spinner" v-if="demoLoading" class="relative animate-spin" :size="20" />
                    <AppIcon name="pause" v-else-if="demoPlaying" class="relative" :size="18" />
                    <AppIcon v-else name="play" class="relative ml-0.5" :size="20" />
                  </span>

                  <span class="min-w-0 flex-1">
                    <span class="block text-[15px] font-semibold text-neutral-900 dark:text-neutral-50">
                      {{ demoActionLabel }}
                    </span>
                    <span class="mt-0.5 block text-xs text-neutral-500 dark:text-neutral-400">
                      {{
                        demoPlaying
                          ? '播放中 · 再点可暂停'
                          : demoSessionActive
                            ? '已暂停 · 再点继续'
                            : demoVoice === 'original'
                              ? practiceMode === 'word'
                                ? '词典音 · 可切换 Ryan / Katerina'
                                : '当前选中的示范源 · 可调语速'
                              : `${demoVoice} · ${demoRate === 0.5 ? '0.5× 慢速' : '正常语速'}`
                      }}
                    </span>
                  </span>

                  <span
                    class="flex items-end gap-[3px] h-7 shrink-0 pr-0.5"
                    :class="demoPlaying ? 'opacity-100' : 'opacity-35 group-hover:opacity-70'"
                    aria-hidden="true"
                  >
                    <span
                      class="w-[3px] rounded-full bg-amber-500"
                      :class="demoPlaying ? 'h-3 animate-[pulse_0.7s_ease-in-out_infinite]' : 'h-2'"
                    />
                    <span
                      class="w-[3px] rounded-full bg-amber-500"
                      :class="demoPlaying ? 'h-6 animate-[pulse_0.85s_ease-in-out_infinite]' : 'h-4'"
                      style="animation-delay: 0.12s"
                    />
                    <span
                      class="w-[3px] rounded-full bg-amber-500"
                      :class="demoPlaying ? 'h-4 animate-[pulse_0.65s_ease-in-out_infinite]' : 'h-3'"
                      style="animation-delay: 0.24s"
                    />
                    <span
                      class="w-[3px] rounded-full bg-amber-500"
                      :class="demoPlaying ? 'h-5 animate-[pulse_0.9s_ease-in-out_infinite]' : 'h-2.5'"
                      style="animation-delay: 0.08s"
                    />
                  </span>
                </div>
              </button>

              <!-- 开始跟读：主 CTA -->
              <button
                type="button"
                class="group relative w-full overflow-hidden rounded-[1.35rem] bg-sky-600 text-left text-white shadow-[0_12px_28px_rgba(2,132,199,0.28)] transition duration-200 hover:bg-sky-500 hover:shadow-[0_14px_32px_rgba(2,132,199,0.34)] active:scale-[0.985]"
                @click="goRecord"
              >
                <span
                  class="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_20%_0%,rgba(255,255,255,0.22),transparent_55%)]"
                  aria-hidden="true"
                />
                <span class="relative flex items-center gap-3.5 px-4 py-3.5">
                  <span
                    class="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-white/18 ring-1 ring-white/25 transition group-hover:scale-105"
                  >
                    <AppIcon name="mic" :size="22" />
                  </span>
                  <span class="min-w-0 flex-1">
                    <span class="block text-[15px] font-semibold tracking-wide">开始跟读</span>
                    <span class="mt-0.5 block text-xs text-sky-100/90">
                      {{ useOral ? '对着麦克风读，系统直接评发音' : '跟读后自动识别并点评' }}
                    </span>
                  </span>
                  <AppIcon name="check" class="shrink-0 opacity-80 transition group-hover:translate-x-0.5" :size="18" />
                </span>
              </button>
            </div>

            <button
              type="button"
              class="mt-1 text-sm text-neutral-400 hover:text-ink-soft transition"
              @click="$emit('close')"
            >
              稍后再练
            </button>
          </section>

          <!-- Record -->
          <section v-else-if="step === 'record'" class="flex flex-col items-center gap-3 pt-1">
            <button
              type="button"
              class="relative w-[5.5rem] h-[5.5rem] rounded-full flex items-center justify-center text-white transition disabled:opacity-60"
              :class="
                listening
                  ? 'bg-rose-500 shadow-[0_10px_28px_rgba(244,63,94,0.35)]'
                  : loading
                    ? 'bg-neutral-400'
                    : 'bg-sky-600 hover:bg-sky-700 shadow-[0_10px_28px_rgba(2,132,199,0.28)]'
              "
              :disabled="loading"
              :aria-label="listening ? '停止' : '开始录音'"
              @click="toggleMic"
            >
              <span
                v-if="listening"
                class="absolute inset-[-6px] rounded-full border-2 border-rose-300/70 animate-ping"
                aria-hidden="true"
              />
              <AppIcon name="spinner" v-if="loading" class="animate-spin" :size="28" />
              <AppIcon name="mic" v-else-if="!listening" :size="30" />
              <AppIcon v-else name="stop" :size="24" />
            </button>

            <p class="text-sm text-neutral-600 dark:text-neutral-300 text-center min-h-[1.25rem] px-2">
              {{ recordHint }}
            </p>

            <button
              type="button"
              class="text-xs text-neutral-500 hover:text-amber-700 dark:hover:text-amber-300 underline underline-offset-2 disabled:opacity-50"
              :disabled="demoLoading"
              @click="playDemo"
            >
              {{ demoLoading ? '合成中…' : '再听一遍' }}
            </button>

            <div v-if="!useOral || micUnsupported" class="w-full space-y-1.5 pt-1">
              <label class="block text-xs text-neutral-500">识别结果（可修改）</label>
              <textarea
                v-model="transcript"
                :rows="practiceMode === 'passage' ? 4 : 2"
                class="w-full rounded-2xl border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 px-3.5 py-2.5 text-sm leading-relaxed"
                placeholder="跟读内容会出现在这里"
              />
            </div>

            <p
              v-if="error && !useOral"
              class="w-full text-sm text-amber-900 dark:text-amber-200 bg-amber-50 dark:bg-amber-950/30 rounded-2xl px-3 py-2"
            >
              {{ error }}
            </p>
          </section>

          <!-- Result -->
          <section v-else-if="step === 'result' && result" class="space-y-3">
            <div
              class="rounded-2xl border border-black/[0.06] dark:border-white/10 bg-white dark:bg-neutral-900 p-4"
            >
              <div class="flex items-center gap-4">
                <div class="relative w-[4.75rem] h-[4.75rem] rounded-full shrink-0 p-[3px]" :style="scoreRingStyle">
                  <div
                    class="w-full h-full rounded-full bg-[#FBF8F3] dark:bg-neutral-950 flex flex-col items-center justify-center"
                  >
                    <span class="text-2xl font-bold leading-none tabular-nums">{{ result.score }}</span>
                    <span class="text-[10px] text-neutral-400 mt-0.5">分</span>
                  </div>
                </div>
                <div class="min-w-0">
                  <p
                    class="text-lg font-semibold"
                    :class="{
                      'text-success': scoreTone === 'good',
                      'text-amber-700 dark:text-amber-300': scoreTone === 'mid',
                      'text-rose-700 dark:text-rose-300': scoreTone === 'low',
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

              <!-- 点评播报：Katerina 精简口播 -->
              <div class="mt-3.5 flex items-center gap-2">
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
                    <AppIcon name="spinner" v-if="feedbackTtsLoading" class="animate-spin" :size="12" />
                    <AppIcon name="pause" v-else-if="feedbackTtsPlaying" :size="11" />
                    <AppIcon v-else name="play" class="ml-0.5" :size="12" />
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
                <button
                  type="button"
                  class="h-9 px-2.5 rounded-full text-[11px] font-medium transition touch-manipulation"
                  :class="
                    feedbackTtsMuted
                      ? 'text-ink-faint bg-sunken'
                      : 'text-violet-700 bg-violet-50 dark:bg-violet-950/40 dark:text-violet-300'
                  "
                  :aria-label="feedbackTtsMuted ? '开启自动播报' : '关闭自动播报'"
                  :title="feedbackTtsMuted ? '已静音自动播报' : '自动播报已开'"
                  @click="setFeedbackTtsMuted(!feedbackTtsMuted)"
                >
                  {{ feedbackTtsMuted ? '已静音' : 'Katerina' }}
                </button>
              </div>

              <div v-if="dimensionItems.length" class="mt-4 grid gap-2" :class="dimensionItems.length === 3 ? 'grid-cols-3' : 'grid-cols-2'">
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

            <div
              v-if="result.words?.length"
              class="rounded-2xl border border-black/[0.06] dark:border-white/10 bg-white/90 dark:bg-neutral-900/80 px-3.5 py-3"
            >
              <p class="text-[11px] font-medium text-neutral-500 mb-2">词级发音</p>
              <div class="flex flex-wrap gap-1.5">
                <span
                  v-for="(w, i) in result.words"
                  :key="`${w.char}-${i}`"
                  class="inline-flex items-center rounded-lg px-2 py-1 text-[13px] font-medium"
                  :class="wordToneClass(w.score)"
                  :title="`${w.char}: ${w.score}`"
                >
                  {{ w.char }}
                </span>
              </div>
            </div>

            <div v-if="showPlaybackBlock" class="space-y-1.5">
              <button
                type="button"
                class="group relative w-full overflow-hidden rounded-[1.35rem] border text-left transition duration-200 active:scale-[0.985] disabled:opacity-60"
                :class="
                  playbackError
                    ? 'border-rose-200 bg-rose-50/80 dark:border-rose-900/50 dark:bg-rose-950/30'
                    : playbackPlaying
                      ? 'border-emerald-300/80 bg-gradient-to-br from-emerald-50 to-teal-50 shadow-[0_10px_28px_rgba(16,185,129,0.16)] dark:border-emerald-700/50 dark:from-emerald-950/40 dark:to-teal-950/30'
                      : 'border-black/[0.06] bg-white hover:border-emerald-200 hover:shadow-[0_8px_24px_rgba(0,0,0,0.06)] dark:border-white/10 dark:bg-neutral-900 dark:hover:border-emerald-800/60'
                "
                :disabled="
                  playbackLoading ||
                  (!playbackUrl && !playbackRemoteUrl && !playbackError && !result?.practice_record_id)
                "
                @click="togglePlayback"
              >
                <span
                  class="pointer-events-none absolute inset-x-0 bottom-0 h-[3px] bg-emerald-100 dark:bg-emerald-950/80"
                  aria-hidden="true"
                >
                  <span
                    class="block h-full bg-emerald-500 transition-[width] duration-150 ease-linear"
                    :style="{ width: `${playbackProgress}%` }"
                  />
                </span>

                <span class="flex items-center gap-3.5 px-4 py-3.5">
                  <span
                    class="relative flex h-12 w-12 shrink-0 items-center justify-center rounded-full text-white transition"
                    :class="
                      playbackLoading
                        ? 'bg-emerald-400'
                        : playbackPlaying
                          ? 'bg-emerald-500 shadow-[0_0_0_6px_rgba(16,185,129,0.2)]'
                          : 'bg-emerald-600 group-hover:bg-emerald-500 group-hover:scale-105'
                    "
                  >
                    <span
                      v-if="playbackPlaying"
                      class="absolute inset-0 rounded-full bg-emerald-400/35 animate-ping"
                      aria-hidden="true"
                    />
                    <AppIcon name="spinner" v-if="playbackLoading" class="relative animate-spin" :size="20" />
                    <AppIcon name="pause" v-else-if="playbackPlaying" class="relative" :size="18" />
                    <AppIcon v-else name="play" class="relative ml-0.5" :size="20" />
                  </span>

                  <span class="min-w-0 flex-1">
                    <span class="block text-[15px] font-semibold text-neutral-900 dark:text-neutral-50">
                      <template v-if="playbackError">弹窗内暂无法回听</template>
                      <template v-else-if="playbackLoading">正在加载录音…</template>
                      <template v-else-if="playbackPlaying">正在回听</template>
                      <template v-else>
                        回听自己的录音
                        <span
                          v-if="playbackDurationLabel"
                          class="ml-1.5 inline-flex align-middle tabular-nums text-[13px] font-semibold text-emerald-700 dark:text-emerald-300"
                        >{{ playbackDurationLabel }}</span>
                      </template>
                    </span>
                    <span class="mt-0.5 block text-xs text-neutral-500 dark:text-neutral-400 tabular-nums">
                      <template v-if="playbackError">点此重试，或到练习记录播放</template>
                      <template v-else-if="playbackLoading">请稍候</template>
                      <template v-else-if="playbackPlaying">
                        {{ playbackCurrentLabel
                        }}{{ playbackDurationLabel ? ` / ${playbackDurationLabel}` : '' }}
                        · 再点暂停
                      </template>
                      <template v-else>听听自己的发音</template>
                    </span>
                  </span>

                  <span
                    class="flex items-end gap-[3px] h-7 shrink-0 pr-0.5"
                    :class="playbackPlaying ? 'opacity-100' : 'opacity-30 group-hover:opacity-70'"
                    aria-hidden="true"
                  >
                    <span
                      class="w-[3px] rounded-full bg-emerald-500"
                      :class="playbackPlaying ? 'h-3 animate-[pulse_0.7s_ease-in-out_infinite]' : 'h-2'"
                    />
                    <span
                      class="w-[3px] rounded-full bg-emerald-500"
                      :class="playbackPlaying ? 'h-6 animate-[pulse_0.85s_ease-in-out_infinite]' : 'h-4'"
                      style="animation-delay: 0.12s"
                    />
                    <span
                      class="w-[3px] rounded-full bg-emerald-500"
                      :class="playbackPlaying ? 'h-4 animate-[pulse_0.65s_ease-in-out_infinite]' : 'h-3'"
                      style="animation-delay: 0.24s"
                    />
                    <span
                      class="w-[3px] rounded-full bg-emerald-500"
                      :class="playbackPlaying ? 'h-5 animate-[pulse_0.9s_ease-in-out_infinite]' : 'h-2.5'"
                      style="animation-delay: 0.08s"
                    />
                  </span>
                </span>
              </button>

              <div
                v-if="playbackError"
                class="rounded-xl border border-rose-200/80 bg-rose-50/90 px-3.5 py-2.5 dark:border-rose-900/40 dark:bg-rose-950/30"
              >
                <p class="text-[13px] text-rose-800 dark:text-rose-200 leading-relaxed">
                  评分已保存。弹窗里暂时播不了这次录音，可到
                  <span class="font-medium">学习 → 练习记录</span>
                  用「听一听」回放（那里通常正常）。
                </p>
                <button
                  type="button"
                  class="mt-2 inline-flex items-center gap-1 text-[13px] font-semibold text-rose-700 hover:text-rose-900 dark:text-rose-300 dark:hover:text-rose-100"
                  @click="goLearningRecords"
                >
                  去练习记录播放
                  <span aria-hidden="true">→</span>
                </button>
              </div>
            </div>

            <div
              v-if="result.issues?.length || result.tips?.length"
              class="rounded-2xl border border-black/[0.06] dark:border-white/10 bg-white/80 dark:bg-neutral-900/60 overflow-hidden"
            >
              <button
                type="button"
                class="w-full flex items-center justify-between px-3.5 py-2.5 text-sm text-neutral-600 dark:text-neutral-300"
                @click="showTips = !showTips"
              >
                <span>{{ showTips ? '收起建议' : '改进建议' }}</span>
                <AppIcon name="chevron-down" class="transition-transform" :size="16" />
              </button>
              <div
                v-if="showTips"
                class="px-3.5 pb-3 space-y-3 border-t border-black/5 dark:border-white/10 pt-3"
              >
                <ul v-if="result.issues?.length" class="space-y-1.5 text-sm text-neutral-700 dark:text-neutral-300">
                  <li v-for="(item, i) in result.issues.slice(0, 3)" :key="`i-${i}`" class="flex gap-2">
                    <span class="text-rose-500 shrink-0">·</span>
                    <span>{{ item }}</span>
                  </li>
                </ul>
                <ul v-if="result.tips?.length" class="space-y-1.5 text-sm text-neutral-700 dark:text-neutral-300">
                  <li v-for="(item, i) in result.tips.slice(0, 3)" :key="`t-${i}`" class="flex gap-2">
                    <span class="text-amber-600 shrink-0">·</span>
                    <span>{{ item }}</span>
                  </li>
                </ul>
              </div>
            </div>
          </section>
        </div>

        <!-- Footer：听示范步主操作已在内容区，不重复底栏 -->
        <div
          v-if="step !== 'listen'"
          class="shrink-0 flex items-center gap-2 px-5 py-3 border-t border-black/5 dark:border-white/10 bg-[#FBF8F3]/95 dark:bg-neutral-950/95 backdrop-blur-sm pb-[max(0.75rem,env(safe-area-inset-bottom))]"
        >
          <template v-if="step === 'record'">
            <button
              type="button"
              class="flex-1 h-11 rounded-2xl text-sm border border-black/10 dark:border-white/15 hover:bg-black/5 dark:hover:bg-white/5 disabled:opacity-40"
              :disabled="loading || listening"
              @click="step = 'listen'"
            >
              返回
            </button>
            <button
              v-if="!useOral"
              type="button"
              class="flex-[1.25] h-11 rounded-2xl text-sm font-semibold bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900 disabled:opacity-40"
              :disabled="loading || listening || !transcript.trim()"
              @click="submitFeedback"
            >
              {{ loading ? '点评中…' : '提交点评' }}
            </button>
            <button
              v-else
              type="button"
              class="flex-[1.25] h-11 rounded-2xl text-sm font-semibold bg-sky-600 text-white hover:bg-sky-700 disabled:opacity-40"
              :disabled="loading"
              @click="toggleMic"
            >
              {{ listening ? '停止评分' : loading ? '评分中…' : '开始录音' }}
            </button>
          </template>

          <template v-else>
            <button
              type="button"
              class="flex-1 h-11 rounded-2xl text-sm border border-line-strong hover:bg-black/5 dark:hover:bg-white/5 disabled:opacity-40"
              :disabled="loading || listening"
              @click.stop="retry"
            >
              再试一次
            </button>
            <button
              type="button"
              class="flex-[1.3] h-11 rounded-2xl text-sm font-semibold bg-amber-600 text-white hover:bg-amber-700"
              @click="onNext"
            >
              {{ hasNext === false || practiceMode === 'word' ? '完成' : practiceMode === 'passage' ? '完成' : '下一句' }}
            </button>
          </template>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.practice-passage-text :deep(.vocab-link-hl) {
  font-weight: 600;
}
</style>
