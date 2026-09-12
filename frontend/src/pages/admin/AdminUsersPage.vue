<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import {
  adminFetchOnlineUsers,
  adminFetchUserSegments,
  adminFetchVisitHourlyStats,
  adminGrantMembership,
  adminListUsers,
  adminUnbindWechat,
  adminUpdateUser,
  type AdminAccessClientFilter,
  type AdminMemberPlanFilter,
  type AdminMembershipPlan,
  type AdminUserSegment,
  type AdminUserSegmentKey,
  type AdminVisitHourlyStats,
  type UserRow,
} from '@/api/admin'
import VisitHourlyBarChart from '@/components/charts/VisitHourlyBarChart.vue'

const loading = ref(true)
const segmentsLoading = ref(true)
const hourlyLoading = ref(true)
const savingId = ref<number | null>(null)
const search = ref('')
const segment = ref<AdminUserSegmentKey | ''>('')
const memberPlanFilter = ref<AdminMemberPlanFilter | ''>('')
const accessClientFilter = ref<AdminAccessClientFilter | ''>('')
const page = ref(1)
const total = ref(0)
const rows = ref<UserRow[]>([])
const segments = ref<AdminUserSegment[]>([])
const error = ref('')
const onlineUsers = ref(0)
const onlineWindowSec = ref(90)
const hourlyDays = ref<7 | 30>(7)
const hourlyStats = ref<AdminVisitHourlyStats | null>(null)
const customGrantUser = ref<UserRow | null>(null)
const customDays = ref('30')

let onlinePollTimer: ReturnType<typeof setInterval> | null = null

type MemberKind = 'none' | 'forever' | 'active' | 'expired'

function parseAdminDt(value: string) {
  return new Date(value.includes('T') ? value : value.replace(' ', 'T') + 'Z')
}

function memberKind(user: UserRow): MemberKind {
  if (!user.is_member) return 'none'
  if (!user.member_until) return 'forever'
  return parseAdminDt(user.member_until) > new Date() ? 'active' : 'expired'
}

function memberPlanTag(user: UserRow) {
  const kind = memberKind(user)
  if (kind === 'none') return '普通'
  if (kind === 'expired') return '已过期'
  if (kind === 'forever' || user.member_plan === 'forever') return '永久'
  if (user.member_plan === 'quarter') return '季会员'
  if (user.member_plan === 'year') return '年会员'
  return ''
}

function showMemberUntil(user: UserRow) {
  const kind = memberKind(user)
  return Boolean(user.member_until && kind !== 'forever' && kind !== 'none')
}

function memberBadgeClass(user: UserRow) {
  const kind = memberKind(user)
  if (kind === 'forever' || kind === 'active') return 'bg-amber-100 text-amber-800'
  if (kind === 'expired') return 'bg-orange-100 text-orange-700'
  return 'bg-neutral-100 text-neutral-500'
}

const memberFilterOptions: { key: AdminMemberPlanFilter | ''; label: string }[] = [
  { key: '', label: '会员' },
  { key: 'none', label: '普通' },
  { key: 'quarter', label: '季会员' },
  { key: 'year', label: '年会员' },
  { key: 'forever', label: '永久' },
  { key: 'custom', label: '赠送天数' },
  { key: 'expired', label: '已过期' },
]

function onMemberPlanFilterChange() {
  page.value = 1
  load()
}

const accessClientFilterOptions: { key: AdminAccessClientFilter | ''; label: string }[] = [
  { key: '', label: '访问端' },
  { key: 'ios', label: 'iOS' },
  { key: 'android', label: 'Android' },
  { key: 'pc', label: 'PC' },
  { key: 'weixin', label: '小程序' },
  { key: 'web', label: '浏览器' },
  { key: 'app', label: 'App' },
  { key: 'none', label: '未知' },
]

function onAccessClientFilterChange() {
  page.value = 1
  load()
}

const totalPages = computed(() => Math.max(1, Math.ceil(total.value / 20)))

