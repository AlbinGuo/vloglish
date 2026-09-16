<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { LISTEN_PLAYBACK_RATES, useListenPlayerStore } from '@/stores/listenPlayer'
import { formatListenTime } from '@/utils/formatListenTime'

const props = defineProps<{
  open: boolean
}>()

const emit = defineEmits<{
  'update:open': [value: boolean]
}>()

const listen = useListenPlayerStore()
const router = useRouter()
const speedOpen = ref(false)

watch(
  () => props.open,
  (open) => {
    if (!open) speedOpen.value = false
  },
)

function close() {
  emit('update:open', false)
}

const rateLabel = computed(() => {
  const rate = listen.playbackRate
  return rate === 1 ? '倍速播放' : `${rate}x`
})

const loopLabel = computed(() => (listen.loopSingle ? '关闭单曲循环' : '开启单曲循环'))

const timerLabel = computed(() => {
  if (!listen.sleepEndsAt) return '定时关闭'
  return `定时 ${formatListenTime(listen.sleepLeftSec)}`
})

function openTimer() {
  close()
  listen.sleepOpen = true
}

function pickRate(rate: number) {
  listen.setRate(rate)
  speedOpen.value = false
}

function goOriginal() {
  const id = listen.currentVideoId
  if (!id) return
  listen.pause()
  close()
  void router.push(`/english/episode/${id}`)
}

function formatRate(rate: number) {
  return rate === 1 ? '1x' : `${rate}x`
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[70] flex flex-col justify-end bg-black/45"
      @click.self="close"
    >
      <div
        class="rounded-t-[1.75rem] bg-white text-neutral-900 dark:bg-neutral-900 dark:text-white pb-[max(1rem,env(safe-area-inset-bottom))]"
        @click.stop
      >
        <div class="relative flex items-center justify-between px-5 pt-4 pb-2">
          <h2 class="flex-1 text-center text-lg font-semibold">更多功能</h2>
          <button
            type="button"
            class="absolute right-4 top-3.5 w-10 h-10 text-2xl leading-none text-neutral-400"
            aria-label="关闭"
            @click="close"
          >
            ×
          </button>
        </div>

        <div class="grid grid-cols-4 gap-3 px-4 pt-3 pb-2">
          <button type="button" class="flex flex-col items-center gap-2" @click="openTimer">
            <span class="w-14 h-14 rounded-2xl bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center">
              <svg viewBox="0 0 24 24" class="w-7 h-7" fill="none" stroke="currentColor" stroke-width="1.7">
                <circle cx="12" cy="13" r="8" />
                <path stroke-linecap="round" d="M12 9v4l2.5 1.5M9 4h6" />
              </svg>
            </span>
            <span class="text-[11px] text-neutral-600 dark:text-neutral-300 text-center leading-tight">
              {{ timerLabel }}
            </span>
          </button>

          <button type="button" class="flex flex-col items-center gap-2" @click="speedOpen = !speedOpen">
            <span
              class="w-14 h-14 rounded-2xl flex items-center justify-center"
              :class="speedOpen || listen.playbackRate !== 1 ? 'bg-amber-50 text-amber-800 dark:bg-amber-950/50 dark:text-amber-200' : 'bg-neutral-100 dark:bg-neutral-800'"
            >
              <svg viewBox="0 0 24 24" class="w-7 h-7" fill="none" stroke="currentColor" stroke-width="1.7">
                <path stroke-linecap="round" stroke-linejoin="round" d="M5 6v12l6-6V6l8 6-8 6" />
              </svg>
            </span>
            <span class="text-[11px] text-neutral-600 dark:text-neutral-300 text-center leading-tight">
              {{ rateLabel }}
            </span>
          </button>

          <button type="button" class="flex flex-col items-center gap-2" @click="listen.toggleLoopSingle()">
            <span
              class="w-14 h-14 rounded-2xl flex items-center justify-center"
              :class="listen.loopSingle ? 'bg-amber-50 text-amber-800 dark:bg-amber-950/50 dark:text-amber-200' : 'bg-neutral-100 dark:bg-neutral-800'"
            >
              <svg viewBox="0 0 24 24" class="w-7 h-7" fill="none" stroke="currentColor" stroke-width="1.7">
                <path stroke-linecap="round" stroke-linejoin="round" d="M7 7h8a4 4 0 0 1 0 8h-1M17 17H9a4 4 0 0 1 0-8h1" />
                <path stroke-linecap="round" stroke-linejoin="round" d="m15 5 2 2-2 2M9 19l-2-2 2-2" />
              </svg>
            </span>
            <span class="text-[11px] text-neutral-600 dark:text-neutral-300 text-center leading-tight">
              {{ loopLabel }}
            </span>
          </button>

          <button type="button" class="flex flex-col items-center gap-2" @click="goOriginal">
            <span class="w-14 h-14 rounded-2xl bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center">
              <svg viewBox="0 0 24 24" class="w-7 h-7" fill="none" stroke="currentColor" stroke-width="1.7">
                <rect x="5" y="4" width="14" height="16" rx="2" />
                <path stroke-linecap="round" d="M8 8h8M8 12h8M8 16h5" />
              </svg>
            </span>
            <span class="text-[11px] text-neutral-600 dark:text-neutral-300 text-center leading-tight">
              查看原文
            </span>
          </button>
        </div>

        <div v-if="speedOpen" class="px-4 pb-3 pt-1">
          <div class="flex flex-wrap gap-2">
            <button
              v-for="rate in LISTEN_PLAYBACK_RATES"
              :key="rate"
              type="button"
              class="min-w-[3.25rem] px-3 py-2 rounded-full text-sm font-medium"
              :class="
                listen.playbackRate === rate
                  ? 'bg-neutral-900 text-white dark:bg-white dark:text-neutral-900'
                  : 'bg-neutral-100 text-neutral-700 dark:bg-neutral-800 dark:text-neutral-200'
              "
              @click="pickRate(rate)"
            >
              {{ formatRate(rate) }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>
