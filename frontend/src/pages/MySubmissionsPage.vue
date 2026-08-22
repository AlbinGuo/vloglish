<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { accentIconFor } from '@/constants/accentOptions'
import { listMyArticleSubmissions, type UserArticleSubmissionItem } from '@/api/articles'
import { getEpisodeList, listMySubmissions, type UserSubmissionItem } from '@/api/episodes'
import EpisodeCard from '@/components/EpisodeCard.vue'
import { useAuthStore } from '@/stores/auth'
import { useMyCorpusBadgeStore } from '@/stores/myCorpusBadge'
import type { EpisodeSummary } from '@/types'

type CorpusTab = 'favorites' | 'videos' | 'articles'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const loading = ref(true)
const error = ref('')
const videoRows = ref<UserSubmissionItem[]>([])
const articleRows = ref<UserArticleSubmissionItem[]>([])
const favoriteEpisodes = ref<EpisodeSummary[]>([])
const corpusBadge = useMyCorpusBadgeStore()

const tab = computed<CorpusTab>(() => {
  const raw = String(route.query.tab || '')
  if (raw === 'articles') return 'articles'
  if (raw === 'videos') return 'videos'
  return 'favorites'
})

const statusLabel: Record<string, string> = {
  draft: '待审核',
  published: '已通过',
  archived: '已下架',
  rejected: '已驳回',
}

const statusClass: Record<string, string> = {
  draft: 'bg-orange-500 text-white',
  published: 'bg-emerald-600/90 text-white',
  archived: 'bg-neutral-600/80 text-white',
  rejected: 'bg-red-500 text-white',
}

const publishedVideos = computed(() => videoRows.value.filter((r) => r.status === 'published'))
const pendingVideos = computed(() => videoRows.value.filter((r) => r.status !== 'published'))
const publishedArticles = computed(() => articleRows.value.filter((r) => r.status === 'published'))
const pendingArticles = computed(() => articleRows.value.filter((r) => r.status !== 'published'))

function formatDate(iso?: string) {
  if (!iso) return ''
  const d = new Date(iso)
  if (Number.isNaN(d.getTime())) return iso.replace('T', ' ').replace('Z', '').slice(0, 16)
  return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
}

function setTab(next: CorpusTab) {
  router.replace({ query: next === 'favorites' ? {} : { tab: next } })
}

