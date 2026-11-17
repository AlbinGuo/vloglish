<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import AppIcon from '@/components/AppIcon.vue'
import { getEpisodeTags, getFollowingStatus } from '@/api/episodes'
import type { Tag } from '@/types'

const props = defineProps<{ selected: string }>()
const emit = defineEmits<{ (e: 'update:selected', key: string): void }>()

const STORAGE_KEY = 'vloglish-mobile-channels-v4'
const SEEN_KEY = 'vloglish-follow-seen-at'
// 初始默认频道（“关注/推荐”固定，其余按名称匹配标签）；重复项会自动去重
const DEFAULT_CHANNEL_NAMES = ['知识', '访谈', '演讲', '生活', 'BBC六分钟英语', '新闻', '日常']
const tags = ref<Tag[]>([])
const order = ref<number[]>([])
const enabled = ref<number[]>([])
const unwatched = ref(0)
const hasNew = ref(false)
const managerOpen = ref(false)

// —— 拖拽状态 ——
const draggingId = ref<number | null>(null)
const ghostLabel = ref('')
const ghostPos = ref({ x: 0, y: 0 })
let pressTimer: ReturnType<typeof setTimeout> | undefined
let pressStart: { x: number; y: number } | null = null
let suppressClick = false

const tagById = computed(() => new Map(tags.value.map((t) => [t.id, t])))
const visibleTags = computed(() =>
  order.value
    .filter((id) => enabled.value.includes(id))
    .map((id) => tagById.value.get(id))
    .filter((t): t is Tag => Boolean(t)),
)

function restore() {
  try {
    const saved = JSON.parse(localStorage.getItem(STORAGE_KEY) || '{}') as {
      order?: number[]
      enabled?: number[]
    }
    if (Array.isArray(saved.order)) order.value = saved.order
    if (Array.isArray(saved.enabled)) enabled.value = saved.enabled
  } catch {
    /* defaults */
  }
}

function persist() {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify({ order: order.value, enabled: enabled.value }))
  } catch {
    /* ignore */
  }
}

function lastSeenAt(): number {
  try {
    return Number(localStorage.getItem(SEEN_KEY) || 0)
  } catch {
    return 0
  }
}

function markFollowSeen() {
  try {
    localStorage.setItem(SEEN_KEY, String(Date.now()))
  } catch {
    /* ignore */
  }
  hasNew.value = false
}

async function refreshStatus() {
  try {
    const s = await getFollowingStatus()
    unwatched.value = s.unwatched_count
    const latest = s.latest_published_at ? Date.parse(s.latest_published_at) : 0
    hasNew.value = latest > lastSeenAt()
  } catch {
    /* keep last */
  }
}

function buildDefault(): { orderIds: number[]; enabledIds: number[] } {
  const norm = (s: string) => s.replace(/\s+/g, '').toLowerCase()
  const picked: number[] = []
  for (const name of DEFAULT_CHANNEL_NAMES) {
    const key = norm(name)
    const t =
      tags.value.find((x) => norm(x.name) === key) ??
      tags.value.find((x) => norm(x.name).includes(key))
    if (t && !picked.includes(t.id)) picked.push(t.id)
  }
  // 不足 8 个时用其余标签补足
  for (const t of tags.value) {
    if (picked.length >= 8) break
    if (!picked.includes(t.id)) picked.push(t.id)
  }
  const enabledIds = picked.slice(0, 8)
  const orderIds = [
    ...enabledIds,
    ...tags.value.map((t) => t.id).filter((id) => !enabledIds.includes(id)),
  ]
  return { orderIds, enabledIds }
}

async function loadTags() {
  try {
    tags.value = await getEpisodeTags()
  } catch {
    tags.value = []
  }
  restore()
  const validIds = tags.value.map((t) => t.id)
  order.value = [
    ...order.value.filter((id) => validIds.includes(id)),
    ...validIds.filter((id) => !order.value.includes(id)),
  ]
  enabled.value = enabled.value.filter((id) => validIds.includes(id))
  if (enabled.value.length === 0) {
    const d = buildDefault()
    order.value = d.orderIds
    enabled.value = d.enabledIds
    persist()
  }
}

function selectKey(key: string) {
  emit('update:selected', key)
}

function toggle(id: number) {
  if (enabled.value.includes(id)) enabled.value = enabled.value.filter((x) => x !== id)
  else enabled.value = [...enabled.value, id]
  persist()
}

function moveBefore(fromId: number, targetId: number) {
  if (fromId === targetId) return
  const next = [...order.value]
  const fi = next.indexOf(fromId)
  const ti = next.indexOf(targetId)
  if (fi < 0 || ti < 0) return
  next.splice(fi, 1)
  next.splice(ti, 0, fromId)
  order.value = next
  persist()
}

