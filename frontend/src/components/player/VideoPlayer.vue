<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from 'vue'
import type { usePlayerControls } from '@/composables/usePlayerControls'
import VideoProgressBar from '@/components/player/VideoProgressBar.vue'
import playIcon from '@/assets/svg/play2.svg'
import { resumeMedia } from '@/utils/playMedia'

const HIDE_DELAY_MS = 3000

const props = defineProps<{
  src: string
  poster?: string
  hidden?: boolean
  autoplay?: boolean
  registerVideo?: (el: HTMLVideoElement | null) => void
  player: ReturnType<typeof usePlayerControls>
  showProgressBar?: boolean
  /** PC/Pad：播放中无操作 3 秒后隐藏 overlay 进度条 */
  autoHideProgress?: boolean
  /** 手机端沉浸式：去掉圆角与阴影，贴边显示 */
  flush?: boolean
}>()

const videoEl = ref<HTMLVideoElement | null>(null)
const controlsVisible = ref(true)
const isHovering = ref(false)
const isProgressHover = ref(false)

let hideTimer: ReturnType<typeof setTimeout> | null = null

const showProgress = computed(() => props.showProgressBar !== false)

const overlayProgressVisible = computed(() => {
  if (!showProgress.value) return false
  if (!props.autoHideProgress) return true
  if (!props.player.isPlaying.value) return true
  return controlsVisible.value || isHovering.value || isProgressHover.value
})

function clearHideTimer() {
  if (hideTimer) {
    clearTimeout(hideTimer)
    hideTimer = null
  }
}

function revealControls() {
  if (!props.autoHideProgress) return
  controlsVisible.value = true
  scheduleHide()
}

function scheduleHide() {
  clearHideTimer()
  if (!props.autoHideProgress) return
  if (!props.player.isPlaying.value) return
  if (isHovering.value || isProgressHover.value) return

  hideTimer = setTimeout(() => {
    if (props.player.isPlaying.value && !isHovering.value && !isProgressHover.value) {
      controlsVisible.value = false
    }
  }, HIDE_DELAY_MS)
}

function onVideoHover(active: boolean) {
  if (!props.autoHideProgress) return
  isHovering.value = active
  if (active) {
    controlsVisible.value = true
    clearHideTimer()
  } else {
    scheduleHide()
  }
}

function onProgressHover(active: boolean) {
  if (!props.autoHideProgress) return
  isProgressHover.value = active
  if (active) {
    controlsVisible.value = true
    clearHideTimer()
  } else {
    scheduleHide()
  }
}

watch(
  () => props.player.isPlaying.value,
  (playing) => {
    if (!props.autoHideProgress) return
    if (playing) {
      controlsVisible.value = true
      scheduleHide()
    } else {
      controlsVisible.value = true
      clearHideTimer()
    }
  },
  { immediate: true },
)

function parseYoutubeId(src: string): string | null {
  if (!src) return null
  const embed = src.match(/youtube\.com\/embed\/([a-zA-Z0-9_-]{11})/)
  if (embed) return embed[1]!
  const watch = src.match(/(?:youtu\.be\/|[?&]v=)([a-zA-Z0-9_-]{11})/)
  if (watch) return watch[1]!
  if (/^[a-zA-Z0-9_-]{11}$/.test(src)) return src
  return null
}

const youtubeId = computed(() => parseYoutubeId(props.src))

const youtubeEmbedSrc = computed(() => {
  if (!youtubeId.value) return ''
  const params = new URLSearchParams({ rel: '0' })
  if (props.autoplay) params.set('autoplay', '1')
  return `https://www.youtube.com/embed/${youtubeId.value}?${params.toString()}`
})

watch(videoEl, (el) => {
  if (!youtubeId.value) props.registerVideo?.(el)
})

watch(youtubeId, (id) => {
  if (id) props.registerVideo?.(null)
})

const showCenterPlay = computed(
  () =>
    !props.hidden &&
    !youtubeId.value &&
    !props.player.isPlaying.value &&
    !props.player.gapActive.value,
)

function onLoadedMetadata() {
  const v = videoEl.value
  if (props.autoplay && v) {
    void resumeMedia(v).catch(() => {})
  }
}

function onTimeUpdate() {
  props.player.onTimeUpdate()
}

function onVideoClick() {
  if (youtubeId.value) return
  props.player.togglePlay()
}

function onVideoError() {
  const code = videoEl.value?.error?.code
  if (code === 4) {
    console.error(
      '视频无法播放：浏览器不支持该编码（常见于 HEVC/H.265）。请重新抓取素材或转码为 H.264。',
    )
  }
}

onUnmounted(() => {
  clearHideTimer()
  props.registerVideo?.(null)
})
</script>

<template>
  <div
    class="w-full"
    :class="
      hidden
        ? 'fixed w-px h-px opacity-0 pointer-events-none overflow-hidden'
        : props.flush
          ? 'relative aspect-video overflow-hidden bg-black cursor-pointer'
          : 'relative aspect-video rounded-xl overflow-hidden bg-black shadow-sm cursor-pointer'
    "
    @mouseenter="onVideoHover(true)"
    @mouseleave="onVideoHover(false)"
  >
    <iframe
      v-if="youtubeId && !hidden"
      :key="youtubeEmbedSrc"
      :src="youtubeEmbedSrc"
      title="YouTube video"
      class="w-full h-full border-0 bg-black"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
      allowfullscreen
    />

    <video
      v-else
      ref="videoEl"
      :src="src"
      :poster="poster"
      playsinline
      webkit-playsinline
      referrerpolicy="no-referrer"
      class="w-full h-full object-contain bg-black cursor-pointer"
      @loadedmetadata="onLoadedMetadata"
      @durationchange="onLoadedMetadata"
      @timeupdate="onTimeUpdate"
      @play="player.onPlayState"
      @pause="player.onPlayState"
      @ended="player.onVideoEnded"
      @error="onVideoError"
    />

    <template v-if="!hidden && !youtubeId">
      <!-- 点击区域：播放 / 暂停 -->
      <div
        class="absolute inset-0 z-10 cursor-pointer"
        aria-label="播放或暂停"
        @click="onVideoClick"
      >
        <div
          v-if="showCenterPlay"
          class="flex h-full items-center justify-center bg-black/10 pointer-events-none"
        >
          <img
            :src="playIcon"
            alt=""
            class="w-10 h-10 sm:w-12 sm:h-12 drop-shadow-md pointer-events-none"
            aria-hidden="true"
          />
        </div>
      </div>

      <!-- 底部进度条 -->
      <div
        v-if="showProgress"
        class="absolute bottom-0 left-0 right-0 z-20 transition-opacity duration-300 ease-out"
        :class="overlayProgressVisible ? 'opacity-100' : 'opacity-0 pointer-events-none'"
        @mouseenter="onProgressHover(true)"
        @mouseleave="onProgressHover(false)"
      >
        <VideoProgressBar
          :video="videoEl"
          variant="overlay"
          @seek="revealControls"
        />
      </div>
    </template>
  </div>
</template>
