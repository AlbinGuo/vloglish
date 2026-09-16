<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AuthorSubscribeButton from '@/components/AuthorSubscribeButton.vue'
import ListenCue from '@/components/listen/ListenCue.vue'
import ListenMoreSheet from '@/components/listen/ListenMoreSheet.vue'
import StarIcon from '@/components/icons/StarIcon.vue'
import { setEpisodeFavorite } from '@/api/episodes'
import { useAuthStore } from '@/stores/auth'
import { useFavoriteToastStore } from '@/stores/favoriteToast'
import { useListenPlayerStore } from '@/stores/listenPlayer'
import { copyText } from '@/utils/clipboard'
import { formatListenTime } from '@/utils/formatListenTime'
import { stripSpeakerMarkers } from '@/utils/subtitleHtml'

const route = useRoute()
const router = useRouter()
const listen = useListenPlayerStore()
const auth = useAuthStore()
const favoriteToast = useFavoriteToastStore()

const moreOpen = ref(false)
const copied = ref(false)
const favoriteBusy = ref(false)
const listRoot = ref<HTMLElement | null>(null)
const swipeRoot = ref<HTMLElement | null>(null)
const dragY = ref(0)
const switching = ref(false)
const dragging = ref(false)

const videoId = computed(() => String(route.params.videoId || ''))
const isFavorite = computed(() => Boolean(listen.episode?.is_favorite))
const progressMax = computed(() => Math.max(listen.duration || 1, 1))
const progressValue = computed(() => listen.currentTime)
const canSwipeSwitch = computed(() => listen.queue.length > 1 && !listen.loading)

const SWIPE_THRESHOLD = 72
const WHEEL_COOLDOWN_MS = 700
let touchStartX = 0
let touchStartY = 0
let tracking = false
let captured = false
let lastWheelAt = 0

async function loadFromRoute() {
  if (!videoId.value) return
  if (videoId.value === listen.currentVideoId) return
  await listen.loadEpisode(videoId.value)
}

onMounted(() => {
  void loadFromRoute()
  bindSwipe()
})

onUnmounted(() => {
  unbindSwipe()
})

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

function isBlockedTarget(target: EventTarget | null) {
  if (!(target instanceof Element)) return false
  return Boolean(target.closest('[data-no-swipe], input[type="range"]'))
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

async function switchBySwipe(dir: 'next' | 'prev') {
  if (switching.value || !canSwipeSwitch.value) return
  switching.value = true
  dragY.value = 0
  try {
    if (dir === 'next') await listen.playNext()
    else await listen.playPrev({ force: true })
  } finally {
    window.setTimeout(() => {
      switching.value = false
    }, 280)
  }
}

function onTouchStart(e: TouchEvent) {
  if (overlayOpen() || switching.value || e.touches.length !== 1) return
  if (isBlockedTarget(e.target)) return
  const t = e.touches[0]
  if (!t) return
  touchStartX = t.clientX
  touchStartY = t.clientY
  tracking = true
  captured = false
  dragging.value = false
  dragY.value = 0
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
    const max = 140
    dragY.value = Math.max(-max, Math.min(max, dy * 0.72))
  }
}

function onTouchEnd() {
  if (!tracking) return
  tracking = false
  const dy = dragY.value
  captured = false
  dragging.value = false
  if (Math.abs(dy) < SWIPE_THRESHOLD || !canSwipeSwitch.value) {
    dragY.value = 0
    return
  }
  void switchBySwipe(dy < 0 ? 'next' : 'prev')
}

function onWheel(e: WheelEvent) {
  if (overlayOpen() || switching.value || !canSwipeSwitch.value) return
  if (e.target instanceof Element && e.target.closest('[data-no-swipe], input')) return
  if (listConsumes(e.deltaY)) return
  if (Math.abs(e.deltaY) < 28) return
  const now = Date.now()
  if (now - lastWheelAt < WHEEL_COOLDOWN_MS) return
  lastWheelAt = now
  e.preventDefault()
  void switchBySwipe(e.deltaY > 0 ? 'next' : 'prev')
}

let swipeCleanup: (() => void) | null = null

function bindSwipe() {
  unbindSwipe()
  const el = swipeRoot.value
  if (!el) return
  el.addEventListener('touchstart', onTouchStart, { passive: true })
  el.addEventListener('touchmove', onTouchMove, { passive: false })
  el.addEventListener('touchend', onTouchEnd)
  el.addEventListener('touchcancel', onTouchEnd)
  el.addEventListener('wheel', onWheel, { passive: false })
  swipeCleanup = () => {
    el.removeEventListener('touchstart', onTouchStart)
    el.removeEventListener('touchmove', onTouchMove)
    el.removeEventListener('touchend', onTouchEnd)
    el.removeEventListener('touchcancel', onTouchEnd)
    el.removeEventListener('wheel', onWheel)
  }
}

function unbindSwipe() {
  swipeCleanup?.()
  swipeCleanup = null
}

