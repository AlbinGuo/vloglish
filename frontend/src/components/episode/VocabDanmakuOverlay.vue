<script setup lang="ts">
import { onUnmounted, ref, watch } from 'vue'
import { lookupWord } from '@/api/episodes'
import { saveVocabulary } from '@/api/learning'
import { type VocabDanmakuSource } from '@/utils/vocabDanmaku'
import AppIcon from '@/components/AppIcon.vue'

const props = withDefaults(
  defineProps<{
    /** 当前句匹配到的汇总词（已与字幕同步） */
    sources: VocabDanmakuSource[]
    context: string
    videoId: string
    subtitleId: number | null
    /** 当前句起止（秒），用于跟视频时间轴同步入场 */
    start?: number
    end?: number
    currentTime?: number
    paused?: boolean
    canSave?: boolean
  }>(),
  {
    sources: () => [],
    start: 0,
    end: 0,
    currentTime: 0,
    paused: false,
    canSave: false,
  },
)

const emit = defineEmits<{
  openWord: [payload: { word: string; tokenType: 1 | 2; context: string; subtitleId: number | null }]
}>()

interface Bullet extends VocabDanmakuSource {
  key: string
  lane: number
  durationSec: number
  saved: boolean
  saving: boolean
  resolvedGloss: string
  /** 发射时的视频时间，用于同轨防撞 */
  launchedAt: number
  subtitleId: number | null
  /** 贴在弹幕上方的短提示 */
  tip: string
  tipTone: 'ok' | 'err'
}

interface Pending {
  src: VocabDanmakuSource
  /** 计划入场的视频时间 */
  at: number
  lane: number
  subtitleId: number | null
}

const LANE_COUNT = 2
/** 同句同轨最小间隔（秒）——双轨交错后实际约一半 */
const MIN_SAME_LANE_GAP_SEC = 1.15
/** 跨句时放宽，避免新句被旧弹幕挡太久 */
const CROSS_SENTENCE_GAP_SEC = 0.75
/** 相对句首的提前量：句未到也可开始进场 */
const LEAD_IN_SEC = 0.55
/** 句首爆发窗口：尽量在开场前后把词排完，避免拖到下句 */
const BURST_AFTER_START_SEC = 1.8
const ENTRY_SPACING_SEC = 0.62

const bullets = ref<Bullet[]>([])
const pending = ref<Pending[]>([])
const savedKeys = ref(new Set<string>())
const leaveTimers = new Map<string, ReturnType<typeof setTimeout>>()
const tipTimers = new Map<string, ReturnType<typeof setTimeout>>()
/** 仅命令式维护，避免 Vue 改 class/style 导致 CSS 动画重启 */
const pinnedKeys = new Set<string>()
let seq = 0
let scheduleSubtitleId: number | null = null
/** 各轨道上次发射 */
const laneLast = ref<{ at: number; durationSec: number; subtitleId: number | null }[]>(
  Array.from({ length: LANE_COUNT }, () => ({ at: -999, durationSec: 16, subtitleId: null })),
)

/** 切句时只清待发队列；已在飞的弹幕继续滚到出屏 */
function clearPendingOnly() {
  pending.value = []
}

function resetLaneClock() {
  const now = props.currentTime
  for (let i = 0; i < LANE_COUNT; i++) {
    const flying = bullets.value.filter((b) => b.lane === i)
    if (!flying.length) {
      laneLast.value[i] = { at: -999, durationSec: 16, subtitleId: null }
      continue
    }
    const latest = flying.reduce((a, b) => (a.launchedAt >= b.launchedAt ? a : b))
    laneLast.value[i] = {
      at: latest.launchedAt,
      durationSec: latest.durationSec,
      subtitleId: latest.subtitleId,
    }
    // 旧弹幕已飞一阵后，不要再用「满间隔」堵住新句
    if (now - latest.launchedAt >= CROSS_SENTENCE_GAP_SEC) {
      laneLast.value[i] = {
        at: now - CROSS_SENTENCE_GAP_SEC,
        durationSec: latest.durationSec,
        subtitleId: latest.subtitleId,
      }
    }
  }
}

function clearLeaveTimers() {
  for (const t of leaveTimers.values()) clearTimeout(t)
  leaveTimers.clear()
}

function clearTipTimers() {
  for (const t of tipTimers.values()) clearTimeout(t)
  tipTimers.clear()
}

