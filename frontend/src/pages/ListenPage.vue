<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import AuthorSubscribeButton from '@/components/AuthorSubscribeButton.vue'
import ListenCue from '@/components/listen/ListenCue.vue'
import ListenEpisodePeek from '@/components/listen/ListenEpisodePeek.vue'
import ListenMoreSheet from '@/components/listen/ListenMoreSheet.vue'
import ListenSwipeHint from '@/components/listen/ListenSwipeHint.vue'
import StarIcon from '@/components/icons/StarIcon.vue'
import { setEpisodeFavorite } from '@/api/episodes'
import { useAuthStore } from '@/stores/auth'
import { useFavoriteToastStore } from '@/stores/favoriteToast'
import { useListenPlayerStore, type ListenQueueItem } from '@/stores/listenPlayer'
import { formatListenTime } from '@/utils/formatListenTime'
import { stripSpeakerMarkers } from '@/utils/subtitleHtml'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const route = useRoute()
const listen = useListenPlayerStore()
const auth = useAuthStore()
const favoriteToast = useFavoriteToastStore()

const moreOpen = ref(false)
const favoriteBusy = ref(false)
const listRoot = ref<HTMLElement | null>(null)
const pageRoot = ref<HTMLElement | null>(null)
const dragY = ref(0)
const switching = ref(false)
const dragging = ref(false)
const snapInstant = ref(false)
const pageH = ref(800)

const videoId = computed(() => String(route.params.videoId || ''))
const isFavorite = computed(() => Boolean(listen.episode?.is_favorite))
const progressMax = computed(() => Math.max(listen.duration || 1, 1))
const progressValue = computed(() => listen.currentTime)
const canSwipeSwitch = computed(() => listen.queue.length > 1 && !listen.loading)

const peekPrev = computed(() => {
  const q = listen.queue
  if (q.length < 2) return null
  const i = listen.queueIndex
  if (i < 0) return q[q.length - 1] ?? null
  return q[i <= 0 ? q.length - 1 : i - 1] ?? null
})
const peekNext = computed(() => {
  const q = listen.queue
  if (q.length < 2) return null
  const i = listen.queueIndex
  if (i < 0) return q[0] ?? null
  return q[i >= q.length - 1 ? 0 : i + 1] ?? null
})

const lockedPrev = ref<ListenQueueItem | null>(null)
const lockedNext = ref<ListenQueueItem | null>(null)
const shownPrev = computed(() => lockedPrev.value ?? peekPrev.value)
const shownNext = computed(() => lockedNext.value ?? peekNext.value)

function preloadCover(url?: string) {
  const src = resolveMediaUrl(url || '')
  if (!src) return
  const img = new Image()
  img.src = src
}

watch(
  () => [peekPrev.value?.cover, peekNext.value?.cover, listen.coverUrl] as const,
  ([prev, next, current]) => {
    preloadCover(prev)
    preloadCover(next)
    preloadCover(current)
  },
  { immediate: true },
)

const layerTransition = computed(() =>
  dragging.value || snapInstant.value ? 'none' : 'transform 280ms cubic-bezier(0.22, 1, 0.36, 1)',
)

function layerShift(index: -1 | 0 | 1) {
  return {
    transform: `translate3d(0, ${index * pageH.value + dragY.value}px, 0)`,
    transition: layerTransition.value,
  }
}

const SWIPE_THRESHOLD = 88
const WHEEL_COOLDOWN_MS = 700
let touchStartX = 0
let touchStartY = 0
let tracking = false
let captured = false
let lastWheelAt = 0

function measurePage() {
  pageH.value = pageRoot.value?.clientHeight || window.innerHeight
}

async function loadFromRoute() {
  if (!videoId.value) return
  if (videoId.value === listen.currentVideoId) return
  await listen.loadEpisode(videoId.value)
}

watch(videoId, () => {
  void loadFromRoute()
})

