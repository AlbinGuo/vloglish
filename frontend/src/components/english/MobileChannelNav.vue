<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AppIcon from '@/components/AppIcon.vue'

const route = useRoute()
const router = useRouter()
const STORAGE_KEY = 'vloglish-mobile-channel-order-v1'
const CHANNELS = [
  { id: 'videos', label: '视频', to: '/english', match: (p: string) => p === '/english' || p.startsWith('/english/episode') || p.startsWith('/english/author') },
  { id: 'listen', label: '收听', to: '/english/listen', match: (p: string) => p.startsWith('/english/listen') },
  { id: 'series', label: '合集', to: '/english/series', match: (p: string) => p.startsWith('/english/series') },
  { id: 'reading', label: '月刊', to: '/english/reading', match: (p: string) => p.startsWith('/english/reading') },
]
const order = ref<string[]>(CHANNELS.map((item) => item.id))
const enabled = ref<string[]>(CHANNELS.map((item) => item.id))
const managerOpen = ref(false)
const draggedId = ref('')
const current = computed(() => CHANNELS.find((item) => item.match(route.path))?.id ?? 'recommend')
const visibleChannels = computed(() => order.value.filter((id) => enabled.value.includes(id)))

function persist() {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify({ order: order.value, enabled: enabled.value }))
  } catch {
    /* ignore storage failures */
  }
}

function restore() {
  try {
    const saved = JSON.parse(localStorage.getItem(STORAGE_KEY) || '{}') as { order?: string[]; enabled?: string[] }
    const validIds = new Set(CHANNELS.map((item) => item.id))
    if (Array.isArray(saved.order)) order.value = [...saved.order.filter((id) => validIds.has(id)), ...CHANNELS.map((item) => item.id).filter((id) => !saved.order?.includes(id))]
    if (Array.isArray(saved.enabled)) enabled.value = [...new Set(saved.enabled.filter((id) => validIds.has(id)))]
  } catch {
    /* use defaults */
  }
}

function openChannel(id: string) {
  if (id === 'follow') void router.push('/english/my-follows')
  else if (id === 'recommend') void router.push('/english')
  else {
    const channel = CHANNELS.find((item) => item.id === id)
    if (channel) void router.push(channel.to)
  }
}

function toggle(id: string) {
  if (enabled.value.includes(id)) enabled.value = enabled.value.filter((item) => item !== id)
  else enabled.value = [...enabled.value, id]
  persist()
}

function moveBefore(targetId: string) {
  if (!draggedId.value || draggedId.value === targetId) return
  const next = [...order.value]
  const from = next.indexOf(draggedId.value)
  const to = next.indexOf(targetId)
  if (from < 0 || to < 0) return
  next.splice(from, 1)
  next.splice(to, 0, draggedId.value)
  order.value = next
  persist()
}

function onTouchStart(id: string, event: TouchEvent) {
  draggedId.value = id
  const touch = event.touches[0]
  if (touch) (event.currentTarget as HTMLElement).dataset.dragY = String(touch.clientY)
}

function onTouchEnd(event: TouchEvent) {
  if (!draggedId.value) return
  const touch = event.changedTouches[0]
  const target = touch ? document.elementFromPoint(touch.clientX, touch.clientY)?.closest<HTMLElement>('[data-channel-id]') : null
  if (target?.dataset.channelId) moveBefore(target.dataset.channelId)
  draggedId.value = ''
}

watch(managerOpen, (open) => {
  if (open) restore()
})
restore()
</script>

