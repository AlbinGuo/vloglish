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
import ListenFloatCard from '@/components/listen/ListenFloatCard.vue'
import ListenMiniBar from '@/components/listen/ListenMiniBar.vue'
import ListenPlayerHost from '@/components/listen/ListenPlayerHost.vue'
import ListenPlaylistSheet from '@/components/listen/ListenPlaylistSheet.vue'
import ListenSleepSheet from '@/components/listen/ListenSleepSheet.vue'
import { useListenPlayerStore } from '@/stores/listenPlayer'
import { isMobileAppBuild } from '@/utils/platform'
import AppIcon from '@/components/AppIcon.vue'
import UserAvatar from '@/components/UserAvatar.vue'
import BottomTabBar from '@/components/layout/BottomTabBar.vue'

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

const listen = useListenPlayerStore()
const immersive = computed(() => Boolean(route.meta.immersive))
const showListenMiniBar = computed(
  () =>
    listen.hasSession &&
    route.name !== 'EpisodePage' &&
    route.name !== 'DemoEpisode' &&
    route.name !== 'AdminEpisodePreview' &&
    (route.name === 'ListenHome' ||
      (route.name === 'ListenEpisode' && listen.sheetMotion !== 'idle')),
)
const showListenMiniBarSpacer = computed(() => showListenMiniBar.value && route.name === 'ListenHome')
const showListenFloatCard = computed(
  () =>
    listen.hasSession &&
    route.name !== 'ListenEpisode' &&
    route.name !== 'ListenHome' &&
    route.name !== 'EpisodePage' &&
    route.name !== 'DemoEpisode' &&
    route.name !== 'AdminEpisodePreview',
)
const { headerVisible: catalogHeaderVisible, catalogHeaderAutoHide } = useCatalogMobileHeaderHide()

