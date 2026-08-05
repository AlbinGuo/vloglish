<script setup lang="ts">
import { computed, nextTick, onUnmounted, ref, watch } from 'vue'
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
import { useOralEvalEngine } from '@/composables/useOralEvalEngine'
import { playWordPronunciation, stopSpeaking } from '@/utils/speakWord'

const props = withDefaults(
  defineProps<{
    open: boolean
    /** word=单词打分 sentence=字幕跟读 passage=篇章评测 */
    mode?: OralPracticeMode
    /** 评测文本；未传时用 english */
    refText?: string
    videoId?: string
    subtitleId?: number | null
    english?: string
    chinese?: string
    /** 单词打分：音标 */
    ipa?: string
    title?: string
    sentenceIndex?: number
    sentenceTotal?: number
    hasNext?: boolean
  }>(),
  {
    mode: 'sentence',
    subtitleId: null,
    hasNext: true,
  },
)

const emit = defineEmits<{ close: []; play: [rate: number]; next: [] }>()

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
/** 结果页回听地址（本地 blob 或代理后的 blob） */
const playbackUrl = ref('')
const playbackError = ref(false)
const playbackLoading = ref(false)
const playbackPlaying = ref(false)
const playbackProgress = ref(0)
const playbackCurrentLabel = ref('0:00')
const playbackDurationLabel = ref('')
const playbackAudioEl = ref<HTMLAudioElement | null>(null)
/** 最近一次评测的云端录音地址，供本地 blob 解码失败时回退 */
const playbackRemoteUrl = ref('')
let playbackIgnoreError = false
let playbackRemoteTried = false

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
  if (score >= 55) return 'bg-neutral-100 text-neutral-700 dark:bg-neutral-800 dark:text-neutral-300'
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

function stopDemoAudio() {
  clearDemoPlayingTimer()
  demoPlaying.value = false
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
}

function formatPlaybackTime(sec: number) {
  if (!Number.isFinite(sec) || sec < 0) return '0:00'
  const s = Math.floor(sec)
  const m = Math.floor(s / 60)
  const r = s % 60
  return `${m}:${String(r).padStart(2, '0')}`
}

function clearPlayback() {
  playbackIgnoreError = true
  const el = playbackAudioEl.value
  if (el) {
    try {
      el.pause()
      el.removeAttribute('src')
      el.load()
    } catch {
      /* ignore */
    }
  }
  if (playbackUrl.value.startsWith('blob:') && playbackUrl.value !== oral.localAudioUrl.value) {
    try {
      URL.revokeObjectURL(playbackUrl.value)
    } catch {
      /* ignore */
    }
  }
  playbackUrl.value = ''
  playbackRemoteUrl.value = ''
  playbackError.value = false
  playbackLoading.value = false
  playbackPlaying.value = false
  playbackProgress.value = 0
  playbackCurrentLabel.value = '0:00'
  playbackDurationLabel.value = ''
  playbackRemoteTried = false
  // load() 的 error 事件可能异步到来
  window.setTimeout(() => {
    playbackIgnoreError = false
  }, 0)
}

function onPlaybackTimeUpdate() {
  const el = playbackAudioEl.value
  if (!el || !el.duration) return
  playbackProgress.value = Math.min(100, (el.currentTime / el.duration) * 100)
  playbackCurrentLabel.value = formatPlaybackTime(el.currentTime)
}

function onPlaybackLoaded() {
  const el = playbackAudioEl.value
  if (!el) return
  playbackError.value = false
  if (Number.isFinite(el.duration) && el.duration > 0) {
    playbackDurationLabel.value = formatPlaybackTime(el.duration)
  }
}

function onPlaybackEnded() {
  playbackPlaying.value = false
  playbackProgress.value = 0
  playbackCurrentLabel.value = '0:00'
  const el = playbackAudioEl.value
  if (el) el.currentTime = 0
}