<template>
  <div class="sm:hidden border-b border-line-soft bg-card">
    <nav class="flex h-11 items-stretch overflow-x-auto pl-3 pr-1 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden" aria-label="频道导航">
      <button
        v-for="item in [{ id: 'follow', label: '关注' }, { id: 'recommend', label: '推荐' }]"
        :key="item.id"
        type="button"
        class="relative shrink-0 px-3 text-[15px] font-medium"
        :class="current === item.id || (item.id === 'follow' && route.path.startsWith('/english/my-follows')) ? 'text-brand' : 'text-ink-soft'"
        @click="openChannel(item.id)"
      >
        {{ item.label }}
        <span v-if="current === item.id || (item.id === 'follow' && route.path.startsWith('/english/my-follows'))" class="absolute inset-x-3 bottom-0 h-[2px] rounded-full bg-brand" />
      </button>
      <button
        v-for="item in visibleChannels"
        :key="item"
        type="button"
        class="relative shrink-0 px-3 text-[15px] font-medium"
        :class="current === item ? 'text-brand' : 'text-ink-soft'"
        @click="openChannel(item)"
      >
        {{ CHANNELS.find((channel) => channel.id === item)?.label }}
        <span v-if="current === item" class="absolute inset-x-3 bottom-0 h-[2px] rounded-full bg-brand" />
      </button>
      <button type="button" class="sticky right-0 ml-auto flex shrink-0 items-center bg-card px-3 text-ink-soft" aria-label="管理频道" @click="managerOpen = true">
        <AppIcon name="settings" class="h-5 w-5" />
      </button>
    </nav>

    <Teleport to="body">
      <Transition name="channel-sheet">
        <div v-if="managerOpen" class="fixed inset-0 z-[100] flex items-end justify-center bg-black/45" @click.self="managerOpen = false">
          <section class="max-h-[82dvh] w-full rounded-t-2xl bg-card px-5 pb-[max(1.25rem,env(safe-area-inset-bottom))] pt-3 shadow-2xl" role="dialog" aria-modal="true" aria-label="管理频道">
            <div class="mx-auto mb-4 h-1 w-10 rounded-full bg-line-soft" />
            <div class="mb-4 flex items-center justify-between">
              <h2 class="text-lg font-semibold text-ink">我的频道</h2>
              <button type="button" class="text-sm font-medium text-brand" @click="managerOpen = false">完成</button>
            </div>
            <p class="mb-3 text-xs text-ink-faint">拖动排序，点击频道卡片添加或移除。关注和推荐为固定频道。</p>
            <div class="mb-5 grid grid-cols-4 gap-2">
              <div v-for="item in [{ id: 'follow', label: '关注' }, { id: 'recommend', label: '推荐' }]" :key="item.id" class="flex h-11 items-center justify-center rounded-lg bg-sunken text-sm text-ink-faint">
                {{ item.label }}
              </div>
              <button
                v-for="id in order"
                :key="id"
                type="button"
                :data-channel-id="id"
                class="flex h-11 touch-none items-center justify-center rounded-lg text-sm transition"
                :class="enabled.includes(id) ? 'bg-brand-soft text-brand ring-1 ring-brand/20' : 'bg-sunken text-ink-faint'"
                :aria-pressed="enabled.includes(id)"
                @click="toggle(id)"
                @dragstart="draggedId = id"
                @dragover.prevent
                @drop.prevent="moveBefore(id); draggedId = ''"
                @dragend="draggedId = ''"
                @touchstart.passive="onTouchStart(id, $event)"
                @touchend="onTouchEnd"
              >
                {{ CHANNELS.find((channel) => channel.id === id)?.label }}
              </button>
            </div>
            <div class="flex items-center justify-between border-t border-line-soft pt-4 text-sm">
              <span class="text-ink-faint">已选 {{ enabled.length }} 个频道</span>
              <button type="button" class="text-ink-soft" @click="enabled = CHANNELS.map((item) => item.id); order = CHANNELS.map((item) => item.id); persist()">恢复默认</button>
            </div>
          </section>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<style scoped>
.channel-sheet-enter-active,
.channel-sheet-leave-active { transition: opacity 180ms ease; }
.channel-sheet-enter-active section,
.channel-sheet-leave-active section { transition: transform 180ms ease; }
.channel-sheet-enter-from,
.channel-sheet-leave-to { opacity: 0; }
.channel-sheet-enter-from section,
.channel-sheet-leave-to section { transform: translateY(24px); }
</style>
