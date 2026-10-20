<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import {
  LOOP_COUNT_OPTIONS,
  PLAYBACK_RATES,
  type usePlayerControls,
} from '@/composables/usePlayerControls'
import { modeShowsChinese, type FullscreenCaptionMode, type SubtitleDisplayMode } from '@/utils/subtitleHtml'
import { getFullscreenElement, subscribeFullscreenChange, toggleAppFullscreen } from '@/utils/fullscreen'
import AppIcon from '@/components/AppIcon.vue'

const props = withDefaults(
  defineProps<{
    player: ReturnType<typeof usePlayerControls>
    showIpa: boolean
    videoHidden: boolean
    subtitlesHidden?: boolean
    subtitleMode?: SubtitleDisplayMode
    fullscreenCaptionMode?: FullscreenCaptionMode
    videoPanelRef: HTMLElement | null | undefined
    /** 移动端精简控制条 */
    compact?: boolean
    /** 贴底栏样式（无圆角背景） */
    docked?: boolean
    /** 手机端：控制栏显示/隐藏切换 */
    showChromeToggle?: boolean
    chromeVisible?: boolean
    /** 字幕重播：原声 | 复刻音色 */
    subtitleVoiceMode?: 'original' | 'cloned'
    hasClonedVoice?: boolean
    clonedSpeaking?: boolean
  }>(),
  {
    subtitleVoiceMode: 'original',
    hasClonedVoice: false,
    clonedSpeaking: false,
  },
)

const emit = defineEmits<{
  'update:showIpa': [value: boolean]
  'update:videoHidden': [value: boolean]
  'update:subtitlesHidden': [value: boolean]
  'update:subtitleMode': [value: SubtitleDisplayMode]
  'update:fullscreenCaptionMode': [value: FullscreenCaptionMode]
  'update:subtitleVoiceMode': [value: 'original' | 'cloned']
  toggleChrome: []
  openVoiceClone: []
  refreshVoiceClone: []
}>()

const voiceSheetOpen = ref(false)

const captionBilingual = computed(() => modeShowsChinese(props.subtitleMode ?? 'both'))
const fsCaptionMode = computed<FullscreenCaptionMode>(
  () => props.fullscreenCaptionMode ?? (captionBilingual.value ? 'both' : 'en'),
)

function setCaptionMode(mode: FullscreenCaptionMode) {
  emit('update:fullscreenCaptionMode', mode)
}

const speedOpen = ref(false)
const speedRoot = ref<HTMLElement | null>(null)
const speedPopoverEl = ref<HTMLElement | null>(null)
const speedMenuPos = ref<{ top: number; left: number } | null>(null)
const loopOpen = ref(false)
const loopRoot = ref<HTMLElement | null>(null)
const loopPopoverEl = ref<HTMLElement | null>(null)
const loopMenuPos = ref<{ top: number; left: number } | null>(null)
const moreOpen = ref(false)
const isFullscreen = ref(false)
const controlScrollRef = ref<HTMLElement | null>(null)
const showControlScrollFade = ref(false)
let controlScrollObserver: ResizeObserver | null = null
let unsubscribeFullscreen: (() => void) | null = null

/** 全屏时弹层挂全屏元素内；非全屏必须挂 body，否则会被底部进度条盖住 */
const popoverTeleportTo = computed(() => {
  if (!isFullscreen.value) return 'body'
  const fs = getFullscreenElement()
  if (fs instanceof HTMLElement) return fs
  if (props.videoPanelRef) return props.videoPanelRef
  return 'body'
})

const overlayLayerClass = computed(() =>
  isFullscreen.value
    ? 'absolute inset-0 z-[400] flex items-end justify-center bg-black/40'
    : 'fixed inset-0 z-[500] flex items-end justify-center bg-black/40',
)

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

const loopCountLabel = computed(() => String(props.player.sentenceLoopCount.value))

const loopActive = computed(() => props.player.loopMode.value === 'sentence')

/** 首次打开循环菜单时的轻量引导 */
const loopCoachVisible = ref(false)

function maybeShowLoopCoach() {
  try {
    if (localStorage.getItem('teco-loop-pause-tip-seen') === '1') {
      loopCoachVisible.value = false
      return
    }
  } catch {
    /* ignore */
  }
  loopCoachVisible.value = true
}

function dismissLoopCoach() {
  loopCoachVisible.value = false
  try {
    localStorage.setItem('teco-loop-pause-tip-seen', '1')
  } catch {
    /* ignore */
  }
}

function formatRate(r: number) {
  return `${Number.isInteger(r) ? r.toFixed(1) : r}x`
}

function anchorMenu(el: HTMLElement | null) {
  if (!el) return null
  const r = el.getBoundingClientRect()
  return { top: r.top - 8, left: r.left + r.width / 2 }
}