function episodePath(ep: EpisodeSummary) {
  if (!auth.isLoggedIn) {
    return `/login?next=${encodeURIComponent(`/english/episode/${ep.video_id}`)}`
  }
  if (ep.requires_membership) return '/pricing'
  return `/english/episode/${ep.video_id}`
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    const [videos, articles, favorites] = await Promise.all([
      listMySubmissions(),
      listMyArticleSubmissions(),
      getEpisodeList({ status: 'favorite', page_size: 50, offset: 0 }),
    ])
    videoRows.value = videos.results
    articleRows.value = articles.results
    favoriteEpisodes.value = favorites.results
    await corpusBadge.markSeen()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

onMounted(load)
watch(
  favoriteEpisodes,
  (list) => {
    if (list.some((ep) => ep.is_favorite === false)) {
      favoriteEpisodes.value = list.filter((ep) => ep.is_favorite !== false)
    }
  },
  { deep: true },
)
</script>

<template>
  <div class="page-container py-6">
    <div class="flex items-center gap-3 text-sm mb-4">
      <RouterLink to="/english" class="text-neutral-500 hover:text-neutral-900 dark:text-neutral-400 dark:hover:text-white">← 返回目录</RouterLink>
      <span class="text-neutral-300 dark:text-neutral-600">|</span>
      <span class="font-medium">我的语料库</span>
      <span class="flex-1" />
      <RouterLink
        v-if="tab === 'videos'"
        to="/english/submit"
        class="rounded-lg bg-amber-500 text-white px-3 py-1.5 text-sm hover:bg-amber-600"
      >
        上传视频
      </RouterLink>
      <RouterLink
        v-else-if="tab === 'articles'"
        to="/english/submit-article"
        class="rounded-lg bg-amber-500 text-white px-3 py-1.5 text-sm hover:bg-amber-600"
      >
        上传文章
      </RouterLink>
    </div>

    <div class="flex gap-1 mb-6 p-1 rounded-xl bg-neutral-100 dark:bg-neutral-800/80 w-fit">
      <button
        type="button"
        class="px-3.5 py-1.5 text-sm rounded-lg transition"
        :class="tab === 'favorites'
          ? 'bg-white dark:bg-neutral-900 shadow-sm font-medium'
          : 'text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200'"
        @click="setTab('favorites')"
      >
        收藏
        <span v-if="favoriteEpisodes.length" class="text-xs text-neutral-400 ml-1">{{ favoriteEpisodes.length }}</span>
      </button>
      <button
        type="button"
        class="px-3.5 py-1.5 text-sm rounded-lg transition"
        :class="tab === 'videos'
          ? 'bg-white dark:bg-neutral-900 shadow-sm font-medium'
          : 'text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200'"
        @click="setTab('videos')"
      >
        我上传的视频
        <span v-if="videoRows.length" class="text-xs text-neutral-400 ml-1">{{ videoRows.length }}</span>
      </button>
      <button
        type="button"
        class="px-3.5 py-1.5 text-sm rounded-lg transition"
        :class="tab === 'articles'
          ? 'bg-white dark:bg-neutral-900 shadow-sm font-medium'
          : 'text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200'"
        @click="setTab('articles')"
      >
        我上传的文章
        <span v-if="articleRows.length" class="text-xs text-neutral-400 ml-1">{{ articleRows.length }}</span>
      </button>
    </div>

    <p v-if="error" class="mb-4 text-sm text-red-600">{{ error }}</p>
    <div v-if="loading" class="text-sm text-neutral-500 py-12 text-center">加载中...</div>

    <template v-else-if="tab === 'favorites'">
      <div v-if="favoriteEpisodes.length" class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
        <EpisodeCard
          v-for="ep in favoriteEpisodes"
          :key="ep.video_id"
          :episode="ep"
          :to="episodePath(ep)"
        />
      </div>
      <div
        v-else
        class="rounded-xl border border-dashed border-black/10 dark:border-white/10 p-12 text-center text-sm text-neutral-500"
      >
        还没有收藏视频。去首页点星星，收藏的内容会出现在这里。
        <RouterLink to="/english" class="text-amber-600 hover:underline ml-1">去首页看看</RouterLink>
      </div>
    </template>

    <template v-else-if="tab === 'videos'">
      <section v-if="publishedVideos.length" class="mb-8">
        <h2 class="text-sm font-medium text-neutral-500 dark:text-neutral-400 mb-3">已通过</h2>
        <ul class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
          <li v-for="row in publishedVideos" :key="row.video_id">
            <RouterLink :to="`/english/episode/${row.video_id}`" class="block group h-full">
              <article class="rounded-xl overflow-hidden border border-black/5 dark:border-white/10 shadow-sm hover:shadow-md transition bg-white dark:bg-neutral-900 h-full">
                <div class="relative aspect-video bg-neutral-200 dark:bg-neutral-800">
                  <img
                    v-if="row.cover"
                    :src="row.cover"
                    :alt="row.short_title"
                    class="w-full h-full object-cover group-hover:scale-[1.02] transition-transform duration-300"
                    loading="lazy"
                  />
                  <div
                    v-else
                    class="w-full h-full flex items-center justify-center text-neutral-400 text-xs"
                  >
                    暂无封面
                  </div>
                  <span
                    class="absolute top-2 left-2 text-[10px] px-1.5 py-0.5 rounded-md font-medium shadow-md"
                    :class="statusClass.published"
                  >
                    {{ statusLabel.published }}
                  </span>
                  <img
                    v-if="accentIconFor(row.accent)"
                    :src="accentIconFor(row.accent)"
                    :alt="row.accent"
                    class="absolute bottom-2 left-2 w-5 h-5 object-contain rounded-full border border-white shadow"
                  />
                </div>
                <div class="p-3 space-y-1">
                  <h3 class="font-semibold text-sm leading-snug line-clamp-2 min-h-[2.5rem]">
                    {{ row.short_title }}
                  </h3>
                  <p class="text-[11px] text-neutral-400">
                    {{ formatDate(row.created_at) }}
                    <span v-if="row.accent"> · {{ row.accent }}</span>
                  </p>
                </div>
              </article>
            </RouterLink>
          </li>
        </ul>
      </section>

      <section v-if="pendingVideos.length">
        <h2 class="text-sm font-medium text-neutral-500 dark:text-neutral-400 mb-3">审核中 / 其他</h2>
        <ul class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-3">
          <li
            v-for="row in pendingVideos"
            :key="row.video_id"
            class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-4"
          >
            <div class="flex items-start justify-between gap-3 mb-2">
              <p class="font-medium text-sm text-neutral-900 dark:text-neutral-100 line-clamp-2">
                {{ row.short_title }}
              </p>
              <span
                class="shrink-0 inline-flex text-[10px] font-medium px-1.5 py-0.5 rounded-md"
                :class="statusClass[row.status] ?? 'bg-neutral-500 text-white'"
              >
                {{ statusLabel[row.status] ?? row.status }}
              </span>
            </div>
            <a
              :href="row.original_video_url"
              target="_blank"
              rel="noopener noreferrer"
              class="text-xs text-neutral-500 hover:underline break-all line-clamp-2"
            >
              {{ row.original_video_url }}
            </a>
            <p class="text-[11px] text-neutral-400 mt-2">
              {{ formatDate(row.created_at) }}
              <span v-if="row.accent"> · {{ row.accent }}</span>
            </p>
            <p v-if="row.status === 'rejected' && row.rejection_reason" class="text-sm text-red-600 dark:text-red-400 mt-2">
              驳回原因：{{ row.rejection_reason }}
            </p>
          </li>
        </ul>
      </section>

      <div
        v-if="!videoRows.length"
        class="rounded-xl border border-dashed border-black/10 dark:border-white/10 p-12 text-center text-sm text-neutral-500"
      >
        暂无视频语料。
        <RouterLink to="/english/submit" class="text-amber-600 hover:underline ml-1">去上传视频</RouterLink>
      </div>
    </template>

    <template v-else>
      <section v-if="publishedArticles.length" class="mb-8">
        <h2 class="text-sm font-medium text-neutral-500 dark:text-neutral-400 mb-3">已通过</h2>
        <ul class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-3">
          <li v-for="row in publishedArticles" :key="row.article_id">
            <RouterLink :to="`/english/reading/${row.article_id}`" class="block group h-full">
              <article class="rounded-xl overflow-hidden border border-black/5 dark:border-white/10 shadow-sm hover:shadow-md transition bg-white dark:bg-neutral-900 h-full">
                <div class="relative aspect-[16/7] bg-neutral-200 dark:bg-neutral-800">
                  <img
                    v-if="row.cover"
                    :src="row.cover"
                    :alt="row.title"
                    class="w-full h-full object-cover group-hover:scale-[1.02] transition-transform duration-300"
                    loading="lazy"
                  />
                  <div
                    v-else
                    class="w-full h-full flex items-center justify-center text-neutral-400 text-xs"
                  >
                    暂无封面
                  </div>
                  <span
                    class="absolute top-2 left-2 text-[10px] px-1.5 py-0.5 rounded-md font-medium shadow-md"
                    :class="statusClass.published"
                  >
                    {{ statusLabel.published }}
                  </span>
                </div>
                <div class="p-3 space-y-1">
                  <h3 class="font-semibold text-sm leading-snug line-clamp-2 min-h-[2.5rem]">
                    {{ row.title }}
                  </h3>
                  <p class="text-[11px] text-neutral-400">
                    {{ formatDate(row.created_at) }}
                    <span v-if="row.source"> · {{ row.source }}</span>
                  </p>
                </div>
              </article>
            </RouterLink>
          </li>
        </ul>
      </section>

      <section v-if="pendingArticles.length">
        <h2 class="text-sm font-medium text-neutral-500 dark:text-neutral-400 mb-3">审核中 / 其他</h2>
        <ul class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-3">
          <li
            v-for="row in pendingArticles"
            :key="row.article_id"
            class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-4"
          >
            <div class="flex items-start justify-between gap-3 mb-2">
              <p class="font-medium text-sm text-neutral-900 dark:text-neutral-100 line-clamp-2">
                {{ row.title }}
              </p>
              <span
                class="shrink-0 inline-flex text-[10px] font-medium px-1.5 py-0.5 rounded-md"
                :class="statusClass[row.status] ?? 'bg-neutral-500 text-white'"
              >
                {{ statusLabel[row.status] ?? row.status }}
              </span>
            </div>
            <a
              v-if="row.source_url"
              :href="row.source_url"
              target="_blank"
              rel="noopener noreferrer"
              class="text-xs text-neutral-500 hover:underline break-all line-clamp-2"
            >
              {{ row.source_url }}
            </a>
            <p v-else-if="row.has_submit_body" class="text-xs text-neutral-500">已粘贴英文正文</p>
            <p class="text-[11px] text-neutral-400 mt-2">{{ formatDate(row.created_at) }}</p>
            <p v-if="row.status === 'rejected' && row.rejection_reason" class="text-sm text-red-600 dark:text-red-400 mt-2">
              驳回原因：{{ row.rejection_reason }}
            </p>
          </li>
        </ul>
      </section>

      <div
        v-if="!articleRows.length"
        class="rounded-xl border border-dashed border-black/10 dark:border-white/10 p-12 text-center text-sm text-neutral-500"
      >
        暂无文章语料。
        <RouterLink to="/english/submit-article" class="text-amber-600 hover:underline ml-1">去上传文章</RouterLink>
      </div>
    </template>
  </div>
</template>
