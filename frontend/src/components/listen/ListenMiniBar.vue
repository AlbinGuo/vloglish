<script setup lang="ts">
import { computed } from 'vue'
import { useListenPlayerStore } from '@/stores/listenPlayer'
import { formatListenTime } from '@/utils/formatListenTime'
import { resolveMediaUrl } from '@/utils/mediaUrl'

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
        <img
          :src="resolveMediaUrl(listen.episode.media.thumbnail_url)"
          alt=""
          class="w-11 h-11 rounded-full object-cover shrink-0"
        />
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
        <svg viewBox="0 0 24 24" class="w-5 h-5" fill="currentColor"><path d="M4 6h16v2H4V6Zm0 5h10v2H4v-2Zm0 5h16v2H4v-2Z"/></svg>
      </button>
      <button
        type="button"
        class="w-9 h-9 shrink-0 flex items-center justify-center text-white"
        :aria-label="listen.isPlaying ? '暂停' : '播放'"
        @click="listen.togglePlay()"
      >
        <svg v-if="listen.isPlaying" viewBox="0 0 24 24" class="w-6 h-6" fill="currentColor">
          <path d="M8 6h3v12H8V6Zm5 0h3v12h-3V6Z" />
        </svg>
        <svg v-else viewBox="0 0 24 24" class="w-6 h-6" fill="currentColor">
          <path d="M8 5.5v13l11-6.5L8 5.5Z" />
        </svg>
      </button>
      <button
        type="button"
        class="w-9 h-9 shrink-0 flex items-center justify-center text-white/90"
        aria-label="下一首"
        @click="listen.playNext()"
      >
        <svg viewBox="0 0 24 24" class="w-5 h-5" fill="currentColor"><path d="M6 6v12l8.5-6L6 6Zm10 0h2v12h-2V6Z"/></svg>
      </button>
    </div>
  </div>
</template>