/** 弹窗以 left 为水平中心、translate(-50%,-100%) 向上展开；贴边时钳制，避免裁掉左侧选项 */
async function clampCenteredPopover(
  getEl: () => HTMLElement | null,
  pos: { top: number; left: number },
): Promise<{ top: number; left: number }> {
  await nextTick()
  const popover = getEl()
  if (!popover) return pos
  const rect = popover.getBoundingClientRect()
  const pad = 8
  const halfW = rect.width / 2
  const minLeft = pad + halfW
  const maxLeft = Math.max(minLeft, window.innerWidth - pad - halfW)
  const nextLeft = Math.min(maxLeft, Math.max(minLeft, pos.left))
  let nextTop = pos.top
  if (rect.top < pad) {
    nextTop = Math.min(window.innerHeight - pad, pos.top + (pad - rect.top))
  }
  return { top: nextTop, left: nextLeft }
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
  } else {
    if (loopCoachVisible.value) dismissLoopCoach()
    if (!speedOpen.value) unbindDocClick()
  }
})

onMounted(() => {
  onFullscreenChange()
  unsubscribeFullscreen = subscribeFullscreenChange(onFullscreenChange)
  bindControlScrollFade()
})

onUnmounted(() => {
  unbindDocClick()
  unsubscribeFullscreen?.()
  unsubscribeFullscreen = null
  controlScrollObserver?.disconnect()
  controlScrollObserver = null
})

watch(
  () => props.compact,
  () => nextTick(() => bindControlScrollFade()),
)

function onFullscreenChange() {
  isFullscreen.value = Boolean(getFullscreenElement())
  if (!isFullscreen.value) {
    moreOpen.value = false
    speedOpen.value = false
    speedMenuPos.value = null
    loopOpen.value = false
    loopMenuPos.value = null
  }
}

async function toggleFullscreen() {
  try {
    await toggleAppFullscreen(props.videoPanelRef)
  } catch (err) {
    console.warn('[PlayerControlBar] fullscreen toggle failed', err)
  }
}

function toggleHideVideo() {
  emit('update:videoHidden', !props.videoHidden)
}

function toggleHideSubtitles() {
  emit('update:subtitlesHidden', !props.subtitlesHidden)
}

function toggleIpa() {
  emit('update:showIpa', !props.showIpa)
}

async function toggleSpeedMenu() {
  if (speedOpen.value) {
    speedOpen.value = false
    speedMenuPos.value = null
    return
  }
  moreOpen.value = false
  loopOpen.value = false
  loopMenuPos.value = null
  // 移动端 / 全屏：用底部 sheet，不依赖 fixed 坐标（全屏内容易被裁切）
  if (props.compact || isFullscreen.value) {
    speedMenuPos.value = null
    speedOpen.value = true
    return
  }
  speedMenuPos.value = anchorMenu(speedRoot.value)
  speedOpen.value = true
  if (speedMenuPos.value) {
    speedMenuPos.value = await clampCenteredPopover(() => speedPopoverEl.value, speedMenuPos.value)
  }
}

async function toggleLoopMenu() {
  if (loopOpen.value) {
    loopOpen.value = false
    loopMenuPos.value = null
    return
  }
  moreOpen.value = false
  speedOpen.value = false
  speedMenuPos.value = null
  if (props.compact || isFullscreen.value) {
    loopMenuPos.value = null
    loopOpen.value = true
    maybeShowLoopCoach()
    return
  }
  loopMenuPos.value = anchorMenu(loopRoot.value)
  loopOpen.value = true
  maybeShowLoopCoach()
  if (loopMenuPos.value) {
    loopMenuPos.value = await clampCenteredPopover(() => loopPopoverEl.value, loopMenuPos.value)
  }
}

function closeLoopSheet() {
  loopOpen.value = false
  loopMenuPos.value = null
  if (loopCoachVisible.value) dismissLoopCoach()
}

function togglePauseAfterSentence() {
  const next = !props.player.pauseAfterSentence.value
  props.player.setPauseAfterSentence(next)
  if (next) dismissLoopCoach()
}

function selectRate(rate: number) {
  props.player.setRate(rate)
  speedOpen.value = false
  speedMenuPos.value = null
}

function selectLoopCount(count: number) {
  props.player.setSentenceLoopCount(count)
  props.player.enableSentenceLoop()
  if (loopCoachVisible.value) dismissLoopCoach()
}

function toggleDictationAfterLoop() {
  props.player.armSentenceLoopMode()
  props.player.setDictationAfterLoop(!props.player.dictationAfterLoop.value)
  if (loopCoachVisible.value) dismissLoopCoach()
}

function toggleAutoAdvanceAfterLoop() {
  if (props.player.pauseAfterSentence.value) return
  props.player.armSentenceLoopMode()
  props.player.setAutoAdvanceAfterLoop(!props.player.autoAdvanceAfterLoop.value)
  if (loopCoachVisible.value) dismissLoopCoach()
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
  // 复刻模式：主按钮始终走 TTS 链（开始/停止），避免误播视频原声
  if (props.subtitleVoiceMode === 'cloned' && props.hasClonedVoice) {
    p.replayCurrentSentence()
    return
  }
  if (p.isPlaying.value) {
    p.togglePlay()
    return
  }
  p.replayCurrentSentence()
}

function openVoiceSheet() {
  moreOpen.value = false
  voiceSheetOpen.value = true
  emit('refreshVoiceClone')
}

function closeVoiceSheet() {
  voiceSheetOpen.value = false
}

function selectVoiceMode(mode: 'original' | 'cloned') {
  voiceSheetOpen.value = false
  emit('update:subtitleVoiceMode', mode)
}

function goCloneFromVoiceSheet() {
  voiceSheetOpen.value = false
  emit('openVoiceClone')
}