// —— 移动端长按拖拽（事件委托） ——
function onGridTouchStart(e: TouchEvent) {
  const el = (e.target as HTMLElement).closest<HTMLElement>('[data-tag-id]')
  if (!el) return
  const id = Number(el.dataset.tagId)
  const t = e.touches[0]
  pressStart = { x: t.clientX, y: t.clientY }
  clearTimeout(pressTimer)
  pressTimer = setTimeout(() => {
    draggingId.value = id
    ghostLabel.value = tagById.value.get(id)?.name || ''
    ghostPos.value = { x: t.clientX, y: t.clientY }
    navigator.vibrate?.(15)
    // 进入拖拽后清掉可能出现的文本选择
    window.getSelection?.()?.removeAllRanges()
  }, 260)
}

function onGridTouchMove(e: TouchEvent) {
  const t = e.touches[0]
  if (draggingId.value != null) {
    e.preventDefault()
    ghostPos.value = { x: t.clientX, y: t.clientY }
    const target = document
      .elementFromPoint(t.clientX, t.clientY)
      ?.closest<HTMLElement>('[data-tag-id]')
    const tid = target?.dataset.tagId ? Number(target.dataset.tagId) : null
    if (tid != null && tid !== draggingId.value) moveBefore(draggingId.value, tid)
    return
  }
  // 还没进入拖拽：手指移动超过阈值则视为滚动，取消长按
  if (pressStart) {
    const dx = t.clientX - pressStart.x
    const dy = t.clientY - pressStart.y
    if (Math.hypot(dx, dy) > 10) {
      clearTimeout(pressTimer)
      pressStart = null
    }
  }
}

function onGridTouchEnd() {
  if (draggingId.value != null) {
    suppressClick = true
    setTimeout(() => {
      suppressClick = false
    }, 60)
  }
  clearTimeout(pressTimer)
  pressStart = null
  draggingId.value = null
}

function onItemClick(id: number) {
  if (suppressClick || draggingId.value != null) return
  toggle(id)
}

// —— 桌面端 HTML5 拖拽 ——
function onDragStart(id: number) {
  draggingId.value = id
  ghostLabel.value = tagById.value.get(id)?.name || ''
}
function onDrop(targetId: number) {
  if (draggingId.value != null) moveBefore(draggingId.value, targetId)
  draggingId.value = null
}
function onDragEnd() {
  draggingId.value = null
}

function resetChannels() {
  const d = buildDefault()
  order.value = d.orderIds
  enabled.value = d.enabledIds
  persist()
}

function onVisible() {
  if (typeof document !== 'undefined' && document.visibilityState === 'visible') {
    void refreshStatus()
  }
}

watch(
  () => props.selected,
  (v) => {
    if (v === 'follow') markFollowSeen()
  },
)

let pollTimer: ReturnType<typeof setInterval> | undefined
onMounted(async () => {
  await loadTags()
  await refreshStatus()
  pollTimer = setInterval(() => void refreshStatus(), 30000)
  document.addEventListener('visibilitychange', onVisible)
})
onUnmounted(() => {
  clearInterval(pollTimer)
  document.removeEventListener('visibilitychange', onVisible)
})
</script>