watch(
  () => listen.currentIndex,
  async () => {
    if (listen.viewMode !== 'subtitles') return
    await nextTick()
    const row = listRoot.value?.querySelector<HTMLElement>('[data-current-cue="1"]')
    row?.scrollIntoView({ block: 'center', behavior: 'smooth' })
  },
)

function overlayOpen() {
  return moreOpen.value || listen.playlistOpen || listen.sleepOpen
}

const swipeHintRef = ref<{ dismiss: () => void } | null>(null)

function isBlockedTarget(target: EventTarget | null) {
  if (!(target instanceof Element)) return false
  return Boolean(target.closest('input[type="range"]'))
}

function listConsumes(dy: number) {
  if (listen.viewMode !== 'subtitles') return false
  const el = listRoot.value
  if (!el) return false
  if (el.scrollHeight <= el.clientHeight + 8) return false
  if (dy < 0 && el.scrollTop + el.clientHeight < el.scrollHeight - 8) return true
  if (dy > 0 && el.scrollTop > 8) return true
  return false
}

function swipeThreshold() {
  return Math.max(SWIPE_THRESHOLD, pageH.value * 0.18)
}

async function switchBySwipe(dir: 'next' | 'prev') {
  if (switching.value || !canSwipeSwitch.value) return
  swipeHintRef.value?.dismiss()
  measurePage()
  lockedPrev.value = peekPrev.value
  lockedNext.value = peekNext.value
  const h = pageH.value || window.innerHeight
  switching.value = true
  dragging.value = false
  dragY.value = dir === 'next' ? -h : h
  await new Promise((resolve) => window.setTimeout(resolve, 280))
  try {
    if (dir === 'next') await listen.playNext()
    else await listen.playPrev({ force: true })
  } finally {
    await nextTick()
    await new Promise<void>((resolve) => {
      requestAnimationFrame(() => requestAnimationFrame(() => resolve()))
    })
    snapInstant.value = true
    dragY.value = 0
    await nextTick()
    requestAnimationFrame(() => {
      lockedPrev.value = null
      lockedNext.value = null
      snapInstant.value = false
      switching.value = false
    })
  }
}

function onTouchStart(e: TouchEvent) {
  if (overlayOpen() || switching.value || sheetAnimating.value || e.touches.length !== 1) return
  if (isBlockedTarget(e.target)) return
  const t = e.touches[0]
  if (!t) return
  measurePage()
  touchStartX = t.clientX
  touchStartY = t.clientY
  tracking = true
  captured = false
  dragging.value = false
}

function onTouchMove(e: TouchEvent) {
  if (!tracking) return
  const t = e.touches[0]
  if (!t) return
  const dx = t.clientX - touchStartX
  const dy = t.clientY - touchStartY
  if (!captured) {
    if (Math.abs(dy) < 12 && Math.abs(dx) < 12) return
    if (Math.abs(dx) > Math.abs(dy)) {
      tracking = false
      return
    }
    if (listConsumes(dy) || overlayOpen()) {
      tracking = false
      return
    }
    captured = true
    dragging.value = true
  }
  if (captured) {
    e.preventDefault()
    const max = pageH.value || window.innerHeight
    let next = dy
    if (!canSwipeSwitch.value) next = dy * 0.28
    dragY.value = Math.max(-max, Math.min(max, next))
  }
}

function onTouchEnd() {
  if (!tracking) return
  tracking = false
  const dy = dragY.value
  captured = false
  dragging.value = false
  if (Math.abs(dy) < swipeThreshold() || !canSwipeSwitch.value) {
    dragY.value = 0
    return
  }
  void switchBySwipe(dy < 0 ? 'next' : 'prev')
}

function onWheel(e: WheelEvent) {
  if (overlayOpen() || switching.value || sheetAnimating.value || !canSwipeSwitch.value) return
  if (e.target instanceof Element && e.target.closest('input')) return
  if (listConsumes(e.deltaY)) return
  if (Math.abs(e.deltaY) < 28) return
  const now = Date.now()
  if (now - lastWheelAt < WHEEL_COOLDOWN_MS) return
  lastWheelAt = now
  e.preventDefault()
  void switchBySwipe(e.deltaY > 0 ? 'next' : 'prev')
}

