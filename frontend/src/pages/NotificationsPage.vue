<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import {
  getNotifications,
  markAllNotificationsRead,
  markNotificationRead,
  type Notification,
} from '@/api/notifications'

const loading = ref(true)
const error = ref('')
const notifications = ref<Notification[]>([])
const unreadCount = ref(0)
const total = ref(0)

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await getNotifications()
    notifications.value = data.results
    unreadCount.value = data.unread_count
    total.value = data.count
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
  if (type === 'episode_published') return 'bg-green-100 text-green-700'
  if (type === 'episode_rejected') return 'bg-red-100 text-red-700'
  if (type === 'admin_broadcast') return 'bg-blue-100 text-blue-700'
  return 'bg-neutral-100 text-neutral-600'
}

onMounted(load)
</script>

<template>
  <div class="page-container py-6 max-w-2xl">
    <div class="flex flex-wrap items-center justify-between gap-3 mb-6">
      <div class="flex items-center gap-3 text-sm min-w-0">
        <RouterLink to="/english" class="text-neutral-500 hover:text-neutral-900 shrink-0">← 返回目录</RouterLink>
        <span class="text-neutral-300 shrink-0">|</span>
        <span class="font-medium">通知</span>
        <span v-if="unreadCount" class="text-xs px-2 py-0.5 rounded-full bg-red-500 text-white">
          {{ unreadCount }} 条未读
        </span>
      </div>
      <button
        v-if="unreadCount"
        type="button"
        class="text-sm text-neutral-600 hover:text-neutral-900 shrink-0"
        @click="readAll"
      >
        全部标为已读
      </button>
    </div>

    <p v-if="error" class="mb-4 text-sm text-red-600">{{ error }}</p>

    <div v-if="loading" class="text-neutral-500 text-sm">加载中...</div>

    <div v-else-if="!notifications.length" class="rounded-xl border border-black/5 bg-white p-12 text-center">
      <p class="text-neutral-500 text-sm">暂无通知</p>
    </div>

    <ul v-else class="space-y-3">
      <li
        v-for="item in notifications"
        :key="item.id"
        class="rounded-xl border bg-white p-4 transition"
        :class="item.is_read ? 'border-black/5' : 'border-amber-200 bg-amber-50/40'"
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
            <h2 class="font-medium text-sm text-neutral-900">{{ item.title }}</h2>
            <span v-if="!item.is_read" class="w-2 h-2 rounded-full bg-red-500 shrink-0" />
          </div>
          <time class="text-xs text-neutral-400 shrink-0">{{ item.created_at }}</time>
        </div>
        <p class="text-sm text-neutral-600 whitespace-pre-line leading-relaxed">{{ item.body }}</p>
        <RouterLink
          v-if="item.type === 'episode_published' && item.video_id"
          :to="`/english/episode/${item.video_id}`"
          class="inline-block mt-3 text-sm font-medium text-amber-700 hover:underline"
          @click.stop
        >
          前往观看 →
        </RouterLink>
      </li>
    </ul>

    <p v-if="!loading && total > notifications.length" class="mt-4 text-center text-xs text-neutral-400">
      共 {{ total }} 条通知
    </p>
  </div>
</template>
