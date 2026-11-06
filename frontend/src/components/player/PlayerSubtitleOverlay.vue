<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from 'vue'
import SubtitleBlock from '@/components/SubtitleBlock.vue'
import AppIcon from '@/components/AppIcon.vue'
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
  close: []
}>()

const DRAG_STORAGE_KEY = 'teco-player-subtitle-drag-offset'

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
  () => props.position,
  () => {
    dragOffset.value = { x: 0, y: 0 }
  },
)

function onDragStart(e: PointerEvent) {
  if (e.button !== 0 || (e.target instanceof Element && e.target.closest('button, .subtitle-english, .subtitle-chinese, .subtitle-ipa'))) return
  dragging.value = true
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
}

onUnmounted(() => {
  dragging.value = false
  dragPointerId = null
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
      :class="[sizeClass, { 'is-dragging': dragging }]"
      :style="dragStyle"
      :data-subtitle-context="sub.english"
    >
      <div
        class="psub-drag-handle"
        title="拖动字幕"
        @pointerdown="onDragStart"
        @pointermove="onDragMove"
        @pointerup="onDragEnd"
        @pointercancel="onDragEnd"
      />
      <button
        type="button"
        class="psub-close"
        aria-label="关闭字幕"
        title="关闭字幕"
        @pointerdown.stop
        @click.stop="emit('close')"
      >
        <AppIcon name="close" :size="12" />
      </button>
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
  /* 空白处点击穿透到播放器分区（单词 span 自带 pointer-events-auto 仍可点击查词） */
  pointer-events: none;
  max-width: min(94%, 60rem);
  background: rgba(0, 0, 0, 0.55);
  border-radius: 10px;
  padding: 0.3em 0.85em;
  position: relative;
  transform: translate(var(--subtitle-drag-x, 0px), var(--subtitle-drag-y, 0px));
  touch-action: none;
  cursor: grab;
  user-select: none;
  text-align: center;
  -webkit-backdrop-filter: blur(2px);
  backdrop-filter: blur(2px);
}

.psub-box.is-dragging {
  cursor: grabbing;
}

.psub-drag-handle {
  position: absolute;
  top: 0;
  left: 50%;
  z-index: 1;
  width: 3.5rem;
  height: 0.7rem;
  transform: translateX(-50%);
  cursor: grab;
  pointer-events: auto;
}

.psub-drag-handle::after {
  content: '';
  position: absolute;
  top: 3px;
  left: 50%;
  width: 1.8rem;
  height: 2px;
  transform: translateX(-50%);
  border-radius: 9999px;
  background: rgba(255, 255, 255, 0.42);
}

.psub-close {
  position: absolute;
  z-index: 2;
  top: 2px;
  right: 3px;
  display: inline-flex;
  width: 19px;
  height: 19px;
  align-items: center;
  justify-content: center;
  border-radius: 9999px;
  color: rgba(255, 255, 255, 0.58);
  background: rgba(0, 0, 0, 0.16);
  pointer-events: auto;
  opacity: 0.72;
  transition: opacity 120ms ease, background-color 120ms ease;
}

.psub-close:hover {
  opacity: 1;
  background: rgba(0, 0, 0, 0.4);
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
