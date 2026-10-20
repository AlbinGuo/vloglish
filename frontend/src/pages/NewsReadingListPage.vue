<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import {
  getArticleFilters,
  getArticleList,
  type ArticleSummary,
} from '@/api/articles'
import EnglishCatalogNavBar from '@/components/english/EnglishCatalogNavBar.vue'
import EnglishNavTabs from '@/components/english/EnglishNavTabs.vue'
import { useAuthStore } from '@/stores/auth'
import { useSiteConfigStore } from '@/stores/siteConfig'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const auth = useAuthStore()
const siteConfig = useSiteConfigStore()

const loading = ref(true)
const loadingMore = ref(false)
const error = ref('')
const articles = ref<ArticleSummary[]>([])
const total = ref(0)
const page = ref(1)
const hasMore = ref(false)
const quota = ref<{ is_member: boolean; monthly_limit: number | null; remaining: number | null } | null>(null)

const source = ref('')
const topic = ref('')
const stars = ref<number | ''>('')
const status = ref<'all' | 'in_progress' | 'completed'>('all')
const search = ref('')

const filterOptions = ref<{ sources: string[]; topics: string[] }>({ sources: [], topics: [] })

const previewBanner = computed(() => {
  if (auth.isMember) return null
  // 关门槛期间登录用户文章不限量
  if (auth.isLoggedIn && !siteConfig.isContentGated) return null
  if (!auth.isLoggedIn) {
    return siteConfig.isContentGated
      ? '未登录可试读 3 篇文章，登录后每月可读 5 篇。'
      : '未登录可试读 3 篇文章；登录后可阅读全部文章。'
  }
  if (quota.value && quota.value.remaining != null && quota.value.remaining <= 1) {
    return `本月还可读 ${quota.value.remaining} 篇文章，开通会员可读全部。`
  }
  return null
})

function articlePath(articleId: string) {
  return `/english/reading/${articleId}`
}

function starsLabel(n: number) {
  return '★'.repeat(n) + '☆'.repeat(Math.max(0, 5 - n))
}

async function load(reset = false) {
  if (reset) {
    page.value = 1
    articles.value = []
  }
  const isFirst = page.value === 1 && !articles.value.length
  if (isFirst) loading.value = true
  else loadingMore.value = true
  error.value = ''

  try {
    const data = await getArticleList({
      page: page.value,
      page_size: 20,
      source: source.value || undefined,
      topic: topic.value || undefined,
      stars: stars.value === '' ? undefined : Number(stars.value),
      status: status.value === 'all' ? undefined : status.value,
      q: search.value.trim() || undefined,
    })
    if (reset || page.value === 1) articles.value = data.results
    else articles.value.push(...data.results)
    total.value = data.count
    hasMore.value = Boolean(data.next)
    quota.value = data.quota
  } catch {
    error.value = '加载失败，请稍后重试'
  } finally {
    loading.value = false
    loadingMore.value = false
  }
}

function applyFilters() {
  load(true)
}

function loadMore() {
  if (!hasMore.value || loadingMore.value) return
  page.value += 1
  load()
}

onMounted(async () => {
  try {
    filterOptions.value = await getArticleFilters()
  } catch {
    filterOptions.value = { sources: [], topics: [] }
  }
  await load(true)
})

watch(
  () => auth.isLoggedIn,
  () => {
    load(true)
  },
)
</script>

