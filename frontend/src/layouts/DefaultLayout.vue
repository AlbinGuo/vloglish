<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink, RouterView, useRoute, useRouter } from 'vue-router'
import {
  ackNotificationPopup,
  ackNotificationPopups,
  getPendingPopups,
  type EpisodePublishedPopup as EpisodePublishedPopupItem,
} from '@/api/notifications'
import { normalizePresencePageKey, sendPresenceHeartbeat } from '@/api/presence'
import BrandLogo from '@/components/BrandLogo.vue'
import ContinueLearningDropdown from '@/components/ContinueLearningDropdown.vue'
import EpisodePublishedPopup from '@/components/EpisodePublishedPopup.vue'
import FavoriteCorpusToast from '@/components/FavoriteCorpusToast.vue'
import AiQuotaExhaustedModal from '@/components/ai/AiQuotaExhaustedModal.vue'
import FeedbackModal from '@/components/FeedbackModal.vue'
import { useCatalogMobileHeaderHide } from '@/composables/useCatalogMobileHeaderHide'
import { useAuthStore } from '@/stores/auth'
import { useMyCorpusBadgeStore } from '@/stores/myCorpusBadge'
import { useNotificationStore } from '@/stores/notifications'
import { useSiteConfigStore } from '@/stores/siteConfig'
import { useVocabularyStore } from '@/stores/vocabulary'
import { useClipsStore } from '@/stores/clips'
import { useVoiceCloneStore } from '@/stores/voiceClone'
import AppDownloadEntry from '@/components/AppDownloadEntry.vue'
import ThemeToggle from '@/components/ThemeToggle.vue'
import BindWechatDialog from '@/components/BindWechatDialog.vue'
import ContactAuthorDialog from '@/components/ContactAuthorDialog.vue'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const siteConfig = useSiteConfigStore()
const notifications = useNotificationStore()
const corpusBadge = useMyCorpusBadgeStore()
const vocabulary = useVocabularyStore()
const clips = useClipsStore()
const voiceClone = useVoiceCloneStore()
const feedbackOpen = ref(false)
const bindWechatOpen = ref(false)
const contactAuthorOpen = ref(false)
/** 会员，或关内容限制后的登录用户 */
const canUseMemberTools = computed(() => auth.isMember || siteConfig.memberToolsOpen)

const vocabCount = computed(() => vocabulary.items.length)
const vocabBadgeLabel = computed(() => (vocabCount.value > 99 ? '99+' : String(vocabCount.value)))
const vocabNavActive = computed(() => route.path.startsWith('/english/vocabulary'))
const clipCount = computed(() => clips.items.length)
const clipBadgeLabel = computed(() => (clipCount.value > 99 ? '99+' : String(clipCount.value)))
const clipNavActive = computed(() => route.path.startsWith('/english/clips'))

type PopupUnit =
  | { kind: 'single'; item: EpisodePublishedPopupItem }
  | { kind: 'multi'; items: EpisodePublishedPopupItem[] }

const RELEASE_POPUP_TYPES = new Set(['episode_new_release', 'article_new_release', 'author_new_episode'])

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
let currentPageKey = normalizePresencePageKey(route.name)

async function sendHeartbeat(pageKey?: string | null) {
  if (!auth.isLoggedIn) return
  // 后台标签不计页面停留，仍可跳过本次（回到前台后会补一次）
  if (typeof document !== 'undefined' && document.hidden && pageKey === undefined) {
    return
  }
  const key = pageKey === undefined ? currentPageKey : pageKey
  try {
    await sendPresenceHeartbeat(key)
  } catch {
    // 静默失败，下次轮询再试
  }
}

function onVisibilityChange() {
  if (typeof document === 'undefined' || document.hidden) return
  if (auth.isLoggedIn) void sendHeartbeat()
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
    if (canUseMemberTools.value) void corpusBadge.refresh()
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
  vocabulary.clear()
  clips.clear()
  voiceClone.clear()
  await router.replace('/english')
}

