<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import AppIcon from '@/components/AppIcon.vue'
import UserAvatar from '@/components/UserAvatar.vue'
import ContactAuthorDialog from '@/components/ContactAuthorDialog.vue'
import FeedbackModal from '@/components/FeedbackModal.vue'
import LearningHeatmapChart from '@/components/charts/LearningHeatmapChart.vue'
import LearningStatCard from '@/components/learning/LearningStatCard.vue'
import { getLearningCalendar, getLearningSummary } from '@/api/learning'
import { useIsPhone } from '@/composables/useBreakpoint'
import { useTheme } from '@/composables/useTheme'
import { useAuthStore } from '@/stores/auth'
import { useClipsStore } from '@/stores/clips'
import { useMyCorpusBadgeStore } from '@/stores/myCorpusBadge'
import { useNotificationStore } from '@/stores/notifications'
import { useVocabularyStore } from '@/stores/vocabulary'
import { useVoiceCloneStore } from '@/stores/voiceClone'
import { isNativePlatform } from '@/utils/platform'

const router = useRouter()
const auth = useAuthStore()
const notifications = useNotificationStore()
const corpusBadge = useMyCorpusBadgeStore()
const vocabulary = useVocabularyStore()
const clips = useClipsStore()
const voiceClone = useVoiceCloneStore()

const { themeMode, setThemeMode } = useTheme()

const isPhone = useIsPhone()

const contactAuthorOpen = ref(false)
const feedbackOpen = ref(false)
const cycling = ref(false)

const appVersion = ref('')

const statsLoading = ref(true)
const summary = ref<Awaited<ReturnType<typeof getLearningSummary>> | null>(null)
const calendar = ref<{ date: string; watch_time_sec: number; sessions: number }[]>([])

onMounted(async () => {
  let version = ''
  let build = ''
  if (isNativePlatform()) {
    try {
      const { App } = await import('@capacitor/app')
      const info = await App.getInfo()
      version = info.version || ''
      build = info.build || ''
    } catch {
      /* 原生信息不可用时回退到构建版本 */
    }
  }
  if (!version && typeof __APP_VERSION__ !== 'undefined') version = __APP_VERSION__
  appVersion.value = version ? `v${version}${build ? ` (${build})` : ''}` : ''

  try {
    const [s, days] = await Promise.all([getLearningSummary(), getLearningCalendar(90)])
    summary.value = s
    calendar.value = days
  } catch {
    /* 统计加载失败时静默，页面其它功能不受影响 */
  } finally {
    statsLoading.value = false
  }
})

const displayName = computed(() => auth.user?.nickname || auth.user?.email || '账户')
const memberUntilLabel = computed(() => {
  const raw = auth.user?.member_until
  if (!raw) return ''
  const d = new Date(raw)
  if (Number.isNaN(d.getTime())) return ''
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
})
const showEmail = computed(() => Boolean(auth.user?.email && !auth.user?.wechat_only))

const themeOptions: { value: 'light' | 'dark' | 'system'; label: string; icon: string }[] = [
  { value: 'light', label: '浅色', icon: 'sun' },
  { value: 'dark', label: '深色', icon: 'moon' },
  { value: 'system', label: '跟随系统', icon: 'sparkles' },
]

function formatDuration(sec: number) {
  const h = Math.floor(sec / 3600)
  const m = Math.floor((sec % 3600) / 60)
  if (h > 0) return `${h} 小时 ${m} 分`
  return `${m} 分钟`
}

const PHONE_HIDDEN_STAT_LABELS = new Set(['连续天数', '本周学习', '查词次数', '生词本'])

