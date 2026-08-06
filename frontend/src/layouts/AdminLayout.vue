<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink, RouterView, useRoute, useRouter } from 'vue-router'
import {
  adminAckSubmissionPopup,
  adminGetPendingSubmissionPopups,
  type AdminEpisodeSubmittedPopup as AdminEpisodeSubmittedPopupItem,
} from '@/api/admin'
import AdminEpisodeSubmittedPopup from '@/components/admin/AdminEpisodeSubmittedPopup.vue'
import { useAdminAuthStore } from '@/stores/adminAuth'

const route = useRoute()
const router = useRouter()
const auth = useAdminAuthStore()
const mobileNavOpen = ref(false)

const popupQueue = ref<AdminEpisodeSubmittedPopupItem[]>([])
const popupBusy = ref(false)
const currentPopup = computed(() => popupQueue.value[0] ?? null)
let popupPollTimer: ReturnType<typeof setInterval> | null = null

const nav = [
  { to: '/gnadmin/dashboard', label: '仪表盘' },
  { to: '/gnadmin/episodes', label: '剧集' },
  { to: '/gnadmin/series', label: '合集' },
  { to: '/gnadmin/reading', label: 'News Reading' },
  { to: '/gnadmin/authors', label: '作者' },
  { to: '/gnadmin/tags', label: '标签' },
  { to: '/gnadmin/import', label: '导入导出' },
  { to: '/gnadmin/demo-codes', label: '体验码' },
  { to: '/gnadmin/activation-codes', label: '激活码' },
  { to: '/gnadmin/membership-orders', label: '会员订单' },
  { to: '/gnadmin/users', label: '用户' },
  { to: '/gnadmin/geo', label: '地区分布' },
  { to: '/gnadmin/learning', label: '学习统计' },
  { to: '/gnadmin/ai-usage', label: 'AI 用量' },
  { to: '/gnadmin/notifications', label: '通知' },
  { to: '/gnadmin/feedback', label: '用户反馈' },
]

const pageTitle = computed(() => {
  if (route.path.startsWith('/gnadmin/episodes/new')) return '新建剧集'
  if (route.path.match(/^\/gnadmin\/episodes\/\d+/)) return '编辑剧集'
  if (route.path.startsWith('/gnadmin/series')) return '合集'
  if (route.path.startsWith('/gnadmin/reading/new')) return '新建文章'
  if (route.path.match(/^\/gnadmin\/reading\/\d+/)) return '编辑文章'
  if (route.path.startsWith('/gnadmin/reading')) return 'News Reading'
  if (route.path.startsWith('/gnadmin/import')) return '导入导出'
  if (route.path.startsWith('/gnadmin/demo-codes')) return '体验码'
  if (route.path.startsWith('/gnadmin/authors')) return '作者'
  if (route.path.startsWith('/gnadmin/tags')) return '标签'
  if (route.path.startsWith('/gnadmin/notifications')) return '通知'
  if (route.path.startsWith('/gnadmin/feedback')) return '用户反馈'
  if (route.path.startsWith('/gnadmin/geo')) return '地区分布'
  if (route.path.startsWith('/gnadmin/learning')) return '学习统计'
  if (route.path.startsWith('/gnadmin/ai-usage')) return 'AI 用量'
  if (route.path.startsWith('/gnadmin/activation-codes')) return '激活码'
  if (route.path.startsWith('/gnadmin/membership-orders')) return '会员订单'
  const item = nav.find((n) => route.path.startsWith(n.to))
  return item?.label ?? '管理后台'
})

watch(
  () => route.fullPath,
  () => {
    mobileNavOpen.value = false
  },
)

async function refreshPendingPopups() {
  if (!auth.isLoggedIn) {
    popupQueue.value = []
    return
  }
  try {
    const results = await adminGetPendingSubmissionPopups()
    const currentId = currentPopup.value?.id
    if (currentId != null && results.some((r) => r.id === currentId)) {
      const head = results.find((r) => r.id === currentId)!
      popupQueue.value = [head, ...results.filter((r) => r.id !== currentId)]
    } else {
      popupQueue.value = results
    }
  } catch {
    // 静默失败
  }
}

function startPopupPolling() {
  stopPopupPolling()
  void refreshPendingPopups()
  popupPollTimer = setInterval(() => {
    if (auth.isLoggedIn) void refreshPendingPopups()
  }, 5000)
}

