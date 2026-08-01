<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue'
import {
  adminFetchUserSegments,
  adminListUsers,
  adminUpdateUser,
  type AdminUserSegment,
  type AdminUserSegmentKey,
  type UserRow,
} from '@/api/admin'

const loading = ref(true)
const segmentsLoading = ref(true)
const savingId = ref<number | null>(null)
const search = ref('')
const segment = ref<AdminUserSegmentKey | ''>('')
const page = ref(1)
const total = ref(0)
const rows = ref<UserRow[]>([])
const segments = ref<AdminUserSegment[]>([])
const error = ref('')

let onlinePollTimer: ReturnType<typeof setInterval> | null = null

const totalPages = computed(() => Math.max(1, Math.ceil(total.value / 20)))
const onlineCount = computed(() => rows.value.filter((u) => u.is_online).length)

const segmentHints: Record<AdminUserSegmentKey, string> = {
  active_7d: '最近 7 天内有学习记录',
  churn_risk: '曾经学过，但超过 14 天未再学习',
  new_inactive: '注册超过 3 天，且从未开始学习',
  deep_learners: '近 7 日学习 ≥ 1 小时，或查词 ≥ 15 次',
  members: '已开通会员的用户',
  non_members: '未开通会员的用户',
}

const currentSegmentHint = computed(() => {
  if (!segment.value) return '显示全部用户，可按分群筛选'
  return segmentHints[segment.value]
})

async function loadSegments() {
  segmentsLoading.value = true
  try {
    segments.value = await adminFetchUserSegments()
  } catch {
    segments.value = []
  } finally {
    segmentsLoading.value = false
  }
}

async function load(opts: { silent?: boolean } = {}) {
  if (!opts.silent) {
    loading.value = true
    error.value = ''
  }
  try {
    const data = await adminListUsers({
      page: page.value,
      page_size: 20,
      search: search.value.trim() || undefined,
      segment: segment.value || undefined,
    })
    rows.value = data.results
    total.value = data.count
  } catch (e: unknown) {
    if (!opts.silent) {
      const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
      error.value = msg || '加载失败'
    }
  } finally {
    if (!opts.silent) loading.value = false
  }
}

async function toggleMember(user: UserRow) {
  savingId.value = user.id
  try {
    await adminUpdateUser(user.id, { is_member: !user.is_member })
    await Promise.all([load(), loadSegments()])
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '更新失败'
  } finally {
    savingId.value = null
  }
}

async function toggleActive(user: UserRow) {
  savingId.value = user.id
  try {
    await adminUpdateUser(user.id, { is_active: !user.is_active })
    await Promise.all([load(), loadSegments()])
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '更新失败'
  } finally {
    savingId.value = null
  }
}

function doSearch() {
  page.value = 1
  load()
}

function onSegmentChange() {
  page.value = 1
  load()
}

function formatWatchTime(sec: number) {
  if (sec <= 0) return '—'
  const h = Math.floor(sec / 3600)
  const m = Math.floor((sec % 3600) / 60)
  if (h > 0) return `${h}h ${m}m`
  return `${m} 分钟`
}

function formatSignupLocation(user: UserRow) {
  if (!user.signup_region && !user.signup_country) return '未知'
  const parts: string[] = []
  if (user.signup_region) parts.push(user.signup_region)
  else if (user.signup_country) parts.push(user.signup_country)
  if (user.signup_city && user.signup_city !== user.signup_region) parts.push(user.signup_city)
  return parts.join(' · ')
}

onMounted(async () => {
  await Promise.all([loadSegments(), load()])
  onlinePollTimer = setInterval(() => load({ silent: true }), 30000)
})

onUnmounted(() => {
  if (onlinePollTimer) clearInterval(onlinePollTimer)
})
</script>

