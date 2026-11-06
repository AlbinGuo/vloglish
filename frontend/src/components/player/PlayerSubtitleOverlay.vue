<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import SubtitleBlock from '@/components/SubtitleBlock.vue'
import type { Subtitle } from '@/types'
import type { PlayerSubtitlePosition } from '@/composables/useSubtitleOverlayPosition'
import type { PlayerSubtitleSize } from '@/composables/usePlayerSubtitlePrefs'
import type { FullscreenCaptionMode } from '@/utils/subtitleHtml'

const props = withDefaults(
  defineProps<{
    sub: Subtitle | null | undefined
    englishHtml: string
    position: PlayerSubtitlePosition
    mode?: FullscreenCaptionMode
    size?: PlayerSubtitleSize
  }>(),
  { mode: 'both', size: 'medium' },
)

const emit = defineEmits<{
  click: [event: MouseEvent]
}>()

const DRAG_STORAGE_KEY = 'teco-player-subtitle-drag-offset'
const HINT_STORAGE_KEY = 'teco-player-subtitle-handle-hint'

function loadDragOffset(): { x: number; y: number } {
  try {
    const raw = localStorage.getItem(DRAG_STORAGE_KEY)
    if (raw) {
      const v = JSON.parse(raw) as { x?: number; y?: number }
      if (typeof v.x === 'number' && typeof v.y === 'number') return { x: v.x, y: v.y }
    }
  } catch {
    /* ignore */
  }
  return { x: 0, y: 0 }
}

const dragOffset = ref(loadDragOffset())
const dragging = ref(false)
let dragPointerId: number | null = null
let dragStart = { x: 0, y: 0 }
let dragOrigin = { x: 0, y: 0 }

const controlsActive = ref(false)
let controlsHideTimer: ReturnType<typeof setTimeout> | null = null
let hintTimer: ReturnType<typeof setTimeout> | null = null

const showControls = computed(() => controlsActive.value || dragging.value)

const en = computed(() => (props.sub?.english || '').trim())
const zh = computed(() => (props.sub?.chinese || '').trim())

const showEnglish = computed(() => props.mode === 'both' || props.mode === 'en')
const showChinese = computed(() => props.mode === 'both')

const visible = computed(() => {
  if (props.position === 'off' || props.mode === 'blind' || !props.sub) return false
  if (showEnglish.value && en.value.length) return true
  if (showChinese.value && zh.value.length) return true
  return false
})

const positionClass = computed(() => {
  switch (props.position) {
    case 'top':
      return 'top-0 pt-2 sm:pt-3'
    case 'middle':
      return 'top-1/2 -translate-y-1/2'
    default:
      return 'bottom-0 pb-3 sm:pb-12'
  }
})

const sizeClass = computed(() => `is-${props.size}`)
const dragStyle = computed(() => ({
  '--subtitle-drag-x': `${dragOffset.value.x}px`,
  '--subtitle-drag-y': `${dragOffset.value.y}px`,
}))

watch(
  dragOffset,
  (v) => {
    try {
      localStorage.setItem(DRAG_STORAGE_KEY, JSON.stringify(v))
    } catch {
      /* ignore */
    }
  },
  { deep: true },
)

watch(
  () => props.position,
  () => {
    dragOffset.value = { x: 0, y: 0 }
  },
)

function clearControlsHideTimer() {
  if (controlsHideTimer) {
    clearTimeout(controlsHideTimer)
    controlsHideTimer = null
  }
}

function revealControls() {
  clearControlsHideTimer()
  controlsActive.value = true
}

function scheduleHideControls(delay = 700) {
  clearControlsHideTimer()
  controlsHideTimer = setTimeout(() => {
    controlsHideTimer = null
    if (!dragging.value) controlsActive.value = false
  }, delay)
}

function onBoxPointerMove() {
  if (!dragging.value) revealControls()
}

function onBoxPointerUp() {
  if (!dragging.value) scheduleHideControls(1200)
}

function onDragStart(e: PointerEvent) {
  if (e.button !== 0) return
  dragging.value = true
  revealControls()
  dragPointerId = e.pointerId
  dragStart = { x: e.clientX, y: e.clientY }
  dragOrigin = { ...dragOffset.value }
  ;(e.currentTarget as HTMLElement).setPointerCapture(e.pointerId)
  e.preventDefault()
}

function onDragMove(e: PointerEvent) {
  if (!dragging.value || e.pointerId !== dragPointerId) return
  dragOffset.value = {
    x: dragOrigin.x + e.clientX - dragStart.x,
    y: dragOrigin.y + e.clientY - dragStart.y,
  }
}

function onDragEnd(e: PointerEvent) {
  if (e.pointerId !== dragPointerId) return
  dragging.value = false
  dragPointerId = null
  scheduleHideControls(900)
}