const hourlySummary = computed(() => {
  const s = hourlyStats.value
  if (!s || s.total_sessions === 0) {
    return '暂无到访会话数据（需用户登录/心跳后开始累计）'
  }
  return `近 ${s.days} 天共 ${s.total_users} 人、${s.total_sessions} 次会话 · 高峰 ${s.peak_label}（${s.peak_users} 人）· 低谷 ${s.low_label}（${s.low_users} 人）`
})

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

function deviceLabel(user: UserRow) {
  const device = (user.last_device || '').toLowerCase()
  if (device === 'ios') return 'iOS'
  if (device === 'android') return 'Android'
  if (device === 'pc') return 'PC'
  if (user.last_client === 'ios') return 'iOS'
  if (user.last_client === 'android') return 'Android'
  if (user.last_client === 'web') return 'PC'
  return ''
}

function surfaceLabel(client: string | null | undefined) {
  if (client === 'weixin') return '小程序'
  if (client === 'android' || client === 'ios') return 'App'
  if (client === 'web') return '浏览器'
  return ''
}

function clientLabel(user: UserRow) {
  return deviceLabel(user) || surfaceLabel(user.last_client)
}

function clientBadgeClass(user: UserRow) {
  const device = deviceLabel(user)
  if (device === 'iOS') return 'bg-sky-100 text-sky-800'
  if (device === 'Android') return 'bg-emerald-100 text-emerald-800'
  if (device === 'PC') return 'bg-neutral-100 text-neutral-700'
  if (user.last_client === 'weixin') return 'bg-emerald-100 text-emerald-800'
  return 'bg-neutral-100 text-neutral-500'
}

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

async function loadHourly() {
  hourlyLoading.value = true
  try {
    hourlyStats.value = await adminFetchVisitHourlyStats(hourlyDays.value)
  } catch {
    hourlyStats.value = null
  } finally {
    hourlyLoading.value = false
  }
}

async function refreshOnlineUsers() {
  try {
    const data = await adminFetchOnlineUsers()
    onlineUsers.value = data.online_users
    onlineWindowSec.value = data.window_sec
  } catch {
    // 静默失败
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
      member_plan: memberPlanFilter.value || undefined,
      access_client: accessClientFilter.value || undefined,
    })
    rows.value = data.results
    total.value = data.count
    await refreshOnlineUsers()
  } catch (e: unknown) {
    if (!opts.silent) {
      const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
      error.value = msg || '加载失败'
    }
  } finally {
    if (!opts.silent) loading.value = false
  }
}

async function applyMembership(user: UserRow, plan: AdminMembershipPlan, days?: number) {
  savingId.value = user.id
  error.value = ''
  try {
    await adminGrantMembership(user.id, days != null ? { plan, days } : { plan })
    customGrantUser.value = null
    await Promise.all([load(), loadSegments()])
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '更新失败'
  } finally {
    savingId.value = null
  }
}

function onGrantChange(user: UserRow, event: Event) {
  const selectEl = event.target as HTMLSelectElement
  onMembershipAction(user, selectEl.value, selectEl)
}

function onMembershipAction(user: UserRow, action: string, selectEl?: HTMLSelectElement) {
  if (selectEl) selectEl.value = ''
  if (!action) return
  if (memberKind(user) === 'forever' && action !== 'forever' && action !== 'revoke') {
    error.value = '该用户已是永久会员，无需再开通限期会员'
    return
  }
  if (action === 'custom') {
    customGrantUser.value = user
    customDays.value = '30'
    return
  }
  if (action === 'revoke') {
    if (!confirm(`确定取消 ${user.email} 的会员？到期时间会一并清除。`)) return
    void applyMembership(user, 'revoke')
    return
  }
  const labels: Record<string, string> = {
    quarter: '季度会员（90 天，未过期则叠加）',
    year: '年度会员（365 天，未过期则叠加）',
    forever: '永久会员',
  }
  const label = labels[action]
  if (!label || !confirm(`确定给 ${user.email} 开通${label}？`)) return
  void applyMembership(user, action as AdminMembershipPlan)
}

