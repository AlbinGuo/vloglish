<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink, RouterView, useRoute, useRouter } from 'vue-router'
import {
  ackNotificationPopup,
  ackNotificationPopups,
  getPendingPopups,
  type EpisodePublishedPopup as EpisodePublishedPopupItem,
} from '@/api/notifications'
import { sendPresenceHeartbeat } from '@/api/presence'
import BrandLogo from '@/components/BrandLogo.vue'
import ContinueLearningDropdown from '@/components/ContinueLearningDropdown.vue'
import EpisodePublishedPopup from '@/components/EpisodePublishedPopup.vue'
import AiQuotaExhaustedModal from '@/components/ai/AiQuotaExhaustedModal.vue'
import FeedbackModal from '@/components/FeedbackModal.vue'
import { useCatalogMobileHeaderHide } from '@/composables/useCatalogMobileHeaderHide'
import { useAuthStore } from '@/stores/auth'
import { useMyCorpusBadgeStore } from '@/stores/myCorpusBadge'
import { useNotificationStore } from '@/stores/notifications'
import ThemeToggle from '@/components/ThemeToggle.vue'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const notifications = useNotificationStore()
const corpusBadge = useMyCorpusBadgeStore()
const feedbackOpen = ref(false)

type PopupUnit =
  | { kind: 'single'; item: EpisodePublishedPopupItem }
  | { kind: 'multi'; items: EpisodePublishedPopupItem[] }

const RELEASE_POPUP_TYPES = new Set(['episode_new_release', 'article_new_release'])

function isReleasePopup(item: EpisodePublishedPopupItem) {
  return RELEASE_POPUP_TYPES.has(item.type)
}

function unitEarliestAt(unit: PopupUnit) {
  if (unit.kind === 'single') return unit.item.created_at
  return unit.items.reduce((min, row) => (row.created_at < min ? row.created_at : min), unit.items[0].created_at)
}

function buildPopupUnits(results: EpisodePublishedPopupItem[]): PopupUnit[] {
  const releases = results.filter(isReleasePopup)
  const others = results.filter((r) => !isReleasePopup(r))
  const units: PopupUnit[] = []
  if (releases.length >= 2) {
    units.push({ kind: 'multi', items: releases })
  } else {
    for (const item of releases) units.push({ kind: 'single', item })
  }
  for (const item of others) units.push({ kind: 'single', item })
  units.sort((a, b) => {
    const ta = unitEarliestAt(a)
    const tb = unitEarliestAt(b)
    if (ta !== tb) return ta < tb ? -1 : 1
    const ida = a.kind === 'single' ? a.item.id : a.items[0]?.id ?? 0
    const idb = b.kind === 'single' ? b.item.id : b.items[0]?.id ?? 0
    return ida - idb
  })
  return units
}

const popupUnits = ref<PopupUnit[]>([])
const popupBusy = ref(false)
const currentUnit = computed(() => popupUnits.value[0] ?? null)
const currentPopupItem = computed(() =>
  currentUnit.value?.kind === 'single' ? currentUnit.value.item : null,
)
const currentPopupItems = computed(() =>
  currentUnit.value?.kind === 'multi' ? currentUnit.value.items : null,
)

const immersive = computed(() => Boolean(route.meta.immersive))
const { headerVisible: catalogHeaderVisible, catalogHeaderAutoHide } = useCatalogMobileHeaderHide()

let pollTimer: ReturnType<typeof setInterval> | null = null
let popupPollTimer: ReturnType<typeof setInterval> | null = null

async function sendHeartbeat() {
  if (!auth.isLoggedIn) return
  try {
    await sendPresenceHeartbeat()
  } catch {
    // 静默失败，下次轮询再试
  }
}

async function refreshUnreadCount() {
  if (!auth.isLoggedIn) {
    notifications.clear()
    return
  }
  await notifications.refresh()
}

