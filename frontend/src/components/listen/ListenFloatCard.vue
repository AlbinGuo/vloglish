<script setup lang="ts">
import { useListenPlayerStore } from '@/stores/listenPlayer'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const listen = useListenPlayerStore()

function onClose() {
  listen.dismissSession()
}
</script>

<template>
  <div
    v-if="listen.hasSession && listen.episode"
    class="listen-float-card pointer-events-auto"
  >
    <button
      type="button"
      class="listen-float-card__body"
      aria-label="回到听页"
      @click="listen.expand()"
    >
      <span class="listen-float-card__cover-wrap">
        <img
          :src="resolveMediaUrl(listen.episode.media.thumbnail_url)"
          alt=""
          class="listen-float-card__cover"
        />
      </span>
    </button>
    <button
      type="button"
      class="listen-float-card__play"
      :aria-label="listen.isPlaying ? '暂停' : '播放'"
      @click.stop="listen.togglePlay()"
    >
      <svg v-if="listen.isPlaying" viewBox="0 0 24 24" class="w-3.5 h-3.5" fill="currentColor">
        <path d="M8 6h3v12H8V6Zm5 0h3v12h-3V6Z" />
      </svg>
      <svg v-else viewBox="0 0 24 24" class="w-3.5 h-3.5 ml-px" fill="currentColor">
        <path d="M8 5.5v13l11-6.5L8 5.5Z" />
      </svg>
    </button>
    <button
      type="button"
      class="listen-float-card__close"
      aria-label="关闭听播放"
      @click.stop="onClose"
    >
      <svg viewBox="0 0 24 24" class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2.4">
        <path stroke-linecap="round" d="M7 7l10 10M17 7 7 17" />
      </svg>
    </button>
  </div>
</template>

<style scoped>
.listen-float-card {
  position: relative;
  width: 5.85rem;
  height: 6.55rem;
  border-radius: 1.45rem;
  background: #3e5163;
  box-shadow: 0 12px 30px rgba(15, 23, 42, 0.32);
}
.listen-float-card__body {
  display: block;
  width: 100%;
  height: 100%;
  padding: 0.42rem 0.42rem 1.28rem;
}
.listen-float-card__cover-wrap {
  display: block;
  width: 100%;
  height: 100%;
  overflow: hidden;
  border-radius: 999px;
  background: #243041;
}
.listen-float-card__cover {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.listen-float-card__play,
.listen-float-card__close {
  position: absolute;
  bottom: 0.22rem;
  width: 1.7rem;
  height: 1.7rem;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
}
.listen-float-card__play {
  left: 0.32rem;
}
.listen-float-card__close {
  right: 0.32rem;
}
</style>
