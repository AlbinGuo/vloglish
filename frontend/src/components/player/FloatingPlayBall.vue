<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import AppIcon from '@/components/AppIcon.vue'
import type { usePlayerControls } from '@/composables/usePlayerControls'

const props = defineProps<{
  player: ReturnType<typeof usePlayerControls>
  hidden?: boolean
  /** 无字幕 / 视频加载中：禁用态 */
  disabled?: boolean
}>()

/* ───────────── 可配置常量（后续可提为 props） ───────────── */
const BALL_SIZE = 48 // 主球直径
const ACTION_SIZE = 40 // 上/下按钮直径
const GAP = 8 // 主球与上/下按钮的间距
const MARGIN = 8 // 吸附边距
const SWIPE_MIN_DIST = 18 // 判定为滑动的最小位移
const SWIPE_SPEED = 0.4 // 快速滑动速度阈值（px/ms，约 400px/s）
const DRAG_THRESHOLD = 40 // 位移超过该值进入拖动跟手
const MOVE_CANCEL = 10 // 视为「有位移」的阈值
const TAP_MAX = 12 // 位移小于该值视为单击
const MAX_NUDGE = 26 // 滑动时球体临时位移上限

const POS_KEY = 'teco-floating-ball-pos'
const GUIDE_KEY = 'teco-floating-ball-guide-done'

type Edge = 'left' | 'right'
interface SavedPos {
  edge: Edge
  centerY: number
}

function clamp(v: number, min: number, max: number) {
  return Math.min(max, Math.max(min, v))
}

