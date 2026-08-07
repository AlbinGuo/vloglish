<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { requestEpisodeAutoplay } from '@/composables/useEpisodeAutoplay'
import { useDemoStore } from '@/stores/demo'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const router = useRouter()
const store = useDemoStore()
const inputCode = ref(store.code || 'ALICE')

onMounted(() => {
  if (store.verified) store.init()
})

async function submit() {
  store.code = inputCode.value
  const ok = await store.verify()
  if (ok && store.episodes.length === 1) {
    requestEpisodeAutoplay()
    router.push(`/english/demo/${store.episodes[0].video_id}`)
  }
}

function formatDuration(sec: number) {
  const m = Math.floor(sec / 60)
  const s = Math.floor(sec % 60)
  return `${m}:${String(s).padStart(2, '0')}`
}

function openEpisode(videoId: string) {
  requestEpisodeAutoplay()
  router.push(`/english/demo/${videoId}`)
}
</script>

<template>
  <div class="min-h-dvh bg-neutral-50 dark:bg-neutral-950 flex flex-col">
    <div v-if="!store.verified" class="flex-1 flex items-center justify-center p-6">
      <div class="w-full max-w-sm space-y-6 text-center">
        <div>
          <p class="text-4xl font-semibold border-b border-black/10 dark:border-white/10 pb-2 mb-2">Vloglish</p>
          <p class="text-lg text-neutral-600 dark:text-neutral-300">请输入体验码</p>
        </div>
        <form class="space-y-4" @submit.prevent="submit">
          <input
            v-model="inputCode"
            type="text"
            placeholder="体验码"
            class="w-full px-4 py-3 border border-neutral-300 dark:border-white/10 dark:bg-neutral-900 dark:text-white rounded-xl text-base focus:outline-none focus:ring-2 focus:ring-black/10 dark:focus:ring-white/10"
            autocomplete="off"
          />
          <p v-if="store.error" class="text-red-500 text-sm">{{ store.error }}</p>
          <button
            type="submit"
            :disabled="store.loading || !inputCode"
            class="w-full py-3 bg-black text-white rounded-xl font-medium disabled:opacity-40 dark:bg-neutral-100 dark:text-neutral-900 dark:hover:bg-white"
          >
            {{ store.loading ? '验证中...' : '继续' }}
          </button>
        </form>
      </div>
    </div>

    <div v-else class="flex-1 p-6 sm:p-8 max-w-5xl mx-auto w-full">
      <div class="flex justify-between items-center mb-8">
        <div>
          <p class="text-2xl font-semibold">Vloglish</p>
          <p class="text-sm text-neutral-500 dark:text-neutral-400">Real vlogs · Real English · 试用</p>
        </div>
        <h2 class="text-2xl font-semibold">试看内容</h2>
      </div>

      <div v-if="store.loading" class="text-center py-12 text-neutral-500">加载中...</div>
      <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          v-for="ep in store.episodes"
          :key="ep.video_id"
          class="cursor-pointer group"
          @click="openEpisode(ep.video_id)"
        >
          <div class="rounded-2xl overflow-hidden border border-black/5 dark:border-white/10 shadow-sm hover:opacity-90 transition">
            <div class="relative aspect-video bg-neutral-200 dark:bg-neutral-800">
              <img :src="resolveMediaUrl(ep.cover)" :alt="ep.short_title" class="w-full h-full object-cover" loading="lazy" />
              <span class="absolute bottom-2 right-2 text-white text-xs bg-black/60 px-2 py-0.5 rounded">
                {{ formatDuration(ep.clip_length) }}
              </span>
            </div>
            <div class="p-4 bg-white dark:bg-neutral-900">
              <div class="flex items-center gap-2 mb-1">
                <span>{{ ep.author.nationality }}</span>
                <span class="text-sm font-medium">{{ ep.author.name }}</span>
              </div>
              <p class="font-medium mb-1">{{ ep.short_title }}</p>
              <p class="text-xs text-neutral-500 dark:text-neutral-400 line-clamp-2">{{ ep.summary }}</p>
              <div class="flex gap-0.5 mt-2">
                <span v-for="n in 5" :key="n" class="text-sm" :class="n <= ep.stars ? 'text-amber-400' : 'text-neutral-300 dark:text-neutral-600'">★</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