function onKeyDown(e: KeyboardEvent) {
  if (overlayOpen() || switching.value || sheetAnimating.value || !canSwipeSwitch.value) return
  if (e.target instanceof HTMLElement) {
    if (e.target.closest('input, textarea, select') || e.target.isContentEditable) return
  }
  if (e.key === 'ArrowDown' || e.key === 'PageDown') {
    e.preventDefault()
    void switchBySwipe('next')
    return
  }
  if (e.key === 'ArrowUp' || e.key === 'PageUp') {
    e.preventDefault()
    void switchBySwipe('prev')
  }
}

let swipeCleanup: (() => void) | null = null

function bindSwipe() {
  unbindSwipe()
  const el = pageRoot.value
  if (!el) return
  el.addEventListener('touchstart', onTouchStart, { passive: true, capture: true })
  el.addEventListener('touchmove', onTouchMove, { passive: false, capture: true })
  el.addEventListener('touchend', onTouchEnd, { capture: true })
  el.addEventListener('touchcancel', onTouchEnd, { capture: true })
  el.addEventListener('wheel', onWheel, { passive: false, capture: true })
  swipeCleanup = () => {
    el.removeEventListener('touchstart', onTouchStart, true)
    el.removeEventListener('touchmove', onTouchMove, true)
    el.removeEventListener('touchend', onTouchEnd, true)
    el.removeEventListener('touchcancel', onTouchEnd, true)
    el.removeEventListener('wheel', onWheel, true)
  }
}

function unbindSwipe() {
  swipeCleanup?.()
  swipeCleanup = null
}

watch(pageRoot, () => {
  bindSwipe()
  measurePage()
})

function onSeekInput(event: Event) {
  const el = event.target as HTMLInputElement
  listen.seek(Number(el.value))
}

async function toggleFavorite() {
  if (!listen.episode || favoriteBusy.value || !auth.isMember) return
  favoriteBusy.value = true
  const next = !isFavorite.value
  try {
    const res = await setEpisodeFavorite(listen.episode.video_id, next)
    listen.episode.is_favorite = res.is_favorite
    favoriteToast.show(res.is_favorite, listen.episode.short_title)
  } catch {
    /* ignore */
  } finally {
    favoriteBusy.value = false
  }
}

function goMore() {
  void collapseSheet()
}

const SHEET_MS = 420
const sheetY = ref(listen.sheetMotion === 'opening' ? 100 : 0)
const sheetAnimating = ref(false)
let sheetTimer: ReturnType<typeof setTimeout> | null = null

function prefersReducedMotion() {
  return Boolean(window.matchMedia?.('(prefers-reduced-motion: reduce)').matches)
}

function finishSheetIdle() {
  listen.sheetMotion = 'idle'
  sheetAnimating.value = false
}

async function collapseSheet() {
  if (sheetAnimating.value || listen.sheetMotion === 'closing') return
  if (prefersReducedMotion()) {
    listen.collapse()
    return
  }
  listen.sheetMotion = 'closing'
  sheetAnimating.value = true
  await nextTick()
  sheetY.value = 100
  if (sheetTimer) clearTimeout(sheetTimer)
  sheetTimer = setTimeout(() => {
    listen.collapse()
  }, SHEET_MS)
}

onMounted(() => {
  void loadFromRoute()
  measurePage()
  bindSwipe()
  window.addEventListener('resize', measurePage)
  window.addEventListener('keydown', onKeyDown)
  if (listen.sheetMotion !== 'opening') return
  if (prefersReducedMotion()) {
    sheetY.value = 0
    finishSheetIdle()
    return
  }
  sheetY.value = 100
  sheetAnimating.value = true
  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      sheetY.value = 0
    })
  })
  if (sheetTimer) clearTimeout(sheetTimer)
  sheetTimer = setTimeout(finishSheetIdle, SHEET_MS)
})