function stopPopupPolling() {
  if (popupPollTimer) {
    clearInterval(popupPollTimer)
    popupPollTimer = null
  }
  popupQueue.value = []
}

async function ackCurrentPopup() {
  const item = currentPopup.value
  if (!item || popupBusy.value) return
  popupBusy.value = true
  try {
    await adminAckSubmissionPopup(item.id)
    popupQueue.value = popupQueue.value.filter((p) => p.id !== item.id)
  } catch {
    popupQueue.value = popupQueue.value.filter((p) => p.id !== item.id)
  } finally {
    popupBusy.value = false
  }
}

async function dismissSubmittedPopup() {
  await ackCurrentPopup()
}

async function reviewSubmittedPopup() {
  const episodeId = currentPopup.value?.episode_id
  await ackCurrentPopup()
  if (episodeId) {
    await router.push(`/gnadmin/episodes/${episodeId}`)
  }
}

async function logout() {
  stopPopupPolling()
  auth.logout()
  await router.replace('/gnadmin/login')
}

onMounted(() => {
  if (auth.isLoggedIn) startPopupPolling()
})

onUnmounted(() => {
  stopPopupPolling()
})

watch(
  () => auth.isLoggedIn,
  (loggedIn) => {
    if (loggedIn) startPopupPolling()
    else stopPopupPolling()
  },
)
</script>

<template>
  <div class="min-h-dvh bg-neutral-100 flex">
    <!-- 桌面侧栏 -->
    <aside class="hidden md:flex w-56 shrink-0 bg-neutral-900 text-white flex-col">
      <div class="px-4 py-5 border-b border-white/10">
        <p class="font-semibold">Vloglish</p>
        <p class="text-xs text-neutral-400 mt-1">管理后台</p>
      </div>
      <nav class="flex-1 p-3 space-y-1 overflow-y-auto">
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

    <!-- 手机侧栏抽屉 -->
    <Teleport to="body">
      <div
        v-if="mobileNavOpen"
        class="md:hidden fixed inset-0 z-50 flex"
      >
        <div class="absolute inset-0 bg-black/40" @click="mobileNavOpen = false" />
        <aside class="relative z-10 w-[min(18rem,85vw)] h-full bg-neutral-900 text-white flex flex-col shadow-xl">
          <div class="px-4 py-4 border-b border-white/10 flex items-center justify-between">
            <div>
              <p class="font-semibold">Vloglish</p>
              <p class="text-xs text-neutral-400 mt-0.5">管理后台</p>
            </div>
            <button
              type="button"
              class="w-9 h-9 rounded-lg text-neutral-300 hover:bg-white/10"
              aria-label="关闭菜单"
              @click="mobileNavOpen = false"
            >
              ×
            </button>
          </div>
          <nav class="flex-1 p-3 space-y-1 overflow-y-auto">
            <RouterLink
              v-for="item in nav"
              :key="item.to"
              :to="item.to"
              class="block px-3 py-2.5 rounded-lg text-sm transition"
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
      </div>
    </Teleport>

    <div class="flex-1 min-w-0 flex flex-col">
      <header class="bg-white border-b border-black/5 px-4 sm:px-6 py-3 sm:py-4 flex items-center gap-3">
        <button
          type="button"
          class="md:hidden shrink-0 w-10 h-10 rounded-lg border border-black/10 flex items-center justify-center text-neutral-700"
          aria-label="打开菜单"
          @click="mobileNavOpen = true"
        >
          <span class="flex flex-col gap-1.5" aria-hidden="true">
            <span class="block w-4 h-0.5 bg-neutral-800 rounded" />
            <span class="block w-4 h-0.5 bg-neutral-800 rounded" />
            <span class="block w-4 h-0.5 bg-neutral-800 rounded" />
          </span>
        </button>
        <h1 class="text-base sm:text-lg font-semibold truncate">{{ pageTitle }}</h1>
      </header>
      <main class="flex-1 p-4 sm:p-6 overflow-auto">
        <RouterView />
      </main>
    </div>

    <AdminEpisodeSubmittedPopup
      :item="currentPopup"
      :busy="popupBusy"
      @dismiss="dismissSubmittedPopup"
      @review="reviewSubmittedPopup"
    />
  </div>
</template>