onMounted(() => {
  if (typeof document !== 'undefined') {
    document.addEventListener('visibilitychange', onVisibilityChange)
  }
  if (auth.ready && auth.isLoggedIn) {
    sendHeartbeat()
    refreshUnreadCount()
    void vocabulary.load()
    void clips.load()
    void voiceClone.refresh()
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
  if (typeof document !== 'undefined') {
    document.removeEventListener('visibilitychange', onVisibilityChange)
  }
})

watch(
  () => route.name,
  (name, prevName) => {
    const nextKey = normalizePresencePageKey(name)
    const prevKey = normalizePresencePageKey(prevName)
    if (prevKey && prevKey !== nextKey && auth.isLoggedIn) {
      void sendHeartbeat(prevKey)
    }
    currentPageKey = nextKey
    if (nextKey && auth.isLoggedIn) void sendHeartbeat(nextKey)
  },
)

watch(
  () => [auth.ready, auth.isLoggedIn] as const,
  ([ready, loggedIn]) => {
    if (ready && loggedIn) {
      currentPageKey = normalizePresencePageKey(route.name)
      sendHeartbeat()
      refreshUnreadCount()
      void vocabulary.load()
      void clips.load()
      void voiceClone.refresh()
      startPopupPolling()
    } else if (ready) {
      notifications.clear()
      corpusBadge.clear()
      vocabulary.clear()
      clips.clear()
      voiceClone.clear()
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
      class="z-40 bg-white/90 dark:bg-neutral-900/90 backdrop-blur border-b border-black/5 dark:border-white/10 transition-transform duration-300 ease-out will-change-transform pt-[env(safe-area-inset-top,0px)]"
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

        <div class="flex items-center gap-1 sm:gap-3 text-sm shrink-0">
          <button
            type="button"
            class="inline-flex items-center gap-1.5 rounded-lg transition p-2 sm:px-2 sm:py-1.5 text-neutral-600 hover:text-black hover:bg-neutral-100 dark:text-neutral-400 dark:hover:text-white dark:hover:bg-neutral-800"
            aria-label="联系作者"
            title="联系作者"
            @click="contactAuthorOpen = true"
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
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M7.5 8.25h9m-9 3.75h5.25M21 12c0 4.556-4.03 8.25-9 8.25a9.76 9.76 0 0 1-2.53-.33l-3.97 1.32a.75.75 0 0 1-.95-.95l1.32-3.97A8.7 8.7 0 0 1 3 12c0-4.556 4.03-8.25 9-8.25s9 3.694 9 8.25Z"
              />
            </svg>
            <span class="hidden sm:inline">联系作者</span>
          </button>
          <AppDownloadEntry variant="header" />
          <ThemeToggle />
          <template v-if="auth.isLoggedIn">
            <RouterLink
              to="/english/study"
              class="inline-flex items-center gap-1.5 rounded-lg transition p-2 sm:px-2 sm:py-1.5"
              :class="
                route.path.startsWith('/english/study')
                  ? 'text-teal-800 bg-teal-50 dark:text-teal-200 dark:bg-teal-950/50'
                  : 'text-neutral-600 hover:text-black hover:bg-neutral-100 dark:text-neutral-400 dark:hover:text-white dark:hover:bg-neutral-800'
              "
              aria-label="怎么学"
              title="英语学习方法"
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
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M12 6.042A8.967 8.967 0 0 0 6 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 0 1 6 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 0 1 6-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0 0 18 18a8.967 8.967 0 0 0-6 2.292m0-14.25v14.25"
                />
              </svg>
              <span class="hidden sm:inline">怎么学</span>
            </RouterLink>
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
              to="/english/vocabulary"
              class="relative inline-flex items-center gap-1.5 rounded-lg transition"
              :class="[
                vocabNavActive
                  ? 'text-amber-800 bg-amber-50 dark:text-amber-200 dark:bg-amber-950/50'
                  : 'text-neutral-600 hover:text-black hover:bg-neutral-100 dark:text-neutral-400 dark:hover:text-white dark:hover:bg-neutral-800',
                'p-2 sm:px-2 sm:py-1.5',
              ]"
              aria-label="生词本"
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
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M17.593 3.322c1.1.128 1.907 1.077 1.907 2.185V21L12 17.25 4.5 21V5.507c0-1.108.806-2.057 1.907-2.185a48.507 48.507 0 0 1 11.186 0Z"
                />
              </svg>
              <span class="hidden sm:inline">生词本</span>
              <span
                v-if="vocabCount > 0"
                class="absolute -top-0.5 -right-0.5 min-w-[1.125rem] h-[1.125rem] px-1 rounded-full bg-amber-500 text-white text-[10px] font-semibold flex items-center justify-center leading-none"
              >
                {{ vocabBadgeLabel }}
              </span>
            </RouterLink>
            <RouterLink
              to="/english/clips"
              class="relative inline-flex items-center gap-1.5 rounded-lg transition"
              :class="[
                clipNavActive
                  ? 'text-sky-800 bg-sky-50 dark:text-sky-200 dark:bg-sky-950/50'
                  : 'text-neutral-600 hover:text-black hover:bg-neutral-100 dark:text-neutral-400 dark:hover:text-white dark:hover:bg-neutral-800',
                'p-2 sm:px-2 sm:py-1.5',
              ]"
              aria-label="我的摘录"
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
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M8.25 6.75h7.5M8.25 12h7.5m-7.5 5.25h4.5M3.75 6.75A2.25 2.25 0 0 1 6 4.5h12A2.25 2.25 0 0 1 20.25 6.75v10.5A2.25 2.25 0 0 1 18 19.5H6a2.25 2.25 0 0 1-2.25-2.25V6.75Z"
                />
              </svg>
              <span class="hidden sm:inline">摘录</span>
              <span
                v-if="clipCount > 0"
                class="absolute -top-0.5 -right-0.5 min-w-[1.125rem] h-[1.125rem] px-1 rounded-full bg-sky-500 text-white text-[10px] font-semibold flex items-center justify-center leading-none"
              >
                {{ clipBadgeLabel }}
              </span>
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
            <!-- 开启内容限制时非会员才显示开通入口；关限制后隐藏 -->
            <RouterLink
              v-if="!auth.isMember && siteConfig.isContentGated"
              to="/pricing"
              class="inline-flex items-center justify-center rounded-lg bg-amber-600 text-white hover:bg-amber-700 transition p-2 sm:px-3 sm:py-1.5"
              aria-label="开通会员"
              title="开通会员"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="currentColor"
                class="w-5 h-5 sm:hidden"
                aria-hidden="true"
              >
                <path d="M5 16 3 5l5.5 5L12 4l3.5 6L21 5l-2 11H5Zm0 2h14v2H5v-2Z" />
              </svg>
              <span class="hidden sm:inline text-sm font-medium">开通会员</span>
            </RouterLink>
            <button
              v-if="!auth.user?.wx_bound"
              type="button"
              class="inline-flex items-center rounded-lg border border-amber-700/30 bg-amber-50 text-amber-900 hover:bg-amber-100 dark:bg-amber-950/40 dark:text-amber-200 dark:border-amber-500/30 px-2 py-1.5 text-xs sm:text-sm font-medium transition"
              title="扫一下即关联微信"
              @click="bindWechatOpen = true"
            >
              关联小程序
            </button>
            <ContinueLearningDropdown
              @logout="handleLogout"
              @feedback="feedbackOpen = true"
            />
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
    <!-- 占位高度勿做 transition：动画过程中 scrollY 连续跳变会触发 header 显隐闪烁 -->
    <div
      v-if="!immersive && catalogHeaderAutoHide"
      class="shrink-0 pointer-events-none overflow-hidden"
      :class="catalogHeaderVisible ? 'h-[calc(4.25rem+env(safe-area-inset-top,0px))]' : 'h-0'"
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
    <FavoriteCorpusToast />
    <FeedbackModal v-model:open="feedbackOpen" />
    <BindWechatDialog v-model:open="bindWechatOpen" />
    <ContactAuthorDialog v-model:open="contactAuthorOpen" />
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