onUnmounted(() => {
  unbindSwipe()
  window.removeEventListener('resize', measurePage)
  window.removeEventListener('keydown', onKeyDown)
  if (sheetTimer) clearTimeout(sheetTimer)
  if (listen.sheetMotion === 'opening') {
    listen.sheetMotion = 'idle'
  }
})

const swipeHint = computed(() => {
  if (Math.abs(dragY.value) < 36) return ''
  return dragY.value < 0 ? '松开切换下一集' : '松开切换上一集'
})

const backdropTint = computed(() => {
  const seed = listen.currentVideoId || listen.coverUrl || 'listen'
  let hash = 2166136261
  for (let i = 0; i < seed.length; i += 1) {
    hash ^= seed.charCodeAt(i)
    hash = Math.imul(hash, 16777619)
  }
  const hue = Math.abs(hash) % 360
  return `hsl(${hue} 46% 36%)`
})
</script>

<template>
  <div
    ref="pageRoot"
    class="listen-page-sheet relative h-full min-h-0 overflow-hidden text-white"
    :class="{ 'listen-page-sheet--animating': sheetAnimating }"
    :style="{ transform: `translate3d(0, ${sheetY}%, 0)` }"
  >
    <div
      v-if="shownPrev"
      class="absolute inset-0 z-[1] pointer-events-none"
      :style="layerShift(-1)"
    >
      <ListenEpisodePeek v-if="shownPrev" :key="shownPrev.video_id" :item="shownPrev" />
    </div>

    <div class="absolute inset-0 z-[2]" :style="layerShift(0)">
      <div class="relative h-full min-h-0 overflow-hidden" :style="{ background: backdropTint }">
        <div class="absolute inset-0 z-0 overflow-hidden pointer-events-none">
          <Transition name="listen-bg" :css="!switching">
            <img
              v-if="listen.coverUrl"
              :key="listen.coverUrl"
              :src="listen.coverUrl"
              alt=""
              class="listen-page__blur"
            />
          </Transition>
          <div class="listen-page__veil" />
        </div>

        <div class="relative z-10 h-full min-h-0 flex flex-col">
          <header
            class="relative z-20 shrink-0 flex items-center gap-2 px-3 py-1.5 pt-[max(0.35rem,env(safe-area-inset-top))]"
          >
            <button
              type="button"
              class="w-10 h-10 flex items-center justify-center text-white/90"
              aria-label="收起"
              @click="collapseSheet"
            >
              <svg viewBox="0 0 24 24" class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="1.8">
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
              </svg>
            </button>

            <div class="flex-1 flex justify-center">
              <div class="inline-flex rounded-full bg-black/25 backdrop-blur-md p-0.5 text-sm">
                <button
                  type="button"
                  class="px-3.5 py-1 rounded-full transition"
                  :class="listen.viewMode === 'subtitles' ? 'bg-white/90 text-neutral-900' : 'text-white/70'"
                  @click="listen.setViewMode('subtitles')"
                >
                  字幕
                </button>
                <button
                  type="button"
                  class="px-3.5 py-1 rounded-full transition"
                  :class="listen.viewMode === 'video' ? 'bg-white/90 text-neutral-900' : 'text-white/70'"
                  @click="listen.setViewMode('video')"
                >
                  视频
                </button>
              </div>
            </div>

            <button
              type="button"
              class="px-3 py-1.5 rounded-full bg-white/10 text-sm text-white/90"
              @click="goMore"
            >
              听更多 ›
            </button>
          </header>

          <p v-if="listen.loadError" class="px-5 py-8 text-center text-sm text-red-200">{{ listen.loadError }}</p>
          <p v-else-if="listen.loading && !listen.episode" class="px-5 py-8 text-center text-sm text-white/70">
            加载中...
          </p>

          <div class="flex-1 min-h-0 flex flex-col relative">
            <div
              class="w-full flex justify-center px-3 sm:px-8 md:px-10 lg:px-12"
              :class="
                listen.viewMode === 'video'
                  ? 'relative z-0 shrink-0 mt-10 md:mt-8'
                  : 'absolute inset-0 z-0 mt-10 opacity-0 pointer-events-none'
              "
            >
              <div class="listen-page__video">
                <div class="listen-page__video-sizer" aria-hidden="true" />
                <img
                  v-if="listen.coverUrl"
                  :src="listen.coverUrl"
                  alt=""
                  class="absolute inset-0 w-full h-full object-cover"
                />
                <div id="listen-video-slot" class="absolute inset-0 z-[1] overflow-hidden" />
              </div>
            </div>
            <ListenCue v-if="listen.viewMode === 'video' && listen.episode" compact />

            <div
              v-if="listen.viewMode === 'subtitles' && listen.episode"
              ref="listRoot"
              class="relative z-10 flex-1 min-h-0 overflow-y-auto px-4 md:px-10 py-2"
            >
              <div class="mx-auto w-full max-w-xl md:max-w-3xl space-y-2">
              <button
                v-for="(sub, index) in listen.subs"
                :key="sub.id"
                type="button"
                class="w-full text-center rounded-xl px-3 py-2.5 md:px-4 md:py-3 transition"
                :data-current-cue="index === listen.currentIndex ? '1' : '0'"
                :class="
                  index === listen.currentIndex
                    ? 'bg-white/16 text-white'
                    : 'text-white/55 hover:bg-white/8'
                "
                @click="listen.seekToSub(sub)"
              >
                <p class="text-[15px] md:text-[1.125rem] leading-snug font-medium">
                  {{ stripSpeakerMarkers(sub.english) }}
                </p>
                <p v-if="sub.chinese" class="mt-0.5 md:mt-1 text-xs md:text-sm leading-relaxed opacity-80">
                  {{ stripSpeakerMarkers(sub.chinese) }}
                </p>
              </button>
              </div>
            </div>
          </div>

          <div class="relative z-20 shrink-0 px-5 pt-2 pb-[max(0.8rem,env(safe-area-inset-bottom))]">
          <div class="flex items-start justify-between gap-3">
            <div class="min-w-0">
              <h1 class="text-lg font-semibold leading-snug line-clamp-2">
                {{ listen.episode?.short_title }}
              </h1>
              <div class="mt-1.5 flex items-center gap-2 text-sm text-white/80">
                <span class="truncate">{{ listen.episode?.author?.name }}</span>
                <AuthorSubscribeButton
                  v-if="listen.episode?.author?.id"
                  listen-chip
                  :author-id="listen.episode.author.id"
                  :is-subscribed="Boolean(listen.episode.author.is_subscribed)"
                  :subscriber-count="listen.episode.author.subscriber_count || 0"
                  @update:is-subscribed="(v) => listen.episode && (listen.episode.author.is_subscribed = v)"
                  @update:subscriber-count="(v) => listen.episode && (listen.episode.author.subscriber_count = v)"
                />
              </div>
            </div>
            <div class="flex items-center gap-1 shrink-0">
              <button
                v-if="auth.isMember"
                type="button"
                class="w-9 h-9 flex items-center justify-center"
                :disabled="favoriteBusy"
                :aria-label="isFavorite ? '取消收藏' : '收藏'"
                @click="toggleFavorite"
              >
                <StarIcon
                  :active="isFavorite"
                  size-class="w-5 h-5"
                  active-class="text-amber-400"
                  inactive-class="text-white/55"
                />
              </button>
              <button
                type="button"
                class="min-w-9 px-1 py-0.5 flex flex-col items-center justify-center gap-0.5 text-white/80"
                aria-label="更多"
                @click="moreOpen = true"
              >
                <svg viewBox="0 0 24 24" class="w-5 h-5" fill="currentColor">
                  <circle cx="5" cy="12" r="1.7" />
                  <circle cx="12" cy="12" r="1.7" />
                  <circle cx="19" cy="12" r="1.7" />
                </svg>
                <span class="text-[10px] leading-none">更多</span>
              </button>
            </div>
          </div>

          <div class="mt-4">
            <input
              class="listen-seek w-full"
              type="range"
              min="0"
              :max="progressMax"
              step="0.1"
              :value="progressValue"
              @input="onSeekInput"
            />
            <div class="mt-1 flex justify-between text-[11px] text-white/70 tabular-nums">
              <span>{{ formatListenTime(listen.currentTime) }}</span>
              <span>{{ formatListenTime(listen.duration) }}</span>
            </div>
          </div>

          <div class="mt-1 flex items-center justify-between">
            <button
              type="button"
              class="min-w-11 px-1 py-0.5 flex flex-col items-center justify-center gap-0.5 text-white/85"
              aria-label="定时关闭"
              @click="listen.sleepOpen = true"
            >
              <svg viewBox="0 0 24 24" class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="1.7">
                <circle cx="12" cy="13" r="8" />
                <path stroke-linecap="round" d="M12 9v4l2.5 1.5M9 4h6" />
              </svg>
              <span class="text-[10px] leading-none">定时</span>
            </button>
            <button
              type="button"
              class="w-12 h-12 flex items-center justify-center"
              aria-label="上一首"
              @click="listen.playPrev()"
            >
              <svg viewBox="0 0 24 24" class="w-7 h-7" fill="currentColor">
                <path d="M18 18V6l-8.5 6L18 18ZM6 6h2v12H6V6Z" />
              </svg>
            </button>
            <button
              type="button"
              class="w-16 h-16 rounded-full bg-white text-neutral-900 flex items-center justify-center"
              :aria-label="listen.isPlaying ? '暂停' : '播放'"
              @click="listen.togglePlay()"
            >
              <svg v-if="listen.isPlaying" viewBox="0 0 24 24" class="w-8 h-8" fill="currentColor">
                <path d="M7 5h4v14H7V5Zm6 0h4v14h-4V5Z" />
              </svg>
              <svg v-else viewBox="0 0 24 24" class="w-8 h-8" fill="currentColor">
                <path d="M8 5.2v13.6L19.5 12 8 5.2Z" />
              </svg>
            </button>
            <button
              type="button"
              class="w-12 h-12 flex items-center justify-center"
              aria-label="下一首"
              @click="listen.playNext()"
            >
              <svg viewBox="0 0 24 24" class="w-7 h-7" fill="currentColor">
                <path d="M6 6v12l8.5-6L6 6Zm10 0h2v12h-2V6Z" />
              </svg>
            </button>
            <button
              type="button"
              class="min-w-11 px-1 py-0.5 flex flex-col items-center justify-center gap-0.5 text-white/85"
              aria-label="播放列表"
              @click="listen.playlistOpen = true"
            >
              <svg viewBox="0 0 24 24" class="w-6 h-6" fill="currentColor">
                <path d="M4 6h16v2H4V6Zm0 5h10v2H4v-2Zm0 5h16v2H4v-2Z" />
              </svg>
              <span class="text-[10px] leading-none">列表</span>
            </button>
          </div>
        </div>
        </div>
      </div>
    </div>

    <div
      v-if="shownNext"
      class="absolute inset-0 z-[1] pointer-events-none"
      :style="layerShift(1)"
    >
      <ListenEpisodePeek v-if="shownNext" :key="shownNext.video_id" :item="shownNext" />
    </div>

    <p
      v-if="swipeHint"
      class="pointer-events-none absolute left-1/2 top-[38%] z-20 -translate-x-1/2 rounded-full bg-black/55 px-3 py-1.5 text-xs text-white/90"
    >
      {{ swipeHint }}
    </p>

    <div
      v-if="canSwipeSwitch"
      class="hidden md:flex absolute right-3 lg:right-5 top-1/2 z-30 -translate-y-1/2 flex-col gap-3"
    >
      <button
        type="button"
        class="listen-side-arrow"
        aria-label="上一集"
        :disabled="switching"
        @click="switchBySwipe('prev')"
      >
        <svg viewBox="0 0 24 24" class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 14l6-6 6 6" />
        </svg>
      </button>
      <button
        type="button"
        class="listen-side-arrow"
        aria-label="下一集"
        :disabled="switching"
        @click="switchBySwipe('next')"
      >
        <svg viewBox="0 0 24 24" class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 10l6 6 6-6" />
        </svg>
      </button>
    </div>

    <ListenSwipeHint ref="swipeHintRef" />
    <ListenMoreSheet v-model:open="moreOpen" />
  </div>