<template>
  <div class="space-y-4">
    <div class="rounded-xl border border-black/5 bg-white p-4 space-y-3">
      <div class="flex flex-wrap gap-3">
        <input
          v-model="search"
          type="search"
          placeholder="搜索邮箱或激活码"
          class="flex-1 min-w-[200px] rounded-lg border border-black/10 px-3 py-2 text-sm"
          @keyup.enter="doSearch"
        />
        <select
          v-model="segment"
          class="min-w-[12rem] rounded-lg border border-black/10 px-3 py-2 text-sm"
          @change="onSegmentChange"
        >
          <option value="">全部分群</option>
          <option
            v-for="item in segments"
            :key="item.key"
            :value="item.key"
          >
            {{ item.label }}（{{ segmentsLoading ? '…' : item.count }}）
          </option>
        </select>
        <button
          type="button"
          class="rounded-lg bg-neutral-900 text-white px-4 py-2 text-sm hover:bg-neutral-800"
          @click="doSearch"
        >
          搜索
        </button>
      </div>
      <p class="text-xs text-neutral-500">
        {{ currentSegmentHint }}
        <span v-if="!loading && onlineCount > 0" class="ml-2 text-emerald-600">
          · 本页在线 {{ onlineCount }} 人（近 90 秒有活动）
        </span>
      </p>
    </div>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>

    <div class="rounded-xl border border-black/5 bg-white overflow-x-auto">
      <div v-if="loading" class="p-8 text-center text-neutral-500">加载中...</div>
      <table v-else class="w-full text-sm min-w-[56rem]">
        <thead class="bg-neutral-50 text-neutral-500">
          <tr>
            <th class="text-left px-4 py-3 font-medium">邮箱</th>
            <th class="text-left px-4 py-3 font-medium">会员</th>
            <th class="text-left px-4 py-3 font-medium">状态</th>
            <th class="text-left px-4 py-3 font-medium whitespace-nowrap">注册地区</th>
            <th class="text-left px-4 py-3 font-medium whitespace-nowrap">最后活跃</th>
            <th class="text-right px-4 py-3 font-medium whitespace-nowrap">7 日学习</th>
            <th class="text-right px-4 py-3 font-medium whitespace-nowrap">学完</th>
            <th class="text-right px-4 py-3 font-medium whitespace-nowrap">查词</th>
            <th class="text-left px-4 py-3 font-medium whitespace-nowrap">注册时间</th>
            <th class="text-left px-4 py-3 font-medium whitespace-nowrap">激活时间</th>
            <th class="text-right px-4 py-3 font-medium">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in rows" :key="user.id" class="border-t border-black/5">
            <td class="px-4 py-3">
              <div class="flex items-center gap-2 min-w-0">
                <span
                  class="inline-block w-2 h-2 rounded-full shrink-0"
                  :class="user.is_online ? 'bg-emerald-500' : 'bg-neutral-200'"
                  :title="user.is_online ? '当前在线' : '离线'"
                  aria-hidden="true"
                />
                <div class="min-w-0">
                  <div class="truncate">{{ user.email }}</div>
                  <div v-if="user.is_staff" class="text-xs text-amber-600">管理员</div>
                  <div v-else-if="user.is_online" class="text-xs text-emerald-600">在线</div>
                </div>
              </div>
            </td>
            <td class="px-4 py-3">
              <div class="space-y-1.5">
                <span
                  class="inline-flex items-center px-2 py-0.5 rounded-md text-xs font-medium leading-none"
                  :class="
                    user.is_member
                      ? 'bg-amber-100 text-amber-800'
                      : 'bg-neutral-100 text-neutral-500'
                  "
                >
                  {{ user.is_member ? '会员' : '普通' }}
                </span>
                <div
                  v-if="user.is_member && user.activation_code"
                  class="text-xs font-mono text-neutral-700 break-all"
                  :title="user.activation_code"
                >
                  {{ user.activation_code }}
                </div>
              </div>
            </td>
            <td class="px-4 py-3">
              <span
                class="inline-flex items-center px-2 py-0.5 rounded-md text-xs font-medium leading-none"
                :class="
                  user.is_active
                    ? 'bg-emerald-100 text-emerald-800'
                    : 'bg-red-100 text-red-700'
                "
              >
                {{ user.is_active ? '正常' : '已停用' }}
              </span>
            </td>
            <td class="px-4 py-3 whitespace-nowrap">{{ formatSignupLocation(user) }}</td>
            <td class="px-4 py-3 whitespace-nowrap">{{ user.last_active_at || '—' }}</td>
            <td class="px-4 py-3 text-right tabular-nums whitespace-nowrap">
              {{ formatWatchTime(user.watch_time_7d) }}
            </td>
            <td class="px-4 py-3 text-right tabular-nums">{{ user.completed_episodes }}</td>
            <td class="px-4 py-3 text-right tabular-nums">{{ user.lookup_count }}</td>
            <td class="px-4 py-3 whitespace-nowrap">{{ user.created_at }}</td>
            <td class="px-4 py-3 whitespace-nowrap">{{ user.member_activated_at || '—' }}</td>
            <td class="px-4 py-3 text-right space-x-2 whitespace-nowrap">
              <button
                type="button"
                class="text-neutral-900 hover:underline disabled:opacity-50"
                :disabled="savingId === user.id"
                @click="toggleMember(user)"
              >
                {{ user.is_member ? '取消会员' : '开通会员' }}
              </button>
              <button
                v-if="!user.is_staff"
                type="button"
                class="text-red-600 hover:underline disabled:opacity-50"
                :disabled="savingId === user.id"
                @click="toggleActive(user)"
              >
                {{ user.is_active ? '停用' : '启用' }}
              </button>
            </td>
          </tr>
          <tr v-if="!rows.length">
            <td colspan="11" class="px-4 py-8 text-center text-neutral-500">暂无数据</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="totalPages > 1" class="flex justify-center gap-3">
      <button
        type="button"
        class="px-3 py-1.5 text-sm border rounded-lg disabled:opacity-40"
        :disabled="page <= 1"
        @click="page--; load()"
      >
        上一页
      </button>
      <span class="text-sm text-neutral-500">{{ page }} / {{ totalPages }}</span>
      <button
        type="button"
        class="px-3 py-1.5 text-sm border rounded-lg disabled:opacity-40"
        :disabled="page >= totalPages"
        @click="page++; load()"
      >
        下一页
      </button>
    </div>
  </div>
</template>