const voiceModeLabel = computed(() =>
  props.subtitleVoiceMode === 'cloned' && props.hasClonedVoice ? '我的声音' : '原声',
)
</script>

<template>
  <div
    class="shrink-0 select-none text-black/70 dark:text-neutral-200"
    :class="
      docked
        ? 'px-2 py-1.5 bg-transparent'
        : subtitlesHidden
          ? 'rounded-xl border border-white/25 dark:border-white/10 bg-white/55 dark:bg-neutral-900/55 backdrop-blur-md shadow-[0_8px_30px_rgba(0,0,0,0.12)] px-2 py-2.5 sm:px-3'
          : 'rounded-xl bg-neutral-200/60 dark:bg-neutral-800/80 px-2 py-2.5 sm:px-3'
    "
    @click.stop
    @pointerdown.stop
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
        <AppIcon name="arrow-uturn-left" class="w-9 h-9" />
      </button>

      <button type="button" class="shrink-0 p-0.5 active:scale-95" :title="player.mainActionLabel.value" @click="handleMainAction">
        <AppIcon name="pause-circle" v-if="player.isPlaying.value || clonedSpeaking" class="w-11 h-11" />
        <AppIcon name="play-circle" class="w-11 h-11" />
      </button>

      <button type="button" class="shrink-0 p-1 active:scale-95" title="下一句" @click="player.nextSentence()">
        <AppIcon name="arrow-uturn-right" class="w-9 h-9" />
      </button>

      <button
        v-if="showChromeToggle"
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[2.75rem] text-xs active:scale-95"
        :title="chromeVisible ? '隐藏控制栏' : '显示控制栏'"
        :aria-label="chromeVisible ? '隐藏控制栏' : '显示控制栏'"
        :aria-expanded="chromeVisible !== false"
        @click.stop="emit('toggleChrome')"
      >
        <div class="w-10 h-10 rounded-full flex items-center justify-center bg-black/5 dark:bg-white/10">
          <AppIcon name="chevron-down" v-if="chromeVisible !== false" class="w-5 h-5" />
          <AppIcon name="menu" class="w-5 h-5" />
        </div>
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
        class="flex items-end justify-between gap-1 sm:gap-0 max-w-full overflow-x-auto player-control-bar__scroll"
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
          <AppIcon name="eye-off" v-if="videoHidden" class="w-4 h-4" />
          <AppIcon name="eye" class="w-4 h-4" />
        </div>
        <span class="text-[11px] leading-tight mt-0.5">{{ videoHidden ? '显示视频' : '隐藏视频' }}</span>
      </button>

      <!-- 隐藏字幕 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        :title="subtitlesHidden ? '显示字幕' : '隐藏字幕'"
        @click="toggleHideSubtitles"
      >
        <div
          class="p-0.5 w-8 h-8 rounded-full flex items-center justify-center bg-black/5 dark:bg-white/10"
          :class="subtitlesHidden ? 'text-orange-500' : ''"
        >
          <AppIcon name="subtitles-off" v-if="subtitlesHidden" class="w-4 h-4" />
          <AppIcon name="subtitles" class="w-4 h-4" />
        </div>
        <span class="text-[11px] leading-tight mt-0.5">{{ subtitlesHidden ? '显示字幕' : '隐藏字幕' }}</span>
      </button>

      <!-- 全屏字幕语言：中英 / 英语 / 盲听 -->
      <div
        v-if="isFullscreen"
        class="flex flex-col items-center shrink-0 min-w-[3.5rem] text-xs"
        role="group"
        aria-label="字幕语言"
      >
        <div class="flex items-center rounded-full bg-black/5 dark:bg-white/10 p-0.5">
          <button
            type="button"
            class="px-1.5 h-7 rounded-full text-[10px] font-medium transition-colors"
            :class="
              fsCaptionMode === 'both'
                ? 'bg-neutral-700 text-ink-inverse dark:bg-neutral-200'
                : 'text-ink-soft'
            "
            :aria-pressed="fsCaptionMode === 'both'"
            title="中英字幕"
            @click="setCaptionMode('both')"
          >
            中英
          </button>
          <button
            type="button"
            class="px-1.5 h-7 rounded-full text-[10px] font-medium transition-colors"
            :class="
              fsCaptionMode === 'en'
                ? 'bg-neutral-700 text-ink-inverse dark:bg-neutral-200'
                : 'text-ink-soft'
            "
            :aria-pressed="fsCaptionMode === 'en'"
            title="仅英文字幕"
            @click="setCaptionMode('en')"
          >
            英语
          </button>
          <button
            type="button"
            class="px-1.5 h-7 rounded-full text-[10px] font-medium transition-colors"
            :class="
              fsCaptionMode === 'blind'
                ? 'bg-neutral-700 text-ink-inverse dark:bg-neutral-200'
                : 'text-ink-soft'
            "
            :aria-pressed="fsCaptionMode === 'blind'"
            title="盲听，不显示字幕"
            @click="setCaptionMode('blind')"
          >
            盲听
          </button>
        </div>
        <span class="text-[11px] leading-tight mt-0.5">字幕</span>
      </div>

      <!-- 全屏 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        @click="toggleFullscreen"
      >
        <div class="p-0.5 w-8 h-8 rounded-full flex items-center justify-center bg-black/5 dark:bg-white/10">
          <AppIcon name="fullscreen" v-if="isFullscreen" class="w-4 h-4" />
          <AppIcon name="fullscreen-exit" class="w-4 h-4" />
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
        <AppIcon name="arrow-uturn-left" class="w-8 h-8 text-neutral-800 dark:text-neutral-200" />
        <span class="text-[11px] leading-tight mt-0.5">上一句</span>
      </button>

      <!-- 重播 / 暂停 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        :title="player.mainActionLabel.value"
        @click="handleMainAction"
      >
        <AppIcon name="pause-circle" v-if="player.isPlaying.value || clonedSpeaking" class="w-8 h-8 text-neutral-800 dark:text-neutral-200" />
        <AppIcon name="play-circle" class="w-8 h-8 text-neutral-800 dark:text-neutral-200" />
        <span class="text-[11px] leading-tight mt-0.5">{{ clonedSpeaking ? '停止' : player.mainActionLabel.value }}</span>
      </button>

      <!-- 下一句 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        title="下一句"
        @click="player.nextSentence()"
      >
        <AppIcon name="arrow-uturn-right" class="w-8 h-8 text-ink-soft" />
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

      <!-- 字幕声音：原声 / 我的声音 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        :title="`字幕重播声音：${voiceModeLabel}`"
        @click="openVoiceSheet"
      >
        <div
          class="p-0.5 w-8 h-8 rounded-full flex items-center justify-center bg-black/5 text-[11px] font-medium"
          :class="subtitleVoiceMode === 'cloned' && hasClonedVoice ? 'text-teal-600 ring-2 ring-teal-400/50' : ''"
        >
          声
        </div>
        <span class="text-[11px] leading-tight mt-0.5">{{ voiceModeLabel }}</span>
      </button>

      <!-- 单句循环（含句末停下等设置） -->
      <div ref="loopRoot" class="relative flex flex-col items-center shrink-0 min-w-[3rem] cursor-pointer">
        <button
          type="button"
          class="flex flex-col items-center text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
          :class="loopActive ? 'text-ink' : ''"
          title="单句循环与句末停下"
          @click.stop="toggleLoopMenu"
        >
          <div class="relative w-8 h-8 flex items-center justify-center">
            <AppIcon name="loop" class="w-8 h-8" />
            <span
              class="absolute inset-0 flex items-center justify-center text-[10px] font-semibold tabular-nums"
              :class="
                loopActive || player.pauseAfterSentence.value
                  ? 'text-amber-700 dark:text-amber-300'
                  : ''
              "
            >
              {{ loopCountLabel }}
            </span>
            <span
              v-if="player.pauseAfterSentence.value"
              class="absolute -top-0.5 -right-0.5 h-2 w-2 rounded-full bg-orange-500 ring-2 ring-neutral-200 dark:ring-neutral-800"
              aria-hidden="true"
            />
          </div>
          <span class="text-[11px] leading-tight mt-0.5">单句循环</span>
        </button>
      </div>

      <!-- 间隔 -->
      <button
        type="button"
        class="flex flex-col items-center shrink-0 min-w-[3rem] text-xs transition-all active:scale-95 focus:outline-none cursor-pointer"
        title="句间/遍间停顿。点击 0→5 秒循环。倒计时可点画面跳过。"
        @click="cycleInterval"
      >
        <div
          class="p-0.5 w-8 h-8 rounded-full flex items-center justify-center"
          :class="
            player.loopInterval.value > 0
              ? 'bg-amber-500/15 text-amber-700 dark:text-amber-300'
              : 'bg-black/5 dark:bg-white/10'
          "
        >
          <AppIcon name="history" class="w-4 h-4" />
        </div>
        <span
          class="text-[11px] leading-tight mt-0.5"
          :class="player.loopInterval.value > 0 ? 'text-amber-700 dark:text-amber-300' : ''"
        >
          间隔{{ player.loopInterval.value > 0 ? player.loopInterval.value + '秒' : '' }}
        </span>
      </button>

      </div>
      <div
        v-if="showControlScrollFade"
        class="pointer-events-none absolute right-0 top-0 bottom-0 z-10 w-10 bg-gradient-to-l from-neutral-200/95 via-neutral-200/60 to-transparent dark:from-neutral-800/95 dark:via-neutral-800/60"
        aria-hidden="true"
      />
    </div>

    <!-- 弹层：非全屏挂 body；全屏挂全屏元素，并用 absolute 避免 overflow 裁切 -->
    <Teleport :to="popoverTeleportTo">
      <!-- 移动端更多 -->
      <div
        v-if="compact && moreOpen"
        data-player-popover
        :class="overlayLayerClass"
        @click.self="moreOpen = false"
      >
        <div
          class="w-full max-w-lg rounded-t-2xl bg-card shadow-2xl border-t border-black/10 dark:border-white/10 pb-[env(safe-area-inset-bottom)]"
          @click.stop
        >
          <div class="flex justify-center pt-3 pb-2">
            <div class="w-10 h-1 rounded-full bg-neutral-300 dark:bg-neutral-600" />
          </div>
          <p class="text-sm font-medium text-center mb-3">更多控制</p>
          <div class="grid grid-cols-4 gap-3 px-4 pb-4">
            <button type="button" class="flex flex-col items-center gap-1 text-xs" @click="toggleHideVideo(); moreOpen = false">
              <div class="w-11 h-11 rounded-full bg-sunken flex items-center justify-center">{{ videoHidden ? '显' : '隐' }}</div>
              <span>{{ videoHidden ? '显示视频' : '隐藏视频' }}</span>
            </button>
            <button type="button" class="flex flex-col items-center gap-1 text-xs" @click="toggleHideSubtitles(); moreOpen = false">
              <div
                class="w-11 h-11 rounded-full bg-sunken flex items-center justify-center"
                :class="subtitlesHidden ? 'text-orange-500' : ''"
              >
                <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                  <path
                    v-if="subtitlesHidden"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M3.75 6.75h16.5M3.75 12h10.5m-10.5 5.25H12m3 0 6 6m0-6-6 6"
                  />
                  <path
                    v-else
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
                  />
                </svg>
              </div>
              <span>{{ subtitlesHidden ? '显示字幕' : '隐藏字幕' }}</span>
            </button>
            <button
              v-if="isFullscreen"
              type="button"
              class="flex flex-col items-center gap-1 text-xs"
              @click="setCaptionMode('both'); moreOpen = false"
            >
              <div
                class="w-11 h-11 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center text-[11px] font-medium"
                :class="fsCaptionMode === 'both' ? 'text-orange-500 ring-2 ring-orange-400/50' : ''"
              >
                中英
              </div>
              <span>中英字幕</span>
            </button>
            <button
              v-if="isFullscreen"
              type="button"
              class="flex flex-col items-center gap-1 text-xs"
              @click="setCaptionMode('en'); moreOpen = false"
            >
              <div
                class="w-11 h-11 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center text-[11px] font-medium"
                :class="fsCaptionMode === 'en' ? 'text-orange-500 ring-2 ring-orange-400/50' : ''"
              >
                EN
              </div>
              <span>英文字幕</span>
            </button>
            <button
              v-if="isFullscreen"
              type="button"
              class="flex flex-col items-center gap-1 text-xs"
              @click="setCaptionMode('blind'); moreOpen = false"
            >
              <div
                class="w-11 h-11 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center text-[11px] font-medium"
                :class="fsCaptionMode === 'blind' ? 'text-orange-500 ring-2 ring-orange-400/50' : ''"
              >
                盲
              </div>
              <span>盲听</span>
            </button>
            <button type="button" class="flex flex-col items-center gap-1 text-xs" @click="openVoiceSheet">
              <div
                class="w-11 h-11 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center text-[11px] font-medium"
                :class="subtitleVoiceMode === 'cloned' && hasClonedVoice ? 'text-teal-600 ring-2 ring-teal-400/50' : ''"
              >
                声
              </div>
              <span>{{ voiceModeLabel }}</span>
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
              <div
                class="w-11 h-11 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center text-amber-600 font-semibold relative"
                :class="player.pauseAfterSentence.value ? 'ring-2 ring-orange-400/60' : ''"
              >
                {{ loopCountLabel }}
              </div>
              <span>单句循环</span>
            </button>
            <button type="button" class="flex flex-col items-center gap-1 text-xs" @click="cycleInterval(); moreOpen = false">
              <div
                class="w-11 h-11 rounded-full bg-neutral-100 dark:bg-neutral-800 flex items-center justify-center"
                :class="player.loopInterval.value > 0 ? 'text-amber-600 ring-2 ring-amber-400/60' : ''"
              >
                ⏱
              </div>
              <span>{{ player.loopInterval.value > 0 ? `间隔${player.loopInterval.value}秒` : '间隔' }}</span>
            </button>
          </div>
        </div>
      </div>

      <!-- 移动端 / 全屏：倍速底部 sheet -->
      <div
        v-if="(compact || isFullscreen) && speedOpen"
        data-player-popover
        :class="overlayLayerClass"
        @click.self="speedOpen = false"
      >
        <div
          class="w-full max-w-lg rounded-t-2xl bg-white dark:bg-neutral-900 shadow-2xl border-t border-black/10 dark:border-white/10 px-4 pt-3 pb-[max(1rem,env(safe-area-inset-bottom))]"
          @click.stop
        >
          <div class="flex justify-center pb-2">
            <div class="w-10 h-1 rounded-full bg-neutral-300 dark:bg-neutral-600" />
          </div>
          <p class="text-sm font-medium text-center mb-3">播放倍速</p>
          <div class="grid grid-cols-4 gap-2 pb-2">
            <button
              v-for="r in PLAYBACK_RATES"
              :key="r"
              type="button"
              class="px-2 py-2.5 text-sm rounded-xl border transition-colors"
              :class="
                player.playbackRate.value === r
                  ? 'bg-neutral-600 border-neutral-600 text-white'
                  : 'border-neutral-200 hover:bg-sunken dark:border-neutral-700'
              "
              @click="selectRate(r)"
            >
              {{ formatRate(r) }}
            </button>
          </div>
        </div>
      </div>

      <!-- 移动端 / 全屏：单句循环底部 sheet -->
      <div
        v-if="(compact || isFullscreen) && loopOpen"
        data-player-popover
        :class="overlayLayerClass"
        @click.self="closeLoopSheet"
      >
        <div
          class="w-full max-w-lg rounded-t-2xl bg-white dark:bg-neutral-900 shadow-2xl border-t border-black/10 dark:border-white/10 px-4 pt-3 pb-[max(1rem,env(safe-area-inset-bottom))]"
          @click.stop
        >
          <div class="flex justify-center pb-2">
            <div class="w-10 h-1 rounded-full bg-neutral-300 dark:bg-neutral-600" />
          </div>
          <p class="text-sm font-medium text-center mb-2">单句循环</p>
          <p
            v-if="loopCoachVisible"
            class="mb-2 rounded-lg bg-orange-50 dark:bg-orange-950/40 px-2.5 py-2 text-[11px] leading-snug text-orange-900 dark:text-orange-100"
          >
            练跟读：设好次数并打开「句末停下」后，会连播满次数再停；点「下一句」自动播下一句。
          </p>
          <p class="text-[10px] text-neutral-400 mb-1.5 px-0.5">循环次数</p>
          <div class="grid grid-cols-4 gap-2 mb-3">
            <button
              v-for="n in LOOP_COUNT_OPTIONS"
              :key="n"
              type="button"
              class="px-2 py-2.5 text-sm rounded-xl border transition-colors"
              :class="
                player.sentenceLoopCount.value === n
                  ? 'bg-neutral-600 border-neutral-600 text-white'
                  : 'border-neutral-200 hover:bg-sunken dark:border-neutral-700'
              "
              @click="selectLoopCount(n)"
            >
              {{ n }}
            </button>
          </div>
          <div class="space-y-2 pb-2">
            <button
              type="button"
              class="w-full flex items-center justify-between gap-2 rounded-lg px-2.5 py-2 text-left text-xs transition-colors"
              :class="
                player.pauseAfterSentence.value
                  ? 'bg-orange-50 text-orange-900 dark:bg-orange-950/50 dark:text-orange-100'
                  : 'hover:bg-sunken text-ink-soft'
              "
              @click="togglePauseAfterSentence"
            >
              <span class="min-w-0">
                <span class="block font-medium">句末停下</span>
                <span class="block text-[10px] text-neutral-400 mt-0.5 leading-snug">
                  按次数连播，播满后停；点下一句自动播下一句
                </span>
              </span>
              <span
                class="shrink-0 w-9 h-5 rounded-full relative transition-colors"
                :class="player.pauseAfterSentence.value ? 'bg-orange-500' : 'bg-neutral-200 dark:bg-neutral-700'"
                aria-hidden="true"
              >
                <span
                  class="absolute top-0.5 left-0.5 w-4 h-4 rounded-full bg-white shadow transition-transform"
                  :class="player.pauseAfterSentence.value ? 'translate-x-4' : ''"
                />
              </span>
            </button>
            <button
              type="button"
              class="w-full flex items-center justify-between gap-2 rounded-lg px-2.5 py-2 text-left text-xs transition-colors"
              :class="
                player.pauseAfterSentence.value
                  ? 'opacity-40 cursor-not-allowed text-neutral-400'
                  : player.autoAdvanceAfterLoop.value
                    ? 'bg-amber-50 text-warning dark:bg-amber-950/50'
                    : 'hover:bg-sunken text-ink-soft'
              "
              :disabled="player.pauseAfterSentence.value"
              @click="toggleAutoAdvanceAfterLoop"
            >
              <span class="min-w-0">
                <span class="block font-medium">自动下一句</span>
                <span class="block text-[10px] text-neutral-400 mt-0.5 leading-snug">
                  {{
                    player.pauseAfterSentence.value
                      ? '句末停下时请手动换句'
                      : '同句多遍连续播；换句时短暂停顿'
                  }}
                </span>
              </span>
              <span
                class="shrink-0 w-9 h-5 rounded-full relative transition-colors"
                :class="player.autoAdvanceAfterLoop.value ? 'bg-amber-500' : 'bg-neutral-200 dark:bg-neutral-700'"
                aria-hidden="true"
              >
                <span
                  class="absolute top-0.5 left-0.5 w-4 h-4 rounded-full bg-white shadow transition-transform"
                  :class="player.autoAdvanceAfterLoop.value ? 'translate-x-4' : ''"
                />
              </span>
            </button>
            <button
              type="button"
              class="w-full flex items-center justify-between gap-2 rounded-lg px-2.5 py-2 text-left text-xs transition-colors"
              :class="
                player.dictationAfterLoop.value
                  ? 'bg-amber-50 text-warning dark:bg-amber-950/50'
                  : 'hover:bg-sunken text-ink-soft'
              "
              @click="toggleDictationAfterLoop"
            >
              <span class="min-w-0">
                <span class="block font-medium">播放完后听写</span>
                <span class="block text-[10px] text-neutral-400 mt-0.5 leading-snug">
                  {{
                    player.autoAdvanceAfterLoop.value
                      ? '整段播完后进入听写'
                      : '当前句次数播完后进入听写'
                  }}
                </span>
              </span>
              <span
                class="shrink-0 w-9 h-5 rounded-full relative transition-colors"
                :class="player.dictationAfterLoop.value ? 'bg-amber-500' : 'bg-neutral-200 dark:bg-neutral-700'"
                aria-hidden="true"
              >
                <span
                  class="absolute top-0.5 left-0.5 w-4 h-4 rounded-full bg-white shadow transition-transform"
                  :class="player.dictationAfterLoop.value ? 'translate-x-4' : ''"
                />
              </span>
            </button>
          </div>
        </div>
      </div>

      <div
        v-if="!compact && !isFullscreen && speedOpen && speedMenuPos"
        ref="speedPopoverEl"
        data-player-popover
        class="fixed z-[300] p-2 bg-white dark:bg-neutral-900 rounded-xl shadow-lg border border-black/10 dark:border-white/10 min-w-[11rem]"
        :style="{
          top: `${speedMenuPos.top}px`,
          left: `${speedMenuPos.left}px`,
          transform: 'translate(-50%, -100%)',
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
                : 'border-neutral-200 hover:bg-sunken dark:border-neutral-700'
            "
            @click="selectRate(r)"
          >
            {{ formatRate(r) }}
          </button>
        </div>
      </div>

      <div
        v-if="!compact && !isFullscreen && loopOpen && loopMenuPos"
        ref="loopPopoverEl"
        data-player-popover
        class="fixed z-[300] p-2.5 bg-white dark:bg-neutral-900 rounded-xl shadow-lg border border-black/10 dark:border-white/10 min-w-[14rem] max-w-[min(20rem,calc(100vw-1rem))]"
        :style="{
          top: `${loopMenuPos.top}px`,
          left: `${loopMenuPos.left}px`,
          transform: 'translate(-50%, -100%)',
        }"
        @click.stop
      >
        <p class="text-[10px] text-center text-neutral-400 uppercase tracking-wider mb-1.5">单句循环</p>
        <p
          v-if="loopCoachVisible"
          class="mb-2 rounded-lg bg-orange-50 dark:bg-orange-950/40 px-2.5 py-2 text-[11px] leading-snug text-orange-900 dark:text-orange-100"
        >
          练跟读：设好次数并打开「句末停下」后，会连播满次数再停；点「下一句」自动播下一句。
        </p>
        <p class="text-[10px] text-neutral-400 mb-1.5 px-0.5">循环次数</p>
        <div class="grid grid-cols-4 gap-1.5">
          <button
            v-for="n in LOOP_COUNT_OPTIONS"
            :key="n"
            type="button"
            class="px-2 py-2 text-xs rounded-lg border transition-colors cursor-pointer"
            :class="
              player.sentenceLoopCount.value === n
                ? 'bg-neutral-600 border-neutral-600 text-white'
                : 'border-neutral-200 hover:bg-sunken dark:border-neutral-700'
            "
            @click="selectLoopCount(n)"
          >
            {{ n }}
          </button>
        </div>
        <div class="mt-2 pt-2 border-t border-black/5 dark:border-white/10 space-y-2">
          <button
            type="button"
            class="w-full flex items-center justify-between gap-2 rounded-lg px-2.5 py-2 text-left text-xs transition-colors"
            :class="
              player.pauseAfterSentence.value
                ? 'bg-orange-50 text-orange-900 dark:bg-orange-950/50 dark:text-orange-100'
                : 'hover:bg-sunken text-ink-soft'
            "
            title="按循环次数连播，播满后暂停"
            @click="togglePauseAfterSentence"
          >
            <span class="min-w-0">
              <span class="block font-medium">句末停下</span>
              <span class="block text-[10px] text-neutral-400 mt-0.5 leading-snug">
                按次数连播，播满后停；点下一句自动播下一句
              </span>
            </span>
            <span
              class="shrink-0 w-9 h-5 rounded-full relative transition-colors"
              :class="player.pauseAfterSentence.value ? 'bg-orange-500' : 'bg-neutral-200 dark:bg-neutral-700'"
              aria-hidden="true"
            >
              <span
                class="absolute top-0.5 left-0.5 w-4 h-4 rounded-full bg-white shadow transition-transform"
                :class="player.pauseAfterSentence.value ? 'translate-x-4' : ''"
              />
            </span>
          </button>
          <button
            type="button"
            class="w-full flex items-center justify-between gap-2 rounded-lg px-2.5 py-2 text-left text-xs transition-colors"
            :class="
              player.pauseAfterSentence.value
                ? 'opacity-40 cursor-not-allowed text-neutral-400'
                : player.autoAdvanceAfterLoop.value
                  ? 'bg-amber-50 text-warning dark:bg-amber-950/50'
                  : 'hover:bg-sunken text-ink-soft'
            "
            :disabled="player.pauseAfterSentence.value"
            :title="
              player.pauseAfterSentence.value
                ? '句末停下开启时请手动点「下一句」换句'
                : '每句播完设定次数后自动进入下一句'
            "
            @click="toggleAutoAdvanceAfterLoop"
          >
            <span class="min-w-0">
              <span class="block font-medium">自动下一句</span>
              <span class="block text-[10px] text-neutral-400 mt-0.5 leading-snug">
                {{
                  player.pauseAfterSentence.value
                    ? '句末停下时请手动换句'
                    : '同句多遍连续播；换句时短暂停顿'
                }}
              </span>
            </span>
            <span
              class="shrink-0 w-9 h-5 rounded-full relative transition-colors"
              :class="player.autoAdvanceAfterLoop.value ? 'bg-amber-500' : 'bg-neutral-200 dark:bg-neutral-700'"
              aria-hidden="true"
            >
              <span
                class="absolute top-0.5 left-0.5 w-4 h-4 rounded-full bg-white shadow transition-transform"
                :class="player.autoAdvanceAfterLoop.value ? 'translate-x-4' : ''"
              />
            </span>
          </button>
          <button
            type="button"
            class="w-full flex items-center justify-between gap-2 rounded-lg px-2.5 py-2 text-left text-xs transition-colors"
            :class="
              player.dictationAfterLoop.value
                ? 'bg-amber-50 text-warning dark:bg-amber-950/50'
                : 'hover:bg-sunken text-ink-soft'
            "
            :title="
              player.autoAdvanceAfterLoop.value
                ? '整段播完后进入听写'
                : '当前句次数播完后进入听写'
            "
            @click="toggleDictationAfterLoop"
          >
            <span class="min-w-0">
              <span class="block font-medium">播放完后听写</span>
              <span class="block text-[10px] text-neutral-400 mt-0.5 leading-snug">
                {{
                  player.autoAdvanceAfterLoop.value
                    ? '整段播完后进入听写'
                    : '当前句次数播完后进入听写'
                }}
              </span>
            </span>
            <span
              class="shrink-0 w-9 h-5 rounded-full relative transition-colors"
              :class="player.dictationAfterLoop.value ? 'bg-amber-500' : 'bg-neutral-200 dark:bg-neutral-700'"
              aria-hidden="true"
            >
              <span
                class="absolute top-0.5 left-0.5 w-4 h-4 rounded-full bg-white shadow transition-transform"
                :class="player.dictationAfterLoop.value ? 'translate-x-4' : ''"
              />
            </span>
          </button>
        </div>
      </div>

      <!-- 字幕声音选择 -->
      <div
        v-if="voiceSheetOpen"
        data-player-popover
        :class="overlayLayerClass"
        @click.self="closeVoiceSheet"
      >
        <div
          class="w-full max-w-lg rounded-t-2xl bg-white dark:bg-neutral-900 shadow-2xl border-t border-black/10 dark:border-white/10 pb-[env(safe-area-inset-bottom)] sm:mb-6 sm:rounded-2xl sm:border"
          @click.stop
        >
          <div class="flex justify-center pt-3 pb-2 sm:hidden">
            <div class="w-10 h-1 rounded-full bg-neutral-300 dark:bg-neutral-600" />
          </div>
          <p class="text-sm font-medium text-center mb-1 px-4">字幕重播声音</p>
          <p class="text-[11px] text-center text-neutral-500 px-4 mb-3">
            音色绑定账号。选「我的声音」后画面按原速连续播，语速与停顿按字幕时间对齐。
          </p>
          <div class="px-4 pb-4 space-y-2">
            <button
              type="button"
              class="w-full flex items-center justify-between rounded-xl border px-3 py-3 text-sm transition-colors"
              :class="
                subtitleVoiceMode === 'original'
                  ? 'border-teal-400 bg-teal-50 dark:bg-teal-950/40 dark:border-teal-600'
                  : 'border-neutral-200 dark:border-neutral-700'
              "
              @click="selectVoiceMode('original')"
            >
              <span>视频原声</span>
              <span v-if="subtitleVoiceMode === 'original'" class="text-teal-600 text-xs">当前</span>
            </button>
            <button
              type="button"
              class="w-full flex items-center justify-between rounded-xl border px-3 py-3 text-sm transition-colors"
              :class="
                subtitleVoiceMode === 'cloned' && hasClonedVoice
                  ? 'border-teal-400 bg-teal-50 dark:bg-teal-950/40 dark:border-teal-600'
                  : 'border-neutral-200 dark:border-neutral-700'
              "
              @click="selectVoiceMode('cloned')"
            >
              <span>{{ hasClonedVoice ? '我的声音（复刻）' : '我的声音' }}</span>
              <span v-if="subtitleVoiceMode === 'cloned' && hasClonedVoice" class="text-teal-600 text-xs">当前</span>
              <span v-else-if="!hasClonedVoice" class="text-neutral-400 text-xs">未复刻或需重录</span>
            </button>
            <button
              type="button"
              class="w-full rounded-xl border border-dashed border-neutral-300 dark:border-neutral-600 px-3 py-2.5 text-sm text-neutral-600 dark:text-neutral-300"
              @click="goCloneFromVoiceSheet"
            >
              {{ hasClonedVoice ? '管理 / 重新录制' : '录制并复刻我的声音' }}
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <p
      v-if="player.pauseHintText.value"
      class="mt-2 text-[12px] font-medium text-orange-900 dark:text-orange-100 bg-orange-50 dark:bg-orange-950/50 px-2 py-1.5 rounded-lg text-center animate-pulse"
    >
      {{ player.pauseHintText.value }}
    </p>
    <p
      v-else-if="player.loopStatusText.value"
      class="mt-2 text-[11px] text-amber-800 dark:text-amber-300 bg-amber-50/80 dark:bg-amber-950/40 px-2 py-1 rounded-lg text-center"
    >
      {{ player.loopStatusText.value }}
    </p>
  </div>
</template>
