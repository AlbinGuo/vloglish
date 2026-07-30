<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { accentIconFor } from '@/constants/accentOptions'
import { listMySubmissions, type UserSubmissionItem } from '@/api/episodes'

const loading = ref(true)
const error = ref('')
const rows = ref<UserSubmissionItem[]>([])

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

const publishedRows = computed(() => rows.value.filter((r) => r.status === 'published'))
const pendingRows = computed(() => rows.value.filter((r) => r.status !== 'published'))

function formatDate(iso?: string) {
  if (!iso) return ''
  const d = new Date(iso)
  if (Number.isNaN(d.getTime())) return iso.replace('T', ' ').replace('Z', '').slice(0, 16)
  return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await listMySubmissions()
    rows.value = data.results
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>

<template>
  <div class="page-container py-6">
    <div class="flex items-center gap-3 text-sm mb-6">
      <RouterLink to="/english" class="text-neutral-500 hover:text-neutral-900 dark:text-neutral-400 dark:hover:text-white">← 返回目录</RouterLink>
      <span class="text-neutral-300 dark:text-neutral-600">|</span>
      <span class="font-medium">我的语料库</span>
      <span class="flex-1" />
      <RouterLink
        to="/english/submit"
        class="rounded-lg bg-amber-500 text-white px-3 py-1.5 text-sm hover:bg-amber-600"
      >
        新投稿
      </RouterLink>
    </div>

    <p v-if="error" class="mb-4 text-sm text-red-600">{{ error }}</p>
    <div v-if="loading" class="text-sm text-neutral-500 py-12 text-center">加载中...</div>

    <template v-else>
      <section v-if="publishedRows.length" class="mb-8">
        <h2 class="text-sm font-medium text-neutral-500 dark:text-neutral-400 mb-3">已通过</h2>
        <ul class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
          <li v-for="row in publishedRows" :key="row.video_id">
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

      <section v-if="pendingRows.length">
        <h2 class="text-sm font-medium text-neutral-500 dark:text-neutral-400 mb-3">审核中 / 其他</h2>
        <ul class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-3">
          <li
            v-for="row in pendingRows"
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
        v-if="!rows.length"
        class="rounded-xl border border-dashed border-black/10 dark:border-white/10 p-12 text-center text-sm text-neutral-500"
      >
        暂无语料。
        <RouterLink to="/english/submit" class="text-amber-600 hover:underline ml-1">去提交链接</RouterLink>
      </div>
    </template>
  </div>
</template>
