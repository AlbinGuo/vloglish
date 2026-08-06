<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import type { ShadowRecorderPhase } from '@/composables/useShadowingRecorder'

const props = withDefaults(
  defineProps<{
    delaySec: number
    rate: number
    micEnabled: boolean
    phase: ShadowRecorderPhase
    error?: string
    busy?: boolean
  }>(),
  {
    error: '',
    busy: false,
  },
)

const emit = defineEmits<{
  'update:delaySec': [value: number]
  'update:rate': [value: number]
  'update:micEnabled': [value: boolean]
  start: []
  stop: []
  close: []
}>()

const settingsOpen = ref(false)

const delayOptions = [
  { value: 0, label: '同步', hint: '0″' },
  { value: 0.5, label: '半拍', hint: '0.5″' },
  { value: 1, label: '一拍', hint: '1″' },
]

const rateOptions = [
  { value: 0.7, label: '慢', hint: '0.7×' },
  { value: 0.85, label: '稍慢', hint: '0.85×' },
  { value: 1, label: '原速', hint: '1×' },
]

const running = computed(
  () => props.phase === 'waiting' || props.phase === 'recording' || props.phase === 'stopping',
)

const isRecording = computed(() => props.phase === 'recording')
const isWaiting = computed(() => props.phase === 'waiting')

const delayLabel = computed(
  () => delayOptions.find((o) => o.value === props.delaySec)?.label ?? `${props.delaySec}″`,
)

const rateLabel = computed(
  () => rateOptions.find((o) => o.value === props.rate)?.label ?? `${props.rate}×`,
)

const summaryText = computed(() => {
  const mic = props.micEnabled ? '麦开' : '只听'
  return `${delayLabel.value} · ${rateLabel.value} · ${mic}`
})

const statusText = computed(() => {
  if (props.error) return props.error
  switch (props.phase) {
    case 'preparing':
      return '正在打开麦克风…'
    case 'waiting':
      return props.micEnabled ? '稍后开录…' : '只听 · 跟着默念'
    case 'recording':
      return '正在录音 · 跟着说'
    case 'stopping':
      return '正在保存…'
    case 'error':
      return props.error || '出了点问题'
    default:
      return ''
  }
})

const primaryLabel = computed(() => {
  if (props.phase === 'preparing') return '准备中…'
  if (!props.micEnabled) return '只听一遍'
  return '开始跟读'
})

watch(running, (v) => {
  if (v) settingsOpen.value = false
})

function toggleSettings() {
  if (props.busy || running.value) return
  settingsOpen.value = !settingsOpen.value
}
</script>

