<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink, RouterView, useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const immersive = computed(() => Boolean(route.meta.immersive))

async function handleLogout() {
  await auth.logout()
  await router.push('/login')
}
</script>

<template>
  <div
    class="flex flex-col bg-neutral-50"
    :class="immersive ? 'h-dvh overflow-hidden' : 'min-h-dvh'"
  >
    <header
      v-if="!immersive"
      class="sticky top-0 z-40 bg-white/90 backdrop-blur border-b border-black/5"
    >
      <div class="page-container py-3 flex items-center justify-between gap-4">
        <RouterLink to="/english" class="flex flex-col shrink-0">
          <span class="text-lg font-semibold">Vloglish</span>
          <span class="text-xs text-neutral-500">Real vlogs · Real English</span>
        </RouterLink>

        <div class="flex items-center gap-3 text-sm shrink-0">
          <template v-if="auth.isLoggedIn">
            <span v-if="auth.isMember" class="text-xs px-2 py-1 rounded-full bg-amber-100 text-amber-800">
              会员
            </span>
            <RouterLink
              v-else
              to="/activate"
              class="text-xs px-2 py-1 rounded-full bg-neutral-900 text-white hover:bg-neutral-800"
            >
              激活会员
            </RouterLink>
            <span class="hidden sm:inline text-neutral-500 max-w-[10rem] truncate">
              {{ auth.user?.nickname || auth.user?.email }}
            </span>
            <button type="button" class="text-neutral-600 hover:text-black" @click="handleLogout">退出</button>
          </template>
          <template v-else>
            <RouterLink to="/login" class="text-neutral-600 hover:text-black">登录</RouterLink>
            <RouterLink
              to="/signup"
              class="px-3 py-1.5 rounded-lg bg-neutral-900 text-white text-sm hover:bg-neutral-800"
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