<template>
  <div>
    <EnglishCatalogNavBar />

    <div class="page-container pt-3 pb-6 sm:py-6">
    <EnglishNavTabs class="hidden sm:block mb-6" />

    <div
      v-if="previewBanner"
      class="mb-4 rounded-xl border border-amber-200 dark:border-amber-800 bg-warning-soft px-4 py-3 text-sm text-amber-900 dark:text-amber-200"
    >
      {{ previewBanner }}
    </div>

    <div class="mb-4 flex flex-wrap items-center justify-end gap-2">
      <RouterLink
        :to="auth.isMember || siteConfig.memberToolsOpen ? '/english/submit-article' : '/pricing'"
        class="inline-flex items-center gap-1 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-xs font-medium px-2.5 py-1.5 transition"
      >
        上传文章
      </RouterLink>
      <RouterLink
        :to="
          auth.isMember || siteConfig.memberToolsOpen
            ? '/english/my-submissions?tab=articles'
            : '/pricing'
        "
        class="text-xs text-neutral-500 hover:text-neutral-800 dark:text-neutral-400 dark:hover:text-neutral-200"
      >
        我的语料库
      </RouterLink>
    </div>

    <div class="mb-4 flex flex-wrap items-end gap-3">
      <label class="text-sm">
        <span class="block text-neutral-500 mb-1">来源</span>
        <select v-model="source" class="rounded-lg border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 px-3 py-2 text-sm" @change="applyFilters">
          <option value="">全部</option>
          <option v-for="s in filterOptions.sources" :key="s" :value="s">{{ s }}</option>
        </select>
      </label>
      <label class="text-sm">
        <span class="block text-neutral-500 mb-1">主题</span>
        <select v-model="topic" class="rounded-lg border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 px-3 py-2 text-sm" @change="applyFilters">
          <option value="">全部</option>
          <option v-for="t in filterOptions.topics" :key="t" :value="t">{{ t }}</option>
        </select>
      </label>
      <label class="text-sm">
        <span class="block text-neutral-500 mb-1">难度</span>
        <select v-model="stars" class="rounded-lg border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 px-3 py-2 text-sm" @change="applyFilters">
          <option value="">全部</option>
          <option v-for="n in 5" :key="n" :value="n">{{ n }} 星</option>
        </select>
      </label>
      <label v-if="auth.isLoggedIn" class="text-sm">
        <span class="block text-neutral-500 mb-1">状态</span>
        <select v-model="status" class="rounded-lg border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 px-3 py-2 text-sm" @change="applyFilters">
          <option value="all">全部</option>
          <option value="in_progress">进行中</option>
          <option value="completed">已读完</option>
        </select>
      </label>
      <label class="text-sm flex-1 min-w-[12rem]">
        <span class="block text-neutral-500 mb-1">搜索</span>
        <input
          v-model="search"
          type="search"
          placeholder="标题关键词"
          class="w-full rounded-lg border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 px-3 py-2 text-sm"
          @keydown.enter="applyFilters"
        />
      </label>
      <button type="button" class="rounded-lg bg-neutral-900 dark:bg-neutral-100 text-white dark:text-neutral-900 px-4 py-2 text-sm" @click="applyFilters">
        筛选
      </button>
    </div>

    <div v-if="loading" class="py-24 text-center text-neutral-500">加载中...</div>
    <div v-else-if="error" class="py-24 text-center text-red-500">{{ error }}</div>
    <div v-else-if="!articles.length" class="py-24 text-center text-neutral-500">暂无文章</div>
    <div v-else>
      <ul class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-4">
        <li v-for="article in articles" :key="article.article_id">
          <RouterLink
            :to="article.accessible ? articlePath(article.article_id) : '#'"
            class="group flex h-full flex-col rounded-2xl border border-black/[0.06] dark:border-white/10 bg-white dark:bg-neutral-900 p-4 sm:p-5 transition hover:border-black/10 dark:hover:border-white/15 hover:bg-neutral-50/80 dark:hover:bg-neutral-900"
            :class="!article.accessible ? 'opacity-60 pointer-events-none' : ''"
          >
            <div class="flex items-start gap-3 min-w-0">
              <div class="min-w-0 flex-1">
                <h3 class="font-semibold text-[15px] sm:text-base leading-snug text-neutral-900 dark:text-neutral-50 line-clamp-2 tracking-tight">
                  <span
                    v-if="article.is_new"
                    class="inline-block align-middle mr-1.5 text-[10px] px-1.5 py-0.5 rounded bg-rose-500 text-white font-bold leading-none"
                  >新</span>
                  {{ article.title }}
                </h3>
                <p
                  class="mt-2 text-sm text-neutral-500 dark:text-neutral-400 leading-relaxed line-clamp-2"
                >
                  {{ article.summary?.trim() || `${article.word_count} 词 · ${article.segment_count} 段` }}
                </p>
              </div>
              <div class="relative shrink-0">
                <div
                  class="w-[4.5rem] h-[3.35rem] sm:w-[5rem] sm:h-[3.75rem] rounded-xl overflow-hidden bg-neutral-100 dark:bg-neutral-800 ring-1 ring-black/5 dark:ring-white/10"
                >
                  <img
                    v-if="article.cover"
                    :src="resolveMediaUrl(article.cover)"
                    :alt="article.title"
                    class="w-full h-full object-cover transition duration-300 group-hover:scale-[1.03]"
                    loading="lazy"
                  />
                  <div
                    v-else
                    class="w-full h-full flex items-center justify-center text-neutral-300 dark:text-neutral-600"
                    aria-hidden="true"
                  >
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                      <path d="M4 6h16v12H4zM8 10h.01M12 14l3-3 3 4" stroke-linecap="round" stroke-linejoin="round" />
                    </svg>
                  </div>
                </div>
                <span
                  v-if="article.progress"
                  class="absolute -bottom-1.5 -right-1.5 text-[10px] font-medium px-1.5 py-0.5 rounded-md shadow-sm"
                  :class="
                    article.progress.is_completed
                      ? 'bg-emerald-500 text-white'
                      : 'bg-card text-ink-soft ring-1 ring-black/8 dark:ring-white/10'
                  "
                >
                  {{ article.progress.is_completed ? '完' : `${Math.round(article.progress.completion_percent)}%` }}
                </span>
                <span
                  v-else-if="!article.accessible"
                  class="absolute -bottom-1.5 -right-1.5 text-[10px] font-medium px-1.5 py-0.5 rounded-md bg-amber-500 text-white shadow-sm"
                >
                  锁
                </span>
              </div>
            </div>

            <div class="mt-auto pt-3.5 flex flex-wrap items-center gap-1.5">
              <span
                v-if="article.topic"
                class="inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium bg-sunken text-neutral-600 dark:text-neutral-300"
              >
                {{ article.topic }}
              </span>
              <span
                v-if="article.source"
                class="inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium bg-sunken text-neutral-600 dark:text-neutral-300"
              >
                {{ article.source }}
              </span>
              <span
                class="inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-medium text-amber-700 dark:text-amber-300 bg-warning-soft"
                :title="`${article.stars} 星`"
              >
                {{ starsLabel(article.stars) }}
              </span>
            </div>
          </RouterLink>
        </li>
      </ul>

      <div v-if="hasMore" class="pt-6 text-center">
        <button
          type="button"
          class="text-sm text-neutral-600 dark:text-neutral-400 hover:text-black dark:hover:text-white"
          :disabled="loadingMore"
          @click="loadMore"
        >
          {{ loadingMore ? '加载中...' : '加载更多' }}
        </button>
      </div>
      <p v-else class="pt-6 text-center text-sm text-neutral-400">共 {{ total }} 篇</p>
    </div>
    </div>
  </div>
</template>
