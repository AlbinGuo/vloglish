<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import {
  clearClonedSpeakCache,
  createVoiceClone,
  deleteVoiceClone,
  fetchVoiceCloneSample,
  fetchVoiceCloneStatus,
  type ClonedVoiceInfo,
} from '@/api/voiceClone'
import {
  clearVoiceCloneDraft,
  loadVoiceCloneDraft,
  saveVoiceCloneDraft,
} from '@/utils/voiceCloneDraft'

const props = defineProps<{
  open: boolean
  userId: number
}>()

const emit = defineEmits<{
  close: []
  updated: [voice: ClonedVoiceInfo | null]
}>()

const MIN_MS = 10_000
const MAX_MS = 20_000

const configured = ref(true)
const enrollText = ref(
  'Hello, this is my voice for English learning. I watch videos every day and practice speaking clearly. Please clone my voice so I can hear the subtitles in my own voice.',
)
const remoteVoice = ref<ClonedVoiceInfo | null>(null)
const loadingStatus = ref(false)
const submitting = ref(false)
const deleting = ref(false)
const error = ref('')
const info = ref('')

const recording = ref(false)
const elapsedMs = ref(0)
const draftBlob = ref<Blob | null>(null)
const draftMime = ref('audio/webm')
const draftDurationMs = ref(0)
const previewing = ref(false)

let mediaStream: MediaStream | null = null
let recorder: MediaRecorder | null = null
let chunks: BlobPart[] = []
let startedAt = 0
let tickTimer: ReturnType<typeof setInterval> | null = null
let stopping = false
let previewAudio: HTMLAudioElement | null = null
let previewUrl: string | null = null

const canSubmit = computed(
  () => Boolean(draftBlob.value) && draftDurationMs.value >= MIN_MS && !submitting.value && !recording.value,
)
const progressPct = computed(() => Math.min(100, (elapsedMs.value / MAX_MS) * 100))
const draftSeconds = computed(() => (draftDurationMs.value / 1000).toFixed(1))
const elapsedLabel = computed(() => (elapsedMs.value / 1000).toFixed(1))

function pickMime(): string {
  const candidates = ['audio/mp4', 'audio/webm;codecs=opus', 'audio/webm', 'audio/ogg;codecs=opus']
  if (typeof MediaRecorder === 'undefined') return ''
  for (const c of candidates) {
    if (MediaRecorder.isTypeSupported(c)) return c
  }
  return ''
}

function clearTick() {
  if (tickTimer) {
    clearInterval(tickTimer)
    tickTimer = null
  }
}

function stopPreview() {
  if (previewAudio) {
    try {
      previewAudio.pause()
      previewAudio.src = ''
    } catch {
      /* ignore */
    }
    previewAudio = null
  }
  if (previewUrl) {
    URL.revokeObjectURL(previewUrl)
    previewUrl = null
  }
  previewing.value = false
}

function releaseMic() {
  if (mediaStream) {
    for (const t of mediaStream.getTracks()) t.stop()
    mediaStream = null
  }
}

async function persistDraft(blob: Blob, durationMs: number, mime: string) {
  draftBlob.value = blob
  draftDurationMs.value = durationMs
  draftMime.value = mime
  if (!props.userId) return
  try {
    await saveVoiceCloneDraft({
      userId: props.userId,
      blob,
      mimeType: mime,
      durationMs,
      text: enrollText.value,
      updatedAt: Date.now(),
    })
  } catch {
    /* 草稿失败不阻断主流程 */
  }
}

async function loadStatus() {
  loadingStatus.value = true
  error.value = ''
  try {
    const st = await fetchVoiceCloneStatus()
    configured.value = st.configured
    if (st.enrollText) enrollText.value = st.enrollText
    remoteVoice.value = st.voice
    emit('updated', st.voice)
  } catch (e) {
    error.value = e instanceof Error ? e.message : '加载失败'
  } finally {
    loadingStatus.value = false
  }
}

async function restoreDraft() {
  if (!props.userId) return
  try {
    const d = await loadVoiceCloneDraft(props.userId)
    if (!d?.blob) return
    draftBlob.value = d.blob
    draftDurationMs.value = d.durationMs
    draftMime.value = d.mimeType || 'audio/webm'
    if (d.text) enrollText.value = d.text
  } catch {
    /* ignore */
  }
}

