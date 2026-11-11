<script setup lang="ts">
defineOptions({ name: 'MyFollowsPage' })
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import AppIcon from '@/components/AppIcon.vue'
import AuthorAvatar from '@/components/AuthorAvatar.vue'
import { getMyFollowedAuthors, setAuthorSubscribe } from '@/api/episodes'
import { getErrorDetail } from '@/api/tokens'
import type { MyFollowedAuthor } from '@/types'

const items = ref<MyFollowedAuthor[]>([])
const loading = ref(true)
const error = ref('')
const unsubscribing = ref<number | null>(null)

async function load() {
  loading.value = true
  error.value = ''
  try {
    const res = await getMyFollowedAuthors()
    items.value = res.results
  } catch (e) {
    error.value = getErrorDetail(e) || '关注列表加载失败，请稍后重试'
    items.value = []
  } finally {
    loading.value = false
  }
}

function authorLink(a: MyFollowedAuthor) {
  return `/english/authors/${a.id}`
}

function unwatchedLabel(a: MyFollowedAuthor) {
  if (a.unwatched_count > 0) return `${a.unwatched_count}个作品未看`
  if (a.episode_count > 0) return '已全部看完'
  return '暂无作品'
}

async function unfollow(a: MyFollowedAuthor) {
  if (unsubscribing.value) return
  unsubscribing.value = a.id
  error.value = ''
  try {
    await setAuthorSubscribe(a.id, false)
    items.value = items.value.filter((item) => item.id !== a.id)
  } catch (e) {
    error.value = getErrorDetail(e) || '取消关注失败，请稍后重试'
  } finally {
    unsubscribing.value = null
  }
}

onMounted(load)
</script>

<template>
  <div class="page-container max-w-3xl py-6">
    <div class="mb-4 hidden items-center justify-center sm:flex">
      <h1 class="text-[15px] font-medium tracking-tight text-ink">我的关注</h1>
    </div>

    <p v-if="error" class="mb-4 text-sm text-red-600 dark:text-red-400">{{ error }}</p>

    <div
      v-if="loading && !items.length"
      class="py-16 text-center text-sm text-neutral-500 dark:text-neutral-400"
    >
      加载中…
    </div>

    <div
      v-else-if="!items.length"
      class="rounded-2xl border border-line-soft bg-card px-5 py-14 text-center"
    >
      <AppIcon name="star" class="mx-auto h-8 w-8 text-ink-faint" />
      <p class="mt-3 text-sm text-ink-soft">还没有关注任何作者</p>
      <p class="mt-1 text-[12px] text-ink-faint">在作者主页点「关注」，新作品上线就会通知你</p>
      <RouterLink
        to="/english"
        class="mt-4 inline-flex items-center gap-1 rounded-lg bg-amber-500 px-3.5 py-1.5 text-[13px] font-medium text-white transition hover:bg-amber-600"
      >
        去首页看看
        <AppIcon name="chevron-right" class="h-3.5 w-3.5" />
      </RouterLink>
    </div>

    <ul v-else class="space-y-3">
      <li
        v-for="a in items"
        :key="a.id"
        class="flex items-center gap-3 rounded-2xl border border-line-soft bg-card p-3.5"
      >
        <RouterLink :to="authorLink(a)" class="shrink-0" :aria-label="a.name">
          <AuthorAvatar :src="a.avatar" :name="a.name" :size="56" />
        </RouterLink>

        <div class="min-w-0 flex-1">
          <RouterLink
            :to="authorLink(a)"
            class="block truncate text-[15px] font-semibold leading-tight text-ink hover:underline"
          >
            {{ a.name }}
          </RouterLink>
          <RouterLink
            :to="authorLink(a)"
            class="mt-1.5 inline-flex items-center gap-1 rounded-md bg-sunken px-2 py-1 text-[12px] text-ink-soft transition hover:bg-line-soft"
          >
            <span>{{ unwatchedLabel(a) }}</span>
            <span class="text-ink-faint">|</span>
            <span class="font-medium text-ink">看作品</span>
            <AppIcon name="chevron-right" class="h-3 w-3" />
          </RouterLink>
        </div>

        <button
          type="button"
          class="shrink-0 rounded-lg bg-sunken px-3.5 py-2 text-[13px] font-medium text-ink-soft transition hover:bg-line-soft disabled:opacity-50"
          :disabled="unsubscribing === a.id"
          @click="unfollow(a)"
        >
          {{ unsubscribing === a.id ? '处理中…' : '已关注' }}
        </button>
      </li>
    </ul>
  </div>
</template>
