<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue'
import AppIcon from '@/components/AppIcon.vue'
import type { usePlayerControls } from '@/composables/usePlayerControls'

const props = defineProps<{
  player: ReturnType<typeof usePlayerControls>
  hidden?: boolean
}>()

/** 主球尺寸 / 快捷按钮尺寸 / 间距 */
const SIZE = 56
const TOGGLE = 28
const ACTION = 44
const GAP = 8
/** 展开时向球体上方延伸的高度（用于避让顶部） */
const EXPAND_EXTRA = TOGGLE + ACTION * 3 + GAP * 3
const MIN_TOP = 12
const MIN_BOTTOM = 12
const MIN_LR = 8

const POS_KEY = 'teco-floating-ball-pos'
const HINT_KEY = 'teco-floating-ball-hint-shown'

type Edge = 'left' | 'right'
interface SavedPos {
  edge: Edge
  centerY: number
}

function clamp(v: number, min: number, max: number) {
  return Math.min(max, Math.max(min, v))
}

function loadSaved(): SavedPos {
  try {
    const raw = localStorage.getItem(POS_KEY)
    if (raw) {
      const parsed = JSON.parse(raw) as Partial<SavedPos>
      return {
        edge: parsed.edge === 'left' ? 'left' : 'right',
        centerY: Number.isFinite(parsed.centerY) ? Number(parsed.centerY) : 0.62,
      }
    }
  } catch {
    /* ignore */
  }
  return { edge: 'right', centerY: 0.62 }
}

const savedPos = loadSaved()
const edge = ref<Edge>(savedPos.edge)
/** 主球中心相对视口高度的比例 */
const centerY = ref<number>(savedPos.centerY)

const vw = ref(typeof window !== 'undefined' ? window.innerWidth : 375)
const vh = ref(typeof window !== 'undefined' ? window.innerHeight : 667)

const expanded = ref(false)
const dragging = ref(false)
const showHint = ref(false)

// 拖拽临时像素位置
const dragLeft = ref(0)
const dragBottom = ref(0)

let pointerId: number | null = null
let startX = 0
let startY = 0
let grabRectLeft = 0
let grabRectBottom = 0
let moved = false

const ballRef = ref<HTMLElement | null>(null)

const isPlaying = computed(() => props.player.isPlaying.value)

const minRatio = computed(() => (MIN_TOP + SIZE / 2 + EXPAND_EXTRA) / vh.value)
const maxRatio = computed(() => (vh.value - MIN_BOTTOM - SIZE / 2) / vh.value)

const widgetStyle = computed(() => {
  if (dragging.value) {
    return { left: `${dragLeft.value}px`, bottom: `${dragBottom.value}px` }
  }
  const ratio = clamp(centerY.value, minRatio.value, maxRatio.value)
  const left = edge.value === 'left' ? MIN_LR : vw.value - MIN_LR - SIZE
  const bottom = vh.value - ratio * vh.value - SIZE / 2
  return { left: `${left}px`, bottom: `${bottom}px` }
})

function persist() {
  try {
    localStorage.setItem(POS_KEY, JSON.stringify({ edge: edge.value, centerY: centerY.value }))
  } catch {
    /* ignore */
  }
}

let collapseTimer: ReturnType<typeof setTimeout> | null = null
function clearCollapseTimer() {
  if (collapseTimer) {
    clearTimeout(collapseTimer)
    collapseTimer = null
  }
}
/** 播放中展开后，静置一段时间自动收起，减少遮挡 */
function scheduleAutoCollapse() {
  clearCollapseTimer()
  if (!expanded.value) return
  collapseTimer = setTimeout(() => {
    if (expanded.value && isPlaying.value) expanded.value = false
    collapseTimer = null
  }, 4000)
}

function onAnyInteraction() {
  scheduleAutoCollapse()
}

function toggleExpanded() {
  expanded.value = !expanded.value
  if (expanded.value) scheduleAutoCollapse()
  else clearCollapseTimer()
  markHintSeen()
}

function togglePlayPause() {
  props.player.togglePlay()
  onAnyInteraction()
}

function prevSentence() {
  props.player.prevSentence()
  onAnyInteraction()
}

function nextSentence() {
  props.player.nextSentence()
  onAnyInteraction()
}

function replay() {
  props.player.replayCurrentSentence()
  onAnyInteraction()
}

function markHintSeen() {
  if (!showHint.value) return
  showHint.value = false
  try {
    localStorage.setItem(HINT_KEY, '1')
  } catch {
    /* ignore */
  }
}

function onPointerDown(e: PointerEvent) {
  if (props.hidden) return
  const el = ballRef.value
  if (!el) return
  const rect = el.getBoundingClientRect()
  startX = e.clientX
  startY = e.clientY
  grabRectLeft = rect.left
  grabRectBottom = vh.value - rect.bottom
  moved = false
  pointerId = e.pointerId
  try {
    el.setPointerCapture(e.pointerId)
  } catch {
    /* ignore */
  }
}

function onPointerMove(e: PointerEvent) {
  if (pointerId == null || e.pointerId !== pointerId) return
  const dx = e.clientX - startX
  const dy = e.clientY - startY
  if (!moved && Math.hypot(dx, dy) > 6) {
    moved = true
    dragging.value = true
    dragLeft.value = grabRectLeft
    dragBottom.value = grabRectBottom
  }
  if (!moved) return
  dragLeft.value = clamp(grabRectLeft + dx, MIN_LR, vw.value - SIZE - MIN_LR)
  dragBottom.value = clamp(grabRectBottom - dy, MIN_BOTTOM, vh.value - SIZE - MIN_BOTTOM)
  e.preventDefault()
}

