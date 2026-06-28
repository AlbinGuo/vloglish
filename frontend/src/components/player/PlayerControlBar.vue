<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import {
  LOOP_COUNT_OPTIONS,
  PLAYBACK_RATES,
  type usePlayerControls,
} from '@/composables/usePlayerControls'

const props = defineProps<{
  player: ReturnType<typeof usePlayerControls>
  showIpa: boolean
  videoHidden: boolean
  videoPanelRef: HTMLElement | null | undefined
  /** 移动端精简控制条 */
  compact?: boolean
  /** 贴底栏样式（无圆角背景） */
  docked?: boolean
}>()

const emit = defineEmits<{
  'update:showIpa': [value: boolean]
  'update:videoHidden': [value: boolean]
}>()

const speedOpen = ref(false)
const speedRoot = ref<HTMLElement | null>(null)
const speedMenuPos = ref<{ top: number; left: number } | null>(null)
const loopOpen = ref(false)
const loopRoot = ref<HTMLElement | null>(null)
const loopMenuPos = ref<{ top: number; left: number } | null>(null)
const moreOpen = ref(false)
const isFullscreen = ref(false)
const controlScrollRef = ref<HTMLElement | null>(null)
const showControlScrollFade = ref(false)
let controlScrollObserver: ResizeObserver | null = null

function updateControlScrollFade() {
  const el = controlScrollRef.value
  if (!el) {
    showControlScrollFade.value = false
    return
  }
  const canScroll = el.scrollWidth > el.clientWidth + 1
  const atEnd = el.scrollLeft + el.clientWidth >= el.scrollWidth - 2
  showControlScrollFade.value = canScroll && !atEnd
}

function bindControlScrollFade() {
  controlScrollObserver?.disconnect()
  controlScrollObserver = null
  const el = controlScrollRef.value
  if (!el || props.compact) {
    showControlScrollFade.value = false
    return
  }
  controlScrollObserver = new ResizeObserver(() => updateControlScrollFade())
  controlScrollObserver.observe(el)
  nextTick(() => updateControlScrollFade())
}

const loopCountLabel = computed(() => {
  const n = props.player.sentenceLoopCount.value
  return n === 0 ? '∞' : String(n)
})

const loopActive = computed(() => props.player.loopMode.value === 'sentence')

function formatRate(r: number) {
  return `${Number.isInteger(r) ? r.toFixed(1) : r}x`
}

function anchorMenu(el: HTMLElement | null) {
  if (!el) return null
  const r = el.getBoundingClientRect()
  return { top: r.top - 8, left: r.left + r.width / 2 }
}

function onDocClick(e: MouseEvent) {
  const target = e.target as HTMLElement
  if (target.closest('[data-player-popover]')) return
  const t = target as Node
  if (speedRoot.value && !speedRoot.value.contains(t)) {
    speedOpen.value = false
    speedMenuPos.value = null
  }
  if (loopRoot.value && !loopRoot.value.contains(t)) {
    loopOpen.value = false
    loopMenuPos.value = null
  }
}

function bindDocClick() {
  nextTick(() => document.addEventListener('click', onDocClick))
}

function unbindDocClick() {
  document.removeEventListener('click', onDocClick)
}

watch(speedOpen, (open) => {
  if (open) {
    loopOpen.value = false
    loopMenuPos.value = null
    bindDocClick()
  } else if (!loopOpen.value) {
    unbindDocClick()
  }
})

watch(loopOpen, (open) => {
  if (open) {
    speedOpen.value = false
    speedMenuPos.value = null
    bindDocClick()
  } else if (!speedOpen.value) {
    unbindDocClick()
  }
})

onMounted(() => {
  document.addEventListener('fullscreenchange', onFullscreenChange)
  bindControlScrollFade()
})

onUnmounted(() => {
  unbindDocClick()
  document.removeEventListener('fullscreenchange', onFullscreenChange)
  controlScrollObserver?.disconnect()
  controlScrollObserver = null
})

watch(
  () => props.compact,
  () => nextTick(() => bindControlScrollFade()),
)

function onFullscreenChange() {
  isFullscreen.value = Boolean(document.fullscreenElement)
}