function clearAll() {
  clearPendingOnly()
  clearLeaveTimers()
  clearTipTimers()
  pinnedKeys.clear()
  bullets.value = []
  scheduleSubtitleId = null
  laneLast.value = Array.from({ length: LANE_COUNT }, () => ({
    at: -999,
    durationSec: 16,
    subtitleId: null,
  }))
}

function durationFor(word: string, gloss: string) {
  const len = word.length + gloss.length
  return Math.min(22, Math.max(14, 13 + len * 0.14))
}

/**
 * 句首预进场 + 短窗口内排队发射。
 * 切句不打断已在滚的弹幕；未发出的上一句待发会被清掉，避免拖到下句才冒出来。
 */
function rebuildSchedule(sources: VocabDanmakuSource[]) {
  clearPendingOnly()
  resetLaneClock()
  scheduleSubtitleId = props.subtitleId

  if (!sources.length) return

  const start = Number.isFinite(props.start) ? props.start : 0
  let end = Number.isFinite(props.end) ? props.end : start + 4
  if (end <= start) end = start + Math.max(3, sources.length * 2.4)

  const n = sources.length
  // 从句首前提前量开始，在短爆发窗内依次入场（双轨交错）
  const windowStart = start - LEAD_IN_SEC
  const burstEnd = start + Math.min(BURST_AFTER_START_SEC, Math.max(1, (end - start) * 0.45))
  const span = Math.max(ENTRY_SPACING_SEC, burstEnd - windowStart)
  const spacing = Math.min(ENTRY_SPACING_SEC, span / Math.max(n, 1))

  pending.value = sources.map((src, i) => ({
    src,
    at: windowStart + i * spacing,
    lane: i % LANE_COUNT,
    subtitleId: props.subtitleId,
  }))

  if (!props.paused) flushPending(props.currentTime)
}

function gapNeeded(lane: number, subtitleId: number | null, durationSec: number) {
  const last = laneLast.value[lane]
  if (!last || last.at < -100) return 0
  const cross = last.subtitleId != null && subtitleId != null && last.subtitleId !== subtitleId
  if (cross) return CROSS_SENTENCE_GAP_SEC
  return Math.max(MIN_SAME_LANE_GAP_SEC, durationSec * 0.16)
}

function canLaunchOnLane(lane: number, now: number, durationSec: number, subtitleId: number | null) {
  const last = laneLast.value[lane]
  if (!last) return true
  const need = gapNeeded(lane, subtitleId, Math.max(last.durationSec, durationSec))
  return now - last.at >= need - 0.02
}

function launchOne(p: Pending, now: number) {
  const durationSec = durationFor(p.src.word, p.src.gloss)
  const subId = p.subtitleId ?? scheduleSubtitleId
  let lane = p.lane
  if (!canLaunchOnLane(lane, now, durationSec, subId)) {
    const alt = (lane + 1) % LANE_COUNT
    if (canLaunchOnLane(alt, now, durationSec, subId)) lane = alt
    else return false
  }

  const key = `${p.src.id}-${++seq}`
  bullets.value.push({
    ...p.src,
    key,
    lane,
    durationSec,
    saved: savedKeys.value.has(p.src.word.toLowerCase()),
    saving: false,
    resolvedGloss: p.src.gloss,
    launchedAt: now,
    subtitleId: subId,
    tip: '',
    tipTone: 'ok',
  })
  laneLast.value[lane] = { at: now, durationSec, subtitleId: subId }
  if (!p.src.gloss) void resolveGloss(key, p.src)
  return true
}

function flushPending(now: number) {
  if (!pending.value.length) return
  const remain: Pending[] = []
  const due = [...pending.value].sort((a, b) => a.at - b.at || a.lane - b.lane)
  for (const p of due) {
    if (now + 0.02 < p.at) {
      remain.push(p)
      continue
    }
    const ok = launchOne(p, Math.max(now, p.at))
    if (!ok) {
      // 轨道略挤时小步重试，避免一下子拖到下一句
      remain.push({ ...p, at: now + 0.2 })
    }
  }
  pending.value = remain
}