function vibrate(pattern: number | number[]) {
  try {
    navigator.vibrate?.(pattern)
  } catch {
    /* ignore */
  }
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
const centerY = ref<number>(savedPos.centerY)

const vw = ref(typeof window !== 'undefined' ? window.innerWidth : 375)
const vh = ref(typeof window !== 'undefined' ? window.innerHeight : 667)

/* ───────────── 交互状态 ───────────── */
const pressed = ref(false)
const dragging = ref(false)
const swipeNudge = ref(0)
const replayFlash = ref(false)
const arrowFlash = ref<'' | 'left' | 'right'>('')

const guideActive = ref(false)
const guideStep = ref(0)
const guideCardRef = ref<HTMLElement | null>(null)
const guideCardHeight = ref(300)

const dragLeft = ref(0)
const dragBottom = ref(0)

const ballRef = ref<HTMLElement | null>(null)

const isPlaying = computed(() => props.player.isPlaying.value)
const disabled = computed(() => Boolean(props.disabled))

/* 手势临时变量 */
let pid: number | null = null
let startX = 0
let startY = 0
let startT = 0
let dragAnchorX = 0
let dragAnchorY = 0
let dragOriginLeft = 0
let dragOriginBottom = 0
let lastX = 0
let lastY = 0
let lastT = 0
let recentSpeed = 0
let moved = false
let dragActive = false
let replayTimer: ReturnType<typeof setTimeout> | null = null
let arrowTimer: ReturnType<typeof setTimeout> | null = null
let guideTimer: ReturnType<typeof setTimeout> | null = null

/* ───────────── 位置（全显示，无半隐藏） ───────────── */
const minBottomPx = computed(() => GAP + ACTION_SIZE + MARGIN)
const maxBottomPx = computed(() => vh.value - BALL_SIZE - GAP - ACTION_SIZE - MARGIN)

function currentRest(): { left: number; bottom: number } {
  const left = edge.value === 'right' ? vw.value - MARGIN - BALL_SIZE : MARGIN
  const rawBottom = vh.value - centerY.value * vh.value - BALL_SIZE / 2
  const bottom = clamp(rawBottom, minBottomPx.value, maxBottomPx.value)
  return { left, bottom }
}

const outerStyle = computed(() => {
  if (dragging.value) {
    return {
      left: `${dragLeft.value}px`,
      bottom: `${dragBottom.value}px`,
      transition: 'none',
    }
  }
  const rest = currentRest()
  return {
    left: `${rest.left}px`,
    bottom: `${rest.bottom}px`,
    transition: 'left .28s ease, bottom .28s ease',
  }
})

const ballStyle = computed(() => ({
  width: `${BALL_SIZE}px`,
  height: `${BALL_SIZE}px`,
  transform: `translateX(${swipeNudge.value}px) scale(${pressed.value ? 0.9 : 1})`,
  transition: 'transform .18s ease, opacity .2s ease',
  opacity: disabled.value ? 0.4 : pressed.value || dragging.value ? 1 : 0.82,
}))

const breathing = computed(
  () => isPlaying.value && !disabled.value && !pressed.value && !dragging.value && !guideActive.value,
)

/* ───────────── 动作 ───────────── */
function flashArrow(dir: 'left' | 'right') {
  arrowFlash.value = dir
  if (arrowTimer) clearTimeout(arrowTimer)
  arrowTimer = setTimeout(() => {
    arrowFlash.value = ''
    arrowTimer = null
  }, 300)
}

function doReplay() {
  if (disabled.value) return
  props.player.replayCurrentSentence()
  vibrate([0, 18, 60, 22])
  replayFlash.value = true
  if (replayTimer) clearTimeout(replayTimer)
  replayTimer = setTimeout(() => {
    replayFlash.value = false
    replayTimer = null
  }, 520)
}

function doPrev() {
  if (disabled.value) return
  props.player.prevSentence()
  vibrate(12)
  flashArrow('left')
}

function doNext() {
  if (disabled.value) return
  props.player.nextSentence()
  vibrate(12)
  flashArrow('right')
}

function persist() {
  try {
    localStorage.setItem(POS_KEY, JSON.stringify({ edge: edge.value, centerY: centerY.value }))
  } catch {
    /* ignore */
  }
}

/* ───────────── 指针手势 ───────────── */
function onPointerDown(e: PointerEvent) {
  if (props.hidden || disabled.value || guideActive.value) return
  const el = ballRef.value
  if (!el) return

  // 阻止移动端长按的原生选中 / 上下文菜单
  e.preventDefault()

  startX = e.clientX
  startY = e.clientY
  startT = performance.now()
  lastX = e.clientX
  lastY = e.clientY
  lastT = startT
  recentSpeed = 0
  moved = false
  dragActive = false
  pid = e.pointerId
  pressed.value = true
  swipeNudge.value = 0

  try {
    el.setPointerCapture(e.pointerId)
  } catch {
    /* ignore */
  }
}

function onPointerMove(e: PointerEvent) {
  if (pid === null || e.pointerId !== pid) return
  const dx = e.clientX - startX
  const dy = e.clientY - startY
  const dist = Math.hypot(dx, dy)

  // 追踪最近一段的瞬时速度，用于区分「快速滑动」与「慢速拖动」
  const now = performance.now()
  const dt = now - lastT
  if (dt > 0) {
    recentSpeed = Math.hypot(e.clientX - lastX, e.clientY - lastY) / dt
  }
  lastX = e.clientX
  lastY = e.clientY
  lastT = now

  if (!moved && dist > MOVE_CANCEL) moved = true
  if (!moved) return

  if (!dragActive && dist >= DRAG_THRESHOLD) {
    // 快速水平滑动视为切句意图，不进入拖动（球只做小幅回弹预览）
    const fastHorizontal =
      Math.abs(dx) > Math.abs(dy) * 1.2 && recentSpeed >= SWIPE_SPEED && dist >= SWIPE_MIN_DIST
    if (!fastHorizontal) {
      const el = ballRef.value
      if (el) {
        const rect = el.getBoundingClientRect()
        dragOriginLeft = rect.left
        dragOriginBottom = vh.value - rect.bottom
      }
      dragAnchorX = e.clientX
      dragAnchorY = e.clientY
      dragActive = true
      dragging.value = true
      pressed.value = false
      swipeNudge.value = 0
    }
  }

  if (dragActive) {
    dragLeft.value = clamp(
      dragOriginLeft + (e.clientX - dragAnchorX),
      MARGIN,
      vw.value - BALL_SIZE - MARGIN,
    )
    dragBottom.value = clamp(
      dragOriginBottom - (e.clientY - dragAnchorY),
      minBottomPx.value,
      maxBottomPx.value,
    )
    e.preventDefault()
  } else {
    swipeNudge.value = clamp(dx, -MAX_NUDGE, MAX_NUDGE)
  }
}

function onPointerUp(e: PointerEvent, cancelled = false) {
  if (pid === null || e.pointerId !== pid) return
  const el = ballRef.value
  try {
    if (el?.hasPointerCapture(e.pointerId)) el.releasePointerCapture(e.pointerId)
  } catch {
    /* ignore */
  }

  const dx = e.clientX - startX
  const dy = e.clientY - startY
  const dist = Math.hypot(dx, dy)
  const duration = Math.max(1, performance.now() - startT)
  const wasDrag = dragActive

  pid = null
  pressed.value = false

  if (cancelled) {
    dragging.value = false
    dragActive = false
    swipeNudge.value = 0
    return
  }

  // 快速水平滑动：优先判定为切句（无论位移多大）
  const avgSpeed = dist / duration
  const flickSpeed = Math.max(avgSpeed, recentSpeed)
  const horizontal = Math.abs(dx) > Math.abs(dy) * 1.2
  if (dist >= SWIPE_MIN_DIST && horizontal && flickSpeed >= SWIPE_SPEED) {
    // 取消拖动位移，球回弹到原位，再切换句子
    dragging.value = false
    dragActive = false
    swipeNudge.value = 0
    if (dx < 0) doPrev()
    else doNext()
    return
  }

  // 慢速拖动：移动悬浮球位置
  if (wasDrag) {
    const centerX = dragLeft.value + BALL_SIZE / 2
    edge.value = centerX < vw.value / 2 ? 'left' : 'right'
    centerY.value = clamp(
      (vh.value - dragBottom.value - BALL_SIZE / 2) / vh.value,
      0,
      1,
    )
    persist()
    dragging.value = false
    dragActive = false
    return
  }

  swipeNudge.value = 0
  dragActive = false

  // 轻点：重播当前句
  if (dist < TAP_MAX) {
    doReplay()
  }
}

/* ───────────── 引导 ───────────── */
const guideSteps = [
  { title: '单击', desc: '重播当前句子', icon: 'repeat' },
  { title: '左右滑动', desc: '左滑上一句 · 右滑下一句', icon: 'swipe-hint' },
  { title: '上下按钮', desc: '球上方切上一句 · 下方切下一句', icon: 'chevron-down' },
  { title: '拖动', desc: '按住拖动可移动悬浮球位置', icon: 'swipe-hint' },
]

function showGuide() {
  guideStep.value = 0
  guideActive.value = true
  // 严格「只显示一次」：展示即标记已引导
  try {
    localStorage.setItem(GUIDE_KEY, '1')
  } catch {
    /* ignore */
  }
}

function nextGuideStep() {
  if (guideStep.value < guideSteps.length - 1) {
    guideStep.value += 1
  } else {
    dismissGuide()
  }
}

function dismissGuide() {
  guideActive.value = false
  try {
    localStorage.setItem(GUIDE_KEY, '1')
  } catch {
    /* ignore */
  }
}

const guideBallCenter = computed(() => {
  const rest = currentRest()
  return { x: rest.left + BALL_SIZE / 2, y: vh.value - rest.bottom - BALL_SIZE / 2 }
})

const guideSpotStyle = computed(() => {
  const c = guideBallCenter.value
  const s = BALL_SIZE + 28
  return { left: `${c.x - s / 2}px`, top: `${c.y - s / 2}px`, width: `${s}px`, height: `${s}px` }
})

const guideCardStyle = computed(() => {
  const c = guideBallCenter.value
  const half = (BALL_SIZE + 28) / 2
  const gap = 14
  const h = guideCardHeight.value
  const topSpace = c.y - half - gap
  const bottomSpace = vh.value - (c.y + half) - gap
  if (topSpace >= h) return { bottom: `${vh.value - (c.y - half) + gap}px` }
  if (bottomSpace >= h) return { top: `${c.y + half + gap}px` }
  // 上下都放不下：竖直居中，避免超出屏幕
  return { top: `${Math.max(12, (vh.value - h) / 2)}px` }
})

/* ───────────── 生命周期 ───────────── */
function onResize() {
  vw.value = window.innerWidth
  vh.value = window.innerHeight
}

watch(
  () => props.hidden,
  (h) => {
    if (h) guideActive.value = false
  },
)

watch([guideActive, guideStep], async () => {
  if (!guideActive.value) return
  await nextTick()
  const el = guideCardRef.value
  if (el) guideCardHeight.value = el.getBoundingClientRect().height
})

onMounted(() => {
  onResize()
  window.addEventListener('resize', onResize)
  window.addEventListener('orientationchange', onResize)

  let done = false
  try {
    done = localStorage.getItem(GUIDE_KEY) === '1'
  } catch {
    /* ignore */
  }
  if (!done && !disabled.value) {
    guideTimer = setTimeout(() => {
      guideTimer = null
      if (!disabled.value && !props.hidden) showGuide()
    }, 600)
  }
})

onUnmounted(() => {
  window.removeEventListener('resize', onResize)
  window.removeEventListener('orientationchange', onResize)
  if (replayTimer) clearTimeout(replayTimer)
  if (arrowTimer) clearTimeout(arrowTimer)
  if (guideTimer) clearTimeout(guideTimer)
})
</script>

<template>
  <div
    v-show="!hidden"
    class="fb-root fixed z-30 select-none"
    :style="outerStyle"
    @selectstart.prevent
    @contextmenu.prevent
    @dragstart.prevent
  >
    <!-- 上一句（球上方） -->
    <button
      type="button"
      class="fb-action absolute flex touch-none items-center justify-center rounded-full border border-white/20 bg-neutral-900/85 text-white shadow-lg backdrop-blur-md active:scale-90 disabled:opacity-40"
      :style="{ left: `${(BALL_SIZE - ACTION_SIZE) / 2}px`, top: `${-(GAP + ACTION_SIZE)}px`, width: `${ACTION_SIZE}px`, height: `${ACTION_SIZE}px` }"
      :disabled="disabled"
      aria-label="上一句"
      title="上一句"
      @click.stop="doPrev"
      @contextmenu.prevent
      @selectstart.prevent
      @dragstart.prevent
    >
      <AppIcon name="chevron-down" class="h-5 w-5 rotate-180" />
    </button>

    <!-- 主球：重复当前句 -->
    <div class="fb-breathe" :class="{ 'fb-breathing': breathing }">
      <button
        ref="ballRef"
        type="button"
        class="fb-ball relative flex touch-none select-none items-center justify-center rounded-full border border-white/20 bg-neutral-900/75 text-white shadow-lg backdrop-blur-md"
        :class="dragging ? 'ring-2 ring-amber-400/70' : ''"
        :style="ballStyle"
        :aria-label="disabled ? '悬浮球不可用' : '重复当前句'"
        :aria-disabled="disabled"
        @pointerdown="onPointerDown"
        @pointermove="onPointerMove"
        @pointerup="onPointerUp($event)"
        @pointercancel="onPointerUp($event, true)"
        @contextmenu.prevent
        @selectstart.prevent
        @dragstart.prevent
      >
        <AppIcon name="repeat" class="h-6 w-6" :class="{ 'fb-replay-icon': replayFlash }" />

        <Transition name="fb-arrow">
          <span
            v-if="arrowFlash"
            class="pointer-events-none absolute inset-0 flex items-center justify-center rounded-full bg-amber-500/30"
          >
            <AppIcon
              :name="arrowFlash === 'left' ? 'chevron-left' : 'chevron-right'"
              class="h-6 w-6 text-white"
            />
          </span>
        </Transition>
      </button>
    </div>

    <!-- 下一句（球下方） -->
    <button
      type="button"
      class="fb-action absolute flex touch-none items-center justify-center rounded-full border border-white/20 bg-neutral-900/85 text-white shadow-lg backdrop-blur-md active:scale-90 disabled:opacity-40"
      :style="{ left: `${(BALL_SIZE - ACTION_SIZE) / 2}px`, top: `${BALL_SIZE + GAP}px`, width: `${ACTION_SIZE}px`, height: `${ACTION_SIZE}px` }"
      :disabled="disabled"
      aria-label="下一句"
      title="下一句"
      @click.stop="doNext"
      @contextmenu.prevent
      @selectstart.prevent
      @dragstart.prevent
    >
      <AppIcon name="chevron-down" class="h-5 w-5" />
    </button>
  </div>

  <!-- 首次使用引导 -->
  <Teleport to="body">
    <div v-if="guideActive" class="fixed inset-0 z-[70]">
      <div
        class="pointer-events-none fixed rounded-full ring-2 ring-amber-300/90"
        :style="[guideSpotStyle, { boxShadow: '0 0 0 9999px rgba(0,0,0,0.55)' }]"
      />
      <div class="absolute inset-0" @click.stop />
      <div
        ref="guideCardRef"
        class="fb-guide-card absolute left-1/2 w-[88vw] max-w-[320px] -translate-x-1/2 rounded-2xl bg-white p-4 shadow-2xl ring-1 ring-black/10 dark:bg-neutral-900 dark:ring-white/10"
        :style="guideCardStyle"
        @click.stop
      >
        <div class="flex items-center justify-between">
          <span class="text-[12px] text-ink-faint">
            引导 {{ guideStep + 1 }}/{{ guideSteps.length }}
          </span>
          <button type="button" class="text-[12px] text-ink-faint" @click="dismissGuide">不再提示</button>
        </div>

        <Transition name="fb-step" mode="out-in">
          <div :key="guideStep" class="mt-3">
            <!-- 操作动画演示 -->
            <div class="fb-demo" aria-hidden="true">
              <!-- 0 单击：重播 -->
              <template v-if="guideStep === 0">
                <div class="fb-demo-ball">
                  <AppIcon name="repeat" class="h-4 w-4" />
                </div>
                <span class="fb-demo-ripple" />
                <span class="fb-demo-finger" />
              </template>

              <!-- 1 左右滑动 -->
              <template v-else-if="guideStep === 1">
                <span class="fb-demo-chev fb-demo-chev-left">
                  <AppIcon name="chevron-left" class="h-5 w-5" />
                </span>
                <span class="fb-demo-chev fb-demo-chev-right">
                  <AppIcon name="chevron-right" class="h-5 w-5" />
                </span>
                <div class="fb-demo-ball fb-demo-swipe">
                  <AppIcon name="repeat" class="h-4 w-4" />
                </div>
              </template>

              <!-- 2 上下按钮 -->
              <template v-else-if="guideStep === 2">
                <div class="fb-demo-col">
                  <span class="fb-demo-btn fb-demo-btn-up">
                    <AppIcon name="chevron-down" class="h-4 w-4 rotate-180" />
                  </span>
                  <div class="fb-demo-ball">
                    <AppIcon name="repeat" class="h-4 w-4" />
                  </div>
                  <span class="fb-demo-btn fb-demo-btn-down">
                    <AppIcon name="chevron-down" class="h-4 w-4" />
                  </span>
                </div>
              </template>

              <!-- 3 拖动 -->
              <template v-else>
                <span class="fb-demo-ghost" />
                <div class="fb-demo-ball fb-demo-drag">
                  <AppIcon name="repeat" class="h-4 w-4" />
                </div>
              </template>
            </div>

            <div class="mt-2 text-center">
              <p class="text-[14px] font-semibold text-ink">{{ guideSteps[guideStep].title }}</p>
              <p class="mt-0.5 text-[12px] text-ink-soft">{{ guideSteps[guideStep].desc }}</p>
            </div>
          </div>
        </Transition>

        <div class="mt-3 flex items-center gap-1">
          <span
            v-for="i in guideSteps.length"
            :key="i"
            class="h-1.5 rounded-full transition-all"
            :class="i - 1 === guideStep ? 'w-4 bg-brand' : 'w-1.5 bg-neutral-300 dark:bg-neutral-600'"
          />
        </div>

        <div class="mt-4 flex items-center justify-between">
          <button type="button" class="text-[13px] text-ink-faint" @click="dismissGuide">跳过</button>
          <button
            type="button"
            class="rounded-full bg-brand px-4 py-1.5 text-[13px] font-medium text-white active:scale-95"
            @click="nextGuideStep"
          >
            {{ guideStep < guideSteps.length - 1 ? '下一步' : '开始使用' }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.fb-root {
  -webkit-user-select: none;
  user-select: none;
  -webkit-touch-callout: none;
  -webkit-tap-highlight-color: transparent;
  -webkit-user-drag: none;
  touch-action: none;
  outline: none;
}
.fb-root * {
  -webkit-user-select: none;
  user-select: none;
  -webkit-touch-callout: none;
  -webkit-user-drag: none;
}

.fb-breathe {
  display: inline-block;
}
.fb-breathing {
  animation: fb-breathe 2.6s ease-in-out infinite;
}
@keyframes fb-breathe {
  0%,
  100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.03);
  }
}

