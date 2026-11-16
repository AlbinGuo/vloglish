<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import AppIcon from '@/components/AppIcon.vue'
import { getMyFollowedAuthors, getPopularEpisodeTags } from '@/api/episodes'
import type { Tag } from '@/types'

defineProps<{ selected: string }>()
const emit = defineEmits<{ (e: 'update:selected', key: string): void }>()

const STORAGE_KEY = 'vloglish-mobile-channels-v2'
const tags = ref<Tag[]>([])
const order = ref<number[]>([])
const enabled = ref<number[]>([])
const unwatched = ref(0)
const managerOpen = ref(false)
const draggedId = ref<number | null>(null)

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
    localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({ order: order.value, enabled: enabled.value }),
    )
  } catch {
    /* ignore */
  }
}

async function load() {
  try {
    tags.value = await getPopularEpisodeTags()
  } catch {
    tags.value = []
  }
  restore()
  const validIds = tags.value.map((t) => t.id)
  // 清理已不存在的标签
  order.value = [...order.value.filter((id) => validIds.includes(id)), ...validIds.filter((id) => !order.value.includes(id))]
  enabled.value = enabled.value.filter((id) => validIds.includes(id))
  if (order.value.length === 0) {
    order.value = validIds
    enabled.value = validIds.slice(0, 6)
    persist()
  }
  try {
    const res = await getMyFollowedAuthors()
    unwatched.value = res.results.reduce((sum, a) => sum + (a.unwatched_count || 0), 0)
  } catch {
    unwatched.value = 0
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

function moveBefore(targetId: number) {
  const from = draggedId.value
  if (from == null || from === targetId) return
  const next = [...order.value]
  const fi = next.indexOf(from)
  const ti = next.indexOf(targetId)
  if (fi < 0 || ti < 0) return
  next.splice(fi, 1)
  next.splice(ti, 0, from)
  order.value = next
  persist()
}

function onTouchStart(id: number) {
  draggedId.value = id
}

function onTouchEnd(e: TouchEvent) {
  if (draggedId.value == null) return
  const touch = e.changedTouches[0]
  const target = touch
    ? document
        .elementFromPoint(touch.clientX, touch.clientY)
        ?.closest<HTMLElement>('[data-tag-id]')
    : null
  const tid = target?.dataset.tagId ? Number(target.dataset.tagId) : null
  if (tid != null) moveBefore(tid)
  draggedId.value = null
}

function resetChannels() {
  order.value = tags.value.map((t) => t.id)
  enabled.value = tags.value.slice(0, 6).map((t) => t.id)
  persist()
}

onMounted(load)
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
          v-if="unwatched > 0"
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
              <button type="button" class="text-sm font-medium text-brand" @click="managerOpen = false">
                完成
              </button>
            </div>
            <p class="mb-4 text-xs text-ink-faint">点击标签添加或移除频道，长按拖动调整顺序。关注、推荐为固定频道。</p>
            <div class="max-h-[58dvh] overflow-y-auto pb-2">
              <div class="grid grid-cols-4 gap-2">
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
                  class="flex h-10 touch-none items-center justify-center rounded-lg text-sm transition"
                  :class="enabled.includes(id) ? 'bg-brand-soft text-brand ring-1 ring-brand/20' : 'bg-sunken text-ink-faint'"
                  :aria-pressed="enabled.includes(id)"
                  @click="toggle(id)"
                  @dragstart="draggedId = id"
                  @dragover.prevent
                  @drop.prevent="moveBefore(id); draggedId = null"
                  @dragend="draggedId = null"
                  @touchstart.passive="onTouchStart(id)"
                  @touchend="onTouchEnd"
                  @touchmove.prevent
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