async function loadRemotePlayback(remote: string): Promise<boolean> {
  const url = remote.trim()
  if (!url || url.startsWith('blob:')) return false
  playbackLoading.value = true
  playbackError.value = false
  try {
    const blob = await fetchOralRemoteAudio(url)
    if (playbackUrl.value.startsWith('blob:') && playbackUrl.value !== oral.localAudioUrl.value) {
      try {
        URL.revokeObjectURL(playbackUrl.value)
      } catch {
        /* ignore */
      }
    }
    playbackUrl.value = URL.createObjectURL(blob)
    playbackRemoteTried = true
    return true
  } catch {
    return false
  } finally {
    playbackLoading.value = false
  }
}

async function onPlaybackAudioError() {
  if (playbackIgnoreError || !playbackUrl.value) return
  // 本地分片常无法直接解码：自动改走云端代理
  if (!playbackRemoteTried && playbackRemoteUrl.value) {
    const ok = await loadRemotePlayback(playbackRemoteUrl.value)
    if (ok) return
  }
  playbackPlaying.value = false
  playbackError.value = true
}

async function togglePlayback() {
  if (playbackLoading.value) return
  // 出错时允许再点一次重试拉取
  if (playbackError.value) {
    playbackError.value = false
    playbackRemoteTried = false
    if (playbackRemoteUrl.value) {
      const ok = await loadRemotePlayback(playbackRemoteUrl.value)
      if (!ok && !oral.localAudioUrl.value) {
        playbackError.value = true
        return
      }
      if (!ok && oral.localAudioUrl.value) playbackUrl.value = oral.localAudioUrl.value
    } else if (oral.localAudioUrl.value) {
      playbackUrl.value = oral.localAudioUrl.value
    } else {
      playbackError.value = true
      return
    }
  }
  if (!playbackUrl.value) return
  const el = playbackAudioEl.value
  if (!el) return
  stopSpeaking()
  stopDemoAudio()
  try {
    if (playbackPlaying.value) {
      el.pause()
      playbackPlaying.value = false
      return
    }
    if (el.getAttribute('src') !== playbackUrl.value) {
      el.src = playbackUrl.value
    }
    await el.play()
    playbackPlaying.value = true
  } catch {
    playbackPlaying.value = false
    // 交给 onPlaybackAudioError 做云端回退
    await onPlaybackAudioError()
  }
}

async function resolvePlayback(remoteUrl?: string | null) {
  clearPlayback()
  const remote = (remoteUrl || '').trim()
  const local = oral.localAudioUrl.value
  playbackRemoteUrl.value = remote.startsWith('http') ? remote : ''

  // 优先云端完整音频（本地 saveAudio 分片经常不是可播容器）
  if (playbackRemoteUrl.value) {
    const ok = await loadRemotePlayback(playbackRemoteUrl.value)
    if (ok) return
  }
  if (local) {
    playbackUrl.value = local
    return
  }
  if (remote.startsWith('blob:')) {
    playbackUrl.value = remote
    return
  }
  // 没有任何可用来源时不展示错误块
}

