<script setup lang="ts">
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'

const emit = defineEmits<{ close: [] }>()

const STORAGE_KEY = 'teco-player-mask-rect'
const MIN_W = 12
const MIN_H = 10

type Rect = { left: number; top: number; width: number; height: number }

function clampRect(r: Rect): Rect {
  const width = Math.min(100, Math.max(MIN_W, r.width))
  const height = Math.min(100, Math.max(MIN_H, r.height))
  const left = Math.min(100 - width, Math.max(0, r.left))
  const top = Math.min(100 - height, Math.max(0, r.top))
  return { left, top, width, height }
}

function loadRect(): Rect {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (raw) {
      const r = JSON.parse(raw) as Partial<Rect>
      if ([r.left, r.top, r.width, r.height].every((n) => typeof n === 'number' && Number.isFinite(n))) {
        return clampRect(r as Rect)
      }
    }
  } catch {
    /* ignore */
  }
  return { left: 18, top: 64, width: 64, height: 22 }
}

const rect = reactive<Rect>(loadRect())
const rootRef = ref<HTMLElement | null>(null)
const hintVisible = ref(true)
let hintTimer: ReturnType<typeof setTimeout> | null = null

const style = computed(() => ({
  left: `${rect.left}%`,
  top: `${rect.top}%`,
  width: `${rect.width}%`,
  height: `${rect.height}%`,
}))

function persistRect() {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify({ ...rect }))
  } catch {
    /* ignore */
  }
}

type Mode = 'move' | 'nw' | 'ne' | 'sw' | 'se'

interface DragState {
  mode: Mode
  startX: number
  startY: number
  startRect: Rect
  parentW: number
  parentH: number
}

let drag: DragState | null = null

function parentMetrics() {
  const parent = rootRef.value?.parentElement
  const r = parent?.getBoundingClientRect()
  return { w: r?.width || 1, h: r?.height || 1 }
}

function onPointerDown(e: PointerEvent, mode: Mode) {
  if (e.pointerType === 'mouse' && e.button !== 0) return
  e.preventDefault()
  e.stopPropagation()
  const { w, h } = parentMetrics()
  drag = {
    mode,
    startX: e.clientX,
    startY: e.clientY,
    startRect: { ...rect },
    parentW: w,
    parentH: h,
  }
  window.addEventListener('pointermove', onPointerMove)
  window.addEventListener('pointerup', onPointerUp)
  window.addEventListener('pointercancel', onPointerUp)
}

function clamp(v: number, min: number, max: number) {
  return Math.min(max, Math.max(min, v))
}

function applyResize(mode: Mode, s: Rect, dxPct: number, dyPct: number): Rect {
  if (mode === 'move') {
    return {
      left: clamp(s.left + dxPct, 0, 100 - s.width),
      top: clamp(s.top + dyPct, 0, 100 - s.height),
      width: s.width,
      height: s.height,
    }
  }
  let left = s.left
  let top = s.top
  let width = s.width
  let height = s.height
  const right = s.left + s.width
  const bottom = s.top + s.height
  if (mode.includes('e')) width = clamp(s.width + dxPct, MIN_W, 100 - s.left)
  if (mode.includes('s')) height = clamp(s.height + dyPct, MIN_H, 100 - s.top)
  if (mode.includes('w')) {
    const newLeft = clamp(s.left + dxPct, 0, right - MIN_W)
    width = right - newLeft
    left = newLeft
  }
  if (mode.includes('n')) {
    const newTop = clamp(s.top + dyPct, 0, bottom - MIN_H)
    height = bottom - newTop
    top = newTop
  }
  return { left, top, width, height }
}

function onPointerMove(e: PointerEvent) {
  if (!drag) return
  const dxPct = ((e.clientX - drag.startX) / drag.parentW) * 100
  const dyPct = ((e.clientY - drag.startY) / drag.parentH) * 100
  Object.assign(rect, applyResize(drag.mode, drag.startRect, dxPct, dyPct))
}

function detach() {
  window.removeEventListener('pointermove', onPointerMove)
  window.removeEventListener('pointerup', onPointerUp)
  window.removeEventListener('pointercancel', onPointerUp)
}

