<script setup lang="ts">
import { computed, inject } from 'vue'
import { READING_TTS_KEY } from '@/composables/useReadingTts'
import { useReadingSettings } from '@/composables/useReadingSettings'
import { useVoiceCloneStore } from '@/stores/voiceClone'
import AppIcon from '@/components/AppIcon.vue'

const props = defineProps<{
  currentIndex: number
  segmentCount: number
}>()

const emit = defineEmits<{
  'open-voice-clone': []
  'need-login': []
}>()

const tts = inject(READING_TTS_KEY, null)
const voiceClone = useVoiceCloneStore()
const { ttsRate, setTtsRate, autoAdvance } = useReadingSettings()

const hasAudio = computed(() => tts?.hasAudio.value ?? false)
const isPlaying = computed(() => tts?.isPlaying.value ?? false)
const synthesizing = computed(() => tts?.synthesizing.value ?? false)
const playingIndex = computed(() => tts?.playingIndex.value ?? null)
const usingCloned = computed(() => tts?.usingCloned.value ?? false)
const hasClonedVoice = computed(() => voiceClone.hasClonedVoice)

const rateOptions = [0.5, 0.75, 1, 1.25] as const

const progressLabel = computed(() => {
  if (props.segmentCount <= 0) return ''
  return `${props.currentIndex + 1} / ${props.segmentCount}`
})

const busy = computed(() => isPlaying.value || synthesizing.value)

function togglePlay() {
  if (!tts) return
  if (synthesizing.value && playingIndex.value === props.currentIndex) {
    tts.stop()
    return
  }
  if (isPlaying.value && playingIndex.value === props.currentIndex) {
    tts.pause()
    return
  }
  tts.playContinuous()
}

function onPrev() {
  tts?.prevSegment()
}

function onNext() {
  tts?.nextSegment()
}

async function selectVoice(mode: 'original' | 'cloned') {
  const result = await voiceClone.selectMode(mode)
  if (result === 'needLogin') {
    emit('need-login')
    return
  }
  if (result === 'needEnroll') {
    emit('open-voice-clone')
    return
  }
}

function manageVoice() {
  if (!voiceClone.hasClonedVoice && !voiceClone.loaded) {
    void voiceClone.refresh()
  }
  emit('open-voice-clone')
}
</script>

<template>
  <div
    v-if="hasAudio"
    class="shrink-0 border-t border-black/5 dark:border-white/10 bg-white/95 dark:bg-neutral-900/95 backdrop-blur-sm px-4 py-2.5 pb-[calc(0.625rem+env(safe-area-inset-bottom))]"
  >
    <div class="mx-auto max-w-3xl flex flex-col gap-2 sm:flex-row sm:items-center sm:gap-3">
      <!-- 主控制：上一段 / 播放 / 下一段 -->
      <div class="flex items-center justify-center gap-1.5 sm:gap-2">
        <button
          type="button"
          class="shrink-0 p-2 rounded-lg text-neutral-500 hover:text-ink-soft hover:bg-sunken disabled:opacity-30"
          :disabled="currentIndex <= 0"
          aria-label="上一段"
          @click="onPrev"
        >
          <AppIcon name="chevron-left" :size="20" />
        </button>
        <button
          type="button"
          class="shrink-0 inline-flex h-10 w-10 items-center justify-center rounded-full bg-ink text-ink-inverse shadow-sm transition active:scale-95"
          :aria-label="busy ? '暂停朗读' : '从当前段连续朗读'"
          @click="togglePlay"
        >
          <AppIcon name="pulse-dot" v-if="synthesizing && !isPlaying" class="h-4 w-4 animate-pulse" />
          <AppIcon name="pause" v-else-if="isPlaying" :size="18" />
          <AppIcon v-else name="play" :size="18" />
        </button>
        <button
          type="button"
          class="shrink-0 p-2 rounded-lg text-neutral-500 hover:text-neutral-800 hover:bg-neutral-100 dark:hover:text-neutral-200 dark:hover:bg-neutral-800 disabled:opacity-30"
          :disabled="currentIndex >= segmentCount - 1"
          aria-label="下一段"
          @click="onNext"
        >
          <AppIcon name="chevron-right" :size="20" />
        </button>
        <span class="ml-1.5 min-w-[3rem] text-center text-xs tabular-nums text-neutral-500 shrink-0">{{ progressLabel }}</span>
      </div>

      <div class="hidden sm:block h-5 w-px bg-black/8 dark:bg-white/10 shrink-0" aria-hidden="true" />

      <!-- 次级设置：音色 / 倍速 / 自动下一段 -->
      <div class="flex items-center justify-center gap-2 flex-wrap sm:ml-auto">
        <div class="inline-flex items-center rounded-lg border border-black/8 dark:border-white/10 p-0.5 text-[11px] shrink-0">
          <button
            type="button"
            class="px-2 py-1 rounded-md transition-colors"
            :class="!usingCloned ? 'bg-ink text-ink-inverse' : 'text-neutral-500 hover:bg-sunken'"
            @click="selectVoice('original')"
          >
            原声
          </button>
          <button
            type="button"
            class="px-2 py-1 rounded-md transition-colors"
            :class="usingCloned ? 'bg-teal-700 text-ink-inverse dark:bg-teal-500' : 'text-neutral-500 hover:bg-sunken'"
            @click="selectVoice('cloned')"
          >
            我的声音
          </button>
        </div>

        <div class="inline-flex items-center rounded-lg bg-sunken p-0.5 text-[11px] shrink-0">
          <button
            v-for="rate in rateOptions"
            :key="rate"
            type="button"
            class="px-2 py-1 rounded-md transition-colors"
            :class="ttsRate === rate ? 'bg-ink text-ink-inverse shadow-sm' : 'text-ink-soft hover:text-ink'"
            @click="setTtsRate(rate)"
          >
            {{ rate }}x
          </button>
        </div>

        <button
          type="button"
          class="hidden sm:inline text-[11px] text-neutral-400 hover:text-neutral-700 dark:hover:text-neutral-200 shrink-0"
          @click="manageVoice"
        >
          {{ hasClonedVoice ? '管理音色' : '去复刻' }}
        </button>

        <label class="inline-flex items-center gap-1.5 text-xs text-neutral-500 shrink-0 cursor-pointer">
          <input v-model="autoAdvance" type="checkbox" class="rounded" />
          自动下一段
        </label>
      </div>
    </div>
  </div>
</template>
