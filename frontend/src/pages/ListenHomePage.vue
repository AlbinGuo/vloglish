<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import EnglishCatalogNavBar from '@/components/english/EnglishCatalogNavBar.vue'
import EnglishNavTabs from '@/components/english/EnglishNavTabs.vue'
import { getEpisodeList } from '@/api/episodes'
import { useAuthStore } from '@/stores/auth'
import { useListenPlayerStore } from '@/stores/listenPlayer'
import { useSiteConfigStore } from '@/stores/siteConfig'
import type { EpisodeSummary } from '@/types'
import { formatListenTime } from '@/utils/formatListenTime'
import { isOpenToFreeUsers } from '@/utils/episodeAccess'
import { resolveMediaUrl } from '@/utils/mediaUrl'

defineOptions({ name: 'ListenHomePage' })

const router = useRouter()
const auth = useAuthStore()
const siteConfig = useSiteConfigStore()
const listen = useListenPlayerStore()

const episodes = ref<EpisodeSummary[]>([])
const total = ref(0)
const loading = ref(false)
const loadingMore = ref(false)
const search = ref('')
const loadMoreSentinel = ref<HTMLElement | null>(null)
let observer: IntersectionObserver | null = null
let searchTimer: ReturnType<typeof setTimeout> | undefined

const hasMore = computed(() => episodes.value.length < total.value)

async function load(reset = false) {
  if (reset) {
    loading.value = true
  } else {
    loadingMore.value = true
  }
  try {
    const offset = reset ? 0 : episodes.value.length
    const data = await getEpisodeList({
      page: 1,
      page_size: 20,
      offset,
      search: search.value.trim() || undefined,
      ordering: 'published_at',
    })
    total.value = data.count
    episodes.value = reset ? data.results : [...episodes.value, ...data.results]
  } finally {
    loading.value = false
    loadingMore.value = false
  }
}

function setupObserver() {
  observer?.disconnect()
  observer = new IntersectionObserver(
    (entries) => {
      if (!entries[0]?.isIntersecting) return
      if (hasMore.value && !loading.value && !loadingMore.value) void load(false)
    },
    { rootMargin: '240px' },
  )
  if (loadMoreSentinel.value) observer.observe(loadMoreSentinel.value)
}

function playRow(ep: EpisodeSummary) {
  if (!auth.isLoggedIn) {
    void router.push(`/login?next=${encodeURIComponent(`/english/listen/${ep.video_id}`)}`)
    return
  }
  if (ep.requires_membership && siteConfig.isContentGated && !auth.isMember && !isOpenToFreeUsers(ep)) {
    void router.push({ path: '/pricing', query: { next: `/english/listen/${ep.video_id}` } })
    return
  }
  void listen.enqueueAndPlay(ep, true)
}

onMounted(async () => {
  await load(true)
  setupObserver()
})

onUnmounted(() => {
  observer?.disconnect()
  if (searchTimer) clearTimeout(searchTimer)
})

watch(search, (value) => {
  if (searchTimer) clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    void load(true)
  }, 280)
  void value
})

watch(
  () => loadMoreSentinel.value,
  () => setupObserver(),
)
</script>

<template>
  <div>
    <EnglishCatalogNavBar />

    <div class="page-container pt-3 pb-8 sm:py-6">
      <EnglishNavTabs class="hidden sm:block mb-5" />

      <label class="sr-only" for="listen-home-search">搜索可听节目</label>
      <input
        id="listen-home-search"
        v-model="search"
        type="search"
        placeholder="搜索要听的节目"
        class="w-full mb-4 rounded-xl border border-line bg-card dark:text-white px-3 py-2.5 text-sm placeholder:text-neutral-400 focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:focus:ring-white/10"
      />

      <p v-if="loading && !episodes.length" class="py-24 text-center text-neutral-500">加载中...</p>
      <p v-else-if="!episodes.length" class="py-24 text-center text-neutral-500">没有可听的节目</p>

      <div v-else class="space-y-2">
        <button
          v-for="ep in episodes"
          :key="ep.video_id"
          type="button"
          class="w-full flex items-center gap-3 rounded-xl border border-line-soft bg-card p-3 text-left hover:bg-sunken transition"
          :class="ep.video_id === listen.currentVideoId ? 'ring-1 ring-amber-400/80' : ''"
          @click="playRow(ep)"
        >
          <div class="relative w-20 sm:w-24 shrink-0 aspect-video rounded-lg overflow-hidden bg-neutral-200 dark:bg-neutral-800">
            <img :src="resolveMediaUrl(ep.cover)" :alt="ep.short_title" class="w-full h-full object-cover" loading="lazy" />
            <span class="absolute bottom-1 right-1 text-[10px] text-white bg-black/60 px-1 rounded tabular-nums">
              {{ formatListenTime(ep.clip_length) }}
            </span>
          </div>
          <div class="min-w-0 flex-1">
            <p class="text-sm font-medium leading-snug line-clamp-2">{{ ep.short_title }}</p>
            <p class="mt-1 text-xs text-neutral-500 truncate">{{ ep.author.name }}</p>
          </div>
          <span class="shrink-0 w-9 h-9 rounded-full bg-neutral-900 text-white dark:bg-white dark:text-neutral-900 flex items-center justify-center">
            <svg viewBox="0 0 24 24" class="w-4 h-4 ml-0.5" fill="currentColor"><path d="M8 5.5v13l11-6.5L8 5.5Z" /></svg>
          </span>
        </button>
      </div>

      <div ref="loadMoreSentinel" class="h-1" aria-hidden="true" />
      <p v-if="loadingMore" class="py-6 text-center text-sm text-neutral-400">加载中...</p>
    </div>
  </div>
</template>
