<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { getContinueReadingArticles, type ContinueReadingItem } from '@/api/articles'
import { getRecentEpisodes, type RecentEpisode } from '@/api/learning'
import { requestEpisodeAutoplay } from '@/composables/useEpisodeAutoplay'
import { useAuthStore } from '@/stores/auth'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const auth = useAuthStore()
const open = ref(false)
const loading = ref(false)
const episodes = ref<RecentEpisode[]>([])
const articles = ref<ContinueReadingItem[]>([])
let closeTimer: ReturnType<typeof setTimeout> | undefined

const label = computed(() => auth.user?.nickname || auth.user?.email || '账户')
const hasAny = computed(() => episodes.value.length > 0 || articles.value.length > 0)

async function loadContinue() {
  if (!auth.isLoggedIn) {
    episodes.value = []
    articles.value = []
    return
  }
  loading.value = true
  try {
    const [epList, artList] = await Promise.all([
      getRecentEpisodes().catch(() => [] as RecentEpisode[]),
      getContinueReadingArticles().catch(() => [] as ContinueReadingItem[]),
    ])
    episodes.value = epList.filter((e) => !e.is_completed).slice(0, 5)
    articles.value = artList.slice(0, 5)
  } catch {
    episodes.value = []
    articles.value = []
  } finally {
    loading.value = false
  }
}

function show() {
  if (closeTimer) {
    clearTimeout(closeTimer)
    closeTimer = undefined
  }
  open.value = true
  void loadContinue()
}

function scheduleHide() {
  if (closeTimer) clearTimeout(closeTimer)
  closeTimer = setTimeout(() => {
    open.value = false
  }, 160)
}

onMounted(() => {
  if (auth.isLoggedIn) void loadContinue()
})

watch(
  () => auth.isLoggedIn,
  (loggedIn) => {
    if (loggedIn) void loadContinue()
    else {
      episodes.value = []
      articles.value = []
      open.value = false
    }
  },
)
</script>

<template>
  <div
    class="relative hidden sm:block"
    @mouseenter="show"
    @mouseleave="scheduleHide"
  >
    <button
      type="button"
      class="inline-flex items-center gap-1 max-w-[12rem] px-2 py-1.5 rounded-lg text-neutral-500 hover:text-black hover:bg-neutral-100 dark:text-neutral-400 dark:hover:text-white dark:hover:bg-neutral-800 transition"
      :aria-expanded="open"
      aria-haspopup="true"
      @focus="show"
      @click="open = !open"
    >
      <span class="truncate">{{ label }}</span>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 20 20"
        fill="currentColor"
        class="w-3.5 h-3.5 shrink-0 opacity-60 transition-transform"
        :class="open ? 'rotate-180' : ''"
        aria-hidden="true"
      >
        <path
          fill-rule="evenodd"
          d="M5.22 8.22a.75.75 0 0 1 1.06 0L10 11.94l3.72-3.72a.75.75 0 1 1 1.06 1.06l-4.25 4.25a.75.75 0 0 1-1.06 0L5.22 9.28a.75.75 0 0 1 0-1.06Z"
          clip-rule="evenodd"
        />
      </svg>
    </button>

    <div
      v-show="open"
      class="absolute right-0 top-full pt-1.5 z-50"
      @mouseenter="show"
      @mouseleave="scheduleHide"
    >
      <div
        class="w-[19rem] rounded-xl border border-black/8 dark:border-white/10 bg-white dark:bg-neutral-900 shadow-lg shadow-black/10 overflow-hidden"
      >
        <div class="flex items-center justify-between px-3 py-2.5 border-b border-black/5 dark:border-white/10">
          <p class="text-sm font-semibold">继续学习</p>
          <RouterLink
            to="/english/learning"
            class="text-xs text-amber-700 dark:text-amber-400 hover:underline"
            @click="open = false"
          >
            全部统计
          </RouterLink>
        </div>

        <div v-if="loading && !hasAny" class="px-3 py-6 text-center text-xs text-neutral-400">
          加载中...
        </div>

        <div v-else-if="hasAny" class="max-h-[26rem] overflow-y-auto">
          <section v-if="episodes.length" class="py-1">
            <p class="px-3 pt-2 pb-1 text-[11px] font-medium text-neutral-400 tracking-wide">
              继续观看
            </p>
            <ul>
              <li v-for="item in episodes" :key="item.video_id">
                <RouterLink
                  :to="`/english/episode/${item.video_id}`"
                  class="flex items-center gap-2.5 px-3 py-2 hover:bg-neutral-50 dark:hover:bg-neutral-800/80 transition"
                  @click="requestEpisodeAutoplay(); open = false"
                >
                  <div class="relative w-[4.5rem] aspect-video rounded-md overflow-hidden bg-neutral-200 dark:bg-neutral-800 shrink-0">
                    <img
                      v-if="item.cover"
                      :src="item.cover"
                      :alt="item.short_title"
                      class="w-full h-full object-cover"
                      loading="lazy"
                    />
                    <span class="absolute bottom-0.5 right-0.5 text-[9px] text-white bg-black/65 px-1 rounded">
                      {{ Math.round(item.completion_percent) }}%
                    </span>
                  </div>
                  <p class="text-xs font-medium leading-snug line-clamp-2 min-w-0">
                    {{ item.short_title }}
                  </p>
                </RouterLink>
              </li>
            </ul>
          </section>

          <section
            v-if="articles.length"
            class="py-1"
            :class="episodes.length ? 'border-t border-black/5 dark:border-white/10' : ''"
          >
            <div class="flex items-center justify-between px-3 pt-2 pb-1">
              <p class="text-[11px] font-medium text-neutral-400 tracking-wide">继续阅读</p>
              <RouterLink
                to="/english/reading"
                class="text-[11px] text-amber-700 dark:text-amber-400 hover:underline"
                @click="open = false"
              >
                读报
              </RouterLink>
            </div>
            <ul>
              <li v-for="item in articles" :key="item.article_id">
                <RouterLink
                  :to="`/english/reading/${item.article_id}`"
                  class="flex items-center gap-2.5 px-3 py-2 hover:bg-neutral-50 dark:hover:bg-neutral-800/80 transition"
                  @click="open = false"
                >
                  <div class="relative w-[4.5rem] aspect-video rounded-md overflow-hidden bg-neutral-200 dark:bg-neutral-800 shrink-0">
                    <img
                      v-if="item.cover"
                      :src="resolveMediaUrl(item.cover)"
                      :alt="item.title"
                      class="w-full h-full object-cover"
                      loading="lazy"
                    />
                    <span class="absolute bottom-0.5 right-0.5 text-[9px] text-white bg-black/65 px-1 rounded">
                      {{ Math.round(item.completion_percent) }}%
                    </span>
                  </div>
                  <div class="min-w-0 flex-1">
                    <p class="text-xs font-medium leading-snug line-clamp-2">{{ item.title }}</p>
                    <p v-if="item.source" class="text-[10px] text-neutral-400 mt-0.5 truncate">
                      {{ item.source }}
                    </p>
                  </div>
                </RouterLink>
              </li>
            </ul>
          </section>
        </div>

        <p v-else class="px-3 py-6 text-center text-xs text-neutral-400">
          暂无未完成的学习记录
        </p>
      </div>
    </div>
  </div>
</template>
