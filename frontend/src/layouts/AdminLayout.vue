<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink, RouterView, useRoute, useRouter } from 'vue-router'
import { useAdminAuthStore } from '@/stores/adminAuth'

const route = useRoute()
const router = useRouter()
const auth = useAdminAuthStore()

const nav = [
  { to: '/gnadmin/dashboard', label: '仪表盘' },
  { to: '/gnadmin/episodes', label: '剧集' },
  { to: '/gnadmin/authors', label: '作者' },
  { to: '/gnadmin/tags', label: '标签' },
  { to: '/gnadmin/import', label: '导入导出' },
  { to: '/gnadmin/demo-codes', label: '体验码' },
  { to: '/gnadmin/activation-codes', label: '激活码' },
  { to: '/gnadmin/users', label: '用户' },
]

const pageTitle = computed(() => {
  if (route.path.startsWith('/gnadmin/episodes/new')) return '新建剧集'
  if (route.path.match(/^\/gnadmin\/episodes\/\d+/)) return '编辑剧集'
  if (route.path.startsWith('/gnadmin/import')) return '导入导出'
  if (route.path.startsWith('/gnadmin/demo-codes')) return '体验码'
  if (route.path.startsWith('/gnadmin/authors')) return '作者'
  if (route.path.startsWith('/gnadmin/tags')) return '标签'
  const item = nav.find((n) => route.path.startsWith(n.to))
  return item?.label ?? '管理后台'
})

async function logout() {
  auth.logout()
  await router.replace('/gnadmin/login')
}
</script>

<template>
  <div class="min-h-dvh bg-neutral-100 flex">
    <aside class="w-56 shrink-0 bg-neutral-900 text-white flex flex-col">
      <div class="px-4 py-5 border-b border-white/10">
        <p class="font-semibold">Vloglish</p>
        <p class="text-xs text-neutral-400 mt-1">管理后台</p>
      </div>
      <nav class="flex-1 p-3 space-y-1">
        <RouterLink
          v-for="item in nav"
          :key="item.to"
          :to="item.to"
          class="block px-3 py-2 rounded-lg text-sm transition"
          :class="route.path.startsWith(item.to) ? 'bg-white/10 text-white' : 'text-neutral-300 hover:bg-white/5'"
        >
          {{ item.label }}
        </RouterLink>
      </nav>
      <div class="p-3 border-t border-white/10 text-xs text-neutral-400">
        <p class="truncate mb-2">{{ auth.user?.email }}</p>
        <button type="button" class="text-neutral-200 hover:text-white" @click="logout">退出登录</button>
      </div>
    </aside>

    <div class="flex-1 min-w-0 flex flex-col">
      <header class="bg-white border-b border-black/5 px-6 py-4">
        <h1 class="text-lg font-semibold">{{ pageTitle }}</h1>
      </header>
      <main class="flex-1 p-6 overflow-auto">
        <RouterView />
      </main>
    </div>
  </div>
</template>
