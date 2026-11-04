<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import AppIcon from '@/components/AppIcon.vue'
import type { usePlayerControls } from '@/composables/usePlayerControls'

const props = defineProps<{
  player: ReturnType<typeof usePlayerControls>
  hidden?: boolean
  /** 无字幕 / 视频加载中：禁用态 */
  disabled?: boolean
}>()

/* ───────────── 可配置常量（后续可提为 props） ───────────── */
const BALL_SIZE = 48 // dp
const SWIPE_THRESHOLD = 24 // 判定为滑动的最小水平位移
const DRAG_THRESHOLD = 40 // 位移超过即进入拖动
const MOVE_CANCEL = 10 // 明显位移阈值：超过则取消长按
const MAX_NUDGE = 26 // 滑动时球体临时位移上限
const LONG_PRESS_MS = 400
const DOUBLE_TAP_MS = 300
const MENU_RADIUS = 70 // 径向菜单半径
const MENU_BTN = 40 // 菜单按钮尺寸
const MENU_CLEARANCE = MENU_RADIUS + MENU_BTN / 2 // 菜单展开时需要的边距
const MARGIN = 8 // 吸附边距
const MIN_BOTTOM = 12
const HALF_HIDE_RATIO = 0.65 // 半隐藏时露出比例

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
const interacting = ref(false)
const dragging = ref(false)
const swipeNudge = ref(0)
const spinning = ref(false)
const replayFlash = ref(false)
const arrowFlash = ref<'' | 'left' | 'right'>('')
const menuOpen = ref(false)

const guideActive = ref(false)
const guideStep = ref(0)

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
let moved = false
let dragActive = false
let longPressFired = false
let longPressTimer: ReturnType<typeof setTimeout> | null = null
let singleTapTimer: ReturnType<typeof setTimeout> | null = null
let lastTapAt = 0
let spinTimer: ReturnType<typeof setTimeout> | null = null
let replayTimer: ReturnType<typeof setTimeout> | null = null
let arrowTimer: ReturnType<typeof setTimeout> | null = null
let guideTimer: ReturnType<typeof setTimeout> | null = null

/* ───────────── 位置与半隐藏 ───────────── */
const minRatio = computed(() => (MENU_CLEARANCE + MARGIN + 4) / vh.value)
const maxRatio = computed(() => (vh.value - MENU_CLEARANCE - MARGIN - 4) / vh.value)

const revealed = computed(
  () => interacting.value || dragging.value || menuOpen.value || guideActive.value,
)

function currentRest(): { left: number; bottom: number } {
  const ratio = clamp(centerY.value, minRatio.value, maxRatio.value)
  const left = edge.value === 'right' ? vw.value - MARGIN - BALL_SIZE : MARGIN
  const bottom = vh.value - ratio * vh.value - BALL_SIZE / 2
  return { left, bottom }
}

const hiddenShift = computed(() => {
  if (revealed.value) return 0
  const rest = currentRest()
  const anchor =
    edge.value === 'right'
      ? vw.value - Math.round(BALL_SIZE * HALF_HIDE_RATIO)
      : -Math.round(BALL_SIZE * (1 - HALF_HIDE_RATIO))
  return anchor - rest.left
})

const outerStyle = computed(() => {
  if (dragging.value) {
    return {
      left: `${dragLeft.value}px`,
      bottom: `${dragBottom.value}px`,
      transform: 'none',
      transition: 'none',
    }
  }
  const rest = currentRest()
  const shift = hiddenShift.value
  const style: Record<string, string> = {
    left: `${rest.left}px`,
    bottom: `${rest.bottom}px`,
    transition: 'left .28s ease, bottom .28s ease, transform .25s ease',
  }
  // 仅在真正半隐藏时加 transform：避免 transform: translateX(0) 让
  // 内部 fixed 遮罩以 48px 容器为参照而非全屏
  if (shift !== 0) style.transform = `translateX(${shift}px)`
  return style
})