function submitCustomDays() {
  const user = customGrantUser.value
  const days = Number.parseInt(customDays.value, 10)
  if (!user) return
  if (!Number.isInteger(days) || days < 1 || days > 3650) {
    error.value = '赠送天数须为 1–3650 的整数'
    return
  }
  if (!confirm(`确定给 ${user.email} 赠送 ${days} 天会员（未过期则叠加）？`)) return
  void applyMembership(user, 'custom', days)
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

async function unbindWechat(user: UserRow) {
  if (user.wechat_only) {
    error.value = '该账号仅能用微信登录，请先让用户在小程序关联网页邮箱'
    return
  }
  if (
    !confirm(
      `确定解除 ${user.email} 的微信关联？解绑后该微信可重新绑定其他网页账号，本账号也无法再扫码支付。`,
    )
  ) {
    return
  }
  savingId.value = user.id
  try {
    await adminUnbindWechat(user.id)
    await Promise.all([load(), loadSegments()])
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '解绑失败'
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

function formatDwellShort(sec: number) {
  const s = Math.max(0, Math.floor(sec || 0))
  if (s < 60) return `${s}s`
  const m = Math.floor(s / 60)
  if (m < 60) return `${m}m`
  const h = Math.floor(m / 60)
  const rm = m % 60
  return rm ? `${h}h${rm}m` : `${h}h`
}

function formatSignupLocation(user: UserRow) {
  if (!user.signup_region && !user.signup_country) return '未知'
  const parts: string[] = []
  if (user.signup_region) parts.push(user.signup_region)
  else if (user.signup_country) parts.push(user.signup_country)
  if (user.signup_city && user.signup_city !== user.signup_region) parts.push(user.signup_city)
  return parts.join(' · ')
}

watch(hourlyDays, () => {
  void loadHourly()
})

onMounted(async () => {
  await Promise.all([loadSegments(), load(), loadHourly()])
  onlinePollTimer = setInterval(() => load({ silent: true }), 30000)
})

onUnmounted(() => {
  if (onlinePollTimer) clearInterval(onlinePollTimer)
})
</script>

<template>
  <div class="space-y-4">
    <div class="rounded-xl border border-black/5 bg-white p-4 space-y-3">
      <div class="flex flex-wrap items-start justify-between gap-3">
        <div>
          <h2 class="text-sm font-medium text-neutral-900">到访时段分布</h2>
          <p class="mt-1 text-xs text-neutral-500 leading-relaxed">
            {{ hourlyLoading ? '加载中...' : hourlySummary }}
          </p>
          <p class="mt-1 text-xs text-neutral-400">
            按东八区小时统计会话开始时间；琥珀色为高峰，灰色为低谷。上线后才开始累计。
          </p>
        </div>
        <div class="inline-flex rounded-lg border border-black/10 p-0.5 text-sm shrink-0">
          <button
            type="button"
            class="px-3 py-1 rounded-md transition"
            :class="hourlyDays === 7 ? 'bg-neutral-900 text-white' : 'text-neutral-600 hover:bg-neutral-50'"
            @click="hourlyDays = 7"
          >
            近 7 天
          </button>
          <button
            type="button"
            class="px-3 py-1 rounded-md transition"
            :class="hourlyDays === 30 ? 'bg-neutral-900 text-white' : 'text-neutral-600 hover:bg-neutral-50'"
            @click="hourlyDays = 30"
          >
            近 30 天
          </button>
        </div>
      </div>
      <VisitHourlyBarChart
        v-if="hourlyStats?.hours?.length"
        :hours="hourlyStats.hours"
        :peak-hour="hourlyStats.peak_hour"
        :low-hour="hourlyStats.low_hour"
        height="260px"
      />
      <div v-else-if="!hourlyLoading" class="py-10 text-center text-sm text-neutral-400">
        暂无图表数据
      </div>
    </div>

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
        <span v-if="!loading" class="ml-2 text-emerald-600">
          · 当前在线 {{ onlineUsers }} 人（近 {{ onlineWindowSec }} 秒有活动，含非会员）
        </span>
        <span class="ml-2">
          · 「访问端」显示最近设备（iOS / Android / PC）及入口（小程序 / 浏览器 / App）；在线时为当前端，离线时为离线前最后一端
        </span>
        <span class="ml-2">
          · 「微信」表示该账号是否已绑定小程序 openid，用于扫码支付与小程序登录
        </span>
        <span class="ml-2">
          · 「到访天数」按东八区自然日；「到访次数」为会话数（距上次活动超过 30 分钟再上线计为新一次，上线后才开始累计）
        </span>
        <span class="ml-2">
          · 开通季度 / 年度 / 赠送天数会在未过期时间上叠加；永久会清空到期日；已是永久不可再开限期
        </span>
      </p>
    </div>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>

    <div class="rounded-xl border border-black/5 bg-white overflow-x-auto">
      <div v-if="loading" class="p-8 text-center text-neutral-500">加载中...</div>
      <table v-else class="w-full text-sm min-w-[56rem]">
        <thead class="bg-neutral-50 text-neutral-500">
          <tr>
            <th class="text-left px-3 py-3 font-medium w-44 max-w-[11rem]">邮箱</th>
            <th class="text-left px-4 py-3 font-medium whitespace-nowrap">
              <select
                v-model="accessClientFilter"
                class="bg-transparent font-medium border-0 p-0 pr-1 cursor-pointer"
                :class="accessClientFilter ? 'text-neutral-900' : 'text-neutral-500'"
                title="按访问端筛选"
                @change="onAccessClientFilterChange"
              >
                <option
                  v-for="item in accessClientFilterOptions"
                  :key="item.key || 'all'"
                  :value="item.key"
                >
                  {{ item.label }}
                </option>
              </select>
            </th>
            <th class="text-left px-4 py-3 font-medium whitespace-nowrap" title="账号是否已绑定微信小程序">
              微信
            </th>
            <th class="text-left px-4 py-3 font-medium whitespace-nowrap">
              <select
                v-model="memberPlanFilter"
                class="bg-transparent font-medium border-0 p-0 pr-1 cursor-pointer"
                :class="memberPlanFilter ? 'text-neutral-900' : 'text-neutral-500'"
                title="按会员权益筛选"
                @change="onMemberPlanFilterChange"
              >
                <option
                  v-for="item in memberFilterOptions"
                  :key="item.key || 'all'"
                  :value="item.key"
                >
                  {{ item.label }}
                </option>
              </select>
            </th>
            <th class="text-left px-4 py-3 font-medium">状态</th>
            <th class="text-left px-4 py-3 font-medium whitespace-nowrap">注册地区</th>
            <th class="text-left px-3 py-3 font-medium w-24 max-w-[6.5rem] whitespace-nowrap">最后活跃</th>
            <th
              class="text-right px-4 py-3 font-medium whitespace-nowrap"
              title="今日到访会话次数（间隔超过 30 分钟算新一次）"
            >
              今日次数
            </th>
            <th
              class="text-right px-4 py-3 font-medium whitespace-nowrap"
              title="近 7 天：有到访的天数 / 会话次数合计"
            >
              7 日到访
            </th>
            <th
              class="text-right px-4 py-3 font-medium whitespace-nowrap"
              title="近 30 天：有到访的天数 / 会话次数合计"
            >
              30 日到访
            </th>
            <th class="text-right px-4 py-3 font-medium whitespace-nowrap">7 日学习</th>
            <th class="text-right px-4 py-3 font-medium whitespace-nowrap">学完</th>
            <th class="text-right px-4 py-3 font-medium whitespace-nowrap">查词</th>
            <th class="text-left px-4 py-3 font-medium whitespace-nowrap" title="近 30 日停留最长的前 3 个页面">
              常停留
            </th>
            <th class="text-left px-4 py-3 font-medium whitespace-nowrap">注册时间</th>
            <th class="text-left px-3 py-3 font-medium w-24 max-w-[6.5rem] whitespace-nowrap">激活时间</th>
            <th class="text-right px-4 py-3 font-medium">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in rows" :key="user.id" class="border-t border-black/5">
            <td class="px-3 py-3 w-44 max-w-[11rem] overflow-hidden">
              <div class="flex items-center gap-1.5 min-w-0">
                <span
                  class="inline-block w-2 h-2 rounded-full shrink-0"
                  :class="user.is_online ? 'bg-emerald-500' : 'bg-neutral-200'"
                  :title="user.is_online ? '当前在线' : '离线'"
                  aria-hidden="true"
                />
                <div class="min-w-0">
                  <div class="truncate" :title="user.email">{{ user.email }}</div>
                  <div v-if="user.is_staff" class="text-xs text-amber-600">管理员</div>
                  <div v-else-if="user.is_online" class="text-xs text-emerald-600">在线</div>
                </div>
              </div>
            </td>
            <td class="px-4 py-3 whitespace-nowrap">
              <template v-if="clientLabel(user)">
                <span
                  class="inline-flex items-center px-2 py-0.5 rounded-md text-xs font-medium leading-none"
                  :class="clientBadgeClass(user)"
                  :title="user.is_online ? '当前访问端' : '最近一次访问端（当前离线）'"
                >
                  {{ clientLabel(user) }}
                </span>
                <div
                  v-if="deviceLabel(user) && surfaceLabel(user.last_client)"
                  class="mt-1 text-[10px] text-neutral-400"
                >
                  {{ surfaceLabel(user.last_client) }}
                </div>
                <div v-if="!user.is_online" class="mt-1 text-[10px] text-neutral-400">离线前</div>
              </template>
              <span v-else class="text-neutral-400">—</span>
            </td>
            <td class="px-4 py-3 whitespace-nowrap">
              <span
                class="inline-flex items-center px-2 py-0.5 rounded-md text-xs font-medium leading-none"
                :class="
                  user.wx_bound
                    ? 'bg-emerald-100 text-emerald-800'
                    : 'bg-neutral-100 text-neutral-500'
                "
                :title="user.wx_bound ? '已绑定微信小程序' : '未绑定微信小程序'"
              >
                {{ user.wx_bound ? '已关联' : '未关联' }}
              </span>
            </td>
            <td class="px-4 py-3">
              <div class="space-y-1">
                <span
                  v-if="memberPlanTag(user)"
                  class="inline-flex items-center px-2 py-0.5 rounded-md text-xs font-medium leading-none"
                  :class="memberBadgeClass(user)"
                >
                  {{ memberPlanTag(user) }}
                </span>
                <div
                  v-if="showMemberUntil(user) && user.member_until"
                  class="text-xs leading-tight"
                  :class="memberKind(user) === 'expired' ? 'text-orange-700' : 'text-neutral-600'"
                  :title="user.member_until"
                >
                  {{ user.member_until.slice(0, 10) }}
                </div>
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
            <td class="px-3 py-3 w-24 max-w-[6.5rem] overflow-hidden">
              <div
                v-if="user.last_active_at"
                class="leading-tight"
                :title="user.last_active_at"
              >
                <div>{{ user.last_active_at.slice(0, 10) }}</div>
                <div class="text-xs text-neutral-500">{{ user.last_active_at.slice(11) }}</div>
              </div>
              <span v-else class="text-neutral-400">—</span>
            </td>
            <td class="px-4 py-3 text-right tabular-nums whitespace-nowrap">
              {{ user.visit_sessions_today ?? 0 }}
            </td>
            <td class="px-4 py-3 text-right tabular-nums whitespace-nowrap">
              <div>{{ user.visit_days_7d ?? 0 }}/7 天</div>
              <div class="text-xs text-neutral-500">{{ user.visit_sessions_7d ?? 0 }} 次</div>
            </td>
            <td class="px-4 py-3 text-right tabular-nums whitespace-nowrap">
              <div>{{ user.visit_days_30d ?? 0 }}/30 天</div>
              <div class="text-xs text-neutral-500">{{ user.visit_sessions_30d ?? 0 }} 次</div>
            </td>
            <td class="px-4 py-3 text-right tabular-nums whitespace-nowrap">
              {{ formatWatchTime(user.watch_time_7d) }}
            </td>
            <td class="px-4 py-3 text-right tabular-nums">{{ user.completed_episodes }}</td>
            <td class="px-4 py-3 text-right tabular-nums">{{ user.lookup_count }}</td>
            <td class="px-4 py-3 text-xs text-neutral-600 min-w-[8rem]">
              <template v-if="user.top_pages?.length">
                <div
                  v-for="p in user.top_pages"
                  :key="p.page_key"
                  class="flex justify-between gap-2 whitespace-nowrap"
                >
                  <span class="truncate">{{ p.label }}</span>
                  <span class="tabular-nums text-neutral-400 shrink-0">{{
                    formatDwellShort(p.dwell_seconds)
                  }}</span>
                </div>
              </template>
              <span v-else class="text-neutral-400">—</span>
            </td>
            <td class="px-4 py-3 whitespace-nowrap">{{ user.created_at }}</td>
            <td class="px-3 py-3 w-24 max-w-[6.5rem] overflow-hidden">
              <div
                v-if="user.member_activated_at"
                class="leading-tight"
                :title="user.member_activated_at"
              >
                <div>{{ user.member_activated_at.slice(0, 10) }}</div>
                <div class="text-xs text-neutral-500">{{ user.member_activated_at.slice(11) }}</div>
              </div>
              <span v-else class="text-neutral-400">—</span>
            </td>
            <td class="px-4 py-3 text-right space-x-2 whitespace-nowrap">
              <select
                class="max-w-[7.5rem] rounded-md border border-black/10 bg-white px-1.5 py-1 text-xs text-neutral-800 disabled:opacity-50"
                :value="''"
                :disabled="savingId === user.id"
                @change="onGrantChange(user, $event)"
              >
                <option value="" disabled>开通</option>
                <option value="quarter">季度 90 天</option>
                <option value="year">年度 365 天</option>
                <option value="forever">永久会员</option>
                <option value="custom">赠送天数…</option>
              </select>
              <button
                v-if="user.is_member"
                type="button"
                class="text-neutral-900 hover:underline disabled:opacity-50"
                :disabled="savingId === user.id"
                @click="onMembershipAction(user, 'revoke')"
              >
                取消会员
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
              <button
                v-if="user.wx_bound"
                type="button"
                class="text-neutral-600 hover:underline disabled:opacity-50"
                :disabled="savingId === user.id || user.wechat_only"
                :title="
                  user.wechat_only
                    ? '仅微信账号，请先关联网页邮箱'
                    : '解除微信与该网页账号的绑定'
                "
                @click="unbindWechat(user)"
              >
                解绑微信
              </button>
            </td>
          </tr>
          <tr v-if="!rows.length">
            <td colspan="17" class="px-4 py-8 text-center text-neutral-500">暂无数据</td>
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

    <div
      v-if="customGrantUser"
      class="fixed inset-0 z-40 flex items-center justify-center bg-black/30 p-4"
      @click.self="customGrantUser = null"
    >
      <div class="w-full max-w-sm rounded-xl bg-white p-4 shadow-lg space-y-3">
        <h3 class="text-sm font-medium text-neutral-900">赠送会员天数</h3>
        <p class="text-xs text-neutral-500 break-all">{{ customGrantUser.email }}</p>
        <p v-if="memberKind(customGrantUser) === 'active' && customGrantUser.member_until" class="text-xs text-amber-700">
          当前有效至 {{ customGrantUser.member_until.slice(0, 10) }}，将在此基础上叠加。
        </p>
        <label class="block text-sm text-neutral-700">
          天数
          <input
            v-model="customDays"
            type="number"
            min="1"
            max="3650"
            class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2 text-sm"
            @keyup.enter="submitCustomDays"
          />
        </label>
        <p class="text-xs text-neutral-400">1–3650 天，未过期则从原到期日往后延。</p>
        <div class="flex justify-end gap-2">
          <button
            type="button"
            class="rounded-lg border border-black/10 px-3 py-1.5 text-sm"
            @click="customGrantUser = null"
          >
            取消
          </button>
          <button
            type="button"
            class="rounded-lg bg-neutral-900 text-white px-3 py-1.5 text-sm disabled:opacity-50"
            :disabled="savingId === customGrantUser.id"
            @click="submitCustomDays"
          >
            确定赠送
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