async function resolveGloss(key: string, src: VocabDanmakuSource) {
  try {
    const entry = await lookupWord(src.word, src.tokenType, props.context, {
      video_id: props.videoId,
      subtitle_id: props.subtitleId ?? undefined,
    })
    const cn =
      entry.definitions?.find((d) => d.definition_cn)?.definition_cn ||
      entry.definitions?.[0]?.definition_cn ||
      ''
    const short = cn.replace(/\s+/g, ' ').trim().slice(0, 16)
    const b = bullets.value.find((x) => x.key === key)
    if (b && short) b.resolvedGloss = short
    if (entry.favorite) {
      savedKeys.value.add(src.word.toLowerCase())
      if (b) b.saved = true
    }
  } catch {
    /* 无释义时仅显示英文 */
  }
}

function cancelLeaveTimer(key: string) {
  const t = leaveTimers.get(key)
  if (t != null) {
    clearTimeout(t)
    leaveTimers.delete(key)
  }
}

function pauseBulletEl(el: HTMLElement) {
  // 只命令式暂停，勿通过 Vue :style 改 animationPlayState（会重启动画）
  el.style.setProperty('animation-play-state', 'paused')
  try {
    for (const anim of el.getAnimations({ subtree: false })) anim.pause()
  } catch {
    try {
      for (const anim of el.getAnimations()) anim.pause()
    } catch {
      /* ignore */
    }
  }
}

function resumeBulletEl(el: HTMLElement) {
  if (props.paused) {
    pauseBulletEl(el)
    return
  }
  el.style.removeProperty('animation-play-state')
  try {
    for (const anim of el.getAnimations({ subtree: false })) {
      if (anim.playState === 'paused') anim.play()
    }
  } catch {
    try {
      for (const anim of el.getAnimations()) {
        if (anim.playState === 'paused') anim.play()
      }
    } catch {
      /* ignore */
    }
  }
}

/**
 * 弹幕在动时 mouseleave 会抖；enter 当帧同步 pause 钉住位置。
 * 视觉悬停态用 classList，避免触发 Vue 重渲染打断动画。
 */
function onBulletEnter(b: Bullet, e: Event) {
  cancelLeaveTimer(b.key)
  const el = e.currentTarget as HTMLElement
  pauseBulletEl(el)
  el.classList.add('vocab-danmaku-bullet--hover')
  pinnedKeys.add(b.key)
}

function onBulletLeave(b: Bullet, e: Event) {
  const el = e.currentTarget as HTMLElement
  const related = (e as PointerEvent).relatedTarget as Node | null
  if (related && el.contains(related)) return

  cancelLeaveTimer(b.key)
  leaveTimers.set(
    b.key,
    setTimeout(() => {
      leaveTimers.delete(b.key)
      if (!pinnedKeys.has(b.key)) return
      pinnedKeys.delete(b.key)
      el.classList.remove('vocab-danmaku-bullet--hover')
      resumeBulletEl(el)
    }, 120),
  )
}

function onBulletPointerDown(e: Event) {
  // 阻断落到下层 VideoPlayer 的播放/暂停热区
  e.stopPropagation()
}

function onBulletClick(e: Event) {
  e.stopPropagation()
  e.preventDefault()
}

function onAnimationEnd(key: string) {
  cancelLeaveTimer(key)
  pinnedKeys.delete(key)
  const tipT = tipTimers.get(key)
  if (tipT != null) {
    clearTimeout(tipT)
    tipTimers.delete(key)
  }
  bullets.value = bullets.value.filter((b) => b.key !== key)
}

/** 只绑不会随悬停变化的量，避免 patch style 重置动画 */
function bulletStyle(b: Bullet) {
  return {
    top: `${laneTop(b.lane)}px`,
    animationDuration: `${b.durationSec}s`,
  }
}

