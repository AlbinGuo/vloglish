<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import type { usePlayerControls } from '@/composables/usePlayerControls'
import { useIsPhone } from '@/composables/useBreakpoint'
import VideoProgressBar from '@/components/player/VideoProgressBar.vue'
import PlayerTapGuide from '@/components/player/PlayerTapGuide.vue'
import playIcon from '@/assets/svg/play2.svg'
import { resumeMedia } from '@/utils/playMedia'

const HIDE_DELAY_MS = 3000
const TAP_GUIDE_KEY = 'teco-player-tap-guide-seen'

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

const isPhone = useIsPhone()
const guideVisible = ref(false)

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

// ===== HLS（m3u8）支持：B 站视频边转边播 =====
const isHlsSrc = computed(() => /\.m3u8(\?|$)/i.test(props.src || ''))
const nativeHlsSupport = (() => {
  try {
    const probe = document.createElement('video')
    return !!probe.canPlayType && probe.canPlayType('application/vnd.apple.mpegurl') !== ''
  } catch {
    return false
  }
})()
const bindSrc = computed(() => (isHlsSrc.value && !nativeHlsSupport ? '' : props.src))

let hlsInstance: any = null

function teardownHls() {
  try {
    hlsInstance?.destroy?.()
  } catch {
    /* ignore */
  }
  hlsInstance = null
}

async function setupHls() {
  const el = videoEl.value
  if (!el || !isHlsSrc.value || nativeHlsSupport) return
  const mod: any = await import('hls.js')
  const Hls = mod.default || mod
  teardownHls()
  if (Hls && typeof Hls.isSupported === 'function' && Hls.isSupported()) {
    const hls = new Hls({ maxBufferLength: 30 })
    hlsInstance = hls
    hls.on(Hls.Events.ERROR, (_evt: unknown, data: { fatal?: boolean }) => {
      if (data?.fatal) {
        // 回退：交给浏览器直接尝试该地址（或由上层替换源）
        try {
          el.src = props.src
        } catch {
          /* ignore */
        }
      }
    })
    hls.loadSource(props.src)
    hls.attachMedia(el)
  } else {
    el.src = props.src
  }
}

watch(videoEl, (el) => {
  if (el && isHlsSrc.value && !nativeHlsSupport) void setupHls()
})

watch(
  () => props.src,
  () => {
    if (isHlsSrc.value && !nativeHlsSupport) void setupHls()
    else teardownHls()
  },
)
// ===== HLS end =====

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

// 视频首帧就绪前用封面（poster）作为背景，避免起播前黑一下
const frameReady = ref(false)
watch(
  () => props.src,
  () => {
    frameReady.value = false
  },
)
function onFrameReady() {
  frameReady.value = true
}
const videoFrameStyle = computed(() => {
  if (frameReady.value || !props.poster) return undefined
  return {
    backgroundImage: `url("${props.poster}")`,
    backgroundSize: 'cover',
    backgroundPosition: 'center',
  }
})

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

function onTapZone(zone: 'left' | 'middle' | 'right') {
  if (youtubeId.value || guideVisible.value) return
  if (zone === 'middle') {
    onVideoClick()
    return
  }
  try {
    navigator.vibrate?.(10)
  } catch {
    /* ignore */
  }
  if (zone === 'left') props.player.prevSentence()
  else props.player.nextSentence()
}

function dismissTapGuide() {
  guideVisible.value = false
  try {
    localStorage.setItem(TAP_GUIDE_KEY, '1')
  } catch {
    /* ignore */
  }
}

function maybeShowTapGuide() {
  if (!isPhone.value || props.hidden || youtubeId.value) return
  if (guideVisible.value) return
  try {
    if (localStorage.getItem(TAP_GUIDE_KEY) === '1') return
  } catch {
    /* ignore */
  }
  // 一直显示，直到用户点按任意处关闭
  guideVisible.value = true
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
  teardownHls()
  props.registerVideo?.(null)
})

onMounted(() => {
  // 首次进入视频页（手机端）给出画面上点按操作指引
  window.setTimeout(maybeShowTapGuide, 800)
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
    :style="videoFrameStyle"
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
      :src="bindSrc"
      :poster="poster"
      preload="auto"
      playsinline
      webkit-playsinline
      referrerpolicy="no-referrer"
      class="w-full h-full object-contain bg-black cursor-pointer transition-opacity duration-200"
      :class="frameReady ? 'opacity-100' : 'opacity-0'"
      @loadeddata="onFrameReady"
      @canplay="onFrameReady"
      @loadedmetadata="onLoadedMetadata"
      @durationchange="onLoadedMetadata"
      @timeupdate="onTimeUpdate"
      @play="player.onPlayState"
      @pause="player.onPlayState"
      @ended="player.onVideoEnded"
      @error="onVideoError"
    />

    <template v-if="!hidden && !youtubeId">
      <!-- 手机端：三分区点按（左=上一句，中=播放/暂停，右=下一句） -->
      <div v-if="isPhone" class="absolute inset-0 z-10 flex">
        <button
          type="button"
          class="h-full flex-1 cursor-pointer border-0 bg-transparent p-0"
          aria-label="上一句"
          @click.stop="onTapZone('left')"
        />
        <button
          type="button"
          class="h-full flex-1 cursor-pointer border-0 bg-transparent p-0"
          aria-label="播放或暂停"
          @click.stop="onTapZone('middle')"
        />
        <button
          type="button"
          class="h-full flex-1 cursor-pointer border-0 bg-transparent p-0"
          aria-label="下一句"
          @click.stop="onTapZone('right')"
        />
      </div>

      <!-- 桌面端：点击切换播放 / 暂停 -->
      <div
        v-else
        class="absolute inset-0 z-10 cursor-pointer"
        aria-label="播放或暂停"
        @click="onVideoClick"
      />

      <!-- 中心播放按钮（暂停时） -->
      <div
        v-if="showCenterPlay && !guideVisible"
        class="pointer-events-none absolute inset-0 z-[11] flex items-center justify-center bg-black/10"
      >
        <img
          :src="playIcon"
          alt=""
          class="w-10 h-10 sm:w-12 sm:h-12 drop-shadow-md pointer-events-none"
          aria-hidden="true"
        />
      </div>

      <!-- 首次使用：播放器点按操作指引 -->
      <PlayerTapGuide v-if="guideVisible" @dismiss="dismissTapGuide" />

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
