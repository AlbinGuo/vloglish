<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import DauTrendChart from '@/components/charts/DauTrendChart.vue'
import UserGeoBarChart from '@/components/charts/UserGeoBarChart.vue'
import {
  adminFetchDashboard,
  adminFetchOnlineUsers,
  adminFetchPageDwellStats,
  adminFetchSiteSettings,
  adminFetchUserGeoStats,
  adminPatchSiteSettings,
  type AdminPageDwellStats,
  type AdminUserGeoStats,
  type DashboardStats,
} from '@/api/admin'

const loading = ref(true)
const stats = ref<DashboardStats | null>(null)
const geoStats = ref<AdminUserGeoStats | null>(null)
const pageDwell = ref<AdminPageDwellStats | null>(null)
const onlineUsers = ref(0)
const onlineMembers = ref(0)
const onlineFree = ref(0)
const onlineWeb = ref(0)
const onlineApp = ref(0)
const onlineAndroid = ref(0)
const onlineIos = ref(0)
const onlineUnknown = ref(0)
const onlineWindowSec = ref(90)

const membershipGateEnabled = ref(true)
const gateSaving = ref(false)
const gateError = ref('')
const gateSavedHint = ref('')

let onlinePollTimer: ReturnType<typeof setInterval> | null = null

function applyOnline(data: {
  online_users: number
  online_members?: number
  online_free?: number
  online_web?: number
  online_app?: number
  online_android?: number
  online_ios?: number
  online_unknown?: number
  window_sec?: number
}) {
  onlineUsers.value = data.online_users
  onlineMembers.value = data.online_members ?? 0
  onlineFree.value = data.online_free ?? 0
  onlineWeb.value = data.online_web ?? 0
  onlineApp.value = data.online_app ?? 0
  onlineAndroid.value = data.online_android ?? 0
  onlineIos.value = data.online_ios ?? 0
  onlineUnknown.value = data.online_unknown ?? 0
  if (data.window_sec != null) onlineWindowSec.value = data.window_sec
}

async function refreshOnlineUsers() {
  try {
    applyOnline(await adminFetchOnlineUsers())
  } catch {
    // 保持上次数值
  }
}

const clientShare = computed(() => {
  const total = Math.max(1, onlineUsers.value)
  const web = onlineWeb.value
  const app = onlineApp.value
  const unknown = onlineUnknown.value
  return {
    webPct: Math.round((web / total) * 100),
    appPct: Math.round((app / total) * 100),
    unknownPct: Math.round((unknown / total) * 100),
    webWidth: `${(web / total) * 100}%`,
    appWidth: `${(app / total) * 100}%`,
    unknownWidth: `${(unknown / total) * 100}%`,
  }
})

async function toggleMembershipGate() {
  if (gateSaving.value) return
  const next = !membershipGateEnabled.value
  const confirmMsg = next
    ? '开启后：非会员立即恢复视频/合集/文章限量。确认开启？'
    : '关闭后：已登录用户可看全部视频、合集与文章；AI 仍限量。新注册用户仍是普通用户。确认关闭？'
  if (!window.confirm(confirmMsg)) return

  gateSaving.value = true
  gateError.value = ''
  gateSavedHint.value = ''
  try {
    const data = await adminPatchSiteSettings({ membership_gate_enabled: next })
    membershipGateEnabled.value = data.membership_gate_enabled
    gateSavedHint.value = data.membership_gate_enabled
      ? '已开启会员内容限制'
      : '已关闭会员内容限制（登录用户内容全开；AI 仍限）'
  } catch {
    gateError.value = '保存失败，请重试'
  } finally {
    gateSaving.value = false
  }
}

function formatDwell(sec: number) {
  const s = Math.max(0, Math.floor(sec || 0))
  if (s < 60) return `${s} 秒`
  const m = Math.floor(s / 60)
  if (m < 60) return `${m} 分钟`
  const h = Math.floor(m / 60)
  const rm = m % 60
  return rm ? `${h} 小时 ${rm} 分` : `${h} 小时`
}