/** 提示贴在弹幕上方；短暂停住便于看清。holdMs=0 表示一直显示直到下次提示覆盖 */
function showBulletTip(b: Bullet, message: string, tone: 'ok' | 'err' = 'ok', holdMs = 1600) {
  const prev = tipTimers.get(b.key)
  if (prev != null) clearTimeout(prev)

  b.tip = message
  b.tipTone = tone

  const el = document.querySelector<HTMLElement>(
    `.vocab-danmaku-bullet[data-bullet-key="${b.key.replace(/"/g, '')}"]`,
  )
  if (el) {
    pauseBulletEl(el)
    el.classList.add('vocab-danmaku-bullet--hover')
    pinnedKeys.add(b.key)
  }

  if (holdMs <= 0) return

  tipTimers.set(
    b.key,
    setTimeout(() => {
      tipTimers.delete(b.key)
      const cur = bullets.value.find((x) => x.key === b.key)
      if (!cur) return
      cur.tip = ''
      const node = document.querySelector<HTMLElement>(
        `.vocab-danmaku-bullet[data-bullet-key="${b.key.replace(/"/g, '')}"]`,
      )
      if (!node) return
      // 鼠标仍在弹幕上则继续停住
      if (node.matches(':hover')) {
        pinnedKeys.add(b.key)
        pauseBulletEl(node)
        return
      }
      pinnedKeys.delete(b.key)
      node.classList.remove('vocab-danmaku-bullet--hover')
      resumeBulletEl(node)
    }, holdMs),
  )
}

function onWordClick(b: Bullet, e: MouseEvent) {
  e.stopPropagation()
  e.preventDefault()
  emit('openWord', {
    word: b.word,
    tokenType: b.tokenType,
    context: props.context,
    subtitleId: props.subtitleId,
  })
}

async function onAddClick(b: Bullet, e: MouseEvent) {
  e.stopPropagation()
  e.preventDefault()
  if (!props.canSave || b.saving) return
  if (b.saved) {
    showBulletTip(b, '已在生词本', 'ok')
    return
  }
  b.saving = true
  b.saved = true
  savedKeys.value.add(b.word.toLowerCase())
  // 先即时反馈；单次快速收藏接口（不再先查词）
  showBulletTip(b, '加入中…', 'ok', 0)
  try {
    await saveVocabulary({
      word: b.word,
      token_type: b.tokenType,
      video_id: props.videoId,
      subtitle_id: props.subtitleId ?? undefined,
    })
    try {
      const { useVocabularyStore } = await import('@/stores/vocabulary')
      useVocabularyStore().invalidate()
    } catch {
      /* ignore */
    }
    showBulletTip(b, '已加入生词本', 'ok')
  } catch {
    b.saved = false
    savedKeys.value.delete(b.word.toLowerCase())
    showBulletTip(b, '收藏失败', 'err')
  } finally {
    b.saving = false
  }
}

watch(
  () => [props.sources, props.subtitleId, props.start, props.end] as const,
  () => rebuildSchedule(props.sources || []),
  { immediate: true, deep: true },
)

watch(
  () => props.currentTime,
  (t) => {
    if (props.paused) return
    flushPending(t)
  },
)

watch(
  () => props.paused,
  (paused) => {
    requestAnimationFrame(() => {
      document.querySelectorAll<HTMLElement>('.vocab-danmaku-bullet[data-bullet-key]').forEach((el) => {
        const key = el.dataset.bulletKey || ''
        if (pinnedKeys.has(key)) return
        if (paused) pauseBulletEl(el)
        else resumeBulletEl(el)
      })
    })
  },
)

onUnmounted(clearAll)

function laneTop(lane: number) {
  // 顶部留白给气泡提示
  return 30 + lane * 40
}
</script>