async function refreshPendingPopups() {
  if (!auth.isLoggedIn) {
    popupUnits.value = []
    return
  }
  try {
    const results = await getPendingPopups()
    const units = buildPopupUnits(results)
    const head = currentUnit.value
    if (head) {
      const headIds = new Set(
        head.kind === 'multi' ? head.items.map((i) => i.id) : [head.item.id],
      )
      const stillHead = results.filter((r) => headIds.has(r.id))
      if (stillHead.length) {
        let headUnit: PopupUnit | null = null
        if (stillHead.length >= 2 && stillHead.every(isReleasePopup)) {
          headUnit = { kind: 'multi', items: stillHead }
        } else if (stillHead.length === 1) {
          headUnit = { kind: 'single', item: stillHead[0] }
        } else {
          headUnit = buildPopupUnits(stillHead)[0] ?? null
        }
        const rest = buildPopupUnits(results.filter((r) => !headIds.has(r.id)))
        popupUnits.value = headUnit ? [headUnit, ...rest] : rest
      } else {
        popupUnits.value = units
      }
    } else {
      popupUnits.value = units
    }
    if (auth.isMember) void corpusBadge.refresh()
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
  popupUnits.value = []
}

async function ackCurrentPopup() {
  const unit = currentUnit.value
  if (!unit || popupBusy.value) return
  popupBusy.value = true
  const ids = unit.kind === 'multi' ? unit.items.map((i) => i.id) : [unit.item.id]
  try {
    if (ids.length > 1) await ackNotificationPopups(ids)
    else await ackNotificationPopup(ids[0])
    popupUnits.value = popupUnits.value.slice(1)
    await refreshUnreadCount()
  } catch {
    // 失败时仍关闭本地项，避免卡死；下次轮询会再出现
    popupUnits.value = popupUnits.value.slice(1)
  } finally {
    popupBusy.value = false
  }
}

async function dismissPublishedPopup() {
  await ackCurrentPopup()
}

async function openPublishedPopup(payload: { videoId?: string; articleId?: string }) {
  await ackCurrentPopup()
  if (payload.videoId) {
    await router.push(`/english/episode/${payload.videoId}`)
  } else if (payload.articleId) {
    await router.push(`/english/reading/${payload.articleId}`)
  }
}

async function handleLogout() {
  stopPopupPolling()
  await auth.logout()
  notifications.clear()
  corpusBadge.clear()
  await router.replace('/english')
}

onMounted(() => {
  if (auth.ready && auth.isLoggedIn) {
    sendHeartbeat()
    refreshUnreadCount()
    startPopupPolling()
  }
  pollTimer = setInterval(() => {
    if (auth.isLoggedIn) {
      sendHeartbeat()
      refreshUnreadCount()
    }
  }, 60000)
})

onUnmounted(() => {
  if (pollTimer) clearInterval(pollTimer)
  stopPopupPolling()
})

watch(
  () => [auth.ready, auth.isLoggedIn] as const,
  ([ready, loggedIn]) => {
    if (ready && loggedIn) {
      sendHeartbeat()
      refreshUnreadCount()
      startPopupPolling()
    } else if (ready) {
      notifications.clear()
      corpusBadge.clear()
      stopPopupPolling()
    }
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
      class="z-40 bg-white/90 dark:bg-neutral-900/90 backdrop-blur border-b border-black/5 dark:border-white/10 transition-transform duration-300 ease-out will-change-transform"
      :class="[
        catalogHeaderAutoHide ? 'fixed inset-x-0 top-0' : 'sticky top-0',
        catalogHeaderVisible ? 'translate-y-0' : '-translate-y-full',
      ]"
    >
      <div class="page-container py-3 flex items-center justify-between gap-4">
        <RouterLink to="/english" class="group flex items-center gap-3 shrink-0 min-w-0">
          <BrandLogo
            class="transition-transform duration-200 group-hover:scale-[1.04]"
            :size="34"
          />
          <span class="flex flex-col min-w-0">
            <span class="text-[1.05rem] font-semibold tracking-[-0.02em] leading-tight">Vloglish</span>
            <span class="text-[11px] text-neutral-500 dark:text-neutral-400 tracking-[0.01em] leading-tight mt-0.5">
              Real vlogs · Real English
            </span>
          </span>
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
            <button
              type="button"
              class="hidden sm:inline-flex items-center gap-1 px-2 py-1.5 rounded-lg text-neutral-600 hover:text-black hover:bg-neutral-100 dark:text-neutral-400 dark:hover:text-white dark:hover:bg-neutral-800 transition"
              @click="feedbackOpen = true"
            >
              反馈
            </button>
            <button
              type="button"
              class="sm:hidden p-2 rounded-lg text-neutral-600 hover:text-black hover:bg-neutral-100 dark:text-neutral-400 dark:hover:text-white dark:hover:bg-neutral-800 transition"
              aria-label="意见反馈"
              @click="feedbackOpen = true"
            >
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" class="w-5 h-5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 9.75h7.5m-7.5 3h4.5M4.5 19.5l2.25-2.25H18a2.25 2.25 0 0 0 2.25-2.25V6.75A2.25 2.25 0 0 0 18 4.5H6A2.25 2.25 0 0 0 3.75 6.75v10.5c0 .621.504 1.125 1.125 1.125H4.5Z" />
              </svg>
            </button>
            <span
              v-if="auth.isMember"
              class="text-xs px-2 py-1 rounded-full bg-amber-100 text-amber-800 dark:bg-amber-900/50 dark:text-amber-300"
            >
              会员
            </span>
            <RouterLink
              v-else
              to="/pricing"
              class="px-3 py-1.5 rounded-lg bg-amber-600 text-white text-sm font-medium hover:bg-amber-700 transition"
            >
              开通会员
            </RouterLink>
            <ContinueLearningDropdown />
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
    <div
      v-if="!immersive && catalogHeaderAutoHide"
      class="shrink-0 pointer-events-none overflow-hidden transition-[height] duration-300 ease-out"
      :class="catalogHeaderVisible ? 'h-[4.25rem]' : 'h-0'"
      aria-hidden="true"
    />
    <main class="flex-1" :class="immersive ? 'min-h-0 overflow-hidden' : ''">
      <RouterView v-slot="{ Component, route }">
        <KeepAlive include="HomePage">
          <component
            :is="Component"
            :key="route.name === 'HomePage' ? 'HomePage' : route.fullPath"
          />
        </KeepAlive>
      </RouterView>
    </main>
    <FeedbackModal v-model:open="feedbackOpen" />
    <AiQuotaExhaustedModal />
    <EpisodePublishedPopup
      :item="currentPopupItem"
      :items="currentPopupItems"
      :busy="popupBusy"
      @dismiss="dismissPublishedPopup"
      @open="openPublishedPopup"
    />
  </div>
</template>