async function startRecording() {
  error.value = ''
  info.value = ''
  stopPreview()
  if (!window.isSecureContext) {
    error.value = '需要 HTTPS 或 localhost 才能录音'
    return
  }
  if (!navigator.mediaDevices?.getUserMedia || typeof MediaRecorder === 'undefined') {
    error.value = '当前环境不支持录音'
    return
  }
  stopping = false
  try {
    mediaStream = await navigator.mediaDevices.getUserMedia({
      audio: {
        channelCount: 1,
        echoCancellation: true,
        noiseSuppression: true,
        autoGainControl: true,
      },
    })
  } catch {
    error.value = '无法使用麦克风，请在系统设置中允许录音（用于声音复刻）'
    return
  }

  const mime = pickMime()
  try {
    recorder = mime ? new MediaRecorder(mediaStream, { mimeType: mime }) : new MediaRecorder(mediaStream)
  } catch {
    error.value = '无法启动录音'
    releaseMic()
    return
  }

  chunks = []
  recorder.ondataavailable = (ev) => {
    if (ev.data && ev.data.size > 0) chunks.push(ev.data)
  }
  startedAt = Date.now()
  elapsedMs.value = 0
  recording.value = true
  clearTick()
  tickTimer = setInterval(() => {
    if (!recording.value) return
    const wall = Date.now() - startedAt
    elapsedMs.value = Math.min(MAX_MS, wall)
    if (wall >= MAX_MS) void stopRecording()
  }, 200)

  try {
    recorder.start(200)
  } catch {
    error.value = '录音启动失败'
    recording.value = false
    clearTick()
    releaseMic()
  }
}

async function stopRecording() {
  if (stopping || !recording.value) return
  stopping = true
  clearTick()
  const wall = Date.now() - startedAt
  const displayed = elapsedMs.value

  const rec = recorder
  recorder = null
  recording.value = false

  const blob = await new Promise<Blob | null>((resolve) => {
    if (!rec || rec.state === 'inactive') {
      resolve(null)
      return
    }
    rec.onstop = () => {
      const type = rec.mimeType || pickMime() || 'audio/webm'
      const b = chunks.length ? new Blob(chunks, { type }) : null
      chunks = []
      resolve(b && b.size > 0 ? b : null)
    }
    try {
      rec.stop()
    } catch {
      resolve(null)
    }
  })

  releaseMic()
  const ms = Math.min(MAX_MS, Math.max(displayed, wall, 0))
  elapsedMs.value = ms

  if (!blob) {
    error.value = '未录到有效音频，请重试'
    stopping = false
    return
  }

  await persistDraft(blob, ms, blob.type || 'audio/webm')
  info.value = ms >= MIN_MS ? '录音已保存，可以开始复刻' : `还需录满 ${(MIN_MS / 1000).toFixed(0)} 秒（当前 ${draftSeconds.value}s）`
  stopping = false
}

async function previewDraft() {
  if (!draftBlob.value) return
  stopPreview()
  previewUrl = URL.createObjectURL(draftBlob.value)
  previewAudio = new Audio(previewUrl)
  previewing.value = true
  try {
    await previewAudio.play()
    await new Promise<void>((resolve) => {
      if (!previewAudio) {
        resolve()
        return
      }
      previewAudio.onended = () => resolve()
      previewAudio.onerror = () => resolve()
    })
  } finally {
    stopPreview()
  }
}

async function previewRemoteSample() {
  stopPreview()
  error.value = ''
  try {
    const blob = await fetchVoiceCloneSample()
    previewUrl = URL.createObjectURL(blob)
    previewAudio = new Audio(previewUrl)
    previewing.value = true
    await previewAudio.play()
    await new Promise<void>((resolve) => {
      if (!previewAudio) {
        resolve()
        return
      }
      previewAudio.onended = () => resolve()
      previewAudio.onerror = () => resolve()
    })
  } catch (e) {
    error.value = e instanceof Error ? e.message : '试听失败'
  } finally {
    stopPreview()
  }
}

function filenameForMime(mime: string): string {
  if (mime.includes('mp4') || mime.includes('m4a')) return 'voice-clone.m4a'
  if (mime.includes('ogg')) return 'voice-clone.ogg'
  if (mime.includes('mpeg') || mime.includes('mp3')) return 'voice-clone.mp3'
  return 'voice-clone.webm'
}