watch(swipeRoot, () => {
  bindSwipe()
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

async function shareLink() {
  const resolved = router.resolve(`/english/listen/${videoId.value}`)
  const url = new URL(resolved.href, window.location.origin).href
  const ok = await copyText(url)
  copied.value = ok
  window.setTimeout(() => {
    copied.value = false
  }, 1600)
}

function goMore() {
  listen.collapse()
}

const swipeHint = computed(() => {
  if (Math.abs(dragY.value) < 36) return ''
  return dragY.value < 0 ? '松开切换下一集' : '松开切换上一集'
})
</script>

<template>
  <div class="relative h-full min-h-0 overflow-hidden text-white bg-[#15210f]">
    <img
      v-if="listen.coverUrl"
      :src="listen.coverUrl"
      alt=""
      class="absolute inset-0 z-0 w-full h-full object-cover scale-125 blur-2xl opacity-50 pointer-events-none"
    />
    <div class="absolute inset-0 z-0 bg-[#15210f]/78 pointer-events-none" />

    <div class="relative z-10 h-full min-h-0 flex flex-col pt-[max(0.4rem,env(safe-area-inset-top))]">
      <header class="relative z-20 shrink-0 flex items-center gap-2 px-3 py-2">
        <button
          type="button"
          class="w-10 h-10 flex items-center justify-center text-white/90"
          aria-label="收起"
          @click="listen.collapse()"
        >
          <svg viewBox="0 0 24 24" class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="1.8">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6" />
          </svg>
        </button>

        <div class="flex-1 flex justify-center">
          <div class="inline-flex rounded-full bg-white/10 p-0.5 text-sm">
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
      <p v-else-if="listen.loading && !listen.episode" class="px-5 py-8 text-center text-sm text-white/70">加载中...</p>

      <div
        ref="swipeRoot"
        class="flex-1 min-h-0 flex flex-col"
        :class="listen.viewMode === 'video' ? 'touch-none' : ''"
        :style="{
          transform: `translateY(${dragY}px)`,
          transition: dragging ? 'none' : 'transform 180ms ease',
        }"
      >
        <div v-show="listen.viewMode === 'video'" class="relative z-0 shrink-0 px-0">
          <div class="relative isolate w-full aspect-video max-h-[42dvh] min-h-[12rem] overflow-hidden bg-black">
            <div id="listen-video-slot" class="absolute inset-0 overflow-hidden" />
          </div>
          <ListenCue v-if="listen.episode" compact />
        </div>

        <div
          v-show="listen.viewMode === 'subtitles' && listen.episode"
          ref="listRoot"
          class="flex-1 min-h-0 overflow-y-auto px-4 py-2 space-y-2"
        >
            <button
              v-for="(sub, index) in listen.subs"
              :key="sub.id"
              type="button"
              class="w-full text-left rounded-xl px-3 py-2.5 transition"
              :data-current-cue="index === listen.currentIndex ? '1' : '0'"
              :class="
                index === listen.currentIndex
                  ? 'bg-white/16 text-white'
                  : 'text-white/55 hover:bg-white/8'
              "
              @click="listen.seekToSub(sub)"
            >
              <p class="text-[15px] leading-snug font-medium">{{ stripSpeakerMarkers(sub.english) }}</p>
              <p v-if="sub.chinese" class="mt-0.5 text-xs leading-relaxed opacity-80">
                {{ stripSpeakerMarkers(sub.chinese) }}
              </p>
            </button>
          </div>
        </div>

        <div class="relative z-20 shrink-0 px-5 pt-2 pb-[max(0.8rem,env(safe-area-inset-bottom))]" data-no-swipe>
          <div class="flex items-start justify-between gap-3">
            <div class="min-w-0">
              <h1 class="text-lg font-semibold leading-snug line-clamp-2">
                {{ listen.episode?.short_title }}
              </h1>
              <div class="mt-1.5 flex items-center gap-2 text-sm text-white/80">
                <span class="truncate">{{ listen.episode?.author?.name }}</span>
                <AuthorSubscribeButton
                  v-if="listen.episode?.author?.id"
                  compact
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
                class="w-9 h-9 flex items-center justify-center text-white/80"
                aria-label="分享"
                @click="shareLink"
              >
                <svg viewBox="0 0 24 24" class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="1.8">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M7 12v7h10v-7M12 4v12M8 8l4-4 4 4" />
                </svg>
              </button>
              <button
                type="button"
                class="w-9 h-9 flex items-center justify-center text-white/80"
                aria-label="更多"
                @click="moreOpen = true"
              >
                <svg viewBox="0 0 24 24" class="w-5 h-5" fill="currentColor">
                  <circle cx="5" cy="12" r="1.7" />
                  <circle cx="12" cy="12" r="1.7" />
                  <circle cx="19" cy="12" r="1.7" />
                </svg>
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
              class="w-11 h-11 flex flex-col items-center justify-center text-white/85"
              aria-label="定时关闭"
              @click="listen.sleepOpen = true"
            >
              <svg viewBox="0 0 24 24" class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="1.7">
                <circle cx="12" cy="13" r="8" />
                <path stroke-linecap="round" d="M12 9v4l2.5 1.5M9 4h6" />
              </svg>
              <span v-if="listen.sleepEndsAt" class="text-[9px] tabular-nums text-amber-200">
                {{ formatListenTime(listen.sleepLeftSec) }}
              </span>
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
              class="w-11 h-11 flex items-center justify-center text-white/85"
              aria-label="播放列表"
              @click="listen.playlistOpen = true"
            >
              <svg viewBox="0 0 24 24" class="w-6 h-6" fill="currentColor">
                <path d="M4 6h16v2H4V6Zm0 5h10v2H4v-2Zm0 5h16v2H4v-2Z" />
              </svg>
            </button>
          </div>
        </div>
      </div>

    <p
      v-if="swipeHint"
      class="pointer-events-none absolute left-1/2 top-[38%] z-20 -translate-x-1/2 rounded-full bg-black/55 px-3 py-1.5 text-xs text-white/90"
    >
      {{ swipeHint }}
    </p>
    <p
      v-if="copied"
      class="absolute bottom-28 left-1/2 -translate-x-1/2 z-20 px-3 py-1.5 rounded-full bg-black/70 text-xs"
    >
      已复制链接
    </p>

    <ListenMoreSheet v-model:open="moreOpen" />
  </div>
</template>

<style scoped>
#listen-video-slot :deep(video) {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  background: #111;
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
