<script setup lang="ts">
import { computed } from 'vue'
import { useListenPlayerStore } from '@/stores/listenPlayer'
import { formatListenTime } from '@/utils/formatListenTime'
import { resolveMediaUrl } from '@/utils/mediaUrl'
import AppIcon from '@/components/AppIcon.vue'

const listen = useListenPlayerStore()

const progress = computed(() => {
  const d = listen.duration || 0
  if (d <= 0) return 0
  return Math.min(100, (listen.currentTime / d) * 100)
})
</script>

<template>
  <div
    v-if="listen.hasSession && listen.episode"
    class="listen-mini-bar w-full text-white bg-[#1c2416]/95 backdrop-blur border-t border-white/10"
  >
    <div class="h-0.5 bg-white/15">
      <div class="h-full bg-amber-400" :style="{ width: `${progress}%` }" />
    </div>
    <div class="flex items-center gap-3 px-3 py-2">
      <button type="button" class="flex items-center gap-3 min-w-0 flex-1 text-left" @click="listen.expand()">
        <span
          class="listen-mini-bar__cover shrink-0"
          :class="{ 'is-spinning': listen.isPlaying }"
        >
          <img
            :src="resolveMediaUrl(listen.episode.media.thumbnail_url)"
            alt=""
          />
        </span>
        <div class="min-w-0 flex-1">
          <p class="text-sm font-medium text-white truncate">{{ listen.episode.short_title }}</p>
          <p class="text-[11px] text-white/70 tabular-nums">
            {{ formatListenTime(listen.currentTime) }}/{{ formatListenTime(listen.duration) }}
          </p>
        </div>
      </button>
      <button
        type="button"
        class="w-9 h-9 shrink-0 flex items-center justify-center text-white/90"
        aria-label="播放列表"
        @click="listen.playlistOpen = true"
      >
        <AppIcon name="align-left" class="w-5 h-5" />
      </button>
      <button
        type="button"
        class="w-9 h-9 shrink-0 flex items-center justify-center text-white"
        :aria-label="listen.isPlaying ? '暂停' : '播放'"
        @click="listen.togglePlay()"
      >
        <AppIcon name="pause" v-if="listen.isPlaying" class="w-6 h-6" />
        <AppIcon name="play" class="w-6 h-6" />
      </button>
      <button
        type="button"
        class="w-9 h-9 shrink-0 flex items-center justify-center text-white/90"
        aria-label="下一首"
        @click="listen.playNext()"
      >
        <AppIcon name="fast-forward" class="w-5 h-5" />
      </button>
    </div>
  </div>
</template>

<style scoped>
.listen-mini-bar__cover {
  width: 2.75rem;
  height: 2.75rem;
  border-radius: 999px;
  overflow: hidden;
  border: 2px solid #fff;
  background: #243041;
  box-shadow: 0 0 0 1px rgb(0 0 0 / 0.18);
}
.listen-mini-bar__cover img {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: cover;
  animation: listen-cover-spin 9s linear infinite;
  animation-play-state: paused;
}
.listen-mini-bar__cover.is-spinning img {
  animation-play-state: running;
}
@keyframes listen-cover-spin {
  to {
    transform: rotate(360deg);
  }
}
@media (prefers-reduced-motion: reduce) {
  .listen-mini-bar__cover img {
    animation: none;
  }
}
</style>