</template>

<style scoped>
.listen-page-sheet {
  will-change: transform;
}
.listen-side-arrow {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 999px;
  color: #fff;
  background: rgb(0 0 0 / 0.38);
  border: 1px solid rgb(255 255 255 / 0.22);
  backdrop-filter: blur(10px);
  transition: background 160ms ease, transform 160ms ease;
}
.listen-side-arrow:hover:not(:disabled) {
  background: rgb(0 0 0 / 0.55);
  transform: scale(1.06);
}
.listen-side-arrow:disabled {
  opacity: 0.45;
}
.listen-page-sheet--animating {
  pointer-events: none;
  transition: transform 420ms cubic-bezier(0.32, 0.72, 0, 1);
}
@media (prefers-reduced-motion: reduce) {
  .listen-page-sheet--animating {
    transition-duration: 0.01ms;
  }
}
.listen-page__video {
  position: relative;
  width: 100%;
  max-width: 36rem;
  min-height: 12.5rem;
  overflow: hidden;
  border-radius: 0.75rem;
  background: #111;
}
@media (min-width: 768px) {
  .listen-page__video {
    min-height: 16rem;
    border-radius: 1rem;
    max-width: min(52rem, calc(100vw - 5rem), calc((100dvh - 24rem) * 16 / 9));
  }
}
@media (min-width: 1024px) {
  .listen-page__video {
    max-width: min(64rem, calc(100vw - 6rem), calc((100dvh - 22rem) * 16 / 9));
  }
}
@media (min-width: 1440px) {
  .listen-page__video {
    max-width: min(74rem, calc(100vw - 8rem), calc((100dvh - 20rem) * 16 / 9));
  }
}
.listen-page__video-sizer {
  width: 100%;
  padding-bottom: 56.25%;
  pointer-events: none;
}
.listen-page__blur {
  position: absolute;
  inset: -22%;
  width: 144%;
  height: 144%;
  object-fit: cover;
  filter: blur(52px) saturate(1.75) brightness(0.78);
  transform: scale(1.08);
}
.listen-page__veil {
  position: absolute;
  inset: 0;
  background: linear-gradient(
    180deg,
    rgb(28 18 12 / 0.28) 0%,
    rgb(28 18 12 / 0.08) 42%,
    rgb(28 18 12 / 0.32) 100%
  );
}
.listen-bg-enter-active,
.listen-bg-leave-active {
  transition: opacity 0.45s ease;
}
.listen-bg-enter-from,
.listen-bg-leave-to {
  opacity: 0;
}
#listen-video-slot :deep(video) {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  object-fit: contain;
  object-position: center;
  background: #111;
  z-index: 1;
}
.listen-seek {
  appearance: none;
  height: 4px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.28);
  outline: none;
}
.listen-seek::-webkit-slider-thumb {
  appearance: none;
  width: 14px;
  height: 14px;
  border-radius: 999px;
  background: #fff;
  border: 0;
}
.listen-seek::-moz-range-thumb {
  width: 14px;
  height: 14px;
  border-radius: 999px;
  background: #fff;
  border: 0;
}
</style>