const statCards = computed(() => {
  const s = summary.value
  if (!s) return []
  const cards = [
    { label: '累计学习', value: formatDuration(s.total_watch_time_sec), icon: 'clock' as const, tone: 'amber' as const },
    { label: '已学完', value: `${s.completed_episodes} 期`, icon: 'check-circle' as const, tone: 'emerald' as const },
    { label: '学习中', value: `${s.in_progress_episodes} 期`, icon: 'play-circle' as const, tone: 'blue' as const },
    { label: '连续天数', value: `${s.streak_days} 天`, icon: 'fire' as const, tone: 'orange' as const },
    { label: '今日学习', value: formatDuration(s.today_watch_time_sec), icon: 'sun' as const, tone: 'sky' as const },
    { label: '本周学习', value: formatDuration(s.week_watch_time_sec), icon: 'calendar' as const, tone: 'violet' as const },
    { label: '查词次数', value: String(s.lookup_count), icon: 'search' as const, tone: 'rose' as const },
    { label: '生词本', value: `${s.vocabulary_count} 词`, icon: 'bookmark' as const, tone: 'amber' as const },
  ]
  if (isPhone.value) {
    return cards.filter((card) => !PHONE_HIDDEN_STAT_LABELS.has(card.label))
  }
  return cards
})

async function changeAvatar() {
  if (cycling.value) return
  cycling.value = true
  try {
    await auth.cycleAvatar()
  } catch {
    /* 忽略 */
  } finally {
    cycling.value = false
  }
}

async function handleLogout() {
  await auth.logout()
  notifications.clear()
  corpusBadge.clear()
  vocabulary.clear()
  clips.clear()
  voiceClone.clear()
  await router.replace('/english')
}
</script>