.fb-replay-icon {
  animation: fb-spin 0.7s linear infinite;
}
@keyframes fb-spin {
  to {
    transform: rotate(360deg);
  }
}

.fb-arrow-enter-active,
.fb-arrow-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}
.fb-arrow-enter-from,
.fb-arrow-leave-to {
  opacity: 0;
  transform: scale(0.7);
}

.fb-guide-card {
  animation: fb-guide-in 0.2s ease-out;
}
@keyframes fb-guide-in {
  from {
    opacity: 0;
    transform: translate(-50%, 6px);
  }
  to {
    opacity: 1;
    transform: translate(-50%, 0);
  }
}

/* ───── 新手引导：操作动画演示 ───── */
.fb-demo {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 116px;
  overflow: hidden;
}
.fb-demo-ball {
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: 9999px;
  background: #52525b;
  color: #fff;
  box-shadow: 0 6px 14px rgba(0, 0, 0, 0.25);
  outline: 2px solid rgba(255, 255, 255, 0.15);
}

/* 单击 */
.fb-demo-finger {
  position: absolute;
  top: 22px;
  left: 50%;
  width: 14px;
  height: 14px;
  margin-left: -7px;
  border-radius: 9999px;
  background: #f59e0b;
  box-shadow: 0 0 0 4px rgba(245, 158, 11, 0.25);
  animation: fbTapFinger 1.9s ease-in-out infinite;
}
.fb-demo-ripple {
  position: absolute;
  left: 50%;
  top: 50%;
  width: 36px;
  height: 36px;
  margin: -18px 0 0 -18px;
  border-radius: 9999px;
  border: 2px solid rgba(245, 158, 11, 0.85);
  animation: fbTapRipple 1.9s ease-out infinite;
}
@keyframes fbTapFinger {
  0%,
  18% {
    transform: translateY(-16px);
    opacity: 0.3;
  }
  40%,
  55% {
    transform: translateY(0);
    opacity: 1;
  }
  72%,
  100% {
    transform: translateY(-16px);
    opacity: 0;
  }
}
@keyframes fbTapRipple {
  0%,
  38% {
    transform: scale(0.85);
    opacity: 0;
  }
  46% {
    transform: scale(1);
    opacity: 0.9;
  }
  80%,
  100% {
    transform: scale(2);
    opacity: 0;
  }
}