async function submitClone() {
  if (!canSubmit.value || !draftBlob.value) return
  submitting.value = true
  error.value = ''
  info.value = '正在创建音色，请稍候…'
  try {
    const res = await createVoiceClone({
      blob: draftBlob.value,
      text: enrollText.value,
      language: 'en',
      durationMs: draftDurationMs.value,
      filename: filenameForMime(draftMime.value),
    })
    remoteVoice.value = res.voice
    clearClonedSpeakCache()
    await clearVoiceCloneDraft(props.userId)
    draftBlob.value = null
    draftDurationMs.value = 0
    info.value = res.message
    emit('updated', res.voice)
  } catch (e) {
    error.value = e instanceof Error ? e.message : '复刻失败'
    info.value = ''
  } finally {
    submitting.value = false
  }
}

async function removeClone() {
  if (!remoteVoice.value || deleting.value) return
  if (!window.confirm('删除后将无法用自己的声音朗读字幕，确定？')) return
  deleting.value = true
  error.value = ''
  try {
    await deleteVoiceClone()
    remoteVoice.value = null
    clearClonedSpeakCache()
    info.value = '已删除复刻音色'
    emit('updated', null)
  } catch (e) {
    error.value = e instanceof Error ? e.message : '删除失败'
  } finally {
    deleting.value = false
  }
}

function close() {
  if (recording.value) void stopRecording()
  stopPreview()
  emit('close')
}

watch(
  () => props.open,
  async (open) => {
    if (!open) {
      // 只停麦克风，不清草稿
      if (recording.value) void stopRecording()
      stopPreview()
      return
    }
    error.value = ''
    info.value = ''
    await loadStatus()
    await restoreDraft()
  },
)

onMounted(() => {
  if (props.open) {
    void loadStatus()
    void restoreDraft()
  }
})