const pageDwellMax = computed(() =>
  Math.max(1, ...(pageDwell.value?.pages.map((p) => p.dwell_seconds) ?? [1])),
)

onMounted(async () => {
  try {
    const [dashboard, geo, site, dwell] = await Promise.all([
      adminFetchDashboard(),
      adminFetchUserGeoStats().catch(() => null),
      adminFetchSiteSettings().catch(() => null),
      adminFetchPageDwellStats(7, 8).catch(() => null),
    ])
    stats.value = dashboard
    geoStats.value = geo
    pageDwell.value = dwell
    if (site) membershipGateEnabled.value = site.membership_gate_enabled
    applyOnline({
      online_users: dashboard.online_users_now,
      online_members: dashboard.online_members_now,
      online_free: dashboard.online_free_now,
      online_web: dashboard.online_web_now,
      online_app: dashboard.online_app_now,
      online_android: dashboard.online_android_now,
      online_ios: dashboard.online_ios_now,
      online_unknown: dashboard.online_unknown_now,
    })
    await refreshOnlineUsers()
  } finally {
    loading.value = false
  }
  onlinePollTimer = setInterval(refreshOnlineUsers, 30000)
})

onUnmounted(() => {
  if (onlinePollTimer) clearInterval(onlinePollTimer)
})

const cards = [
  { key: 'users_total', label: '用户总数' },
  { key: 'users_today', label: '今日注册' },
  { key: 'members_total', label: '会员数' },
  { key: 'episodes_total', label: '剧集总数' },
  { key: 'episodes_published', label: '已发布' },
  { key: 'episodes_draft', label: '草稿' },
  { key: 'episodes_missing_media', label: '缺媒体 URL' },
  { key: 'activation_codes_total', label: '激活码总数' },
  { key: 'activation_codes_available', label: '未使用激活码' },
  { key: 'activation_codes_used', label: '已使用激活码' },
  { key: 'learning_active_7d', label: '7 日活跃学习用户' },
  { key: 'learning_completions_total', label: '累计学完期数' },
  { key: 'learning_lookups_total', label: '累计查词次数' },
  { key: 'ai_calls_today', label: '今日 AI 调用' },
  { key: 'ai_billed_today', label: '今日 AI 计费' },
] as const

const dauTrend = computed(() => stats.value?.dau_trend ?? [])
const registerLearn = computed(() => stats.value?.funnel_register_learn ?? null)
const memberFunnel = computed(() => stats.value?.funnel_member ?? null)

function barWidth(rate: number) {
  return `${Math.max(0, Math.min(100, rate))}%`
}
</script>