<template>
  <div class="mine-page mx-auto w-full max-w-2xl px-4 pb-8 pt-4 sm:pt-6">
    <!-- 用户卡片 -->
    <section
      class="relative overflow-hidden rounded-3xl border border-line-soft bg-card p-5 shadow-sm"
    >
      <div
        class="pointer-events-none absolute -right-10 -top-12 h-40 w-40 rounded-full bg-brand-soft opacity-70 blur-2xl"
        aria-hidden="true"
      />
      <div class="relative flex items-center gap-4">
        <button
          type="button"
          class="group relative shrink-0 rounded-full ring-2 ring-brand transition active:scale-95"
          :disabled="cycling"
          aria-label="更换头像"
          @click="changeAvatar"
        >
          <UserAvatar
            :avatar-key="auth.user?.avatar_key"
            :user-id="auth.user?.id"
            size-class="w-16 h-16"
            alt=""
          />
          <span
            class="absolute -bottom-1 -right-1 flex h-6 w-6 items-center justify-center rounded-full bg-ink text-ink-inverse shadow ring-2 ring-card"
          >
            <AppIcon name="plus" class="h-3.5 w-3.5" />
          </span>
        </button>

        <div class="min-w-0 flex-1">
          <div class="flex items-center gap-2">
            <p class="truncate text-lg font-semibold text-ink">{{ displayName }}</p>
            <span
              v-if="auth.isMember"
              class="inline-flex items-center gap-1 rounded-full bg-warning-soft px-2 py-0.5 text-[11px] font-medium text-warning"
            >
              <AppIcon name="crown" class="h-3 w-3" />会员
            </span>
            <span
              v-else
              class="inline-flex items-center rounded-full bg-sunken px-2 py-0.5 text-[11px] font-medium text-ink-faint"
            >
              普通用户
            </span>
          </div>
          <p v-if="showEmail" class="mt-0.5 truncate text-[12px] text-ink-faint">{{ auth.user?.email }}</p>
          <p v-if="auth.isMember && memberUntilLabel" class="mt-1 text-[12px] text-ink-soft">
            会员有效期至 {{ memberUntilLabel }}
          </p>
          <button
            v-else-if="!auth.isMember"
            type="button"
            class="mt-1.5 inline-flex items-center gap-1 rounded-full bg-ink px-3 py-1 text-[12px] font-medium text-ink-inverse transition hover:opacity-90"
            @click="router.push('/pricing')"
          >
            开通会员
            <AppIcon name="chevron-right" class="h-3 w-3" />
          </button>
        </div>
      </div>
    </section>

    <!-- 学习统计 -->
    <section class="mt-4 space-y-3">
      <div
        v-if="statsLoading"
        class="rounded-2xl border border-line-soft bg-card px-4 py-6 text-center text-sm text-ink-faint"
      >
        统计加载中…
      </div>
      <template v-else-if="summary">
        <div class="grid grid-cols-2 gap-3 sm:grid-cols-4">
          <LearningStatCard
            v-for="card in statCards"
            :key="card.label"
            :label="card.label"
            :value="card.value"
            :icon="card.icon"
            :tone="card.tone"
          />
        </div>

        <div class="rounded-2xl border border-line-soft bg-card p-4">
          <h2 class="text-[14px] font-medium text-ink">近 90 天学习热力</h2>
          <p class="mt-1 text-[11px] text-ink-faint">颜色越深表示当日学习时长越长</p>
          <div class="mt-3 overflow-x-auto scrollbar-none">
            <LearningHeatmapChart :days="calendar" :range-days="90" theme="amber" height="200px" />
          </div>
        </div>
      </template>
    </section>

    <!-- 设置 -->
    <section class="mt-4 overflow-hidden rounded-2xl border border-line-soft bg-card">
      <RouterLink
        to="/english/study"
        class="flex items-center gap-3 px-4 py-3.5 text-ink-soft transition hover:bg-sunken"
      >
        <AppIcon name="book-open" class="h-5 w-5 shrink-0" />
        <span class="flex-1 text-[14px] text-ink">怎么学</span>
        <AppIcon name="chevron-right" class="h-4 w-4 text-ink-faint" />
      </RouterLink>

      <div class="flex items-center gap-3 border-t border-line-soft px-4 py-3.5">
        <AppIcon name="moon" class="h-5 w-5 shrink-0 text-ink-soft" />
        <span class="flex-1 text-[14px] text-ink">主题</span>
        <div class="flex items-center gap-1 rounded-full bg-sunken p-0.5">
          <button
            v-for="opt in themeOptions"
            :key="opt.value"
            type="button"
            class="rounded-full px-2.5 py-1 text-[12px] transition"
            :class="
              themeMode === opt.value
                ? 'bg-card text-ink shadow-sm font-medium'
                : 'text-ink-faint'
            "
            @click="setThemeMode(opt.value)"
          >
            {{ opt.label }}
          </button>
        </div>
      </div>

      <button
        type="button"
        class="flex w-full items-center gap-3 border-t border-line-soft px-4 py-3.5 text-left text-ink-soft transition hover:bg-sunken"
        @click="contactAuthorOpen = true"
      >
        <AppIcon name="chat-bubble" class="h-5 w-5 shrink-0" />
        <span class="flex-1 text-[14px]">联系作者</span>
        <AppIcon name="chevron-right" class="h-4 w-4 text-ink-faint" />
      </button>

      <button
        type="button"
        class="flex w-full items-center gap-3 border-t border-line-soft px-4 py-3.5 text-left text-ink-soft transition hover:bg-sunken"
        @click="feedbackOpen = true"
      >
        <AppIcon name="inbox" class="h-5 w-5 shrink-0" />
        <span class="flex-1 text-[14px]">意见反馈</span>
        <AppIcon name="chevron-right" class="h-4 w-4 text-ink-faint" />
      </button>

      <button
        type="button"
        class="flex w-full items-center gap-3 border-t border-line-soft px-4 py-3.5 text-left text-danger transition hover:bg-sunken"
        @click="handleLogout"
      >
        <AppIcon name="logout" class="h-5 w-5 shrink-0" />
        <span class="flex-1 text-[14px]">退出登录</span>
      </button>
    </section>

    <p v-if="appVersion" class="mt-6 mb-1 text-center text-[11px] tracking-wide text-ink-faint">
      Vloglish {{ appVersion }}
    </p>

    <ContactAuthorDialog v-model:open="contactAuthorOpen" />
    <FeedbackModal v-model:open="feedbackOpen" />
  </div>
</template>