function onPointerUp(e: PointerEvent) {
  if (pointerId == null || e.pointerId !== pointerId) return
  const el = ballRef.value
  if (el) {
    try {
      if (el.hasPointerCapture(e.pointerId)) el.releasePointerCapture(e.pointerId)
    } catch {
      /* ignore */
    }
  }
  pointerId = null
  if (moved) {
    const centerX = dragLeft.value + SIZE / 2
    edge.value = centerX < vw.value / 2 ? 'left' : 'right'
    centerY.value = clamp(
      (vh.value - dragBottom.value - SIZE / 2) / vh.value,
      minRatio.value,
      maxRatio.value,
    )
    persist()
    dragging.value = false
    markHintSeen()
    return
  }
  // 单击（未拖动）：播放 / 暂停
  togglePlayPause()
  markHintSeen()
}

function onResize() {
  vw.value = window.innerWidth
  vh.value = window.innerHeight
}

onMounted(() => {
  onResize()
  window.addEventListener('resize', onResize)
  window.addEventListener('orientationchange', onResize)
  try {
    if (localStorage.getItem(HINT_KEY) !== '1') {
      showHint.value = true
      window.setTimeout(() => {
        showHint.value = false
      }, 5200)
    }
  } catch {
    /* ignore */
  }
})

onUnmounted(() => {
  window.removeEventListener('resize', onResize)
  window.removeEventListener('orientationchange', onResize)
  clearCollapseTimer()
})
</script>

<template>
  <div
    v-show="!hidden"
    class="fixed z-30 select-none"
    :style="widgetStyle"
    aria-live="off"
  >
    <div class="flex flex-col items-center" :style="{ gap: `${GAP}px` }">
      <!-- 展开/收起把手 -->
      <button
        type="button"
        class="flex items-center justify-center rounded-full border border-white/15 bg-neutral-900/70 text-white/90 shadow-md backdrop-blur-md transition active:scale-95"
        :style="{ width: `${TOGGLE}px`, height: `${TOGGLE}px` }"
        :aria-label="expanded ? '收起快捷操作' : '展开快捷操作'"
        :aria-expanded="expanded"
        @click.stop="toggleExpanded"
      >
        <AppIcon
          name="chevron-down"
          class="h-3.5 w-3.5 transition-transform duration-200"
          :class="expanded ? 'rotate-0' : 'rotate-180'"
        />
      </button>

      <!-- 展开后的快捷操作 -->
      <template v-if="expanded">
        <button
          type="button"
          class="flex items-center justify-center rounded-full border border-white/15 bg-neutral-900/85 text-white shadow-md backdrop-blur-md transition active:scale-95"
          :style="{ width: `${ACTION}px`, height: `${ACTION}px` }"
          aria-label="上一句"
          title="上一句"
          @click.stop="prevSentence"
        >
          <AppIcon name="chevron-down" class="h-5 w-5 rotate-180" />
        </button>
        <button
          type="button"
          class="flex items-center justify-center rounded-full border border-white/15 bg-neutral-900/85 text-white shadow-md backdrop-blur-md transition active:scale-95"
          :style="{ width: `${ACTION}px`, height: `${ACTION}px` }"
          aria-label="重播当前句"
          title="重播当前句"
          @click.stop="replay"
        >
          <AppIcon name="repeat" class="h-5 w-5" />
        </button>
        <button
          type="button"
          class="flex items-center justify-center rounded-full border border-white/15 bg-neutral-900/85 text-white shadow-md backdrop-blur-md transition active:scale-95"
          :style="{ width: `${ACTION}px`, height: `${ACTION}px` }"
          aria-label="下一句"
          title="下一句"
          @click.stop="nextSentence"
        >
          <AppIcon name="chevron-down" class="h-5 w-5" />
        </button>
      </template>

      <!-- 主球：点击播放/暂停，拖动移动 -->
      <button
        ref="ballRef"
        type="button"
        class="relative flex touch-none items-center justify-center rounded-full border border-white/20 text-white shadow-lg backdrop-blur-md transition-colors"
        :class="[
          isPlaying ? 'bg-neutral-900/75' : 'bg-neutral-900/90',
          dragging ? 'scale-105 ring-2 ring-amber-400/70' : '',
        ]"
        :style="{ width: `${SIZE}px`, height: `${SIZE}px` }"
        :aria-label="isPlaying ? '暂停' : '播放'"
        @pointerdown="onPointerDown"
        @pointermove="onPointerMove"
        @pointerup="onPointerUp"
        @pointercancel="onPointerUp"
      >
        <AppIcon v-if="isPlaying" name="pause" class="h-6 w-6" />
        <AppIcon v-else name="play" class="ml-0.5 h-6 w-6" />
      </button>

      <!-- 首次使用提示 -->
      <Transition name="fb-hint-fade">
        <div
          v-if="showHint"
          class="pointer-events-none absolute -top-2 whitespace-nowrap rounded-full bg-neutral-900/90 px-2.5 py-1 text-[11px] text-white shadow-md"
          :style="edge === 'left' ? { left: `${SIZE + 6}px`, top: '50%' } : { right: `${SIZE + 6}px`, top: '50%' }"
        >
          拖动可换边 · 点击暂停/播放
        </div>
      </Transition>
    </div>
  </div>
</template>

<style scoped>
.fb-hint-fade-enter-active,
.fb-hint-fade-leave-active {
  transition: opacity 0.25s ease;
}
.fb-hint-fade-enter-from,
.fb-hint-fade-leave-to {
  opacity: 0;
}
</style>