function toggleFullscreen() {
  const el = props.videoPanelRef
  if (!el) return
  if (document.fullscreenElement) {
    void document.exitFullscreen()
  } else {
    void el.requestFullscreen()
  }
}

function toggleHideVideo() {
  emit('update:videoHidden', !props.videoHidden)
}

function toggleIpa() {
  emit('update:showIpa', !props.showIpa)
}

function toggleSpeedMenu() {
  if (speedOpen.value) {
    speedOpen.value = false
    speedMenuPos.value = null
    return
  }
  if (props.compact) {
    speedMenuPos.value = { top: window.innerHeight - 16, left: window.innerWidth / 2 }
  } else {
    speedMenuPos.value = anchorMenu(speedRoot.value)
  }
  speedOpen.value = true
}

function toggleLoopMenu() {
  if (loopOpen.value) {
    loopOpen.value = false
    loopMenuPos.value = null
    return
  }
  moreOpen.value = false
  if (props.compact) {
    loopMenuPos.value = { top: window.innerHeight - 16, left: window.innerWidth / 2 }
  } else {
    loopMenuPos.value = anchorMenu(loopRoot.value)
  }
  loopOpen.value = true
}

function selectRate(rate: number) {
  props.player.setRate(rate)
  speedOpen.value = false
  speedMenuPos.value = null
}

function selectLoopCount(count: number) {
  props.player.setSentenceLoopCount(count)
  props.player.enableSentenceLoop()
  loopOpen.value = false
  loopMenuPos.value = null
}

function cycleInterval() {
  props.player.cycleLoopInterval()
}

function handleBPoint() {
  const p = props.player
  if (p.abLoopPhase.value === 'waitB') {
    p.setLoopPoint('B')
  } else if (p.abLoopPhase.value === 'active') {
    p.clearAbLoop()
  } else {
    p.setLoopPoint('A')
  }
}

function handleMainAction() {
  const p = props.player
  if (p.isPlaying.value) {
    p.togglePlay()
  } else {
    p.replayCurrentSentence()
  }
}
</script>

