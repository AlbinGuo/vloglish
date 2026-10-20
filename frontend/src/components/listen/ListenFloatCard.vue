<script setup lang="ts">
import { useListenPlayerStore } from '@/stores/listenPlayer'
import { resolveMediaUrl } from '@/utils/mediaUrl'
import AppIcon from '@/components/AppIcon.vue'

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
      <AppIcon name="pause" v-if="listen.isPlaying" class="w-3.5 h-3.5" />
      <AppIcon name="play" class="w-3.5 h-3.5 ml-px" />
    </button>
    <button
      type="button"
      class="listen-float-card__close"
      aria-label="关闭听播放"
      @click.stop="onClose"
    >
      <AppIcon name="close" class="w-3.5 h-3.5" />
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