const ballStyle = computed(() => ({
  width: `${BALL_SIZE}px`,
  height: `${BALL_SIZE}px`,
  transform: `translateX(${swipeNudge.value}px) scale(${pressed.value ? 0.9 : 1})`,
  transition: 'transform .18s ease, opacity .2s ease',
  opacity: disabled.value ? 0.4 : pressed.value || dragging.value || menuOpen.value ? 0.96 : 0.75,
}))

const breathing = computed(
  () =>
    isPlaying.value &&
    !disabled.value &&
    !interacting.value &&
    !dragging.value &&
    !menuOpen.value &&
    !guideActive.value,
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

function doToggle() {
  props.player.togglePlay()
  vibrate(10)
}

function doReplay() {
  props.player.replayCurrentSentence()
  vibrate([0, 18, 60, 22])
  spinning.value = true
  replayFlash.value = true
  if (spinTimer) clearTimeout(spinTimer)
  if (replayTimer) clearTimeout(replayTimer)
  spinTimer = setTimeout(() => {
    spinning.value = false
    spinTimer = null
  }, 520)
  replayTimer = setTimeout(() => {
    replayFlash.value = false
    replayTimer = null
  }, 620)
}

function doPrev() {
  props.player.prevSentence()
  vibrate(12)
  flashArrow('left')
}

function doNext() {
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

/* ───────────── 菜单 ───────────── */
function openMenu() {
  menuOpen.value = true
  vibrate([0, 22])
}

function closeMenu() {
  menuOpen.value = false
}

const menuButtons = computed(() => {
  const sign = edge.value === 'right' ? -1 : 1
  const playing = isPlaying.value
  const defs: { key: string; angle: number; icon: string; label: string }[] = [
    { key: 'replay', angle: -60, icon: 'repeat', label: '重播当前句' },
    { key: 'prev', angle: -22, icon: 'chevron-left', label: '上一句' },
    { key: 'next', angle: 22, icon: 'chevron-right', label: '下一句' },
    { key: 'play', angle: 60, icon: playing ? 'pause' : 'play', label: playing ? '暂停' : '播放' },
  ]
  return defs.map((d) => {
    const rad = (d.angle * Math.PI) / 180
    const x = sign * MENU_RADIUS * Math.cos(rad)
    const y = MENU_RADIUS * Math.sin(rad)
    return {
      ...d,
      left: BALL_SIZE / 2 + x - MENU_BTN / 2,
      top: BALL_SIZE / 2 + y - MENU_BTN / 2,
    }
  })
})

function onMenuAction(key: string) {
  if (key === 'prev') doPrev()
  else if (key === 'next') doNext()
  else if (key === 'replay') doReplay()
  else doToggle()
  closeMenu()
}

/* ───────────── 指针手势 ───────────── */
function clearLongPress() {
  if (longPressTimer) {
    clearTimeout(longPressTimer)
    longPressTimer = null
  }
}

function handleTap() {
  const now = performance.now()
  if (lastTapAt > 0 && now - lastTapAt <= DOUBLE_TAP_MS) {
    if (singleTapTimer) {
      clearTimeout(singleTapTimer)
      singleTapTimer = null
    }
    lastTapAt = 0
    doReplay()
    return
  }
  lastTapAt = now
  if (singleTapTimer) clearTimeout(singleTapTimer)
  singleTapTimer = setTimeout(() => {
    singleTapTimer = null
    lastTapAt = 0
    doToggle()
  }, DOUBLE_TAP_MS)
}

function resetTapChain() {
  lastTapAt = 0
  if (singleTapTimer) {
    clearTimeout(singleTapTimer)
    singleTapTimer = null
  }
}

function clearSingleTimer() {
  if (singleTapTimer) {
    clearTimeout(singleTapTimer)
    singleTapTimer = null
  }
}

function onPointerDown(e: PointerEvent) {
  if (props.hidden || disabled.value || guideActive.value) return
  if (menuOpen.value) {
    closeMenu()
    return
  }
  const el = ballRef.value
  if (!el) return

  // 只清除待触发的单击动作，保留 lastTapAt 以便识别双击
  clearSingleTimer()

  startX = e.clientX
  startY = e.clientY
  startT = performance.now()
  moved = false
  dragActive = false
  longPressFired = false
  pid = e.pointerId
  interacting.value = true
  pressed.value = true
  swipeNudge.value = 0

  try {
    el.setPointerCapture(e.pointerId)
  } catch {
    /* ignore */
  }

  clearLongPress()
  longPressTimer = setTimeout(() => {
    longPressTimer = null
    if (pid !== null && !moved && !dragActive) {
      longPressFired = true
      pressed.value = false
      openMenu()
    }
  }, LONG_PRESS_MS)
}

function onPointerMove(e: PointerEvent) {
  if (pid === null || e.pointerId !== pid) return
  const dx = e.clientX - startX
  const dy = e.clientY - startY
  const dist = Math.hypot(dx, dy)

  if (!moved && dist > MOVE_CANCEL) {
    moved = true
    clearLongPress()
  }
  if (!moved) return

  if (!dragActive && dist >= DRAG_THRESHOLD) {
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

  if (dragActive) {
    dragLeft.value = clamp(
      dragOriginLeft + (e.clientX - dragAnchorX),
      MARGIN,
      vw.value - BALL_SIZE - MARGIN,
    )
    dragBottom.value = clamp(
      dragOriginBottom - (e.clientY - dragAnchorY),
      MIN_BOTTOM,
      vh.value - BALL_SIZE - MIN_BOTTOM,
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
  clearLongPress()

  const wasLong = longPressFired
  const dx = e.clientX - startX
  const dy = e.clientY - startY
  const dist = Math.hypot(dx, dy)
  const duration = performance.now() - startT

  pid = null
  pressed.value = false

  if (wasLong) {
    interacting.value = false
    resetTapChain()
    return
  }

  if (dragActive) {
    const centerX = dragLeft.value + BALL_SIZE / 2
    edge.value = centerX < vw.value / 2 ? 'left' : 'right'
    centerY.value = clamp(
      (vh.value - dragBottom.value - BALL_SIZE / 2) / vh.value,
      minRatio.value,
      maxRatio.value,
    )
    persist()
    dragging.value = false
    dragActive = false
    interacting.value = false
    resetTapChain()
    return
  }

  swipeNudge.value = 0
  interacting.value = false

  if (cancelled) {
    dragActive = false
    resetTapChain()
    return
  }

  const horizontal = Math.abs(dx) > Math.abs(dy) * 1.2
  if (dist >= SWIPE_THRESHOLD && horizontal && duration <= 600) {
    dragActive = false
    resetTapChain()
    if (dx < 0) doPrev()
    else doNext()
    return
  }

  dragActive = false
  if (dist < SWIPE_THRESHOLD) {
    handleTap()
  } else {
    resetTapChain()
  }
}

/* ───────────── 引导 ───────────── */
const guideSteps = [
  { title: '单击', desc: '播放 / 暂停', icon: 'play' },
  { title: '双击', desc: '重播当前句子', icon: 'repeat' },
  { title: '左右滑动', desc: '左滑上一句 · 右滑下一句', icon: 'swipe-hint' },
  { title: '长按', desc: '展开完整菜单', icon: 'menu' },
]

function showGuide() {
  guideStep.value = 0
  guideActive.value = true
  interacting.value = false
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
  const placeAbove = c.y > vh.value * 0.5
  return placeAbove
    ? { bottom: `${vh.value - (c.y - half) + 14}px` }
    : { top: `${c.y + half + 14}px` }
})

/* ───────────── 生命周期 ───────────── */
function onResize() {
  vw.value = window.innerWidth
  vh.value = window.innerHeight
}

watch(
  () => props.hidden,
  (h) => {
    if (h) {
      menuOpen.value = false
      guideActive.value = false
    }
  },
)

watch(disabled, (d) => {
  if (d) menuOpen.value = false
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
  clearLongPress()
  if (singleTapTimer) clearTimeout(singleTapTimer)
  if (spinTimer) clearTimeout(spinTimer)
  if (replayTimer) clearTimeout(replayTimer)
  if (arrowTimer) clearTimeout(arrowTimer)
  if (guideTimer) clearTimeout(guideTimer)
})
</script>

<template>
  <div
    v-show="!hidden"
    class="fixed select-none"
    :class="menuOpen ? 'z-[45]' : 'z-30'"
    :style="outerStyle"
  >
    <!-- 径向菜单按钮 -->
    <template v-if="menuOpen">
      <button
        v-for="item in menuButtons"
        :key="item.key"
        type="button"
        class="fb-menu-btn absolute flex items-center justify-center rounded-full border border-white/20 bg-neutral-900/90 text-white shadow-lg backdrop-blur-md active:scale-90"
        :style="{ left: `${item.left}px`, top: `${item.top}px`, width: `${MENU_BTN}px`, height: `${MENU_BTN}px` }"
        :aria-label="item.label"
        :title="item.label"
        @click.stop="onMenuAction(item.key)"
      >
        <AppIcon :name="item.icon" class="h-5 w-5" />
      </button>
    </template>

    <!-- 主球 -->
    <div class="fb-breathe" :class="{ 'fb-breathing': breathing }">
      <button
        ref="ballRef"
        type="button"
        class="fb-ball relative flex touch-none select-none items-center justify-center rounded-full border border-white/20 text-white shadow-lg backdrop-blur-md"
        :class="[dragging ? 'ring-2 ring-amber-400/70' : '', spinning ? 'fb-spin-once' : '']"
        :style="ballStyle"
        :aria-label="disabled ? '悬浮球不可用' : isPlaying ? '暂停' : '播放'"
        :aria-disabled="disabled"
        @pointerdown="onPointerDown"
        @pointermove="onPointerMove"
        @pointerup="onPointerUp($event)"
        @pointercancel="onPointerUp($event, true)"
        @contextmenu.prevent
      >
        <AppIcon v-if="replayFlash" name="repeat" class="fb-replay-icon h-6 w-6" />
        <AppIcon v-else-if="isPlaying" name="pause" class="h-6 w-6" />
        <AppIcon v-else name="play" class="ml-0.5 h-6 w-6" />

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
  </div>

  <!-- 菜单遮罩（独立于球体定位，避免 transform 影响 fixed 参照） -->
  <Teleport to="body">
    <div v-if="menuOpen" class="fixed inset-0 z-[44] bg-black/25" @click="closeMenu" />
  </Teleport>

  <!-- 首次使用引导 -->
  <Teleport to="body">
    <div v-if="guideActive" class="fixed inset-0 z-[70]">
      <div
        class="pointer-events-none fixed rounded-full ring-2 ring-amber-300/90"
        :style="[guideSpotStyle, { boxShadow: '0 0 0 9999px rgba(0,0,0,0.55)' }]"
      />
      <div class="absolute inset-0" @click.stop />
      <div
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

        <div class="mt-3 flex items-center gap-3">
          <span class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-sunken text-ink">
            <AppIcon :name="guideSteps[guideStep].icon" class="h-5 w-5" />
          </span>
          <div class="min-w-0">
            <p class="text-[14px] font-semibold text-ink">{{ guideSteps[guideStep].title }}</p>
            <p class="text-[12px] text-ink-soft">{{ guideSteps[guideStep].desc }}</p>
          </div>
        </div>

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

.fb-spin-once {
  animation: fb-spin 0.5s ease;
}
@keyframes fb-spin {
  to {
    transform: rotate(360deg);
  }
}

.fb-replay-icon {
  animation: fb-spin 0.7s linear infinite;
}

.fb-menu-btn {
  animation: fb-menu-in 0.16s ease-out;
}
@keyframes fb-menu-in {
  from {
    opacity: 0;
    transform: scale(0.7);
  }
  to {
    opacity: 1;
    transform: scale(1);
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
</style>