<template>
  <div class="sm:hidden border-b border-line-soft bg-card">
    <nav
      class="flex h-11 items-stretch overflow-x-auto pl-3 pr-1 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
      aria-label="频道导航"
    >
      <button
        type="button"
        class="relative shrink-0 px-3 text-[15px]"
        :class="selected === 'follow' ? 'font-semibold text-brand' : 'font-medium text-ink-soft'"
        @click="selectKey('follow')"
      >
        关注
        <span
          v-if="hasNew"
          class="absolute -right-1 top-0.5 rounded-full bg-red-500 px-1 text-center text-[9px] font-semibold leading-[14px] text-white"
          aria-label="有新视频"
        >
          新
        </span>
        <span
          v-else-if="unwatched > 0"
          class="absolute -right-0.5 top-1 min-w-[14px] rounded-full bg-red-500 px-1 text-center text-[9px] font-semibold leading-[14px] text-white"
          aria-label="未看新视频数量"
        >
          {{ unwatched > 99 ? '99+' : unwatched }}
        </span>
        <span v-if="selected === 'follow'" class="absolute inset-x-3 bottom-0 h-[2px] rounded-full bg-brand" />
      </button>
      <button
        type="button"
        class="relative shrink-0 px-3 text-[15px]"
        :class="selected === 'recommend' ? 'font-semibold text-brand' : 'font-medium text-ink-soft'"
        @click="selectKey('recommend')"
      >
        推荐
        <span v-if="selected === 'recommend'" class="absolute inset-x-3 bottom-0 h-[2px] rounded-full bg-brand" />
      </button>
      <button
        v-for="t in visibleTags"
        :key="t.id"
        type="button"
        class="relative shrink-0 px-3 text-[15px]"
        :class="selected === `tag:${t.id}` ? 'font-semibold text-brand' : 'font-medium text-ink-soft'"
        @click="selectKey(`tag:${t.id}`)"
      >
        {{ t.name }}
        <span v-if="selected === `tag:${t.id}`" class="absolute inset-x-3 bottom-0 h-[2px] rounded-full bg-brand" />
      </button>
      <button
        type="button"
        class="sticky right-0 ml-auto flex shrink-0 items-center bg-card pl-2 pr-3 text-ink-soft"
        aria-label="管理频道"
        @click="managerOpen = true"
      >
        <AppIcon name="settings" class="h-5 w-5" />
      </button>
    </nav>

    <Teleport to="body">
      <Transition name="channel-sheet">
        <div
          v-if="managerOpen"
          class="fixed inset-0 z-[100] flex items-end justify-center bg-black/45"
          @click.self="managerOpen = false"
        >
          <section
            class="max-h-[82dvh] w-full rounded-t-2xl bg-card px-5 pb-[max(1.25rem,env(safe-area-inset-bottom))] pt-3 shadow-2xl"
            role="dialog"
            aria-modal="true"
            aria-label="管理频道"
          >
            <div class="mx-auto mb-4 h-1 w-10 rounded-full bg-line-soft" />
            <div class="mb-1 flex items-center justify-between">
              <h2 class="text-lg font-semibold text-ink">我的频道</h2>
              <button type="button" class="text-sm font-medium text-brand" @click="managerOpen = false">完成</button>
            </div>
            <p class="mb-4 text-xs text-ink-faint">
              点击标签添加或移除频道；<b>长按</b>标签后拖动可调整顺序。关注、推荐为固定频道。
            </p>
            <div class="max-h-[58dvh] overflow-y-auto pb-2">
              <div
                class="grid select-none grid-cols-4 gap-2 [-webkit-touch-callout:none]"
                @touchstart="onGridTouchStart"
                @touchmove="onGridTouchMove"
                @touchend="onGridTouchEnd"
                @touchcancel="onGridTouchEnd"
                @contextmenu.prevent
              >
                <div
                  v-for="fix in [{ k: '关注' }, { k: '推荐' }]"
                  :key="fix.k"
                  class="flex h-10 items-center justify-center rounded-lg bg-sunken text-sm text-ink-faint"
                >
                  {{ fix.k }}
                </div>
                <button
                  v-for="id in order"
                  :key="id"
                  type="button"
                  :data-tag-id="id"
                  class="flex h-10 items-center justify-center rounded-lg text-sm transition-all duration-150"
                  :class="[
                    enabled.includes(id)
                      ? 'bg-brand-soft text-brand ring-1 ring-brand/20'
                      : 'bg-sunken text-ink-faint',
                    draggingId === id ? 'scale-95 opacity-50 ring-2 ring-brand' : '',
                  ]"
                  :aria-pressed="enabled.includes(id)"
                  draggable="true"
                  @click="onItemClick(id)"
                  @dragstart="onDragStart(id)"
                  @dragover.prevent
                  @drop.prevent="onDrop(id)"
                  @dragend="onDragEnd"
                >
                  {{ tagById.get(id)?.name }}
                </button>
              </div>
            </div>
            <div class="mt-3 flex items-center justify-between border-t border-line-soft pt-4 text-sm">
              <span class="text-ink-faint">已选 {{ enabled.length }} 个频道</span>
              <button type="button" class="text-ink-soft" @click="resetChannels">恢复默认</button>
            </div>
          </section>
        </div>
      </Transition>

      <!-- 长按拖动时跟随手指的“轨迹” -->
      <div
        v-if="draggingId != null"
        class="pointer-events-none fixed z-[200] flex h-10 items-center justify-center rounded-lg bg-brand px-3 text-sm font-medium text-white shadow-lg shadow-black/30"
        :style="{ left: ghostPos.x + 'px', top: ghostPos.y + 'px', transform: 'translate(-50%, -150%)' }"
      >
        {{ ghostLabel }}
      </div>
    </Teleport>
  </div>
</template>

<style scoped>
.channel-sheet-enter-active,
.channel-sheet-leave-active {
  transition: opacity 180ms ease;
}
.channel-sheet-enter-active section,
.channel-sheet-leave-active section {
  transition: transform 180ms ease;
}
.channel-sheet-enter-from,
.channel-sheet-leave-to {
  opacity: 0;
}
.channel-sheet-enter-from section,
.channel-sheet-leave-to section {
  transform: translateY(24px);
}
</style>