onUnmounted(() => {
  clearTick()
  if (recording.value && recorder) {
    try {
      recorder.onstop = null
      recorder.stop()
    } catch {
      /* ignore */
    }
  }
  releaseMic()
  stopPreview()
})
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[600] flex items-end justify-center bg-black/45 sm:items-center sm:p-4"
      @click.self="close"
    >
      <div
        class="flex max-h-[min(92vh,720px)] w-full max-w-lg flex-col overflow-hidden rounded-t-2xl bg-white shadow-2xl dark:bg-neutral-900 sm:rounded-2xl"
        role="dialog"
        aria-modal="true"
        aria-labelledby="voice-clone-title"
        @click.stop
      >
        <div class="flex shrink-0 items-center justify-between border-b border-black/5 px-4 py-3 dark:border-white/10">
          <h2 id="voice-clone-title" class="text-base font-semibold text-neutral-900 dark:text-neutral-100">
            复刻我的声音
          </h2>
          <button
            type="button"
            class="rounded-lg px-2 py-1 text-sm text-neutral-500 hover:bg-neutral-100 dark:hover:bg-neutral-800"
            @click="close"
          >
            关闭
          </button>
        </div>

        <div class="min-h-0 flex-1 overflow-y-auto px-4 py-4 space-y-4">
          <p class="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300">
            录一段英文（推荐 10–20 秒）。朗读时用你的音色，语速和停顿尽量跟原视频字幕时间对齐。音色保存在账号里，各端登录后可直接选。
          </p>

          <div
            v-if="!configured"
            class="rounded-xl border border-amber-200 bg-amber-50 px-3 py-2 text-sm text-amber-900 dark:border-amber-800 dark:bg-amber-950/40 dark:text-amber-100"
          >
            服务端尚未配置声音复刻（DASHSCOPE_API_KEY），暂时无法创建音色。
          </div>

          <div
            v-if="remoteVoice?.needsReenroll"
            class="rounded-xl border border-amber-200 bg-amber-50 px-3 py-2 text-sm text-amber-900 dark:border-amber-800 dark:bg-amber-950/40 dark:text-amber-100"
          >
            需重新录制以启用语速/停顿对齐。旧版音色无法控制节奏，请再录一段后提交。
          </div>

          <!-- 已有音色 -->
          <div
            v-if="remoteVoice"
            class="rounded-xl border px-3 py-3"
            :class="
              remoteVoice.needsReenroll
                ? 'border-amber-200/80 bg-amber-50/70 dark:border-amber-800 dark:bg-amber-950/30'
                : 'border-teal-200/80 bg-teal-50/80 dark:border-teal-800 dark:bg-teal-950/30'
            "
          >
            <div class="flex items-start justify-between gap-2">
              <div>
                <p
                  class="text-sm font-medium"
                  :class="
                    remoteVoice.needsReenroll
                      ? 'text-amber-900 dark:text-amber-100'
                      : 'text-teal-900 dark:text-teal-100'
                  "
                >
                  {{ remoteVoice.needsReenroll ? '已有旧音色，需重新复刻' : '已复刻：我的声音（账号通用）' }}
                </p>
                <p
                  class="mt-1 text-xs"
                  :class="
                    remoteVoice.needsReenroll
                      ? 'text-amber-800/80 dark:text-amber-200/80'
                      : 'text-teal-800/80 dark:text-teal-200/80'
                  "
                >
                  {{
                    remoteVoice.needsReenroll
                      ? '重新录音后即可用你的声音按原视频节奏朗读字幕'
                      : '手机 / App / iPad / 电脑登录同一账号即可直接使用，无需重录'
                  }}
                </p>
                <p v-if="remoteVoice.fallbackMode" class="mt-1 text-xs text-amber-700 dark:text-amber-300">
                  样本质量一般，建议重新录制以更像你的声音
                </p>
              </div>
            </div>
            <div class="mt-3 flex flex-wrap gap-2">
              <button
                v-if="remoteVoice.hasSample"
                type="button"
                class="rounded-lg border border-teal-300/80 px-3 py-1.5 text-xs text-teal-800 dark:border-teal-700 dark:text-teal-200"
                :disabled="previewing"
                @click="previewRemoteSample"
              >
                试听报名录音
              </button>
              <button
                type="button"
                class="rounded-lg border border-neutral-200 px-3 py-1.5 text-xs text-neutral-600 dark:border-neutral-700 dark:text-neutral-300"
                :disabled="deleting"
                @click="removeClone"
              >
                {{ deleting ? '删除中…' : '删除音色' }}
              </button>
            </div>
          </div>

          <div>
            <p class="mb-1.5 text-xs font-medium text-neutral-500">请朗读下面英文</p>
            <div
              class="rounded-xl border border-dashed border-neutral-300 bg-neutral-50 px-3 py-3 text-sm leading-relaxed text-neutral-800 dark:border-neutral-600 dark:bg-neutral-800/60 dark:text-neutral-100"
            >
              {{ enrollText }}
            </div>
          </div>

          <!-- 进度 -->
          <div>
            <div class="mb-1 flex items-center justify-between text-xs text-neutral-500">
              <span>{{ recording ? `录音中 ${elapsedLabel}s` : draftBlob ? `已录 ${draftSeconds}s` : '未录音' }}</span>
              <span>满 10s 可提交 · 最长 20s</span>
            </div>
            <div class="h-2 overflow-hidden rounded-full bg-neutral-200 dark:bg-neutral-700">
              <div
                class="h-full rounded-full transition-[width] duration-200"
                :class="
                  (recording ? elapsedMs : draftDurationMs) >= MIN_MS
                    ? 'bg-teal-500'
                    : 'bg-neutral-400 dark:bg-neutral-500'
                "
                :style="{ width: `${recording ? progressPct : Math.min(100, (draftDurationMs / MAX_MS) * 100)}%` }"
              />
            </div>
          </div>

          <p v-if="info" class="text-sm text-teal-700 dark:text-teal-300">{{ info }}</p>
          <p v-if="error" class="text-sm text-red-600 dark:text-red-400">{{ error }}</p>
        </div>

        <div
          class="flex shrink-0 flex-wrap items-center gap-2 border-t border-black/5 px-4 py-3 pb-[max(0.75rem,env(safe-area-inset-bottom))] dark:border-white/10"
        >
          <button
            v-if="!recording"
            type="button"
            class="rounded-xl bg-neutral-900 px-4 py-2.5 text-sm font-medium text-white dark:bg-neutral-100 dark:text-neutral-900 disabled:opacity-40"
            :disabled="!configured || submitting || loadingStatus"
            @click="startRecording"
          >
            {{ draftBlob || remoteVoice ? '重新录制' : '开始录音' }}
          </button>
          <button
            v-else
            type="button"
            class="rounded-xl bg-red-600 px-4 py-2.5 text-sm font-medium text-white"
            @click="stopRecording"
          >
            停止
          </button>
          <button
            type="button"
            class="rounded-xl border border-neutral-200 px-3 py-2.5 text-sm dark:border-neutral-700 disabled:opacity-40"
            :disabled="!draftBlob || recording || previewing"
            @click="previewDraft"
          >
            试听草稿
          </button>
          <button
            type="button"
            class="ml-auto rounded-xl bg-teal-600 px-4 py-2.5 text-sm font-medium text-white disabled:opacity-40"
            :disabled="!canSubmit || !configured"
            @click="submitClone"
          >
            {{ submitting ? '复刻中…' : remoteVoice ? '用新录音替换' : '开始复刻' }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