/** 移动端底部 Tab Bar：仅非沉浸式页面、已登录时显示 */
const showBottomTabs = computed(() => !immersive.value && auth.isLoggedIn && !route.meta.landing)

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
    const raw = await getPendingPopups()
    // App 端不展示"新剧集/文章发布"类弹窗（管理端发布后不应打扰移动端用户）
    const results = isMobileAppBuild() ? raw.filter((r) => !isReleasePopup(r)) : raw
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
  void listen.hydrateSession()
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
    class="flex flex-col bg-canvas"
    :class="immersive ? 'h-dvh overflow-hidden' : 'min-h-dvh'"
  >
    <header
      v-if="!immersive"
      class="max-sm:hidden z-40 bg-card-glass backdrop-blur border-b border-line-soft transition-transform duration-300 ease-out will-change-transform pt-[env(safe-area-inset-top,0px)]"
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
            <span class="text-[11px] text-ink-faint tracking-[0.01em] leading-tight mt-0.5">
              Real vlogs · Real English
            </span>
          </span>
        </RouterLink>

        <div class="flex items-center gap-1 sm:gap-3 text-sm shrink-0">
          <button
            type="button"
            class="inline-flex items-center gap-1.5 rounded-lg transition p-2 sm:px-2 sm:py-1.5 text-ink-soft hover:text-ink hover:bg-sunken"
            aria-label="联系作者"
            title="联系作者"
            @click="contactAuthorOpen = true"
          >
            <AppIcon name="chat-bubble" class="w-5 h-5 shrink-0" />
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
                  ? 'text-brand-on-soft bg-brand-soft'
                  : 'text-ink-soft hover:text-ink hover:bg-sunken'
              "
              aria-label="怎么学"
              title="英语学习方法"
            >
              <AppIcon name="book-open" class="w-5 h-5 shrink-0" />
              <span class="hidden sm:inline">怎么学</span>
            </RouterLink>
            <RouterLink
              to="/english/learning"
              class="hidden sm:inline-flex items-center gap-1.5 px-2 py-1.5 rounded-lg text-ink-soft hover:text-ink hover:bg-sunken transition"
            >
              <AppIcon name="chart-bar" class="w-5 h-5 shrink-0" />
              学习统计
            </RouterLink>
            <RouterLink
              to="/english/vocabulary"
              class="relative inline-flex items-center gap-1.5 rounded-lg transition"
              :class="[
                vocabNavActive
                  ? 'text-warning bg-warning-soft'
                  : 'text-ink-soft hover:text-ink hover:bg-sunken',
                'p-2 sm:px-2 sm:py-1.5',
              ]"
              aria-label="生词本"
            >
              <AppIcon name="flag" class="w-5 h-5 shrink-0" />
              <span class="hidden sm:inline">生词本</span>
              <span
                v-if="vocabCount > 0"
                class="absolute -top-0.5 -right-0.5 min-w-[1.125rem] h-[1.125rem] px-1 rounded-full bg-warning text-ink-inverse text-[10px] font-semibold flex items-center justify-center leading-none"
              >
                {{ vocabBadgeLabel }}
              </span>
            </RouterLink>
            <RouterLink
              to="/english/clips"
              class="relative inline-flex items-center gap-1.5 rounded-lg transition"
              :class="[
                clipNavActive
                  ? 'text-info bg-info-soft'
                  : 'text-ink-soft hover:text-ink hover:bg-sunken',
                'p-2 sm:px-2 sm:py-1.5',
              ]"
              aria-label="我的摘录"
            >
              <AppIcon name="clipboard-list" class="w-5 h-5 shrink-0" />
              <span class="hidden sm:inline">摘录</span>
              <span
                v-if="clipCount > 0"
                class="absolute -top-0.5 -right-0.5 min-w-[1.125rem] h-[1.125rem] px-1 rounded-full bg-info text-ink-inverse text-[10px] font-semibold flex items-center justify-center leading-none"
              >
                {{ clipBadgeLabel }}
              </span>
            </RouterLink>
            <RouterLink
              to="/english/notifications"
              class="relative p-2 rounded-lg text-ink-soft hover:text-ink hover:bg-sunken transition"
              aria-label="通知"
            >
              <AppIcon name="bell" class="w-5 h-5" />
              <span
                v-if="notifications.unreadCount > 0"
                class="absolute -top-0.5 -right-0.5 min-w-[1.125rem] h-[1.125rem] px-1 rounded-full bg-danger text-ink-inverse text-[10px] font-semibold flex items-center justify-center leading-none"
              >
                {{ notifications.unreadCount > 99 ? '99+' : notifications.unreadCount }}
              </span>
            </RouterLink>
            <!-- 开启内容限制时非会员才显示开通入口；关限制后隐藏 -->
            <RouterLink
              v-if="!auth.isMember && siteConfig.isContentGated"
              to="/pricing"
              class="inline-flex items-center justify-center rounded-lg bg-brand text-ink-inverse hover:bg-brand-hover transition p-2 sm:px-3 sm:py-1.5"
              aria-label="开通会员"
              title="开通会员"
            >
              <AppIcon name="crown" class="w-5 h-5 sm:hidden" />
              <span class="hidden sm:inline text-sm font-medium">开通会员</span>
            </RouterLink>
            <button
              v-if="!auth.user?.wx_bound"
              type="button"
              class="inline-flex items-center rounded-lg border border-warning/30 bg-warning-soft text-warning hover:opacity-90 px-2 py-1.5 text-xs sm:text-sm font-medium transition"
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
            <RouterLink to="/login" class="text-ink-soft hover:text-ink">登录</RouterLink>
            <RouterLink
              to="/signup"
              class="px-3 py-1.5 rounded-lg bg-ink text-ink-inverse text-sm hover:opacity-90"
            >
              注册
            </RouterLink>
          </template>
        </div>
      </div>
    </header>
    <!-- 移动端轻量 header：品牌 + 通知 + 我的头像（底部 Tab 负责主导航） -->
    <header
      v-if="!immersive"
      class="sm:hidden sticky top-0 z-40 bg-card-glass backdrop-blur border-b border-line-soft pt-[env(safe-area-inset-top,0px)]"
    >
      <div class="px-4 py-2 flex items-center justify-between gap-3">
        <RouterLink to="/english" class="flex items-center gap-2 min-w-0 shrink-0">
          <BrandLogo :size="26" />
          <span class="text-[1rem] font-semibold tracking-[-0.02em] leading-none">Vloglish</span>
        </RouterLink>
        <div class="flex items-center gap-0.5">
          <RouterLink
            v-if="auth.isLoggedIn"
            to="/english/notifications"
            class="relative inline-flex items-center justify-center rounded-lg p-2 text-ink-soft transition hover:bg-sunken"
            aria-label="通知"
          >
            <AppIcon name="bell" class="w-5 h-5" />
            <span
              v-if="notifications.unreadCount > 0"
              class="absolute top-0.5 right-0.5 min-w-[1.05rem] h-[1.05rem] px-1 rounded-full bg-danger text-ink-inverse text-[10px] font-semibold flex items-center justify-center leading-none"
            >
              {{ notifications.unreadCount > 99 ? '99+' : notifications.unreadCount }}
            </span>
          </RouterLink>
          <RouterLink
            :to="auth.isLoggedIn ? '/english/mine' : '/login'"
            class="inline-flex items-center justify-center rounded-full p-1 transition active:scale-95"
            aria-label="我的"
          >
            <UserAvatar
              v-if="auth.isLoggedIn"
              :avatar-key="auth.user?.avatar_key"
              :user-id="auth.user?.id"
              size-class="w-7 h-7"
              alt=""
            />
            <AppIcon v-else name="user" class="w-6 h-6 text-ink-soft" />
          </RouterLink>
        </div>
      </div>
    </header>
    <!-- 占位高度勿做 transition：动画过程中 scrollY 连续跳变会触发 header 显隐闪烁 -->
    <div
      v-if="!immersive && catalogHeaderAutoHide"
      class="max-sm:hidden shrink-0 pointer-events-none overflow-hidden"
      :class="catalogHeaderVisible ? 'h-[calc(4.25rem+env(safe-area-inset-top,0px))]' : 'h-0'"
      aria-hidden="true"
    />
    <main
      class="flex-1"
      :class="[
        immersive ? 'min-h-0 overflow-hidden' : '',
        showBottomTabs ? 'pb-[var(--tabbar-offset)]' : '',
      ]"
    >
      <RouterView v-slot="{ Component, route }">
        <KeepAlive include="HomePage">
          <component
            :is="Component"
            :key="route.name === 'HomePage' ? 'HomePage' : route.name === 'ListenEpisode' ? 'ListenEpisode' : route.fullPath"
          />
        </KeepAlive>
      </RouterView>
    </main>
    <div
      v-if="showListenMiniBarSpacer"
      class="shrink-0"
      :style="{
        height: showBottomTabs
          ? 'calc(4.35rem + var(--tabbar-offset))'
          : 'calc(4.35rem + env(safe-area-inset-bottom, 0px))',
      }"
      aria-hidden="true"
    />
    <div
      v-if="showListenMiniBar"
      class="fixed inset-x-0 z-40"
      :class="showBottomTabs ? 'bottom-[var(--tabbar-offset)]' : 'bottom-0 pb-[env(safe-area-inset-bottom,0px)]'"
    >
      <ListenMiniBar />
    </div>
    <div
      v-if="showListenFloatCard"
      class="fixed z-40 right-3"
      :class="
        showBottomTabs
          ? 'bottom-[calc(var(--tabbar-offset)+0.85rem)]'
          : 'bottom-[max(1.25rem,calc(env(safe-area-inset-bottom,0px)+0.85rem))]'
      "
    >
      <ListenFloatCard />
    </div>
    <BottomTabBar v-if="showBottomTabs" :vocab-count="vocabCount" />
    <ListenPlayerHost />
    <ListenPlaylistSheet />
    <ListenSleepSheet />
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
