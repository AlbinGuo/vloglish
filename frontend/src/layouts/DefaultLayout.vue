<script setup lang="ts">
import { computed, onMounted, onUnmounted, watch } from 'vue'
import { RouterLink, RouterView, useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useNotificationStore } from '@/stores/notifications'
import ThemeToggle from '@/components/ThemeToggle.vue'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const notifications = useNotificationStore()

const immersive = computed(() => Boolean(route.meta.immersive))

let pollTimer: ReturnType<typeof setInterval> | null = null

async function refreshUnreadCount() {
  if (!auth.isLoggedIn) {
    notifications.clear()
    return
  }
  await notifications.refresh()
}

async function handleLogout() {
  await auth.logout()
  notifications.clear()
  await router.replace('/english')
}

onMounted(() => {
  if (auth.ready && auth.isLoggedIn) {
    refreshUnreadCount()
  }
  pollTimer = setInterval(() => {
    if (auth.isLoggedIn) refreshUnreadCount()
  }, 60000)
})

onUnmounted(() => {
  if (pollTimer) clearInterval(pollTimer)
})

watch(
  () => [auth.ready, auth.isLoggedIn] as const,
  ([ready, loggedIn]) => {
    if (ready && loggedIn) refreshUnreadCount()
    else if (ready) notifications.clear()
  },
)

watch(
  () => route.path,
  (path) => {
    if (path === '/english/notifications' && auth.isLoggedIn) {
      refreshUnreadCount()
    }
  },
)
</script>

<template>
  <div
    class="flex flex-col bg-neutral-50 dark:bg-neutral-950"
    :class="immersive ? 'h-dvh overflow-hidden' : 'min-h-dvh'"
  >
    <header
      v-if="!immersive"
      class="sticky top-0 z-40 bg-white/90 dark:bg-neutral-900/90 backdrop-blur border-b border-black/5 dark:border-white/10"
    >
      <div class="page-container py-3 flex items-center justify-between gap-4">
        <RouterLink to="/english" class="flex flex-col shrink-0">
          <span class="text-lg font-semibold">Vloglish</span>
          <span class="text-xs text-neutral-500 dark:text-neutral-400">Real vlogs · Real English</span>
        </RouterLink>

        <div class="flex items-center gap-3 text-sm shrink-0">
          <ThemeToggle />
          <template v-if="auth.isLoggedIn">
            <RouterLink
              to="/english/learning"
              class="hidden sm:inline-flex items-center gap-1.5 px-2 py-1.5 rounded-lg text-neutral-600 hover:text-black hover:bg-neutral-100 dark:text-neutral-400 dark:hover:text-white dark:hover:bg-neutral-800 transition"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="1.75"
                class="w-5 h-5 shrink-0"
                aria-hidden="true"
              >
                <path stroke-linecap="round" stroke-linejoin="round" d="M7 19V11M12 19V5M17 19V15" />
                <path stroke-linecap="round" d="M4 19h16" />
              </svg>
              学习统计
            </RouterLink>
            <RouterLink
              to="/english/notifications"
              class="relative p-2 rounded-lg text-neutral-600 hover:text-black hover:bg-neutral-100 dark:text-neutral-400 dark:hover:text-white dark:hover:bg-neutral-800 transition"
              aria-label="通知"
            >
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-5 h-5">
                <path
                  fill-rule="evenodd"
                  d="M5.25 9a6.75 6.75 0 0 1 13.5 0v.75c0 2.123.8 4.077 2.125 5.548a.75.75 0 0 1-.513 1.297H3.638a.75.75 0 0 1-.513-1.297A6.75 6.75 0 0 0 5.25 9Zm2.25 0a4.5 4.5 0 1 1 9 0v.75c0 1.214.455 2.34 1.204 3.192a.75.75 0 0 1-.204 1.058H6.5a.75.75 0 0 1-.204-1.058A4.5 4.5 0 0 0 7.5 9.75V9Z"
                  clip-rule="evenodd"
                />
                <path d="M9 18.75a3 3 0 0 0 6 0H9Z" />
              </svg>
              <span
                v-if="notifications.unreadCount > 0"
                class="absolute -top-0.5 -right-0.5 min-w-[1.125rem] h-[1.125rem] px-1 rounded-full bg-red-500 text-white text-[10px] font-semibold flex items-center justify-center leading-none"
              >
                {{ notifications.unreadCount > 99 ? '99+' : notifications.unreadCount }}
              </span>
            </RouterLink>
            <span v-if="auth.isMember" class="text-xs px-2 py-1 rounded-full bg-amber-100 text-amber-800 dark:bg-amber-900/50 dark:text-amber-300">
              会员
            </span>
            <span class="hidden sm:inline text-neutral-500 dark:text-neutral-400 max-w-[10rem] truncate">
              {{ auth.user?.nickname || auth.user?.email }}
            </span>
            <button type="button" class="text-neutral-600 hover:text-black dark:text-neutral-400 dark:hover:text-white" @click="handleLogout">退出</button>
          </template>
          <template v-else>
            <RouterLink to="/login" class="text-neutral-600 hover:text-black dark:text-neutral-400 dark:hover:text-white">登录</RouterLink>
            <RouterLink
              to="/signup"
              class="px-3 py-1.5 rounded-lg bg-neutral-900 text-white text-sm hover:bg-neutral-800 dark:bg-neutral-100 dark:text-neutral-900 dark:hover:bg-white"
            >
              注册
            </RouterLink>
          </template>
        </div>
      </div>
    </header>
    <main class="flex-1" :class="immersive ? 'min-h-0 overflow-hidden' : ''">
      <RouterView />
    </main>
  </div>
</template>