<template>
  <div v-if="loading" class="text-neutral-500">加载中...</div>
  <div v-else-if="stats" class="space-y-4">
    <section
      class="rounded-xl border p-5 shadow-sm"
      :class="
        membershipGateEnabled
          ? 'border-amber-200 bg-gradient-to-br from-amber-50 to-white'
          : 'border-sky-200 bg-gradient-to-br from-sky-50 to-white'
      "
    >
      <div class="flex flex-wrap items-start justify-between gap-4">
        <div class="min-w-0 flex-1">
          <h2 class="font-medium text-neutral-900">会员内容限制</h2>
          <p class="mt-1 text-sm text-neutral-600 leading-relaxed max-w-2xl">
            开启时：非会员只能播放管理员勾选「对普通用户开放」的剧集，合集/文章仍需会员，AI 每日限额。关闭时：已登录可看全部视频、合集与文章，AI 仍限；新注册用户仍是普通用户，不会自动成为会员。
          </p>
          <p class="mt-2 text-sm font-medium" :class="membershipGateEnabled ? 'text-amber-800' : 'text-sky-800'">
            当前：{{ membershipGateEnabled ? '已开启（内容限量）' : '已关闭（登录用户内容全开）' }}
          </p>
          <p v-if="gateSavedHint" class="mt-1 text-xs text-emerald-700">{{ gateSavedHint }}</p>
          <p v-if="gateError" class="mt-1 text-xs text-red-600">{{ gateError }}</p>
        </div>
        <button
          type="button"
          class="shrink-0 rounded-lg px-4 py-2 text-sm font-medium transition disabled:opacity-50"
          :class="
            membershipGateEnabled
              ? 'bg-sky-700 text-white hover:bg-sky-800'
              : 'bg-amber-700 text-white hover:bg-amber-800'
          "
          :disabled="gateSaving"
          @click="toggleMembershipGate"
        >
          {{
            gateSaving
              ? '保存中…'
              : membershipGateEnabled
                ? '关闭限制（开放内容）'
                : '开启限制（恢复 Freemium）'
          }}
        </button>
      </div>
    </section>

    <div
      class="rounded-xl border border-emerald-200 bg-gradient-to-br from-emerald-50 to-white p-5 shadow-sm"
    >
      <div class="flex flex-wrap items-start justify-between gap-4">
        <div class="min-w-0 flex-1">
          <p class="text-sm text-emerald-700 mb-1 flex items-center gap-2">
            <span class="inline-block w-2 h-2 rounded-full bg-emerald-500 animate-pulse" aria-hidden="true" />
            当前在线用户
          </p>
          <p class="text-4xl font-semibold tabular-nums text-emerald-900">{{ onlineUsers }}</p>
          <div class="mt-3 flex flex-wrap gap-4 text-sm">
            <div>
              <span class="text-neutral-500">会员</span>
              <span class="ml-2 font-semibold tabular-nums text-amber-800">{{ onlineMembers }}</span>
            </div>
            <div>
              <span class="text-neutral-500">普通用户</span>
              <span class="ml-2 font-semibold tabular-nums text-neutral-800">{{ onlineFree }}</span>
            </div>
          </div>
        </div>
        <p class="text-xs text-neutral-500 text-right max-w-[12rem]">
          近 {{ onlineWindowSec }} 秒内有活动视为在线（不含管理员），每 30 秒自动刷新
        </p>
      </div>

      <div class="mt-5 pt-4 border-t border-emerald-100/80">
        <p class="text-xs font-medium text-neutral-600 mb-3">访问端分布</p>
        <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
          <div class="rounded-lg bg-white/70 border border-sky-100 px-3 py-2.5">
            <p class="text-xs text-sky-700">浏览器</p>
            <p class="mt-0.5 text-2xl font-semibold tabular-nums text-sky-900">{{ onlineWeb }}</p>
            <p class="text-[11px] text-neutral-400">{{ clientShare.webPct }}%</p>
          </div>
          <div class="rounded-lg bg-white/70 border border-violet-100 px-3 py-2.5">
            <p class="text-xs text-violet-700">App</p>
            <p class="mt-0.5 text-2xl font-semibold tabular-nums text-violet-900">{{ onlineApp }}</p>
            <p class="text-[11px] text-neutral-400">
              {{ clientShare.appPct }}%
              <template v-if="onlineApp > 0">
                · Android {{ onlineAndroid }} / iOS {{ onlineIos }}
              </template>
            </p>
          </div>
          <div
            v-if="onlineUnknown > 0"
            class="rounded-lg bg-white/70 border border-neutral-100 px-3 py-2.5"
          >
            <p class="text-xs text-neutral-500">未知</p>
            <p class="mt-0.5 text-2xl font-semibold tabular-nums text-neutral-700">{{ onlineUnknown }}</p>
            <p class="text-[11px] text-neutral-400">尚未上报端信息</p>
          </div>
        </div>
        <div
          v-if="onlineUsers > 0"
          class="mt-3 h-2.5 rounded-full bg-white/80 border border-emerald-100 overflow-hidden flex"
          title="浏览器 / App / 未知"
        >
          <div
            class="h-full bg-sky-500 transition-all"
            :style="{ width: clientShare.webWidth }"
          />
          <div
            class="h-full bg-violet-500 transition-all"
            :style="{ width: clientShare.appWidth }"
          />
          <div
            v-if="onlineUnknown > 0"
            class="h-full bg-neutral-300 transition-all"
            :style="{ width: clientShare.unknownWidth }"
          />
        </div>
        <div class="mt-2 flex flex-wrap gap-3 text-[11px] text-neutral-500">
          <span class="inline-flex items-center gap-1.5">
            <span class="w-2 h-2 rounded-sm bg-sky-500" aria-hidden="true" />
            浏览器
          </span>
          <span class="inline-flex items-center gap-1.5">
            <span class="w-2 h-2 rounded-sm bg-violet-500" aria-hidden="true" />
            App
          </span>
          <span v-if="onlineUnknown > 0" class="inline-flex items-center gap-1.5">
            <span class="w-2 h-2 rounded-sm bg-neutral-300" aria-hidden="true" />
            未知
          </span>
        </div>
      </div>
    </div>

    <!-- 本周健康度 -->
    <section class="rounded-xl border border-black/5 bg-white p-5 shadow-sm space-y-4">
      <div class="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h2 class="font-medium">运营健康度</h2>
          <p class="text-xs text-neutral-400 mt-1">
            DAU 基于到访记录（东八区）；漏斗不含管理员。到访数据上线后才开始累计。
          </p>
        </div>
        <div class="text-right">
          <p class="text-xs text-neutral-500">今日 DAU</p>
          <p class="text-2xl font-semibold tabular-nums text-amber-700">{{ stats.dau_today ?? 0 }}</p>
        </div>
      </div>
      <DauTrendChart v-if="dauTrend.length" :points="dauTrend" height="240px" />
      <p v-else class="py-8 text-center text-sm text-neutral-400">暂无 DAU 趋势数据</p>
    </section>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
      <section
        v-if="registerLearn"
        class="rounded-xl border border-black/5 bg-white p-5 shadow-sm space-y-4"
      >
        <div>
          <h2 class="font-medium">注册 → 首次学习</h2>
          <p class="text-xs text-neutral-400 mt-1">
            有任意视频学习进度即计为已学习；今日首学 {{ registerLearn.first_learn_today }} 人
          </p>
        </div>
        <div class="flex items-end justify-between gap-3">
          <div>
            <p class="text-3xl font-semibold tabular-nums text-neutral-900">
              {{ registerLearn.rate }}%
            </p>
            <p class="text-xs text-neutral-500 mt-1">
              {{ registerLearn.users_learned }} / {{ registerLearn.users_total }} 用户已开过学
            </p>
          </div>
          <div class="text-right text-xs text-neutral-500">
            <p>近 30 日注册 {{ registerLearn.registered_30d }}</p>
            <p class="mt-0.5">
              其中已学习 {{ registerLearn.learned_among_registered_30d }}
              （{{ registerLearn.rate_30d }}%）
            </p>
          </div>
        </div>
        <div class="space-y-2">
          <div class="h-2 rounded-full bg-neutral-100 overflow-hidden">
            <div
              class="h-full rounded-full bg-neutral-800 transition-all"
              :style="{ width: barWidth(registerLearn.rate) }"
            />
          </div>
          <div class="h-2 rounded-full bg-amber-50 overflow-hidden">
            <div
              class="h-full rounded-full bg-amber-500 transition-all"
              :style="{ width: barWidth(registerLearn.rate_30d) }"
              title="近 30 日注册用户转化"
            />
          </div>
          <p class="text-[11px] text-neutral-400">深色：全量转化 · 琥珀色：近 30 日注册转化</p>
        </div>
      </section>

      <section
        v-if="memberFunnel"
        class="rounded-xl border border-black/5 bg-white p-5 shadow-sm space-y-4"
      >
        <div>
          <h2 class="font-medium">用户 → 会员转化</h2>
          <p class="text-xs text-neutral-400 mt-1">
            近 7 日新开通 {{ memberFunnel.activated_7d }} · 近 30 日
            {{ memberFunnel.activated_30d }}
          </p>
        </div>
        <div class="flex items-end justify-between gap-3">
          <div>
            <p class="text-3xl font-semibold tabular-nums text-amber-700">
              {{ memberFunnel.rate }}%
            </p>
            <p class="text-xs text-neutral-500 mt-1">
              {{ memberFunnel.members_total }} / {{ memberFunnel.users_total }} 为会员
            </p>
          </div>
          <div class="text-right text-xs text-neutral-500">
            <p>近 30 日注册 {{ memberFunnel.registered_30d }}</p>
            <p class="mt-0.5">
              其中已开通 {{ memberFunnel.members_among_registered_30d }}
              （{{ memberFunnel.rate_among_registered_30d }}%）
            </p>
          </div>
        </div>
        <div class="space-y-2">
          <div class="h-2 rounded-full bg-neutral-100 overflow-hidden">
            <div
              class="h-full rounded-full bg-amber-600 transition-all"
              :style="{ width: barWidth(memberFunnel.rate) }"
            />
          </div>
          <div class="h-2 rounded-full bg-amber-50 overflow-hidden">
            <div
              class="h-full rounded-full bg-amber-400 transition-all"
              :style="{ width: barWidth(memberFunnel.rate_among_registered_30d) }"
            />
          </div>
          <p class="text-[11px] text-neutral-400">深琥珀：全量会员占比 · 浅色：近 30 日注册开通率</p>
        </div>
      </section>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
      <div
        v-for="card in cards"
        :key="card.key"
        class="rounded-xl border border-black/5 bg-white p-5 shadow-sm"
      >
        <p class="text-sm text-neutral-500 mb-2">{{ card.label }}</p>
        <p class="text-3xl font-semibold tabular-nums">{{ stats[card.key] ?? 0 }}</p>
      </div>
    </div>

    <p class="text-sm text-neutral-500">
      AI 用量明细见
      <RouterLink to="/gnadmin/ai-usage" class="text-amber-700 hover:underline">AI 用量</RouterLink>
    </p>

    <section class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
      <div class="flex flex-wrap items-start justify-between gap-3 mb-4">
        <div>
          <h2 class="font-medium">页面停留 Top</h2>
          <p class="text-xs text-neutral-400 mt-1">
            近 7 日累计停留（由登录用户心跳估算，约 ±1 分钟精度）
            <template v-if="pageDwell">
              · Top 合计 {{ formatDwell(pageDwell.total_dwell_seconds) }}
            </template>
          </p>
        </div>
        <RouterLink to="/gnadmin/users" class="text-sm text-amber-700 hover:underline">
          按用户查看
        </RouterLink>
      </div>
      <div v-if="!pageDwell?.pages.length" class="py-6 text-center text-sm text-neutral-400">
        暂无停留数据（用户登录浏览后开始累计）
      </div>
      <ul v-else class="space-y-3">
        <li v-for="p in pageDwell.pages" :key="p.page_key" class="space-y-1">
          <div class="flex items-baseline justify-between gap-3 text-sm">
            <span class="font-medium text-neutral-800">{{ p.label }}</span>
            <span class="tabular-nums text-neutral-600 shrink-0">
              {{ formatDwell(p.dwell_seconds) }}
              <span class="text-neutral-400 text-xs ml-1">{{ p.users }} 人</span>
            </span>
          </div>
          <div class="h-1.5 rounded-full bg-neutral-100 overflow-hidden">
            <div
              class="h-full rounded-full bg-sky-500/80"
              :style="{ width: `${Math.max(4, (p.dwell_seconds / pageDwellMax) * 100)}%` }"
            />
          </div>
        </li>
      </ul>
    </section>

    <section
      v-if="geoStats?.by_region.length"
      class="rounded-xl border border-black/5 bg-white p-5 shadow-sm"
    >
      <div class="flex flex-wrap items-start justify-between gap-3 mb-4">
        <div>
          <h2 class="font-medium">注册用户地区 Top</h2>
          <p class="text-xs text-neutral-400 mt-1">按省份/国家统计，未知 {{ geoStats.unknown_users }} 人</p>
        </div>
        <RouterLink
          to="/gnadmin/geo"
          class="text-sm text-amber-700 hover:underline shrink-0"
        >
          查看地图 →
        </RouterLink>
      </div>
      <UserGeoBarChart :items="geoStats.by_region" height="240px" />
    </section>
  </div>
</template>
