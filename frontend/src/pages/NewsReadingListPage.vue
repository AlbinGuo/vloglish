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
import AppIcon from '@/components/AppIcon.vue'

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
      class="mb-4 flex items-start gap-2 rounded-2xl border border-warning bg-warning-soft px-4 py-3 text-sm text-warning"
    >
      <AppIcon name="sparkles" class="mt-0.5 h-4 w-4 shrink-0" />
      <span>{{ previewBanner }}</span>
    </div>

    <div class="mb-4 rounded-2xl border border-line-soft bg-card p-3 shadow-sm sm:p-4">
      <!-- 搜索 + 筛选 -->
      <div class="flex items-center gap-2">
        <div class="relative min-w-0 flex-1">
          <AppIcon
            name="search"
            class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-ink-faint"
          />
          <input
            v-model="search"
            type="search"
            placeholder="搜索标题关键词"
            class="w-full rounded-xl border border-line-soft bg-canvas py-2.5 pl-9 pr-3 text-sm text-ink placeholder:text-ink-faint focus:border-brand focus:outline-none"
            @keydown.enter="applyFilters"
          />
        </div>
        <button
          type="button"
          class="shrink-0 rounded-xl bg-ink px-4 py-2.5 text-sm font-medium text-ink-inverse transition hover:opacity-90 active:scale-[0.98]"
          @click="applyFilters"
        >
          筛选
        </button>
      </div>

      <!-- 下拉筛选 -->
      <div class="mt-3 grid grid-cols-2 gap-2 sm:grid-cols-4">
        <label class="block min-w-0">
          <span class="mb-1 block text-[11px] font-medium text-ink-faint">来源</span>
          <select v-model="source" class="w-full rounded-xl border border-line-soft bg-canvas px-3 py-2 text-sm text-ink focus:border-brand focus:outline-none" @change="applyFilters">
            <option value="">全部</option>
            <option v-for="s in filterOptions.sources" :key="s" :value="s">{{ s }}</option>
          </select>
        </label>
        <label class="block min-w-0">
          <span class="mb-1 block text-[11px] font-medium text-ink-faint">主题</span>
          <select v-model="topic" class="w-full rounded-xl border border-line-soft bg-canvas px-3 py-2 text-sm text-ink focus:border-brand focus:outline-none" @change="applyFilters">
            <option value="">全部</option>
            <option v-for="t in filterOptions.topics" :key="t" :value="t">{{ t }}</option>
          </select>
        </label>
        <label class="block min-w-0">
          <span class="mb-1 block text-[11px] font-medium text-ink-faint">难度</span>
          <select v-model="stars" class="w-full rounded-xl border border-line-soft bg-canvas px-3 py-2 text-sm text-ink focus:border-brand focus:outline-none" @change="applyFilters">
            <option value="">全部</option>
            <option v-for="n in 5" :key="n" :value="n">{{ n }} 星</option>
          </select>
        </label>
        <label v-if="auth.isLoggedIn" class="block min-w-0">
          <span class="mb-1 block text-[11px] font-medium text-ink-faint">状态</span>
          <select v-model="status" class="w-full rounded-xl border border-line-soft bg-canvas px-3 py-2 text-sm text-ink focus:border-brand focus:outline-none" @change="applyFilters">
            <option value="all">全部</option>
            <option value="in_progress">进行中</option>
            <option value="completed">已读完</option>
          </select>
        </label>
      </div>

      <!-- 上传 / 我的语料库 -->
      <div class="mt-3 flex flex-wrap items-center gap-2 border-t border-line-soft pt-3">
        <RouterLink
          :to="auth.isMember || siteConfig.memberToolsOpen ? '/english/submit-article' : '/pricing'"
          class="inline-flex items-center gap-1.5 rounded-xl bg-warning px-3 py-2 text-xs font-medium text-ink-inverse transition hover:opacity-90 active:scale-[0.98]"
        >
          <AppIcon name="plus" class="h-3.5 w-3.5" />
          上传文章
        </RouterLink>
        <RouterLink
          :to="
            auth.isMember || siteConfig.memberToolsOpen
              ? '/english/my-submissions?tab=articles'
              : '/pricing'
          "
          class="inline-flex items-center gap-1.5 rounded-xl border border-line-soft bg-canvas px-3 py-2 text-xs font-medium text-ink-soft transition hover:bg-sunken active:scale-[0.98]"
        >
          <AppIcon name="inbox" class="h-3.5 w-3.5" />
          我的语料库
        </RouterLink>
      </div>
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
                    <AppIcon name="notification" :size="20" />
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
