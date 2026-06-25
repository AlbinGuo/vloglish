<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { adminCreateBroadcast, adminListBroadcasts, type AdminBroadcast } from '@/api/admin'

const loading = ref(true)
const publishing = ref(false)
const error = ref('')
const success = ref('')
const title = ref('')
const body = ref('')
const rows = ref<AdminBroadcast[]>([])
const total = ref(0)

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await adminListBroadcasts()
    rows.value = data.results
    total.value = data.count
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

async function publish() {
  const t = title.value.trim()
  const b = body.value.trim()
  if (!t) {
    error.value = '请填写通知标题'
    return
  }
  if (!b) {
    error.value = '请填写通知内容'
    return
  }
  if (!confirm(`确定向全部用户发布通知「${t}」？`)) return

  publishing.value = true
  error.value = ''
  success.value = ''
  try {
    const data = await adminCreateBroadcast({ title: t, body: b })
    success.value = `已发布，共 ${data.recipient_count} 位用户将收到通知`
    title.value = ''
    body.value = ''
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '发布失败'
  } finally {
    publishing.value = false
  }
}

onMounted(load)
</script>

<template>
  <div class="space-y-6 max-w-3xl">
    <section class="rounded-xl border border-black/5 bg-white p-5 space-y-4">
      <h2 class="font-medium">发布全员通知</h2>
      <p class="text-sm text-neutral-600">
        通知将发送给所有已注册且账号启用的用户，用户可在前台「通知」中查看。
      </p>
      <label class="block text-sm">
        <span class="text-neutral-500">标题 *</span>
        <input
          v-model="title"
          maxlength="256"
          placeholder="例如：系统维护公告"
          class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2"
          :disabled="publishing"
        />
      </label>
      <label class="block text-sm">
        <span class="text-neutral-500">内容 *</span>
        <textarea
          v-model="body"
          rows="5"
          placeholder="请输入通知正文..."
          class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2"
          :disabled="publishing"
        />
      </label>
      <button
        type="button"
        class="rounded-lg bg-neutral-900 text-white px-5 py-2 text-sm hover:bg-neutral-800 disabled:opacity-50"
        :disabled="publishing"
        @click="publish"
      >
        {{ publishing ? '发布中...' : '发布通知' }}
      </button>
    </section>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
    <p v-if="success" class="text-sm text-green-600">{{ success }}</p>

    <section class="rounded-xl border border-black/5 bg-white overflow-hidden">
      <div class="px-5 py-4 border-b border-black/5">
        <h2 class="font-medium">发布记录</h2>
      </div>
      <div v-if="loading" class="p-8 text-center text-neutral-500 text-sm">加载中...</div>
      <ul v-else-if="rows.length" class="divide-y divide-black/5">
        <li v-for="row in rows" :key="row.id" class="px-5 py-4 space-y-2">
          <div class="flex flex-wrap items-start justify-between gap-2">
            <h3 class="font-medium text-sm">{{ row.title }}</h3>
            <time class="text-xs text-neutral-400 shrink-0">{{ row.created_at }}</time>
          </div>
          <p class="text-sm text-neutral-600 whitespace-pre-line leading-relaxed">{{ row.body }}</p>
          <p class="text-xs text-neutral-400">
            送达 {{ row.recipient_count }} 人
            <span v-if="row.created_by_email"> · {{ row.created_by_email }}</span>
          </p>
        </li>
      </ul>
      <p v-else class="p-8 text-center text-neutral-500 text-sm">暂无发布记录</p>
    </section>

    <p v-if="!loading && total > rows.length" class="text-xs text-neutral-400 text-center">
      共 {{ total }} 条记录
    </p>
  </div>
</template>