function resetState() {
  clearAutoPlay()
  stopListening(true)
  oral.cancel()
  oral.revokeLocalAudio()
  stopSpeaking()
  stopDemoAudio()
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

function playOriginalSource() {
  const rate = demoRate.value
  markDemoPlaying()
  if (practiceMode.value === 'word') {
    void playWordPronunciation(targetText.value, null, rate)
    return
  }
  emit('play', rate)
}

async function playTtsDemo(voice: PracticeTtsVoice) {
  if (!targetText.value) return
  const blob = await fetchPracticeTts(targetText.value, voice, practiceMode.value)
  const url = URL.createObjectURL(blob)
  demoObjectUrl = url
  const audio = new Audio(url)
  demoAudio = audio
  audio.playbackRate = demoRate.value
  audio.onended = () => {
    stopDemoAudio()
  }
  clearDemoPlayingTimer()
  demoPlaying.value = true
  await audio.play()
}

async function playDemo() {
  error.value = ''
  stopSpeaking()
  stopDemoAudio()

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
  demoVoice.value = voice
  void playDemo()
}

function setDemoRate(rate: 0.5 | 1) {
  demoRate.value = rate
  void playDemo()
}

function goRecord() {
  error.value = ''
  result.value = null
  step.value = 'record'
}

async function resolveEngine() {
  engineMode.value = 'unknown'
  const ok = await oral.probe()
  engineMode.value = ok ? 'oral' : 'llm'
}

async function submitOralResult(oralRaw: Record<string, unknown>) {
  if (props.videoId && props.subtitleId != null && practiceMode.value === 'sentence') {
    return aiShadowingOralFeedback(props.videoId, props.subtitleId, oralRaw)
  }
  return aiOralEvalFeedback(targetText.value, oralRaw, coreType.value)
}

async function startOralRecording() {
  if (!targetText.value) return
  error.value = ''
  result.value = null
  transcript.value = ''
  fallbackHint.value = ''
  autoSubmitArmed.value = true
  step.value = 'record'

  // 口语 SDK 自己申请麦克风；不要先 getUserMedia 再 stop，否则易抢占/弄死 stream
  if (typeof window !== 'undefined' && !window.isSecureContext) {
    engineMode.value = 'llm'
    micUnsupported.value = true
    error.value = '需要 HTTPS 或 localhost 才能录音'
    return
  }
  try {
    if (navigator.permissions?.query) {
      const status = await navigator.permissions.query({ name: 'microphone' as PermissionName })
      if (status.state === 'denied') {
        engineMode.value = 'llm'
        micUnsupported.value = true
        error.value = '麦克风权限被拒绝，请在浏览器地址栏允许后重试'
        return
      }
    }
  } catch {
    /* Permissions API 不支持 microphone 时忽略，交给 SDK */
  }

  listening.value = true
  loading.value = false
  try {
    const oralRaw = await oral.evaluate(targetText.value, coreType.value)
    listening.value = false
    loading.value = true
    const remoteFromSdk = String(oralRaw.audioUrl || oralRaw.audio_url || '').trim()
    result.value = await submitOralResult(oralRaw)
    transcript.value = result.value.transcript || ''
    step.value = 'result'
    showTips.value = Boolean(result.value.issues?.length || result.value.tips?.length)
    await resolvePlayback(result.value.audio_url || remoteFromSdk)
    await nextTick()
  } catch (e: unknown) {
    engineMode.value = 'llm'
    const detail = e instanceof Error ? e.message.trim() : ''
    fallbackHint.value = detail
      ? `发音评测暂不可用（${detail.slice(0, 80)}），已切换为识别点评`
      : '发音评测暂不可用，已切换为识别点评'
    error.value = ''
    void startListening()
  } finally {
    autoSubmitArmed.value = false
    listening.value = false
    loading.value = false
  }
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
    error.value = '当前浏览器不支持语音识别，请输入内容后点评'
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
      result.value = await aiShadowingTextFeedback(targetText.value, text)
    }
    step.value = 'result'
    showTips.value = Boolean(result.value.issues?.length || result.value.tips?.length)
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

onUnmounted(() => {
  clearAutoPlay()
  stopListening(true)
  oral.cancel()
  oral.revokeLocalAudio()
  stopSpeaking()
  stopDemoAudio()
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
        class="w-full sm:max-w-md max-h-[92dvh] flex flex-col rounded-t-[1.75rem] sm:rounded-[1.75rem] bg-[#FBF8F3] dark:bg-neutral-950 border border-black/5 dark:border-white/10 overflow-hidden"
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
                  :class="useOral ? 'text-emerald-700 dark:text-emerald-400' : 'text-amber-700 dark:text-amber-400'"
                >{{ engineLabel }}</span>
                <span class="mx-1 opacity-40">·</span>
                <span>{{ step === 'listen' ? '听示范' : step === 'record' ? '跟读录音' : '查看结果' }}</span>
              </p>
            </div>
            <button
              type="button"
              class="w-9 h-9 flex items-center justify-center rounded-full text-neutral-400 hover:text-neutral-700 hover:bg-black/5 dark:hover:text-neutral-200 dark:hover:bg-white/10 shrink-0"
              aria-label="关闭"
              @click="$emit('close')"
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M18 6L6 18M6 6l12 12" />
              </svg>
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
                    : 'bg-neutral-200 dark:bg-neutral-800'
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
            class="relative overflow-hidden rounded-2xl border border-black/[0.06] dark:border-white/10 bg-white dark:bg-neutral-900 px-4 py-3.5"
          >
            <p
              class="leading-relaxed text-neutral-900 dark:text-neutral-50"
              :class="practiceMode === 'word' ? 'text-2xl font-semibold tracking-wide' : 'text-[15px] sm:text-base font-medium'"
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
            >
              {{ chinese }}
            </p>
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
                      : 'text-neutral-500 hover:text-neutral-700 dark:text-neutral-400'
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
                      : 'text-neutral-500 hover:text-neutral-700 dark:text-neutral-400'
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
                      : 'text-neutral-500 hover:text-neutral-700 dark:text-neutral-400'
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
                      : 'text-neutral-500 hover:text-neutral-700 dark:text-neutral-400'
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
                      : 'text-neutral-500 hover:text-neutral-700 dark:text-neutral-400'
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

            <div class="w-full max-w-sm space-y-3">
              <!-- 听示范：大圆形播放，播放中有声波动效 -->
              <button
                type="button"
                class="group relative w-full overflow-hidden rounded-[1.35rem] border text-left transition duration-200 active:scale-[0.985] disabled:opacity-60"
                :class="
                  demoPlaying
                    ? 'border-amber-300/80 bg-gradient-to-br from-amber-50 to-orange-50 shadow-[0_10px_28px_rgba(217,119,6,0.18)] dark:border-amber-700/50 dark:from-amber-950/40 dark:to-orange-950/30'
                    : 'border-black/[0.06] bg-white hover:border-amber-200 hover:shadow-[0_8px_24px_rgba(0,0,0,0.06)] dark:border-white/10 dark:bg-neutral-900 dark:hover:border-amber-800/60'
                "
                :disabled="demoLoading"
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
                    <svg
                      v-if="demoLoading"
                      class="relative animate-spin"
                      width="20"
                      height="20"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2.2"
                      aria-hidden="true"
                    >
                      <path d="M12 3a9 9 0 1 0 9 9" stroke-linecap="round" />
                    </svg>
                    <svg
                      v-else-if="demoPlaying"
                      class="relative"
                      width="20"
                      height="20"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                      aria-hidden="true"
                    >
                      <path
                        d="M11 5L6 9H3v6h3l5 4V5zm5.5 1.5a6.5 6.5 0 0 1 0 11"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                        stroke-linecap="round"
                      />
                      <path
                        d="M15 8.5a3.5 3.5 0 0 1 0 7"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                        stroke-linecap="round"
                      />
                    </svg>
                    <svg
                      v-else
                      class="relative ml-0.5"
                      width="20"
                      height="20"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                      aria-hidden="true"
                    >
                      <path d="M8 5v14l11-7L8 5z" />
                    </svg>
                  </span>

                  <span class="min-w-0 flex-1">
                    <span class="block text-[15px] font-semibold text-neutral-900 dark:text-neutral-50">
                      {{ demoLoading ? '示范音合成中…' : demoPlaying ? '正在播放示范' : playDemoLabel }}
                    </span>
                    <span class="mt-0.5 block text-xs text-neutral-500 dark:text-neutral-400">
                      {{
                        demoPlaying
                          ? '听清了再开始跟读'
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
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                      <path
                        d="M12 14a3 3 0 0 0 3-3V6a3 3 0 1 0-6 0v5a3 3 0 0 0 3 3zm5-3a5 5 0 0 1-10 0H5a7 7 0 0 0 6 6.92V21h2v-3.08A7 7 0 0 0 19 11h-2z"
                      />
                    </svg>
                  </span>
                  <span class="min-w-0 flex-1">
                    <span class="block text-[15px] font-semibold tracking-wide">开始跟读</span>
                    <span class="mt-0.5 block text-xs text-sky-100/90">
                      {{ useOral ? '对着麦克风读，系统直接评发音' : '跟读后自动识别并点评' }}
                    </span>
                  </span>
                  <svg
                    class="shrink-0 opacity-80 transition group-hover:translate-x-0.5"
                    width="18"
                    height="18"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="2.2"
                    aria-hidden="true"
                  >
                    <path d="M9 6l6 6-6 6" stroke-linecap="round" stroke-linejoin="round" />
                  </svg>
                </span>
              </button>
            </div>

            <button
              type="button"
              class="mt-1 text-sm text-neutral-400 hover:text-neutral-600 dark:hover:text-neutral-300 transition"
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
              <svg
                v-if="loading"
                class="animate-spin"
                width="28"
                height="28"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
              >
                <path d="M12 3a9 9 0 1 0 9 9" stroke-linecap="round" />
              </svg>
              <svg v-else-if="!listening" width="30" height="30" viewBox="0 0 24 24" fill="currentColor">
                <path
                  d="M12 14a3 3 0 0 0 3-3V6a3 3 0 1 0-6 0v5a3 3 0 0 0 3 3zm5-3a5 5 0 0 1-10 0H5a7 7 0 0 0 6 6.92V21h2v-3.08A7 7 0 0 0 19 11h-2z"
                />
              </svg>
              <svg v-else width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                <rect x="6" y="6" width="12" height="12" rx="2" />
              </svg>
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
                rows="2"
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
                      'text-emerald-700 dark:text-emerald-300': scoreTone === 'good',
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

            <div v-if="playbackUrl || playbackLoading || playbackError || playbackRemoteUrl" class="space-y-1.5">
              <audio
                ref="playbackAudioEl"
                class="hidden"
                preload="metadata"
                :src="playbackUrl || undefined"
                @timeupdate="onPlaybackTimeUpdate"
                @loadedmetadata="onPlaybackLoaded"
                @ended="onPlaybackEnded"
                @pause="playbackPlaying = false"
                @play="playbackPlaying = true"
                @error="onPlaybackAudioError"
              />

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
                :disabled="playbackLoading || (!playbackUrl && !playbackRemoteUrl && !playbackError)"
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
                    <svg
                      v-if="playbackLoading"
                      class="relative animate-spin"
                      width="20"
                      height="20"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      stroke-width="2.2"
                      aria-hidden="true"
                    >
                      <path d="M12 3a9 9 0 1 0 9 9" stroke-linecap="round" />
                    </svg>
                    <svg
                      v-else-if="playbackPlaying"
                      class="relative"
                      width="18"
                      height="18"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                      aria-hidden="true"
                    >
                      <rect x="6" y="5" width="4" height="14" rx="1" />
                      <rect x="14" y="5" width="4" height="14" rx="1" />
                    </svg>
                    <svg
                      v-else
                      class="relative ml-0.5"
                      width="20"
                      height="20"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                      aria-hidden="true"
                    >
                      <path d="M8 5v14l11-7L8 5z" />
                    </svg>
                  </span>

                  <span class="min-w-0 flex-1">
                    <span class="block text-[15px] font-semibold text-neutral-900 dark:text-neutral-50">
                      {{
                        playbackError
                          ? '录音暂无法播放'
                          : playbackLoading
                            ? '正在加载录音…'
                            : playbackPlaying
                              ? '正在回听'
                              : '回听自己的录音'
                      }}
                    </span>
                    <span class="mt-0.5 block text-xs text-neutral-500 dark:text-neutral-400 tabular-nums">
                      <template v-if="playbackError">点此重试加载录音</template>
                      <template v-else-if="playbackLoading">请稍候</template>
                      <template v-else-if="playbackPlaying">
                        {{ playbackCurrentLabel
                        }}{{ playbackDurationLabel ? ` / ${playbackDurationLabel}` : '' }}
                        · 再点暂停
                      </template>
                      <template v-else>
                        {{ playbackDurationLabel ? `时长 ${playbackDurationLabel} · ` : '' }}听听自己的发音
                      </template>
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
              class="flex-1 h-11 rounded-2xl text-sm border border-black/10 dark:border-white/15 hover:bg-black/5 dark:hover:bg-white/5 disabled:opacity-40"
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
