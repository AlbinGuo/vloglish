<script setup lang="ts">
import { computed } from 'vue'
import type { ListenQueueItem } from '@/stores/listenPlayer'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const props = defineProps<{
  item: ListenQueueItem
}>()

function tintFor(id: string) {
  let hash = 2166136261
  for (let i = 0; i < id.length; i += 1) {
    hash ^= id.charCodeAt(i)
    hash = Math.imul(hash, 16777619)
  }
  return `hsl(${Math.abs(hash) % 360} 46% 36%)`
}

const cover = computed(() => resolveMediaUrl(props.item.cover))
const tint = computed(() => tintFor(props.item.video_id))
</script>

<template>
  <div class="relative h-full min-h-0 overflow-hidden text-white" :style="{ background: tint }">
    <div class="absolute inset-0 overflow-hidden pointer-events-none">
      <img v-if="cover" :src="cover" alt="" class="listen-peek__blur" />
      <div class="listen-peek__veil" />
    </div>
    <div class="relative z-10 h-full min-h-0 flex flex-col">
      <header
        class="shrink-0 flex items-center gap-2 px-3 py-1.5 pt-[max(0.35rem,env(safe-area-inset-top))] opacity-70"
      >
        <span class="w-10 h-10" />
        <div class="flex-1 flex justify-center">
          <span class="h-8 w-28 rounded-full bg-white/15" />
        </div>
        <span class="w-16 h-8" />
      </header>
      <div class="flex-1 min-h-0 flex flex-col">
        <div class="shrink-0 w-full flex justify-center px-3 sm:px-8 md:px-10 lg:px-12 mt-10 md:mt-8">
          <div class="listen-peek__video">
            <div class="listen-peek__video-sizer" aria-hidden="true" />
            <img v-if="cover" :src="cover" alt="" class="absolute inset-0 w-full h-full object-cover" />
          </div>
        </div>
        <p class="px-5 pt-3 text-base font-semibold leading-snug line-clamp-2">{{ item.short_title }}</p>
        <p class="px-5 mt-1 text-sm text-white/75 truncate">{{ item.author_name || 'Vloglish' }}</p>
      </div>
      <div class="shrink-0 px-5 pt-2 pb-[max(0.8rem,env(safe-area-inset-bottom))] opacity-55">
        <div class="h-1 rounded-full bg-white/25" />
        <div class="mt-3 flex items-center justify-between">
          <span class="w-11 h-11" />
          <span class="w-12 h-12 rounded-full bg-white/15" />
          <span class="w-16 h-16 rounded-full bg-white/80" />
          <span class="w-12 h-12 rounded-full bg-white/15" />
          <span class="w-11 h-11" />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.listen-peek__blur {
  position: absolute;
  inset: -22%;
  width: 144%;
  height: 144%;
  object-fit: cover;
  filter: blur(52px) saturate(1.75) brightness(0.78);
}
.listen-peek__veil {
  position: absolute;
  inset: 0;
  background: linear-gradient(
    180deg,
    rgb(28 18 12 / 0.28) 0%,
    rgb(28 18 12 / 0.08) 42%,
    rgb(28 18 12 / 0.32) 100%
  );
}
.listen-peek__video {
  position: relative;
  width: 100%;
  max-width: 36rem;
  min-height: 12.5rem;
  overflow: hidden;
  border-radius: 0.75rem;
  background: #111;
}
@media (min-width: 768px) {
  .listen-peek__video {
    min-height: 16rem;
    border-radius: 1rem;
    max-width: min(52rem, calc(100vw - 5rem), calc((100dvh - 24rem) * 16 / 9));
  }
}
@media (min-width: 1024px) {
  .listen-peek__video {
    max-width: min(64rem, calc(100vw - 6rem), calc((100dvh - 22rem) * 16 / 9));
  }
}
@media (min-width: 1440px) {
  .listen-peek__video {
    max-width: min(74rem, calc(100vw - 8rem), calc((100dvh - 20rem) * 16 / 9));
  }
}
.listen-peek__video-sizer {
  width: 100%;
  padding-bottom: 56.25%;
  pointer-events: none;
}
</style>