<template>
  <div
    class="mt-1.5 rounded-xl border overflow-hidden transition-colors"
    :class="
      isRecording
        ? 'border-rose-300/70 bg-rose-50/90 dark:border-rose-800/50 dark:bg-rose-950/35'
        : isWaiting
          ? 'border-amber-300/70 bg-amber-50/90 dark:border-amber-800/45 dark:bg-amber-950/30'
          : 'border-teal-200/60 bg-teal-50/70 dark:border-teal-800/40 dark:bg-teal-950/30'
    "
    @click.stop
  >
    <!-- Running: status + stop -->
    <template v-if="running">
      <div class="flex items-center gap-2 px-2.5 py-2">
        <span class="relative shrink-0" aria-hidden="true">
          <span
            class="absolute inset-0 rounded-full animate-ping"
            :class="isRecording ? 'bg-rose-400/50' : 'bg-amber-400/50'"
          />
          <span
            class="relative block h-2 w-2 rounded-full"
            :class="isRecording ? 'bg-rose-500' : 'bg-amber-500'"
          />
        </span>
        <p class="min-w-0 flex-1 text-[12px] font-medium truncate text-neutral-800 dark:text-neutral-100">
          {{ statusText }}
        </p>
        <button
          type="button"
          class="shrink-0 min-h-10 px-3.5 rounded-lg text-[13px] font-semibold border touch-manipulation active:scale-[0.98] transition disabled:opacity-50"
          :class="
            isRecording
              ? 'border-rose-400 text-rose-700 bg-white dark:border-rose-600 dark:text-rose-100 dark:bg-neutral-900'
              : 'border-amber-400 text-amber-800 bg-white dark:border-amber-700 dark:text-amber-100 dark:bg-neutral-900'
          "
          :disabled="busy || phase === 'stopping'"
          @click="emit('stop')"
        >
          {{ phase === 'stopping' ? '保存中…' : '结束' }}
        </button>
      </div>
    </template>

    <!-- Idle: one-line toolbar -->
    <template v-else>
      <div class="flex items-center gap-1.5 px-2 py-1.5">
        <button
          type="button"
          class="min-w-0 flex-1 min-h-10 px-2 rounded-lg text-left touch-manipulation active:bg-teal-100/60 dark:active:bg-teal-900/40"
          :disabled="busy"
          :aria-expanded="settingsOpen"
          title="调整延迟、语速、麦克风"
          @click="toggleSettings"
        >
          <span class="block text-[11px] font-semibold text-teal-900 dark:text-teal-100 truncate leading-tight">
            {{ summaryText }}
          </span>
          <span class="block text-[10px] text-teal-700/65 dark:text-teal-300/60 mt-0.5 leading-none">
            {{ settingsOpen ? '收起设置' : '点此设置' }}
          </span>
        </button>

        <button
          type="button"
          class="shrink-0 min-h-10 px-2.5 rounded-lg text-[12px] font-semibold text-teal-800 dark:text-teal-200 hover:bg-teal-100/70 dark:hover:bg-teal-900/40 touch-manipulation"
          :disabled="busy"
          :aria-expanded="settingsOpen"
          @click="toggleSettings"
        >
          设置{{ settingsOpen ? '▴' : '▾' }}
        </button>

        <button
          type="button"
          class="shrink-0 min-h-10 px-3 rounded-lg text-[13px] font-semibold text-white bg-teal-600 hover:bg-teal-500 active:scale-[0.98] transition disabled:opacity-50 touch-manipulation"
          :disabled="busy || phase === 'preparing'"
          @click="emit('start')"
        >
          {{ primaryLabel }}
        </button>

        <button
          type="button"
          class="shrink-0 min-h-10 min-w-9 inline-flex items-center justify-center rounded-lg text-neutral-500 hover:bg-black/5 dark:hover:bg-white/10 touch-manipulation disabled:opacity-40"
          aria-label="收起"
          :disabled="busy"
          @click="emit('close')"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path d="M6 6l12 12M18 6L6 18" stroke-linecap="round" />
          </svg>
        </button>
      </div>

      <!-- Settings panel -->
      <div
        v-if="settingsOpen"
        class="px-2.5 pb-2.5 pt-0.5 space-y-2 border-t border-teal-200/50 dark:border-teal-800/40"
      >
        <div>
          <p class="text-[10px] font-medium text-teal-900/70 dark:text-teal-100/70 mb-1">跟读延迟</p>
          <div class="grid grid-cols-3 gap-0.5 p-0.5 rounded-lg bg-teal-100/50 dark:bg-black/25" role="group" aria-label="跟读延迟">
            <button
              v-for="opt in delayOptions"
              :key="opt.value"
              type="button"
              class="min-h-9 rounded-md px-1 transition touch-manipulation active:scale-[0.98]"
              :class="
                delaySec === opt.value
                  ? 'bg-white text-teal-900 shadow-sm dark:bg-neutral-800 dark:text-teal-50'
                  : 'text-teal-800/75 dark:text-teal-200/70'
              "
              :disabled="busy"
              @click="emit('update:delaySec', opt.value)"
            >
              <span class="block text-[12px] font-semibold leading-none">{{ opt.label }}</span>
              <span class="block mt-0.5 text-[9px] tabular-nums opacity-70">{{ opt.hint }}</span>
            </button>
          </div>
        </div>

        <div>
          <p class="text-[10px] font-medium text-teal-900/70 dark:text-teal-100/70 mb-1">原声语速</p>
          <div class="grid grid-cols-3 gap-0.5 p-0.5 rounded-lg bg-teal-100/50 dark:bg-black/25" role="group" aria-label="原声语速">
            <button
              v-for="opt in rateOptions"
              :key="opt.value"
              type="button"
              class="min-h-9 rounded-md px-1 transition touch-manipulation active:scale-[0.98]"
              :class="
                rate === opt.value
                  ? 'bg-white text-teal-900 shadow-sm dark:bg-neutral-800 dark:text-teal-50'
                  : 'text-teal-800/75 dark:text-teal-200/70'
              "
              :disabled="busy"
              @click="emit('update:rate', opt.value)"
            >
              <span class="block text-[12px] font-semibold leading-none">{{ opt.label }}</span>
              <span class="block mt-0.5 text-[9px] tabular-nums opacity-70">{{ opt.hint }}</span>
            </button>
          </div>
        </div>

        <button
          type="button"
          class="w-full min-h-10 rounded-lg px-2.5 flex items-center gap-2.5 border transition touch-manipulation"
          :class="
            micEnabled
              ? 'border-teal-300/70 bg-white dark:border-teal-700 dark:bg-neutral-900/60'
              : 'border-black/8 bg-neutral-50 dark:border-white/10 dark:bg-neutral-900/40'
          "
          :disabled="busy"
          @click="emit('update:micEnabled', !micEnabled)"
        >
          <span
            class="flex h-7 w-7 items-center justify-center rounded-full shrink-0"
            :class="micEnabled ? 'bg-teal-600 text-white' : 'bg-neutral-200 text-neutral-500 dark:bg-neutral-700 dark:text-neutral-300'"
            aria-hidden="true"
          >
            <svg v-if="micEnabled" width="13" height="13" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 14a3 3 0 0 0 3-3V6a3 3 0 1 0-6 0v5a3 3 0 0 0 3 3Z" />
              <path d="M5 11a7 7 0 0 0 14 0" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
              <path d="M12 18v3" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
            </svg>
            <svg v-else width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M9 9v2a3 3 0 0 0 5.1 2.1" stroke-linecap="round" />
              <path d="M15 9.5V6a3 3 0 0 0-5.2-2" stroke-linecap="round" />
              <path d="M5 11a7 7 0 0 0 11.2 5.5" stroke-linecap="round" />
              <path d="M19 11a6.9 6.9 0 0 0-.3-2" stroke-linecap="round" />
              <path d="M12 18v3M4 4l16 16" stroke-linecap="round" />
            </svg>
          </span>
          <span class="min-w-0 flex-1 text-left">
            <span class="block text-[12px] font-semibold text-neutral-900 dark:text-neutral-100">
              {{ micEnabled ? '录音已开启' : '录音已关闭' }}
            </span>
            <span class="block text-[10px] text-neutral-500 dark:text-neutral-400">
              {{ micEnabled ? '练完出现在句下' : '本次只听不保存' }}
            </span>
          </span>
          <span
            class="shrink-0 w-9 h-5 rounded-full relative transition"
            :class="micEnabled ? 'bg-teal-500' : 'bg-neutral-300 dark:bg-neutral-600'"
            aria-hidden="true"
          >
            <span
              class="absolute top-0.5 h-4 w-4 rounded-full bg-white shadow transition"
              :class="micEnabled ? 'left-[1.15rem]' : 'left-0.5'"
            />
          </span>
        </button>
      </div>

      <p
        v-if="error || phase === 'error'"
        class="px-2.5 pb-2 text-[11px] font-medium text-rose-700 dark:text-rose-300"
      >
        {{ error || statusText }}
      </p>
    </template>
  </div>
</template>