/* 左右滑动 */
.fb-demo-chev {
  position: absolute;
  top: 50%;
  margin-top: -10px;
  color: #f59e0b;
}
.fb-demo-chev-left {
  left: calc(50% - 56px);
  animation: fbChevLeft 2.6s ease-in-out infinite;
}
.fb-demo-chev-right {
  right: calc(50% - 56px);
  animation: fbChevRight 2.6s ease-in-out infinite;
}
@keyframes fbChevLeft {
  0%,
  8%,
  46%,
  100% {
    opacity: 0;
  }
  18%,
  34% {
    opacity: 1;
  }
}
@keyframes fbChevRight {
  0%,
  54%,
  92%,
  100% {
    opacity: 0;
  }
  64%,
  80% {
    opacity: 1;
  }
}
.fb-demo-swipe {
  animation: fbSwipeX 2.6s ease-in-out infinite;
}
@keyframes fbSwipeX {
  0%,
  8% {
    transform: translateX(0);
  }
  26% {
    transform: translateX(-26px);
  }
  46% {
    transform: translateX(0);
  }
  66% {
    transform: translateX(26px);
  }
  88%,
  100% {
    transform: translateX(0);
  }
}

/* 上下按钮 */
.fb-demo-col {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}
.fb-demo-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  border-radius: 9999px;
  background: #52525b;
  color: #fff;
}
.fb-demo-btn-up {
  animation: fbBtnUp 2.4s ease-in-out infinite;
}
.fb-demo-btn-down {
  animation: fbBtnDown 2.4s ease-in-out infinite;
}
@keyframes fbBtnUp {
  0%,
  100% {
    transform: scale(1);
    box-shadow: 0 0 0 0 rgba(245, 158, 11, 0);
  }
  20% {
    transform: scale(1.14);
    box-shadow: 0 0 0 5px rgba(245, 158, 11, 0.35);
  }
  44% {
    transform: scale(1);
    box-shadow: 0 0 0 0 rgba(245, 158, 11, 0);
  }
}
@keyframes fbBtnDown {
  0%,
  52%,
  100% {
    transform: scale(1);
    box-shadow: 0 0 0 0 rgba(245, 158, 11, 0);
  }
  70% {
    transform: scale(1.14);
    box-shadow: 0 0 0 5px rgba(245, 158, 11, 0.35);
  }
  90% {
    transform: scale(1);
    box-shadow: 0 0 0 0 rgba(245, 158, 11, 0);
  }
}

/* 拖动 */
.fb-demo-ghost {
  position: absolute;
  left: 50%;
  top: 50%;
  width: 36px;
  height: 36px;
  margin: -18px 0 0 -18px;
  border-radius: 9999px;
  border: 2px dashed rgba(130, 130, 140, 0.65);
}
.fb-demo-drag {
  animation: fbDragPath 2.8s ease-in-out infinite;
}
@keyframes fbDragPath {
  0%,
  100% {
    transform: translate(0, 0);
  }
  30% {
    transform: translate(34px, -22px);
  }
  60% {
    transform: translate(-14px, 18px);
  }
  80% {
    transform: translate(0, 0);
  }
}

/* 步骤切换淡入 */
.fb-step-enter-active,
.fb-step-leave-active {
  transition: opacity 0.18s ease, transform 0.18s ease;
}
.fb-step-enter-from,
.fb-step-leave-to {
  opacity: 0;
  transform: translateY(6px);
}

@media (prefers-reduced-motion: reduce) {
  .fb-demo * {
    animation: none !important;
  }
}
</style>