<template>
  <!-- z-30：盖过 VideoPlayer 内 z-10 点击热区，否则点击会落到视频上 -->
  <div
    class="vocab-danmaku-layer absolute inset-0 z-30 overflow-hidden pointer-events-none"
    aria-hidden="false"
  >
    <div
      v-for="b in bullets"
      :key="b.key"
      class="vocab-danmaku-bullet absolute pointer-events-auto flex items-center gap-1.5 max-w-[min(85%,20rem)] pl-2.5 pr-1 py-1 rounded-full shadow-md shadow-black/25 border backdrop-blur-sm select-none cursor-default"
      :class="['bg-neutral-900/75 border-white/15 text-white', b.highlight ? `vocab-danmaku--${b.highlight}` : '']"
      :data-bullet-key="b.key"
      :style="bulletStyle(b)"
      @pointerenter="onBulletEnter(b, $event)"
      @pointerleave="onBulletLeave(b, $event)"
      @pointerdown="onBulletPointerDown"
      @click="onBulletClick"
      @animationend="onAnimationEnd(b.key)"
    >
      <Transition name="danmaku-tip">
        <span
          v-if="b.tip"
          class="vocab-danmaku-tip absolute left-1/2 bottom-[calc(100%+6px)] -translate-x-1/2 whitespace-nowrap px-2 py-0.5 rounded-md text-[10px] sm:text-[11px] font-medium shadow-md pointer-events-none"
          :class="
            b.tipTone === 'err'
              ? 'bg-red-500 text-white'
              : 'bg-emerald-500 text-white'
          "
          role="status"
        >
          {{ b.tip }}
        </span>
      </Transition>
      <button
        type="button"
        class="min-w-0 text-left touch-manipulation"
        :title="b.word"
        @pointerdown.stop
        @click="onWordClick(b, $event)"
      >
        <span class="block text-[12px] sm:text-[13px] font-semibold leading-tight truncate">{{ b.word }}</span>
        <span
          v-if="b.resolvedGloss"
          class="block text-[10px] sm:text-[11px] text-white/75 leading-tight truncate mt-0.5"
        >
          {{ b.resolvedGloss }}
        </span>
      </button>
      <button
        v-if="canSave"
        type="button"
        class="shrink-0 w-7 h-7 rounded-full flex items-center justify-center transition touch-manipulation"
        :class="
          b.saved
            ? 'bg-emerald-500 text-white'
            : 'bg-white/15 text-white hover:bg-white/25'
        "
        :disabled="b.saving"
        :title="b.saved ? '已在生词本' : '加入生词本'"
        :aria-label="b.saved ? '已在生词本' : `将 ${b.word} 加入生词本`"
        @pointerdown.stop
        @click="onAddClick(b, $event)"
      >
        <AppIcon name="check-xs" v-if="b.saved" class="w-3.5 h-3.5" />
        <AppIcon v-else name="plus" class="w-3.5 h-3.5" />
      </button>
    </div>
  </div>
</template>

<style scoped>
.vocab-danmaku-bullet {
  left: 100%;
  z-index: 1;
  animation-name: vocab-danmaku-rtl;
  animation-timing-function: linear;
  animation-fill-mode: forwards;
  will-change: transform;
}

.vocab-danmaku-bullet--hover {
  background: rgb(23 23 23 / 0.92);
  box-shadow:
    0 8px 24px rgb(0 0 0 / 0.35),
    inset 3px 0 0 rgb(255 255 255 / 0.35);
}

.vocab-danmaku-tip::after {
  content: '';
  position: absolute;
  left: 50%;
  top: 100%;
  margin-left: -4px;
  border: 4px solid transparent;
  border-top-color: rgb(16 185 129);
}

.vocab-danmaku-tip.bg-red-500::after {
  border-top-color: rgb(239 68 68);
}

.danmaku-tip-enter-active,
.danmaku-tip-leave-active {
  transition: opacity 0.15s ease;
}

.danmaku-tip-enter-from,
.danmaku-tip-leave-to {
  opacity: 0;
}

@keyframes vocab-danmaku-rtl {
  from {
    transform: translateX(0);
  }
  to {
    transform: translateX(calc(-100% - 100cqi));
  }
}

@supports not (width: 1cqi) {
  @keyframes vocab-danmaku-rtl {
    from {
      transform: translateX(0);
    }
    to {
      transform: translateX(calc(-100% - 100vw));
    }
  }
}

.vocab-danmaku-layer {
  container-type: inline-size;
  container-name: vocab-danmaku;
  /* 保证与播放器热区叠层时弹幕可点 */
  isolation: isolate;
}

.vocab-danmaku--a:not(.vocab-danmaku-bullet--hover) {
  box-shadow: inset 3px 0 0 #3b82f6;
}
.vocab-danmaku--d:not(.vocab-danmaku-bullet--hover) {
  box-shadow: inset 3px 0 0 #a855f7;
}
.vocab-danmaku--i:not(.vocab-danmaku-bullet--hover) {
  box-shadow: inset 3px 0 0 #14b8a6;
}
.vocab-danmaku--c:not(.vocab-danmaku-bullet--hover) {
  box-shadow: inset 3px 0 0 #f59e0b;
}
.vocab-danmaku--l:not(.vocab-danmaku-bullet--hover) {
  box-shadow: inset 3px 0 0 #ef4444;
}
.vocab-danmaku--f:not(.vocab-danmaku-bullet--hover) {
  box-shadow: inset 3px 0 0 #ec4899;
}
.vocab-danmaku--p:not(.vocab-danmaku-bullet--hover) {
  box-shadow: inset 3px 0 0 #84cc16;
}
</style>
