<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink } from 'vue-router'
import AppIcon from '@/components/AppIcon.vue'
import { useAuthStore } from '@/stores/auth'
import { useTheme } from '@/composables/useTheme'

const props = defineProps<{ open: boolean }>()
const emit = defineEmits<{
  (e: 'update:open', v: boolean): void
  (e: 'contact'): void
  (e: 'feedback'): void
  (e: 'logout'): void
}>()

const auth = useAuthStore()
const { resolvedTheme, setThemeMode } = useTheme()

const links = computed(() => {
  const base = [
    { to: '/english/study', icon: 'book-open', label: '怎么学' },
    { to: '/english/learning', icon: 'chart-bar', label: '学习统计' },
    { to: '/english/clips', icon: 'clipboard-list', label: '我的摘录' },
    { to: '/english/series', icon: 'text-lines', label: '全部系列' },
    { to: '/english/wish-wall', icon: 'sparkles', label: '心愿墙' },
  ]
  if (auth.isLoggedIn) base.splice(3, 0, { to: '/english/notifications', icon: 'bell', label: '通知' })
  return base
})

const isDark = computed(() => resolvedTheme.value === 'dark')

function close() {
  emit('update:open', false)
}
function toggleTheme() {
  setThemeMode(isDark.value ? 'light' : 'dark')
}
function contact() {
  close()
  emit('contact')
}
function feedback() {
  close()
  emit('feedback')
}
function logout() {
  close()
  emit('logout')
}
</script>

<template>
  <Teleport to="body">
    <Transition name="more-sheet">
      <div
        v-if="open"
        class="fixed inset-0 z-[70] flex flex-col justify-end bg-black/45 sm:hidden"
        @click.self="close"
      >
        <div
          class="rounded-t-[1.75rem] bg-card text-ink pb-[max(1rem,env(safe-area-inset-bottom))] shadow-[var(--shadow-sheet)]"
          @click.stop
        >
          <div class="relative flex items-center justify-between px-5 pt-4 pb-2">
            <h2 class="flex-1 text-center text-base font-semibold">我的</h2>
            <button
              type="button"
              class="absolute right-4 top-3 w-9 h-9 flex items-center justify-center rounded-full text-ink-faint hover:bg-sunken transition"
              aria-label="关闭"
              @click="close"
            >
              <AppIcon name="close" class="w-5 h-5" />
            </button>
          </div>

          <div class="grid grid-cols-4 gap-1 px-3 pt-2 pb-3">
            <RouterLink
              v-for="item in links"
              :key="item.to"
              :to="item.to"
              class="flex flex-col items-center gap-2 py-2 rounded-xl text-ink-soft transition active:bg-sunken"
              @click="close"
            >
              <span class="w-12 h-12 rounded-2xl bg-sunken flex items-center justify-center">
                <AppIcon :name="item.icon" class="w-6 h-6" />
              </span>
              <span class="text-[11px] leading-tight text-center">{{ item.label }}</span>
            </RouterLink>
          </div>

          <div class="mx-4 border-t border-line-soft" />

          <div class="px-3 pt-2 pb-1">
            <button
              type="button"
              class="w-full flex items-center gap-3 px-3 py-3 rounded-xl text-ink-soft hover:bg-sunken transition"
              @click="toggleTheme"
            >
              <AppIcon :name="isDark ? 'sun' : 'moon'" class="w-5 h-5" />
              <span class="flex-1 text-left text-sm">{{ isDark ? '切换到浅色' : '切换到深色' }}</span>
            </button>
            <button
              type="button"
              class="w-full flex items-center gap-3 px-3 py-3 rounded-xl text-ink-soft hover:bg-sunken transition"
              @click="contact"
            >
              <AppIcon name="chat-bubble" class="w-5 h-5" />
              <span class="flex-1 text-left text-sm">联系作者</span>
            </button>
            <button
              v-if="auth.isLoggedIn"
              type="button"
              class="w-full flex items-center gap-3 px-3 py-3 rounded-xl text-ink-soft hover:bg-sunken transition"
              @click="feedback"
            >
              <AppIcon name="inbox" class="w-5 h-5" />
              <span class="flex-1 text-left text-sm">意见反馈</span>
            </button>
            <RouterLink
              v-if="!auth.isLoggedIn"
              to="/login"
              class="w-full flex items-center gap-3 px-3 py-3 rounded-xl text-brand hover:bg-sunken transition"
              @click="close"
            >
              <AppIcon name="logout" class="w-5 h-5" />
              <span class="flex-1 text-left text-sm">登录 / 注册</span>
            </RouterLink>
            <button
              v-else
              type="button"
              class="w-full flex items-center gap-3 px-3 py-3 rounded-xl text-danger hover:bg-sunken transition"
              @click="logout"
            >
              <AppIcon name="logout" class="w-5 h-5" />
              <span class="flex-1 text-left text-sm">退出登录</span>
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.more-sheet-enter-active,
.more-sheet-leave-active {
  transition: opacity 0.2s ease;
}
.more-sheet-enter-active > div,
.more-sheet-leave-active > div {
  transition: transform 0.25s cubic-bezier(0.22, 1, 0.36, 1);
}
.more-sheet-enter-from,
.more-sheet-leave-to {
  opacity: 0;
}
.more-sheet-enter-from > div,
.more-sheet-leave-to > div {
  transform: translateY(100%);
}
</style>