<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { getContinueReadingArticles, type ContinueReadingItem } from '@/api/articles'
import { getRecentEpisodes, type RecentEpisode } from '@/api/learning'
import { requestEpisodeAutoplay } from '@/composables/useEpisodeAutoplay'
import { useAuthStore } from '@/stores/auth'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const emit = defineEmits<{
  logout: []
  feedback: []
}>()

const auth = useAuthStore()
const open = ref(false)
const loading = ref(false)
const episodes = ref<RecentEpisode[]>([])
const articles = ref<ContinueReadingItem[]>([])
const rootEl = ref<HTMLElement | null>(null)
let closeTimer: ReturnType<typeof setTimeout> | undefined

const label = computed(() => auth.user?.nickname || auth.user?.email || '账户')
const avatarInitial = computed(() => {
  const raw = (auth.user?.nickname || auth.user?.email || '?').trim()
  const ch = raw.charAt(0)
  return /[a-z]/i.test(ch) ? ch.toUpperCase() : ch
})
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

function toggle() {
  if (open.value) {
    open.value = false
    return
  }
  show()
}

function close() {
  open.value = false
}

function onDocPointerDown(e: PointerEvent) {
  if (!open.value) return
  const t = e.target as Node | null
  if (t && rootEl.value?.contains(t)) return
  open.value = false
}

function onLogout() {
  close()
  emit('logout')
}

function onFeedback() {
  close()
  emit('feedback')
}

onMounted(() => {
  if (auth.isLoggedIn) void loadContinue()
  document.addEventListener('pointerdown', onDocPointerDown, true)
})

onUnmounted(() => {
  document.removeEventListener('pointerdown', onDocPointerDown, true)
  if (closeTimer) clearTimeout(closeTimer)
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
    ref="rootEl"
    class="relative"
    @mouseenter="show"
    @mouseleave="scheduleHide"
  >
    <button
      type="button"
      class="inline-flex items-center justify-center w-9 h-9 rounded-full bg-neutral-200 dark:bg-neutral-700 text-neutral-800 dark:text-neutral-100 text-sm font-semibold ring-1 ring-black/5 dark:ring-white/10 hover:ring-amber-400/60 transition"
      :aria-expanded="open"
      aria-haspopup="true"
      aria-label="账户菜单"
      @click.stop="toggle"
    >
      {{ avatarInitial }}
    </button>

    <div
      v-show="open"
      class="absolute right-0 top-full pt-1.5 z-50"
      @mouseenter="show"
      @mouseleave="scheduleHide"
    >
      <div
        class="w-[min(19rem,calc(100vw-1.5rem))] rounded-xl border border-black/8 dark:border-white/10 bg-white dark:bg-neutral-900 shadow-lg shadow-black/10 overflow-hidden"
      >
        <div class="flex items-center gap-2.5 px-3 py-3 border-b border-black/5 dark:border-white/10">
          <div
            class="w-9 h-9 rounded-full bg-amber-100 dark:bg-amber-900/40 text-amber-900 dark:text-amber-200 text-sm font-semibold flex items-center justify-center shrink-0"
            aria-hidden="true"
          >
            {{ avatarInitial }}
          </div>
          <div class="min-w-0 flex-1">
            <p class="text-sm font-semibold truncate text-neutral-900 dark:text-neutral-100">
              {{ label }}
            </p>
            <p
              v-if="auth.isMember"
              class="text-[11px] text-amber-700 dark:text-amber-300 mt-0.5"
            >
              会员
            </p>
            <p v-else class="text-[11px] text-neutral-400 mt-0.5">普通用户</p>
          </div>
        </div>

        <div class="flex items-center justify-between px-3 py-2 border-b border-black/5 dark:border-white/10">
          <p class="text-sm font-semibold">继续学习</p>
          <RouterLink
            to="/english/learning"
            class="text-xs text-amber-700 dark:text-amber-400 hover:underline"
            @click="close"
          >
            全部统计
          </RouterLink>
        </div>

        <div v-if="loading && !hasAny" class="px-3 py-6 text-center text-xs text-neutral-400">
          加载中...
        </div>

        <div v-else-if="hasAny" class="max-h-[min(20rem,50dvh)] overflow-y-auto">
          <section v-if="episodes.length" class="py-1">
            <p class="px-3 pt-2 pb-1 text-[11px] font-medium text-neutral-400 tracking-wide">
              继续观看
            </p>
            <ul>
              <li v-for="item in episodes" :key="item.video_id">
                <RouterLink
                  :to="`/english/episode/${item.video_id}`"
                  class="flex items-center gap-2.5 px-3 py-2 hover:bg-neutral-50 dark:hover:bg-neutral-800/80 transition"
                  @click="requestEpisodeAutoplay(); close()"
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
                @click="close"
              >
                读报
              </RouterLink>
            </div>
            <ul>
              <li v-for="item in articles" :key="item.article_id">
                <RouterLink
                  :to="`/english/reading/${item.article_id}`"
                  class="flex items-center gap-2.5 px-3 py-2 hover:bg-neutral-50 dark:hover:bg-neutral-800/80 transition"
                  @click="close"
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

        <div class="border-t border-black/5 dark:border-white/10 py-1">
          <button
            type="button"
            class="w-full flex items-center gap-2 px-3 py-2.5 text-sm text-neutral-700 hover:bg-neutral-50 dark:text-neutral-300 dark:hover:bg-neutral-800/80 transition text-left"
            @click="onFeedback"
          >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" class="w-4 h-4 shrink-0 opacity-70" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 9.75h7.5m-7.5 3h4.5M4.5 19.5l2.25-2.25H18a2.25 2.25 0 0 0 2.25-2.25V6.75A2.25 2.25 0 0 0 18 4.5H6A2.25 2.25 0 0 0 3.75 6.75v10.5c0 .621.504 1.125 1.125 1.125H4.5Z" />
            </svg>
            意见反馈
          </button>
          <button
            type="button"
            class="w-full flex items-center gap-2 px-3 py-2.5 text-sm text-red-600 hover:bg-red-50 dark:text-red-400 dark:hover:bg-red-950/40 transition text-left"
            @click="onLogout"
          >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" class="w-4 h-4 shrink-0" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0 0 13.5 3h-6a2.25 2.25 0 0 0-2.25 2.25v13.5A2.25 2.25 0 0 0 7.5 21h6a2.25 2.25 0 0 0 2.25-2.25V15M12 9l-3 3m0 0 3 3m-3-3h12.75" />
            </svg>
            退出登录
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
