<script setup lang="ts">
import { computed } from 'vue'
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

const statusText = computed(() => {
  if (props.error) return props.error
  switch (props.phase) {
    case 'preparing':
      return '正在打开麦克风…'
    case 'waiting':
      return props.micEnabled ? '原声已开始，稍后开录…' : '只听不录 · 跟着原声默念'
    case 'recording':
      return '正在录音 · 跟着说'
    case 'stopping':
      return '正在保存你的跟读…'
    case 'error':
      return props.error || '出了点问题'
    default:
      return props.micEnabled
        ? '边听边说，练完会出现在下方'
        : '已关录音，本次只听原声'
  }
})

const primaryLabel = computed(() => {
  if (props.phase === 'preparing') return '准备中…'
  if (!props.micEnabled) return '只听一遍'
  return '开始跟读'
})
</script>

<template>
  <div
    class="mt-2 rounded-2xl border overflow-hidden shadow-sm transition-colors"
    :class="
      isRecording
        ? 'border-rose-300/80 bg-gradient-to-b from-rose-50 to-white dark:border-rose-800/50 dark:from-rose-950/40 dark:to-neutral-900/90'
        : isWaiting
          ? 'border-amber-300/80 bg-gradient-to-b from-amber-50 to-white dark:border-amber-800/45 dark:from-amber-950/35 dark:to-neutral-900/90'
          : 'border-teal-200/70 bg-gradient-to-b from-teal-50 to-white dark:border-teal-800/45 dark:from-teal-950/50 dark:to-neutral-900/80'
    "
    @click.stop
  >
    <!-- Header -->
    <div class="flex items-center gap-2.5 px-3 pt-2.5 pb-2">
      <span
        class="relative inline-flex h-8 w-8 items-center justify-center rounded-full text-white shrink-0"
        :class="isRecording ? 'bg-rose-500' : isWaiting ? 'bg-amber-500' : 'bg-teal-600'"
        aria-hidden="true"
      >
        <span
          v-if="isRecording"
          class="absolute inset-0 rounded-full bg-rose-400/50 animate-ping"
        />
        <svg class="relative" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
          <path d="M12 3v10" stroke-linecap="round" />
          <path d="M8 7a4 4 0 0 0 8 0" stroke-linecap="round" />
          <path d="M5 11a7 7 0 0 0 14 0" stroke-linecap="round" />
          <path d="M12 18v3" stroke-linecap="round" />
        </svg>
      </span>
      <div class="min-w-0 flex-1">
        <p class="text-[13px] font-semibold text-neutral-900 dark:text-neutral-50 leading-none">
          {{ isRecording ? '录音中' : isWaiting ? '准备开录' : '影子跟读' }}
        </p>
        <p class="mt-1 text-[11px] text-neutral-500 dark:text-neutral-400 leading-none truncate">
          <template v-if="running">
            {{ delayLabel }} · {{ rateLabel }}{{ micEnabled ? '' : ' · 只听' }}
          </template>
          <template v-else>边听边说 · 练节奏</template>
        </p>
      </div>
      <button
        type="button"
        class="shrink-0 min-h-10 min-w-10 inline-flex items-center justify-center rounded-xl text-neutral-500 hover:bg-black/5 dark:hover:bg-white/10 touch-manipulation disabled:opacity-40"
        aria-label="收起"
        :disabled="busy || running"
        @click="emit('close')"
      >
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <path d="M6 6l12 12M18 6L6 18" stroke-linecap="round" />
        </svg>
      </button>
    </div>

    <div class="px-3 pb-3 space-y-2.5">
      <!-- Settings: only when idle (keeps phone viewport free while recording) -->
      <template v-if="!running">
        <div class="grid grid-cols-1 gap-2.5">
          <div>
            <div class="flex items-baseline justify-between mb-1">
              <p class="text-[11px] font-medium text-teal-900/80 dark:text-teal-100/80">跟读延迟</p>
              <p class="text-[10px] text-teal-700/55 dark:text-teal-300/55">原声后多久开录</p>
            </div>
            <div
              class="grid grid-cols-3 gap-1 p-1 rounded-xl bg-teal-100/55 dark:bg-black/25"
              role="group"
              aria-label="跟读延迟"
            >
              <button
                v-for="opt in delayOptions"
                :key="opt.value"
                type="button"
                class="min-h-11 rounded-lg px-1 py-1.5 transition touch-manipulation active:scale-[0.98]"
                :class="
                  delaySec === opt.value
                    ? 'bg-white text-teal-900 shadow-sm dark:bg-neutral-800 dark:text-teal-50'
                    : 'text-teal-800/75 dark:text-teal-200/70'
                "
                :disabled="busy"
                @click="emit('update:delaySec', opt.value)"
              >
                <span class="block text-[13px] font-semibold leading-none">{{ opt.label }}</span>
                <span class="block mt-1 text-[10px] tabular-nums opacity-70">{{ opt.hint }}</span>
              </button>
            </div>
          </div>

          <div>
            <p class="text-[11px] font-medium text-teal-900/80 dark:text-teal-100/80 mb-1">原声语速</p>
            <div
              class="grid grid-cols-3 gap-1 p-1 rounded-xl bg-teal-100/55 dark:bg-black/25"
              role="group"
              aria-label="原声语速"
            >
              <button
                v-for="opt in rateOptions"
                :key="opt.value"
                type="button"
                class="min-h-11 rounded-lg px-1 py-1.5 transition touch-manipulation active:scale-[0.98]"
                :class="
                  rate === opt.value
                    ? 'bg-white text-teal-900 shadow-sm dark:bg-neutral-800 dark:text-teal-50'
                    : 'text-teal-800/75 dark:text-teal-200/70'
                "
                :disabled="busy"
                @click="emit('update:rate', opt.value)"
              >
                <span class="block text-[13px] font-semibold leading-none">{{ opt.label }}</span>
                <span class="block mt-1 text-[10px] tabular-nums opacity-70">{{ opt.hint }}</span>
              </button>
            </div>
          </div>
        </div>

        <button
          type="button"
          class="w-full min-h-12 rounded-xl px-3 flex items-center gap-3 border transition touch-manipulation active:scale-[0.99]"
          :class="
            micEnabled
              ? 'border-teal-300/80 bg-white dark:border-teal-700 dark:bg-neutral-900/70'
              : 'border-black/8 bg-neutral-50 dark:border-white/10 dark:bg-neutral-900/40'
          "
          :disabled="busy"
          @click="emit('update:micEnabled', !micEnabled)"
        >
          <span
            class="flex h-9 w-9 items-center justify-center rounded-full shrink-0"
            :class="micEnabled ? 'bg-teal-600 text-white' : 'bg-neutral-200 text-neutral-500 dark:bg-neutral-700 dark:text-neutral-300'"
            aria-hidden="true"
          >
            <svg v-if="micEnabled" width="15" height="15" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 14a3 3 0 0 0 3-3V6a3 3 0 1 0-6 0v5a3 3 0 0 0 3 3Z" />
              <path d="M5 11a7 7 0 0 0 14 0" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
              <path d="M12 18v3" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
            </svg>
            <svg v-else width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M9 9v2a3 3 0 0 0 5.1 2.1" stroke-linecap="round" />
              <path d="M15 9.5V6a3 3 0 0 0-5.2-2" stroke-linecap="round" />
              <path d="M5 11a7 7 0 0 0 11.2 5.5" stroke-linecap="round" />
              <path d="M19 11a6.9 6.9 0 0 0-.3-2" stroke-linecap="round" />
              <path d="M12 18v3M4 4l16 16" stroke-linecap="round" />
            </svg>
          </span>
          <span class="min-w-0 flex-1 text-left">
            <span class="block text-[13px] font-semibold text-neutral-900 dark:text-neutral-100">
              {{ micEnabled ? '录音已开启' : '录音已关闭' }}
            </span>
            <span class="block text-[11px] text-neutral-500 dark:text-neutral-400 mt-0.5">
              {{ micEnabled ? '练完会出现在句子下方' : '本次只听，不保存录音' }}
            </span>
          </span>
          <span
            class="shrink-0 w-11 h-6 rounded-full relative transition"
            :class="micEnabled ? 'bg-teal-500' : 'bg-neutral-300 dark:bg-neutral-600'"
            aria-hidden="true"
          >
            <span
              class="absolute top-0.5 h-5 w-5 rounded-full bg-white shadow transition"
              :class="micEnabled ? 'left-[1.45rem]' : 'left-0.5'"
            />
          </span>
        </button>
      </template>

      <!-- Live status -->
      <div
        class="flex items-start gap-2.5 rounded-xl px-3 py-2.5 min-h-12"
        :class="
          isRecording
            ? 'bg-rose-100/80 text-rose-950 dark:bg-rose-950/50 dark:text-rose-50'
            : isWaiting
              ? 'bg-amber-100/80 text-amber-950 dark:bg-amber-950/45 dark:text-amber-50'
              : error
                ? 'bg-rose-50 text-rose-900 dark:bg-rose-950/40 dark:text-rose-100'
                : 'bg-teal-50/90 text-teal-900 dark:bg-teal-950/30 dark:text-teal-100'
        "
      >
        <span class="relative mt-1.5 shrink-0" aria-hidden="true">
          <span
            v-if="isRecording || isWaiting"
            class="absolute inset-0 rounded-full animate-ping"
            :class="isRecording ? 'bg-rose-400/55' : 'bg-amber-400/55'"
          />
          <span
            class="relative block h-2.5 w-2.5 rounded-full"
            :class="
              isRecording
                ? 'bg-rose-500'
                : isWaiting
                  ? 'bg-amber-500'
                  : error
                    ? 'bg-rose-500'
                    : 'bg-teal-500'
            "
          />
        </span>
        <p class="text-[13px] leading-snug font-medium pt-0.5">{{ statusText }}</p>
      </div>

      <!-- CTA: 44px+ touch target -->
      <button
        v-if="!running"
        type="button"
        class="w-full min-h-12 rounded-2xl text-[15px] font-semibold text-white bg-teal-600 hover:bg-teal-500 active:scale-[0.99] transition shadow-[0_8px_20px_rgba(13,148,136,0.28)] disabled:opacity-50 touch-manipulation"
        :disabled="busy || phase === 'preparing'"
        @click="emit('start')"
      >
        {{ primaryLabel }}
      </button>
      <button
        v-else
        type="button"
        class="w-full min-h-[3.25rem] rounded-2xl text-[15px] font-semibold border-2 touch-manipulation active:scale-[0.99] transition disabled:opacity-50 inline-flex items-center justify-center gap-2"
        :class="
          isRecording
            ? 'border-rose-400 text-rose-700 bg-white hover:bg-rose-50 dark:border-rose-600 dark:text-rose-100 dark:bg-neutral-900 dark:hover:bg-rose-950/40'
            : 'border-amber-400 text-amber-800 bg-white hover:bg-amber-50 dark:border-amber-700 dark:text-amber-100 dark:bg-neutral-900 dark:hover:bg-amber-950/40'
        "
        :disabled="busy || phase === 'stopping'"
        @click="emit('stop')"
      >
        <span
          class="h-2.5 w-2.5 rounded-full animate-pulse"
          :class="isRecording ? 'bg-rose-500' : 'bg-amber-500'"
          aria-hidden="true"
        />
        {{ phase === 'stopping' ? '保存中…' : '结束本句' }}
      </button>
    </div>
  </div>
</template>