<template>
  <div
    class="shrink-0 select-none text-black/70 dark:text-neutral-200 cursor-pointer"
    :class="
      docked
        ? 'px-2 py-1.5 bg-transparent'
        : 'rounded-xl bg-neutral-200/60 dark:bg-neutral-800/80 px-2 py-2.5 sm:px-3'
    "
  >
    <!-- 移动端：核心控制 -->
    <div v-if="compact" class="flex items-center justify-between gap-1 max-w-full">
      <div ref="speedRoot" class="relative flex flex-col items-center shrink-0 min-w-[2.75rem]">
        <button
          type="button"
          class="flex flex-col items-center text-xs active:scale-95"
          title="倍速"
          @click.stop="toggleSpeedMenu"
        >
        <div class="w-10 h-10 rounded-full flex items-center justify-center bg-black/5 dark:bg-white/10">
          <span class="text-xs font-medium tabular-nums">{{ formatRate(player.playbackRate.value) }}</span>
        </div>
        </button>
      </div>

      <button type="button" class="shrink-0 p-1 active:scale-95" title="上一句" @click="player.prevSentence()">
        <svg class="w-9 h-9" viewBox="0 0 24 24" fill="currentColor">
          <path fill-rule="evenodd" clip-rule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25Zm-4.28 9.22a.75.75 0 0 0 0 1.06l3 3a.75.75 0 1 0 1.06-1.06l-1.72-1.72h5.69a.75.75 0 0 0 0-1.5h-5.69l1.72-1.72a.75.75 0 0 0-1.06-1.06l-3 3Z" />
        </svg>
      </button>

      <button type="button" class="shrink-0 p-0.5 active:scale-95" :title="player.mainActionLabel.value" @click="handleMainAction">
        <svg v-if="player.isPlaying.value" class="w-11 h-11" viewBox="0 0 24 24" fill="currentColor">
          <path fill-rule="evenodd" clip-rule="evenodd" d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12ZM9 8.25a.75.75 0 0 0-.75.75v6c0 .414.336.75.75.75h.75a.75.75 0 0 0 .75-.75V9a.75.75 0 0 0-.75-.75H9Zm5.25 0a.75.75 0 0 0-.75.75v6c0 .414.336.75.75.75H15a.75.75 0 0 0 .75-.75V9a.75.75 0 0 0-.75-.75h-.75Z" />
        </svg>
        <svg v-else class="w-11 h-11" viewBox="0 0 24 24" fill="currentColor">
          <path fill-rule="evenodd" clip-rule="evenodd" d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12Zm14.024-.983a1.125 1.125 0 0 1 0 1.966l-5.603 3.113A1.125 1.125 0 0 1 9 15.113V8.887c0-.857.921-1.4 1.671-.983l5.603 3.113Z" />
        </svg>
      </button>

      <button type="button" class="shrink-0 p-1 active:scale-95" title="下一句" @click="player.nextSentence()">
        <svg class="w-9 h-9" viewBox="0 0 24 24" fill="currentColor">
          <path fill-rule="evenodd" clip-rule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25Zm4.28 10.28a.75.75 0 0 0 0-1.06l-3-3a.75.75 0 1 0-1.06 1.06l1.72 1.72H8.25a.75.75 0 0 0 0 1.5h5.69l-1.72 1.72a.75.75 0 0 0 1.06 1.06l3-3Z" />
        </svg>
      </button>

      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[2.75rem] text-xs active:scale-95"
        title="更多"
        @click="moreOpen = true"
      >
        <div class="w-10 h-10 rounded-full flex items-center justify-center bg-black/5 dark:bg-white/10 text-sm font-medium">⋯</div>
      </button>
    </div>

    <!-- 桌面端：完整控制条 -->
    <div v-else class="relative max-w-full">
      <div
        ref="controlScrollRef"
        class="flex items-end justify-between gap-1 sm:gap-0 max-w-full overflow-x-auto cursor-pointer player-control-bar__scroll"
        @scroll="updateControlScrollFade"
      >
      <!-- 倍速 -->
      <div ref="speedRoot" class="relative flex flex-col items-center shrink-0 min-w-[3rem] cursor-pointer">
        <button
          type="button"
          class="flex flex-col items-center text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
          title="倍速"
          @click.stop="toggleSpeedMenu"
        >
          <div class="p-0.5 w-8 h-8 rounded-full flex items-center justify-center bg-black/5 dark:bg-white/10">
            <span class="text-xs font-medium tabular-nums leading-none">
              {{ formatRate(player.playbackRate.value) }}
            </span>
          </div>
          <span class="text-[11px] leading-tight mt-0.5">倍速</span>
        </button>
      </div>

      <!-- 隐藏视频 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        @click="toggleHideVideo"
      >
        <div class="p-0.5 w-8 h-8 rounded-full flex items-center justify-center bg-black/5 dark:bg-white/10">
          <svg v-if="videoHidden" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
          </svg>
          <svg v-else class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
            <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
          </svg>
        </div>
        <span class="text-[11px] leading-tight mt-0.5">{{ videoHidden ? '显示视频' : '隐藏视频' }}</span>
      </button>

      <!-- 全屏 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        @click="toggleFullscreen"
      >
        <div class="p-0.5 w-8 h-8 rounded-full flex items-center justify-center bg-black/5 dark:bg-white/10">
          <svg v-if="isFullscreen" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 9V4.5M9 9H4.5M9 9 3.75 3.75M9 15v4.5M9 15H4.5M9 15l-5.25 5.25M15 9h4.5M15 9V4.5M15 9l5.25-5.25M15 15h4.5M15 15v4.5m0-4.5 5.25 5.25" />
          </svg>
          <svg v-else class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 3.75v4.5m0-4.5h4.5m-4.5 0L9 9M3.75 20.25v-4.5m0 4.5h4.5m-4.5 0L9 15M20.25 3.75h-4.5m4.5 0v4.5m0-4.5L15 9m5.25 11.25h-4.5m4.5 0v-4.5m0 4.5L15 15" />
          </svg>
        </div>
        <span class="text-[11px] leading-tight mt-0.5">全屏</span>
      </button>

      <!-- 音标 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        @click="toggleIpa"
      >
        <div class="p-0.5 w-8 h-8 rounded-full flex items-center justify-center bg-black/5 dark:bg-white/10">
          <span
            class="font-serif text-xl pb-0.5 w-full h-full flex items-center justify-center rounded-full"
            :class="showIpa ? 'text-orange-500' : 'text-neutral-500'"
          >ə</span>
        </div>
        <span class="text-[11px] leading-tight mt-0.5">音标</span>
      </button>

      <!-- 上一句 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        title="上一句"
        @click="player.prevSentence()"
      >
        <svg class="w-8 h-8 text-neutral-800 dark:text-neutral-200" viewBox="0 0 24 24" fill="currentColor">
          <path fill-rule="evenodd" clip-rule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25Zm-4.28 9.22a.75.75 0 0 0 0 1.06l3 3a.75.75 0 1 0 1.06-1.06l-1.72-1.72h5.69a.75.75 0 0 0 0-1.5h-5.69l1.72-1.72a.75.75 0 0 0-1.06-1.06l-3 3Z" />
        </svg>
        <span class="text-[11px] leading-tight mt-0.5">上一句</span>
      </button>

      <!-- 重播 / 暂停 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        :title="player.mainActionLabel.value"
        @click="handleMainAction"
      >
        <svg v-if="player.isPlaying.value" class="w-8 h-8 text-neutral-800 dark:text-neutral-200" viewBox="0 0 24 24" fill="currentColor">
          <path fill-rule="evenodd" clip-rule="evenodd" d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12ZM9 8.25a.75.75 0 0 0-.75.75v6c0 .414.336.75.75.75h.75a.75.75 0 0 0 .75-.75V9a.75.75 0 0 0-.75-.75H9Zm5.25 0a.75.75 0 0 0-.75.75v6c0 .414.336.75.75.75H15a.75.75 0 0 0 .75-.75V9a.75.75 0 0 0-.75-.75h-.75Z" />
        </svg>
        <svg v-else class="w-8 h-8 text-neutral-800 dark:text-neutral-200" viewBox="0 0 24 24" fill="currentColor">
          <path fill-rule="evenodd" clip-rule="evenodd" d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12Zm14.024-.983a1.125 1.125 0 0 1 0 1.966l-5.603 3.113A1.125 1.125 0 0 1 9 15.113V8.887c0-.857.921-1.4 1.671-.983l5.603 3.113Z" />
        </svg>
        <span class="text-[11px] leading-tight mt-0.5">{{ player.mainActionLabel.value }}</span>
      </button>

      <!-- 下一句 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        title="下一句"
        @click="player.nextSentence()"
      >
        <svg class="w-8 h-8 text-neutral-800 dark:text-neutral-200" viewBox="0 0 24 24" fill="currentColor">
          <path fill-rule="evenodd" clip-rule="evenodd" d="M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25Zm4.28 10.28a.75.75 0 0 0 0-1.06l-3-3a.75.75 0 1 0-1.06 1.06l1.72 1.72H8.25a.75.75 0 0 0 0 1.5h5.69l-1.72 1.72a.75.75 0 0 0 1.06 1.06l3-3Z" />
        </svg>
        <span class="text-[11px] leading-tight mt-0.5">下一句</span>
      </button>

      <!-- B点 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        :title="player.abLoopPhase.value === 'active' ? '取消 AB 循环' : '设置 B 点'"
        @click="handleBPoint"
      >
        <div
          class="p-0.5 w-8 h-8 rounded-full flex items-center justify-center bg-black/5"
          :class="player.abLoopPhase.value === 'waitB' ? 'ring-2 ring-blue-300' : ''"
        >
          <span class="text-blue-700 text-base font-semibold leading-none">B</span>
        </div>
        <span class="text-[11px] leading-tight mt-0.5">B点</span>
      </button>

      <!-- 单句循环 -->
      <div ref="loopRoot" class="relative flex flex-col items-center shrink-0 min-w-[3rem] cursor-pointer">
        <button
          type="button"
          class="flex flex-col items-center text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
          :class="loopActive ? 'text-neutral-900' : ''"
          @click.stop="toggleLoopMenu"
        >
          <div class="relative w-8 h-8 flex items-center justify-center">
            <svg
              class="w-8 h-8"
              :class="loopActive ? 'text-amber-600' : ''"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="1.5"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 12c0-1.232-.046-2.453-.138-3.662a4.006 4.006 0 0 0-3.7-3.7 48.678 48.678 0 0 0-7.324 0 4.006 4.006 0 0 0-3.7 3.7c-.017.22-.032.441-.046.662M19.5 12l3-3m-3 3-3-3m-12 3c0 1.232.046 2.453.138 3.662a4.006 4.006 0 0 0 3.7 3.7 48.656 48.656 0 0 0 7.324 0 4.006 4.006 0 0 0 3.7-3.7c.017-.22.032-.441.046-.662M4.5 12l3 3m-3-3-3 3" />
            </svg>
            <span class="absolute inset-0 flex items-center justify-center text-[10px] font-semibold tabular-nums">
              {{ loopCountLabel }}
            </span>
          </div>
          <span class="text-[11px] leading-tight mt-0.5">单句循环</span>
        </button>
      </div>

      <!-- 间隔 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        title="循环间隔"
        @click="cycleInterval"
      >
        <div class="p-0.5 w-8 h-8 rounded-full flex items-center justify-center bg-black/5 dark:bg-white/10">
          <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
          </svg>
        </div>
        <span class="text-[11px] leading-tight mt-0.5">
          间隔{{ player.loopInterval.value > 0 ? player.loopInterval.value + '秒' : '' }}
        </span>
      </button>

      <!-- 单句暂停 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        title="循环完当前句后自动暂停"
        @click="player.pauseAfterSentence.value = !player.pauseAfterSentence.value"
      >
        <div
          class="p-0.5 w-8 h-8 flex items-center justify-center"
          :class="player.pauseAfterSentence.value ? 'text-orange-500' : ''"
        >
          <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M21 7.5V18M15 7.5V18M3 16.811V8.69c0-.864.933-1.406 1.683-.977l7.108 4.061a1.125 1.125 0 0 1 0 1.954l-7.108 4.061A1.125 1.125 0 0 1 3 16.811Z" />
          </svg>
        </div>
        <span class="text-[11px] leading-tight mt-0.5">单句暂停</span>
      </button>
      </div>
      <div
        v-if="showControlScrollFade"
        class="pointer-events-none absolute right-0 top-0 bottom-0 z-10 w-10 bg-gradient-to-l from-neutral-200/95 via-neutral-200/60 to-transparent dark:from-neutral-800/95 dark:via-neutral-800/60"
        aria-hidden="true"
      />
    </div>

    <!-- 弹层挂到 body，避免被 overflow 裁剪 -->
    <Teleport to="body">
      <!-- 移动端更多 -->
      <div
        v-if="compact && moreOpen"
        data-player-popover
        class="fixed inset-0 z-[300] flex items-end justify-center bg-black/40"
        @click.self="moreOpen = false"
      >
        <div
          class="w-full max-w-lg rounded-t-2xl bg-white dark:bg-neutral-900 shadow-2xl border-t border-black/10 dark:border-white/10 pb-[env(safe-area-inset-bottom)]"
          @click.stop
        >
          <div class="flex justify-center pt-3 pb-2">
            <div class="w-10 h-1 rounded-full bg-neutral-300 dark:bg-neutral-600" />
          </div>
          <p class="text-sm font-medium text-center mb-3">更多控制</p>
          <div class="grid grid-cols-4 gap-3 px-4 pb-4">
            <button type="button" class="flex flex-col items-center gap-1 text-xs" @click="toggleHideVideo(); moreOpen = false">
              <div class="w-11 h-11 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center">{{ videoHidden ? '显' : '隐' }}</div>
              <span>{{ videoHidden ? '显示视频' : '隐藏视频' }}</span>
            </button>
            <button type="button" class="flex flex-col items-center gap-1 text-xs" @click="toggleFullscreen(); moreOpen = false">
              <div class="w-11 h-11 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center">⛶</div>
              <span>全屏</span>
            </button>
            <button type="button" class="flex flex-col items-center gap-1 text-xs" @click="toggleIpa(); moreOpen = false">
              <div class="w-11 h-11 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center font-serif text-lg" :class="showIpa ? 'text-orange-500' : ''">ə</div>
              <span>音标</span>
            </button>
            <button type="button" class="flex flex-col items-center gap-1 text-xs" @click="handleBPoint(); moreOpen = false">
              <div class="w-11 h-11 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center text-blue-700 font-semibold">B</div>
              <span>B 点</span>
            </button>
            <button type="button" class="flex flex-col items-center gap-1 text-xs" @click="toggleLoopMenu()">
              <div class="w-11 h-11 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center text-amber-600 font-semibold">{{ loopCountLabel }}</div>
              <span>单句循环</span>
            </button>
            <button type="button" class="flex flex-col items-center gap-1 text-xs" @click="cycleInterval(); moreOpen = false">
              <div class="w-11 h-11 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center">⏱</div>
              <span>间隔</span>
            </button>
            <button
              type="button"
              class="flex flex-col items-center gap-1 text-xs"
              @click="player.pauseAfterSentence.value = !player.pauseAfterSentence.value; moreOpen = false"
            >
              <div class="w-11 h-11 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center" :class="player.pauseAfterSentence.value ? 'text-orange-500' : ''">⏸</div>
              <span>句末暂停</span>
            </button>
          </div>
        </div>
      </div>

      <div
        v-if="speedOpen && speedMenuPos"
        data-player-popover
        class="fixed z-[300] p-2 bg-white dark:bg-neutral-900 rounded-xl shadow-lg border border-black/10 dark:border-white/10 min-w-[9rem]"
        :style="{
          top: `${speedMenuPos.top}px`,
          left: `${speedMenuPos.left}px`,
          transform: compact ? 'translate(-50%, -100%)' : 'translate(-50%, -100%)',
        }"
        @click.stop
      >
        <p class="text-[10px] text-center text-neutral-400 uppercase tracking-wider mb-2">播放倍速</p>
        <div class="grid grid-cols-4 gap-1.5">
          <button
            v-for="r in PLAYBACK_RATES"
            :key="r"
            type="button"
            class="px-2 py-1.5 text-xs rounded-lg border transition-colors cursor-pointer"
            :class="
              player.playbackRate.value === r
                ? 'bg-neutral-600 border-neutral-600 text-white'
                : 'border-neutral-200 hover:bg-neutral-50 dark:border-neutral-700 dark:hover:bg-neutral-800'
            "
            @click="selectRate(r)"
          >
            {{ formatRate(r) }}
          </button>
        </div>
      </div>

      <div
        v-if="loopOpen && loopMenuPos"
        data-player-popover
        class="fixed z-[300] p-2 bg-white dark:bg-neutral-900 rounded-xl shadow-lg border border-black/10 dark:border-white/10 min-w-[10rem]"
        :style="{
          top: `${loopMenuPos.top}px`,
          left: `${loopMenuPos.left}px`,
          transform: 'translate(-50%, -100%)',
        }"
        @click.stop
      >
        <p class="text-[10px] text-center text-neutral-400 uppercase tracking-wider mb-2">设置单句循环次数</p>
        <div class="grid grid-cols-4 gap-1.5">
          <button
            v-for="n in LOOP_COUNT_OPTIONS"
            :key="n"
            type="button"
            class="px-2 py-2 text-xs rounded-lg border transition-colors cursor-pointer"
            :class="
              player.sentenceLoopCount.value === n
                ? 'bg-neutral-600 border-neutral-600 text-white'
                : 'border-neutral-200 hover:bg-neutral-50 dark:border-neutral-700 dark:hover:bg-neutral-800'
            "
            @click="selectLoopCount(n)"
          >
            {{ n === 0 ? '∞' : n }}
          </button>
        </div>
      </div>
    </Teleport>

    <p
      v-if="player.loopStatusText.value"
      class="mt-2 text-[11px] text-amber-800 dark:text-amber-300 bg-amber-50/80 dark:bg-amber-950/40 px-2 py-1 rounded-lg text-center"
    >
      {{ player.loopStatusText.value }}
    </p>
  </div>
</template>
