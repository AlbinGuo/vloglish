<script setup lang="ts">
import { onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import {
  getNotifications,
  markAllNotificationsRead,
  markNotificationRead,
  type Notification,
} from '@/api/notifications'
import { useNotificationStore } from '@/stores/notifications'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const notificationStore = useNotificationStore()
const loading = ref(true)
const error = ref('')
const notifications = ref<Notification[]>([])
const unreadCount = ref(0)
const total = ref(0)
const previewImageUrl = ref('')

function openImagePreview(url: string) {
  previewImageUrl.value = resolveMediaUrl(url)
}

function closeImagePreview() {
  previewImageUrl.value = ''
}

function onPreviewKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape') closeImagePreview()
}

watch(previewImageUrl, (url) => {
  if (url) {
    document.addEventListener('keydown', onPreviewKeydown)
    document.body.style.overflow = 'hidden'
  } else {
    document.removeEventListener('keydown', onPreviewKeydown)
    document.body.style.overflow = ''
  }
})

onUnmounted(() => {
  document.removeEventListener('keydown', onPreviewKeydown)
  document.body.style.overflow = ''
})

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await getNotifications()
    notifications.value = data.results
    unreadCount.value = data.unread_count
    total.value = data.count
    notificationStore.setCount(data.unread_count)
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

async function readOne(item: Notification) {
  if (item.is_read) return
  try {
    await markNotificationRead(item.id)
    item.is_read = true
    unreadCount.value = Math.max(0, unreadCount.value - 1)
    notificationStore.decrement()
  } catch {
    // ignore
  }
}

async function readAll() {
  if (!unreadCount.value) return
  try {
    await markAllNotificationsRead()
    notifications.value.forEach((n) => {
      n.is_read = true
    })
    unreadCount.value = 0
    notificationStore.clear()
  } catch {
    // ignore
  }
}

function typeLabel(type: string) {
  if (type === 'episode_published') return '审核通过'
  if (type === 'episode_rejected') return '已驳回'
  if (type === 'admin_broadcast') return '系统通知'
  return '通知'
}

function typeTagClass(type: string) {
  if (type === 'episode_published') return 'bg-green-100 text-green-700 dark:bg-green-900/40 dark:text-green-400'
  if (type === 'episode_rejected') return 'bg-red-100 text-red-700 dark:bg-red-900/40 dark:text-red-400'
  if (type === 'admin_broadcast') return 'bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-400'
  return 'bg-neutral-100 text-neutral-600 dark:bg-neutral-800 dark:text-neutral-400'
}

onMounted(load)
</script>

<template>
  <div class="page-container py-6 max-w-2xl">
    <div class="flex flex-wrap items-center justify-between gap-3 mb-6">
      <div class="flex items-center gap-3 text-sm min-w-0">
        <RouterLink to="/english" class="text-neutral-500 hover:text-neutral-900 dark:text-neutral-400 dark:hover:text-white shrink-0">← 返回目录</RouterLink>
        <span class="text-neutral-300 dark:text-neutral-600 shrink-0">|</span>
        <span class="font-medium">通知</span>
        <span v-if="unreadCount" class="text-xs px-2 py-0.5 rounded-full bg-red-500 text-white">
          {{ unreadCount }} 条未读
        </span>
      </div>
      <button
        v-if="unreadCount"
        type="button"
        class="text-sm text-neutral-600 hover:text-neutral-900 dark:text-neutral-400 dark:hover:text-white shrink-0"
        @click="readAll"
      >
        全部标为已读
      </button>
    </div>

    <p v-if="error" class="mb-4 text-sm text-red-600">{{ error }}</p>

    <div v-if="loading" class="text-neutral-500 text-sm">加载中...</div>

    <div v-else-if="!notifications.length" class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-12 text-center">
      <p class="text-neutral-500 text-sm">暂无通知</p>
    </div>

    <ul v-else class="space-y-3">
      <li
        v-for="item in notifications"
        :key="item.id"
        class="rounded-xl border bg-white dark:bg-neutral-900 p-4 transition cursor-pointer"
        :class="item.is_read ? 'border-black/5 dark:border-white/10' : 'border-amber-200 dark:border-amber-800 bg-amber-50/40 dark:bg-amber-950/30'"
        @click="readOne(item)"
      >
        <div class="flex flex-wrap items-start justify-between gap-2 mb-2">
          <div class="flex flex-wrap items-center gap-2 min-w-0">
            <span
              class="text-xs font-medium px-2 py-0.5 rounded-full shrink-0"
              :class="typeTagClass(item.type)"
            >
              {{ typeLabel(item.type) }}
            </span>
            <h2 class="font-medium text-sm text-neutral-900 dark:text-neutral-100">{{ item.title }}</h2>
            <span v-if="!item.is_read" class="w-2 h-2 rounded-full bg-red-500 shrink-0" />
          </div>
          <time class="text-xs text-neutral-400 shrink-0">{{ item.created_at }}</time>
        </div>
        <p class="text-sm text-neutral-600 dark:text-neutral-300 whitespace-pre-line leading-relaxed">{{ item.body }}</p>
        <button
          v-if="item.image_url"
          type="button"
          class="mt-3 block w-full cursor-zoom-in rounded-lg bg-neutral-50 dark:bg-neutral-800 p-0 border-0"
          @click.stop="openImagePreview(item.image_url)"
        >
          <img
            :src="resolveMediaUrl(item.image_url)"
            alt="通知配图，点击放大"
            class="max-h-72 w-full rounded-lg object-contain"
          />
        </button>
        <RouterLink
          v-if="item.type === 'episode_published' && item.video_id"
          :to="`/english/episode/${item.video_id}`"
          class="inline-block mt-3 text-sm font-medium text-amber-700 dark:text-amber-400 hover:underline"
          @click.stop
        >
          前往观看 →
        </RouterLink>
      </li>
    </ul>

    <p v-if="!loading && total > notifications.length" class="mt-4 text-center text-xs text-neutral-400">
      共 {{ total }} 条通知
    </p>

    <Teleport to="body">
      <div
        v-if="previewImageUrl"
        class="fixed inset-0 z-[100] flex items-center justify-center bg-black/80 p-4"
        role="dialog"
        aria-modal="true"
        aria-label="图片预览"
        @click="closeImagePreview"
      >
        <button
          type="button"
          class="absolute top-4 right-4 z-10 flex h-10 w-10 items-center justify-center rounded-full bg-white/15 text-white text-2xl leading-none hover:bg-white/25"
          aria-label="关闭"
          @click="closeImagePreview"
        >
          ×
        </button>
        <img
          :src="previewImageUrl"
          alt="通知配图预览"
          class="max-h-[90vh] max-w-[min(96vw,1200px)] object-contain rounded-lg shadow-lg"
          @click.stop
        />
      </div>
    </Teleport>
  </div>
</template>
