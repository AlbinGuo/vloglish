<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import AppIcon from '@/components/AppIcon.vue'

const props = defineProps<{ vocabCount?: number }>()
const emit = defineEmits<{ (e: 'more'): void }>()

const route = useRoute()

interface Tab {
  key: string
  label: string
  icon: string
  to: string
  badge?: number
  match: (path: string) => boolean
}

const tabs = computed<Tab[]>(() => [
  {
    key: 'home',
    label: '首页',
    icon: 'home',
    to: '/english',
    match: (p) =>
      p === '/english' ||
      p.startsWith('/english/series') ||
      p.startsWith('/english/episode') ||
      p.startsWith('/english/author'),
  },
  {
    key: 'listen',
    label: '听力',
    icon: 'headphones',
    to: '/english/listen',
    match: (p) => p.startsWith('/english/listen'),
  },
  {
    key: 'reading',
    label: '阅读',
    icon: 'book-open',
    to: '/english/reading',
    match: (p) => p.startsWith('/english/reading'),
  },
  {
    key: 'vocab',
    label: '生词本',
    icon: 'flag',
    to: '/english/vocabulary',
    badge: props.vocabCount,
    match: (p) => p.startsWith('/english/vocabulary'),
  },
])

const moreActive = computed(() =>
  ['/english/learning', '/english/clips', '/english/study', '/english/notifications', '/english/wish-wall'].some(
    (p) => route.path.startsWith(p),
  ),
)
</script>

<template>
  <nav
    class="fixed inset-x-0 bottom-0 z-40 border-t border-line-soft bg-card-glass backdrop-blur-md pb-[env(safe-area-inset-bottom,0px)] sm:hidden"
    aria-label="主导航"
  >
    <div class="grid grid-cols-5">
      <RouterLink
        v-for="tab in tabs"
        :key="tab.key"
        :to="tab.to"
        class="relative flex flex-col items-center justify-center gap-0.5 transition-colors duration-150 active:scale-95"
        :class="tab.match(route.path) ? 'text-brand' : 'text-ink-faint'"
        :style="{ height: 'var(--tabbar-height)' }"
      >
        <span class="relative">
          <AppIcon :name="tab.icon" class="w-[1.375rem] h-[1.375rem]" />
          <span
            v-if="tab.badge && tab.badge > 0"
            class="absolute -top-1 -right-2 min-w-[1rem] h-4 px-1 rounded-full bg-warning text-ink-inverse text-[10px] font-semibold flex items-center justify-center leading-none"
          >
            {{ tab.badge > 99 ? '99+' : tab.badge }}
          </span>
        </span>
        <span class="text-[10.5px] leading-none">{{ tab.label }}</span>
      </RouterLink>

      <button
        type="button"
        class="relative flex flex-col items-center justify-center gap-0.5 transition-colors duration-150 active:scale-95"
        :class="moreActive ? 'text-brand' : 'text-ink-faint'"
        :style="{ height: 'var(--tabbar-height)' }"
        aria-label="更多"
        @click="emit('more')"
      >
        <AppIcon name="user" class="w-[1.375rem] h-[1.375rem]" />
        <span class="text-[10.5px] leading-none">我的</span>
      </button>
    </div>
  </nav>
</template>