<script setup lang="ts">
defineOptions({ name: 'MySubmissionsPage' })
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { accentIconFor } from '@/constants/accentOptions'
import { listMyArticleSubmissions, type UserArticleSubmissionItem } from '@/api/articles'
import { getEpisodeList, listMySubmissions, type UserSubmissionItem } from '@/api/episodes'
import { getSubtitleFavorites, removeSubtitleFavorite, type SubtitleFavorite } from '@/api/subtitleFavorites'
import EpisodeCard from '@/components/EpisodeCard.vue'
import { useAuthStore } from '@/stores/auth'
import { isMobileAppBuild } from '@/utils/platform'
import { useMyCorpusBadgeStore } from '@/stores/myCorpusBadge'
import type { EpisodeSummary } from '@/types'

type CorpusTab = 'favorites' | 'videos' | 'articles' | 'subtitle-favorites'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const loading = ref(true)
const error = ref('')
const videoRows = ref<UserSubmissionItem[]>([])
const articleRows = ref<UserArticleSubmissionItem[]>([])
const favoriteEpisodes = ref<EpisodeSummary[]>([])
const favoriteSubtitles = ref<SubtitleFavorite[]>([])
const corpusBadge = useMyCorpusBadgeStore()

const isApp = isMobileAppBuild()

const tab = computed<CorpusTab>(() => {
  const raw = String(route.query.tab || '')
  // App 不含「文章投稿」创建，但保留收藏 + 我上传的视频（管理）
  if (raw === 'articles' && !isApp) return 'articles'
  if (raw === 'videos') return 'videos'
  if (raw === 'subtitle-favorites') return 'subtitle-favorites'
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
    const [videos, articles, favorites, subtitleFavs] = await Promise.all([
      listMySubmissions(),
      listMyArticleSubmissions(),
      getEpisodeList({ status: 'favorite', page_size: 50, offset: 0 }),
      getSubtitleFavorites({ limit: 200 }),
    ])
    videoRows.value = videos.results
    articleRows.value = articles.results
    favoriteEpisodes.value = favorites.results
    favoriteSubtitles.value = subtitleFavs
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

async function removeFavoriteSubtitle(item: SubtitleFavorite) {
  try {
    await removeSubtitleFavorite(item.id)
    favoriteSubtitles.value = favoriteSubtitles.value.filter((x) => x.id !== item.id)
  } catch {
    // ignore
  }
}
</script>

<template>
  <div class="page-container py-6">
    <div class="relative mb-4 hidden h-9 items-center justify-center sm:flex">
      <h1 class="text-[15px] font-medium tracking-tight text-ink">我的语料库</h1>
      <div class="absolute right-0 flex items-center gap-2">
        <RouterLink
          v-if="tab === 'videos' && !isApp"
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
    </div>

    <div class="flex gap-1 mb-6 p-1 rounded-xl bg-neutral-100 dark:bg-neutral-800/80 w-fit">
      <button
        type="button"
        class="px-3.5 py-1.5 text-sm rounded-lg transition"
        :class="tab === 'favorites'
          ? 'bg-card shadow-sm font-medium'
          : 'text-neutral-500 hover:text-ink-soft'"
        @click="setTab('favorites')"
      >
        收藏
        <span v-if="favoriteEpisodes.length" class="text-xs text-neutral-400 ml-1">{{ favoriteEpisodes.length }}</span>
      </button>
      <button
        type="button"
        class="px-3.5 py-1.5 text-sm rounded-lg transition"
        :class="tab === 'subtitle-favorites'
          ? 'bg-card shadow-sm font-medium'
          : 'text-neutral-500 hover:text-ink-soft'"
        @click="setTab('subtitle-favorites')"
      >
        收藏字幕
        <span v-if="favoriteSubtitles.length" class="text-xs text-neutral-400 ml-1">{{ favoriteSubtitles.length }}</span>
      </button>
      <button
        type="button"
        class="px-3.5 py-1.5 text-sm rounded-lg transition"
        :class="tab === 'videos'
          ? 'bg-card shadow-sm font-medium'
          : 'text-neutral-500 hover:text-ink-soft'"
        @click="setTab('videos')"
      >
        我上传的视频
        <span v-if="videoRows.length" class="text-xs text-neutral-400 ml-1">{{ videoRows.length }}</span>
      </button>
      <button
        v-if="!isApp"
        type="button"
        class="px-3.5 py-1.5 text-sm rounded-lg transition"
        :class="tab === 'articles'
          ? 'bg-card shadow-sm font-medium'
          : 'text-neutral-500 hover:text-ink-soft'"
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

    <template v-else-if="tab === 'subtitle-favorites'">
      <ul v-if="favoriteSubtitles.length" class="space-y-3">
        <li
          v-for="item in favoriteSubtitles"
          :key="item.id"
          class="rounded-2xl border border-line-soft bg-card p-3"
        >
          <div class="flex items-start justify-between gap-3">
            <RouterLink
              :to="`/english/episode/${encodeURIComponent(item.video_id)}`"
              class="min-w-0 flex-1"
            >
              <p class="text-[14px] font-medium leading-snug text-ink line-clamp-2">{{ item.english }}</p>
              <p v-if="item.chinese" class="mt-1 text-[13px] text-ink-soft line-clamp-2">{{ item.chinese }}</p>
              <p class="mt-1.5 text-[11px] text-ink-faint">
                <span v-if="item.episode_title" class="truncate">{{ item.episode_title }}</span>
                <span v-if="item.episode_title"> · </span>
                <span>{{ formatDate(item.created_at) }}</span>
              </p>
            </RouterLink>
            <button
              type="button"
              class="shrink-0 rounded-lg px-2 py-1 text-[12px] text-ink-faint transition hover:text-red-500"
              @click="removeFavoriteSubtitle(item)"
            >
              取消
            </button>
          </div>
        </li>
      </ul>
      <div
        v-else
        class="rounded-xl border border-dashed border-black/10 dark:border-white/10 p-12 text-center text-sm text-neutral-500"
      >
        还没有收藏字幕。在视频字幕行点右上角的星标即可收藏整句。
      </div>
    </template>

    <template v-else-if="tab === 'videos'">
      <section v-if="publishedVideos.length" class="mb-8">
        <h2 class="text-sm font-medium text-neutral-500 dark:text-neutral-400 mb-3">已发布</h2>
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
        <h2 class="text-sm font-medium text-neutral-500 dark:text-neutral-400 mb-3">其他</h2>
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
              v-if="row.original_video_url"
              :href="row.original_video_url"
              target="_blank"
              rel="noopener noreferrer"
              class="text-xs text-neutral-500 hover:underline break-all line-clamp-2"
            >
              {{ row.original_video_url }}
            </a>
            <p v-else class="text-xs text-neutral-500">本地上传视频</p>
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
        <RouterLink
          v-if="!isApp"
          to="/english/submit"
          class="text-amber-600 hover:underline ml-1"
        >
          去上传视频
        </RouterLink>
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