onMounted(() => {
  // 触屏设备首次出现时短暂显示一下拖拽横杠作为提示，之后不再常驻
  try {
    const touchDevice = window.matchMedia?.('(hover: none)').matches
    if (touchDevice && !sessionStorage.getItem(HINT_STORAGE_KEY)) {
      controlsActive.value = true
      hintTimer = setTimeout(() => {
        hintTimer = null
        if (!dragging.value) controlsActive.value = false
        try {
          sessionStorage.setItem(HINT_STORAGE_KEY, '1')
        } catch {
          /* ignore */
        }
      }, 1600)
    }
  } catch {
    /* ignore */
  }
})

onUnmounted(() => {
  dragging.value = false
  dragPointerId = null
  clearControlsHideTimer()
  if (hintTimer) {
    clearTimeout(hintTimer)
    hintTimer = null
  }
})
</script>

<template>
  <div
    v-if="visible && sub"
    class="psub-layer pointer-events-none absolute inset-x-0 z-[16] flex justify-center px-3"
    :class="positionClass"
  >
    <div
      class="psub-box"
      :class="[sizeClass, { 'is-dragging': dragging, 'is-controls': showControls }]"
      :style="dragStyle"
      :data-subtitle-context="sub.english"
      @pointerenter="revealControls"
      @pointerleave="scheduleHideControls()"
      @pointerdown="revealControls"
      @pointermove="onBoxPointerMove"
      @pointerup="onBoxPointerUp"
      @pointercancel="onBoxPointerUp"
    >
      <div
        class="psub-drag-handle"
        title="拖动字幕"
        aria-hidden="true"
        @pointerdown.stop="onDragStart"
        @pointermove="onDragMove"
        @pointerup="onDragEnd"
        @pointercancel="onDragEnd"
      >
        <span class="psub-drag-grip" />
      </div>
      <SubtitleBlock
        :english-html="englishHtml"
        :chinese="sub.chinese"
        :ipa="sub.ipa"
        :show-english="showEnglish"
        :show-chinese="showChinese"
        :show-ipa="false"
        align="center"
        @click="emit('click', $event)"
      />
    </div>
  </div>
</template>

<style scoped>
.psub-box {
  pointer-events: auto;
  max-width: min(94%, 60rem);
  background: rgba(0, 0, 0, 0.55);
  border-radius: 10px;
  padding: 0.3em 0.85em;
  position: relative;
  transform: translate(var(--subtitle-drag-x, 0px), var(--subtitle-drag-y, 0px));
  user-select: none;
  text-align: center;
  -webkit-backdrop-filter: blur(2px);
  backdrop-filter: blur(2px);
  transition: box-shadow 160ms ease;
}

.psub-box.is-dragging {
  box-shadow: 0 0 0 1px rgba(255, 255, 255, 0.25);
}

/* 顶部拖拽横杠：默认隐藏，悬停/触摸/拖动时才淡入 */
.psub-drag-handle {
  position: absolute;
  top: 0;
  left: 50%;
  z-index: 1;
  display: flex;
  justify-content: center;
  width: 3rem;
  height: 0.9rem;
  padding-top: 3px;
  transform: translateX(-50%);
  cursor: grab;
  touch-action: none;
  opacity: 0;
  transition: opacity 200ms ease;
}

.psub-box.is-controls .psub-drag-handle {
  opacity: 0.55;
}

.psub-box.is-dragging .psub-drag-handle {
  opacity: 0.95;
  cursor: grabbing;
}

.psub-drag-grip {
  width: 1.6rem;
  height: 2px;
  border-radius: 9999px;
  background: rgba(255, 255, 255, 0.6);
  transition: width 160ms ease, height 160ms ease;
}

.psub-box.is-dragging .psub-drag-grip {
  width: 2rem;
  height: 3px;
}

.psub-box :deep(.subtitle-english) {
  color: #22e3ff !important;
  font-weight: 900 !important;
  letter-spacing: 0.02em;
  line-height: 1.15;
}

.psub-box :deep(.subtitle-chinese) {
  color: #ffffff !important;
  font-weight: 500;
  line-height: 1.3;
  margin-top: 0.1em;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.7);
}

.psub-box.is-small :deep(.subtitle-english) {
  font-size: clamp(0.8rem, 2.8vw, 1.3rem);
}
.psub-box.is-small :deep(.subtitle-chinese) {
  font-size: clamp(0.68rem, 2.2vw, 1rem);
}

.psub-box.is-medium :deep(.subtitle-english) {
  font-size: clamp(1rem, 3.6vw, 1.75rem);
}
.psub-box.is-medium :deep(.subtitle-chinese) {
  font-size: clamp(0.8rem, 2.8vw, 1.25rem);
}

.psub-box.is-large :deep(.subtitle-english) {
  font-size: clamp(1.2rem, 4.6vw, 2.2rem);
}
.psub-box.is-large :deep(.subtitle-chinese) {
  font-size: clamp(0.95rem, 3.4vw, 1.5rem);
}
</style>