function onPointerUp() {
  const wasDragging = Boolean(drag)
  drag = null
  detach()
  if (wasDragging) persistRect()
}

function startHint() {
  hintVisible.value = true
  if (hintTimer) clearTimeout(hintTimer)
  hintTimer = setTimeout(() => {
    hintVisible.value = false
    hintTimer = null
  }, 7000)
}

onMounted(startHint)
onUnmounted(() => {
  if (hintTimer) clearTimeout(hintTimer)
  detach()
})
</script>

<template>
  <div
    ref="rootRef"
    data-swipe-back-ignore
    class="pmask absolute z-[34] select-none touch-none"
    :style="style"
    @pointerdown="onPointerDown($event, 'move')"
  >
    <div class="pmask__panel pointer-events-none absolute inset-0" />

    <span class="pmask__corner pmask__corner--tl" @pointerdown.stop="onPointerDown($event, 'nw')" />
    <span class="pmask__corner pmask__corner--tr" @pointerdown.stop="onPointerDown($event, 'ne')" />
    <span class="pmask__corner pmask__corner--bl" @pointerdown.stop="onPointerDown($event, 'sw')" />
    <span class="pmask__corner pmask__corner--br" @pointerdown.stop="onPointerDown($event, 'se')" />

    <button
      type="button"
      class="pmask__close"
      title="关闭遮挡板"
      aria-label="关闭遮挡板"
      @pointerdown.stop
      @click.stop="emit('close')"
    >
      <svg class="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" d="M6 6l12 12M18 6L6 18" />
      </svg>
    </button>

    <transition name="pmask-fade">
      <div v-if="hintVisible" class="pmask__hint">可拖动调整遮挡区域</div>
    </transition>
  </div>
</template>

<style scoped>
.pmask {
  cursor: move;
}

.pmask__panel {
  border-radius: 6px;
  background: rgba(8, 16, 20, 0.88);
  box-shadow:
    0 8px 30px rgba(0, 0, 0, 0.45),
    inset 0 0 0 1px rgba(255, 255, 255, 0.08);
  -webkit-backdrop-filter: blur(16px) saturate(120%);
  backdrop-filter: blur(16px) saturate(120%);
}

.pmask__corner {
  position: absolute;
  width: 16px;
  height: 16px;
  box-sizing: border-box;
  border-color: #ffffff;
  border-style: solid;
  border-width: 0;
  filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.6));
  pointer-events: auto;
}

.pmask__corner--tl {
  top: -2px;
  left: -2px;
  border-top-width: 2.5px;
  border-left-width: 2.5px;
  cursor: nwse-resize;
}
.pmask__corner--tr {
  top: -2px;
  right: -2px;
  border-top-width: 2.5px;
  border-right-width: 2.5px;
  cursor: nesw-resize;
}
.pmask__corner--bl {
  bottom: -2px;
  left: -2px;
  border-bottom-width: 2.5px;
  border-left-width: 2.5px;
  cursor: nesw-resize;
}
.pmask__corner--br {
  bottom: -2px;
  right: -2px;
  border-bottom-width: 2.5px;
  border-right-width: 2.5px;
  cursor: nwse-resize;
}

.pmask__close {
  position: absolute;
  top: 6px;
  right: 16px;
  display: flex;
  height: 24px;
  width: 24px;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  border: 1px solid rgba(255, 255, 255, 0.28);
  background: rgba(255, 255, 255, 0.1);
  color: rgba(255, 255, 255, 0.82);
  cursor: pointer;
  transition: background-color 0.15s ease, color 0.15s ease;
}
.pmask__close:hover {
  background: rgba(255, 255, 255, 0.2);
  color: #ffffff;
}

.pmask__hint {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 2.5rem;
  text-align: center;
  font-size: 13px;
  letter-spacing: 0.04em;
  color: rgba(255, 255, 255, 0.72);
  pointer-events: none;
  user-select: none;
}

.pmask-fade-enter-active,
.pmask-fade-leave-active {
  transition: opacity 0.4s ease;
}
.pmask-fade-enter-from,
.pmask-fade-leave-to {
  opacity: 0;
}
</style>
