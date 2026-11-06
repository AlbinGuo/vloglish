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
import { getErrorDetail } from '@/api/tokens'
import { useIsPhone } from '@/composables/useBreakpoint'
import { useTheme } from '@/composables/useTheme'
import { useHighlightStyle, type HighlightStyle } from '@/composables/useHighlightStyle'
import { useVocabDanmaku } from '@/composables/useVocabDanmaku'
import { useFloatingBall } from '@/composables/useFloatingBall'
import { useSubtitleAlign } from '@/composables/useSubtitleAlign'
import {
  usePlayerSubtitlePosition,
  type PlayerSubtitlePosition,
} from '@/composables/useSubtitleOverlayPosition'
import {
  usePlayerSubtitlePrefs,
  type PlayerSubtitleSize,
} from '@/composables/usePlayerSubtitlePrefs'
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
const { highlightStyle, setHighlightStyle } = useHighlightStyle()
const { vocabDanmakuEnabled, setVocabDanmakuEnabled } = useVocabDanmaku()
const { floatingBallEnabled, setFloatingBallEnabled } = useFloatingBall()
const { subtitleAlign, setSubtitleAlign } = useSubtitleAlign()
const { playerSubtitlePosition, setPlayerSubtitlePosition } = usePlayerSubtitlePosition()
const { subtitleSize, setSubtitleSize } = usePlayerSubtitlePrefs()

const isPhone = useIsPhone()

const contactAuthorOpen = ref(false)
const feedbackOpen = ref(false)
const cycling = ref(false)

const idCopied = ref(false)
let copyTimer: ReturnType<typeof setTimeout> | undefined
async function copyUserId() {
  const value = auth.user?.user_no
  if (!value) return
  try {
    await navigator.clipboard.writeText(value)
  } catch {
    const el = document.createElement('textarea')
    el.value = value
    el.style.position = 'fixed'
    el.style.opacity = '0'
    document.body.appendChild(el)
    el.select()
    try {
      document.execCommand('copy')
    } catch {
      /* ignore */
    }
    document.body.removeChild(el)
  }
  idCopied.value = true
  if (copyTimer) clearTimeout(copyTimer)
  copyTimer = setTimeout(() => {
    idCopied.value = false
  }, 1500)
}

const deleteOpen = ref(false)
const deleteChecked = ref(false)
const deleting = ref(false)
const deleteError = ref('')

const appVersion = ref('')

const statsLoading = ref(true)
const summary = ref<Awaited<ReturnType<typeof getLearningSummary>> | null>(null)
const calendar = ref<{ date: string; watch_time_sec: number; sessions: number }[]>([])

onMounted(async () => {
  // 进入「我的」时刷新账号信息，确保支付后会员状态立即反映
  if (auth.isLoggedIn) void auth.fetchMe().catch(() => {})
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

const highlightOptions: { value: HighlightStyle; label: string }[] = [
  { value: 'underline', label: '下划线' },
  { value: 'background', label: '背景色' },
]

const alignOptions: { value: 'left' | 'center'; label: string }[] = [
  { value: 'left', label: '左对齐' },
  { value: 'center', label: '居中' },
]

const subtitlePositionOptions: { value: PlayerSubtitlePosition; label: string }[] = [
  { value: 'top', label: '顶部' },
  { value: 'middle', label: '中部' },
  { value: 'bottom', label: '底部' },
  { value: 'off', label: '关闭' },
]

const subtitleSizeOptions: { value: PlayerSubtitleSize; label: string }[] = [
  { value: 'small', label: '小' },
  { value: 'medium', label: '中' },
  { value: 'large', label: '大' },
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

function openDeleteDialog() {
  deleteChecked.value = false
  deleteError.value = ''
  deleteOpen.value = true
}

async function confirmDeleteAccount() {
  if (!deleteChecked.value || deleting.value) return
  deleting.value = true
  deleteError.value = ''
  try {
    await auth.deleteAccount()
    notifications.clear()
    corpusBadge.clear()
    vocabulary.clear()
    clips.clear()
    voiceClone.clear()
    deleteOpen.value = false
    await router.replace('/login')
  } catch (e) {
    deleteError.value = getErrorDetail(e) || '注销失败，请稍后重试'
  } finally {
    deleting.value = false
  }
}

// 登录邮箱与密码（Apple 登录用户绑定网页登录）
const credOpen = ref(false)
const credEmail = ref('')
const credPassword = ref('')
const credPassword2 = ref('')
const credCurrent = ref('')
const credError = ref('')
const credBusy = ref(false)
const credDone = ref(false)

const emailBound = computed(() => Boolean(auth.user?.email_bound))

function maskEmail(email?: string | null) {
  if (!email) return ''
  const at = email.indexOf('@')
  if (at <= 1) return email
  const name = email.slice(0, at)
  const keep = name.slice(0, Math.min(2, at))
  return `${keep}${'*'.repeat(Math.max(1, name.length - keep.length))}${email.slice(at)}`
}

function openCredentials() {
  credEmail.value = emailBound.value ? (auth.user?.email || '') : ''
  credPassword.value = ''
  credPassword2.value = ''
  credCurrent.value = ''
  credError.value = ''
  credDone.value = false
  credOpen.value = true
}

async function submitCredentials() {
  if (credBusy.value || credDone.value) return
  credError.value = ''
  const email = credEmail.value.trim()
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    credError.value = '请输入正确的邮箱地址'
    return
  }
  if (credPassword.value.length < 8) {
    credError.value = '密码至少 8 位'
    return
  }
  if (credPassword.value !== credPassword2.value) {
    credError.value = '两次输入的密码不一致'
    return
  }
  if (emailBound.value && !credCurrent.value) {
    credError.value = '请输入已设置的登录密码，以确认身份'
    return
  }
  credBusy.value = true
  try {
    await auth.setCredentials(
      email,
      credPassword.value,
      emailBound.value ? credCurrent.value : undefined,
    )
    credDone.value = true
    setTimeout(() => {
      credOpen.value = false
    }, 800)
  } catch (e) {
    const status = (e as { response?: { status?: number } })?.response?.status
    const detail = getErrorDetail(e)
    if (status === 409) {
      credError.value =
        detail ||
        '该邮箱已被其他账号使用。如果你就是该账号的主人，请直接用该邮箱 + 密码登录，或联系客服合并账号。'
    } else {
      credError.value = detail || '保存失败，请稍后重试'
    }
  } finally {
    credBusy.value = false
  }
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
            <p class="min-w-0 truncate text-lg font-semibold text-ink">{{ displayName }}</p>
            <span
              v-if="auth.isMember"
              class="inline-flex shrink-0 items-center gap-1 whitespace-nowrap rounded-full bg-warning-soft px-2 py-0.5 text-[11px] font-medium text-warning"
            >
              <AppIcon name="crown" class="h-3 w-3" />会员
            </span>
            <span
              v-else
              class="inline-flex shrink-0 items-center whitespace-nowrap rounded-full bg-sunken px-2 py-0.5 text-[11px] font-medium text-ink-faint"
            >
              普通用户
            </span>
          </div>
          <div v-if="auth.user?.user_no" class="mt-1 flex items-center gap-1.5">
            <span class="text-[12px] text-ink-faint">ID</span>
            <span class="font-mono text-[13px] font-medium tracking-wide text-ink-soft">{{ auth.user.user_no }}</span>
            <button
              type="button"
              class="inline-flex items-center gap-0.5 rounded-md px-1.5 py-0.5 text-[11px] text-ink-faint transition hover:bg-sunken hover:text-ink"
              :aria-label="idCopied ? '已复制' : '复制用户ID'"
              @click="copyUserId"
            >
              <AppIcon :name="idCopied ? 'check-xs' : 'clipboard'" class="h-3.5 w-3.5" />
              {{ idCopied ? '已复制' : '复制' }}
            </button>
          </div>
          <p v-else-if="showEmail" class="mt-0.5 truncate text-[12px] text-ink-faint">{{ auth.user?.email }}</p>
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

    <!-- 我的语料库 + 浏览记录 -->
    <section class="mt-4 overflow-hidden rounded-2xl border border-line-soft bg-card">
      <RouterLink
        to="/english/my-submissions?tab=favorites"
        class="flex items-center gap-3 px-4 py-3.5 text-ink-soft transition hover:bg-sunken"
      >
        <AppIcon name="sparkle" class="h-5 w-5 shrink-0 text-amber-500" />
        <span class="flex-1 text-[14px] text-ink">我的语料库</span>
        <span
          v-if="corpusBadge.hasNew"
          class="rounded-md bg-red-500 px-1.5 py-0.5 text-[10px] font-bold leading-none text-white"
        >新</span>
        <span v-else-if="corpusBadge.count > 0" class="text-[12px] text-ink-faint">
          {{ corpusBadge.count }}
        </span>
        <AppIcon name="chevron-right" class="h-4 w-4 text-ink-faint" />
      </RouterLink>
      <RouterLink
        to="/english/history"
        class="flex items-center gap-3 border-t border-line-soft px-4 py-3.5 text-ink-soft transition hover:bg-sunken"
      >
        <AppIcon name="history" class="h-5 w-5 shrink-0 text-sky-500" />
        <span class="flex-1 text-[14px] text-ink">浏览记录</span>
        <AppIcon name="chevron-right" class="h-4 w-4 text-ink-faint" />
      </RouterLink>
    </section>

    <!-- 设置 -->
    <section class="mt-4 overflow-hidden rounded-2xl border border-line-soft bg-card">
      <h2 class="px-4 pt-4 text-[14px] font-medium text-ink">设置</h2>

      <!-- 主题 -->
      <div class="flex items-center gap-3 px-4 py-3.5">
        <AppIcon name="sun" class="h-5 w-5 shrink-0 text-ink-soft" />
        <span class="flex-1 text-[14px] text-ink">主题</span>
        <div class="flex items-center gap-1 rounded-full bg-sunken p-0.5">
          <button
            v-for="opt in themeOptions"
            :key="opt.value"
            type="button"
            class="rounded-full px-2.5 py-1 text-[12px] transition"
            :class="themeMode === opt.value ? 'bg-card text-ink shadow-sm font-medium' : 'text-ink-faint'"
            @click="setThemeMode(opt.value)"
          >
            {{ opt.label }}
          </button>
        </div>
      </div>

      <!-- 文字高亮样式 -->
      <div class="flex items-center gap-3 border-t border-line-soft px-4 py-3.5">
        <AppIcon name="sparkles" class="h-5 w-5 shrink-0 text-ink-soft" />
        <span class="flex-1 text-[14px] text-ink">文字高亮</span>
        <div class="flex items-center gap-1 rounded-full bg-sunken p-0.5">
          <button
            v-for="opt in highlightOptions"
            :key="opt.value"
            type="button"
            class="rounded-full px-2.5 py-1 text-[12px] transition"
            :class="highlightStyle === opt.value ? 'bg-card text-ink shadow-sm font-medium' : 'text-ink-faint'"
            @click="setHighlightStyle(opt.value)"
          >
            {{ opt.label }}
          </button>
        </div>
      </div>

      <!-- 字幕对齐 -->
      <div class="flex items-center gap-3 border-t border-line-soft px-4 py-3.5">
        <AppIcon name="align-left" class="h-5 w-5 shrink-0 text-ink-soft" />
        <span class="flex-1 text-[14px] text-ink">字幕对齐</span>
        <div class="flex items-center gap-1 rounded-full bg-sunken p-0.5">
          <button
            v-for="opt in alignOptions"
            :key="opt.value"
            type="button"
            class="rounded-full px-2.5 py-1 text-[12px] transition"
            :class="subtitleAlign === opt.value ? 'bg-card text-ink shadow-sm font-medium' : 'text-ink-faint'"
            @click="setSubtitleAlign(opt.value)"
          >
            {{ opt.label }}
          </button>
        </div>
      </div>

      <!-- 播放器字幕位置 -->
      <div class="flex items-center gap-3 border-t border-line-soft px-4 py-3.5">
        <AppIcon name="subtitles" class="h-5 w-5 shrink-0 text-ink-soft" />
        <span class="flex-1 text-[14px] text-ink">播放器字幕位置</span>
        <div class="flex items-center gap-1 rounded-full bg-sunken p-0.5">
          <button
            v-for="opt in subtitlePositionOptions"
            :key="opt.value"
            type="button"
            class="rounded-full px-2.5 py-1 text-[12px] transition"
            :class="playerSubtitlePosition === opt.value ? 'bg-card text-ink shadow-sm font-medium' : 'text-ink-faint'"
            @click="setPlayerSubtitlePosition(opt.value)"
          >
            {{ opt.label }}
          </button>
        </div>
      </div>

      <!-- 字幕文字大小 -->
      <div class="flex items-center gap-3 border-t border-line-soft px-4 py-3.5">
        <AppIcon name="subtitles" class="h-5 w-5 shrink-0 text-ink-soft" />
        <span class="flex-1 text-[14px] text-ink">字幕文字大小</span>
        <div class="flex items-center gap-1 rounded-full bg-sunken p-0.5">
          <button
            v-for="opt in subtitleSizeOptions"
            :key="opt.value"
            type="button"
            class="rounded-full px-3 py-1 text-[12px] transition"
            :class="subtitleSize === opt.value ? 'bg-card text-ink shadow-sm font-medium' : 'text-ink-faint'"
            @click="setSubtitleSize(opt.value)"
          >
            {{ opt.label }}
          </button>
        </div>
      </div>

      <!-- 词汇弹幕 -->
      <div class="flex items-center gap-3 border-t border-line-soft px-4 py-3.5">
        <AppIcon name="chat-bubble" class="h-5 w-5 shrink-0 text-ink-soft" />
        <div class="min-w-0 flex-1">
          <p class="text-[14px] text-ink">词汇弹幕</p>
          <p class="text-[11px] text-ink-faint">视频上飘过当前句命中的重点词汇</p>
        </div>
        <button
          type="button"
          role="switch"
          :aria-checked="vocabDanmakuEnabled"
          class="relative h-6 w-11 shrink-0 rounded-full transition-colors"
          :class="vocabDanmakuEnabled ? 'bg-brand' : 'bg-neutral-300 dark:bg-neutral-600'"
          @click="setVocabDanmakuEnabled(!vocabDanmakuEnabled)"
        >
          <span
            class="absolute top-0.5 h-5 w-5 rounded-full bg-white shadow transition-all"
            :class="vocabDanmakuEnabled ? 'left-[1.375rem]' : 'left-0.5'"
          />
        </button>
      </div>

      <!-- 悬浮播放球 -->
      <div class="flex items-center gap-3 border-t border-line-soft px-4 py-3.5">
        <AppIcon name="play-circle" class="h-5 w-5 shrink-0 text-ink-soft" />
        <div class="min-w-0 flex-1">
          <p class="text-[14px] text-ink">悬浮播放球</p>
          <p class="text-[11px] text-ink-faint">手机视频页显示可拖动悬浮球，方便单手操作</p>
        </div>
        <button
          type="button"
          role="switch"
          :aria-checked="floatingBallEnabled"
          class="relative h-6 w-11 shrink-0 rounded-full transition-colors"
          :class="floatingBallEnabled ? 'bg-brand' : 'bg-neutral-300 dark:bg-neutral-600'"
          @click="setFloatingBallEnabled(!floatingBallEnabled)"
        >
          <span
            class="absolute top-0.5 h-5 w-5 rounded-full bg-white shadow transition-all"
            :class="floatingBallEnabled ? 'left-[1.375rem]' : 'left-0.5'"
          />
        </button>
      </div>
    </section>

    <!-- 账户与更多 -->
    <section class="mt-4 overflow-hidden rounded-2xl border border-line-soft bg-card">
      <RouterLink
        to="/english/study"
        class="flex items-center gap-3 px-4 py-3.5 text-ink-soft transition hover:bg-sunken"
      >
        <AppIcon name="book-open" class="h-5 w-5 shrink-0" />
        <span class="flex-1 text-[14px] text-ink">怎么学</span>
        <AppIcon name="chevron-right" class="h-4 w-4 text-ink-faint" />
      </RouterLink>

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

      <RouterLink
        to="/privacy"
        class="flex w-full items-center gap-3 border-t border-line-soft px-4 py-3.5 text-left text-ink-soft transition hover:bg-sunken"
      >
        <AppIcon name="document-text" class="h-5 w-5 shrink-0" />
        <span class="flex-1 text-[14px]">隐私政策</span>
        <AppIcon name="chevron-right" class="h-4 w-4 text-ink-faint" />
      </RouterLink>

      <RouterLink
        to="/terms"
        class="flex w-full items-center gap-3 border-t border-line-soft px-4 py-3.5 text-left text-ink-soft transition hover:bg-sunken"
      >
        <AppIcon name="document-text" class="h-5 w-5 shrink-0" />
        <span class="flex-1 text-[14px]">用户协议</span>
        <AppIcon name="chevron-right" class="h-4 w-4 text-ink-faint" />
      </RouterLink>

      <button
        type="button"
        class="flex w-full items-center gap-3 border-t border-line-soft px-4 py-3.5 text-left text-danger transition hover:bg-sunken"
        @click="handleLogout"
      >
        <AppIcon name="logout" class="h-5 w-5 shrink-0" />
        <span class="flex-1 text-[14px]">退出登录</span>
      </button>

      <button
        type="button"
        class="flex w-full items-center gap-3 border-t border-line-soft px-4 py-3.5 text-left text-ink-soft transition hover:bg-sunken"
        @click="openCredentials"
      >
        <AppIcon name="user" class="h-5 w-5 shrink-0" />
        <span class="flex-1 text-[14px] text-ink">
          绑定邮箱
          <span class="ml-1 text-[12px] text-ink-faint">
            {{ emailBound ? maskEmail(auth.user?.email) : '未绑定' }}
          </span>
        </span>
        <AppIcon name="chevron-right" class="h-4 w-4 text-ink-faint" />
      </button>

      <button
        type="button"
        class="flex w-full items-center gap-3 border-t border-line-soft px-4 py-3.5 text-left text-danger transition hover:bg-sunken"
        @click="openDeleteDialog"
      >
        <AppIcon name="trash" class="h-5 w-5 shrink-0" />
        <span class="flex-1 text-[14px]">注销账号</span>
        <AppIcon name="chevron-right" class="h-4 w-4 text-ink-faint" />
      </button>
    </section>

    <p v-if="appVersion" class="mt-6 mb-1 text-center text-[11px] tracking-wide text-ink-faint">
      Vloglish {{ appVersion }}
    </p>

    <ContactAuthorDialog v-model:open="contactAuthorOpen" />
    <FeedbackModal v-model:open="feedbackOpen" />

    <!-- 绑定邮箱弹窗 -->
    <div
      v-if="credOpen"
      class="fixed inset-0 z-50 flex items-end justify-center bg-black/50 px-4 pb-[calc(1rem+env(safe-area-inset-bottom,0px))] pt-8 sm:items-center"
      @click.self="credOpen = false"
    >
      <div class="w-full max-w-md rounded-2xl bg-card p-5 shadow-xl">
        <div class="flex items-center gap-2 text-ink">
          <AppIcon name="user" class="h-5 w-5" />
          <h3 class="text-[16px] font-semibold">
            {{ emailBound ? '更换绑定邮箱' : '绑定邮箱' }}
          </h3>
        </div>
        <p class="mt-2 text-[12px] leading-relaxed text-ink-soft">
          <template v-if="!emailBound">
            绑定一个邮箱 + 登录密码后，就可以在电脑浏览器用「邮箱 + 密码」登录；和 App 里的 Apple 登录是同一个账号，数据实时同步。
          </template>
          <template v-else>
            当前已绑定邮箱。如需更换绑定邮箱或重置网页登录密码，请填写新信息并输入当前登录密码确认身份。如只需修改密码，邮箱保持不变即可。
          </template>
        </p>

        <label class="mt-4 block text-[12px] text-ink-soft">邮箱地址</label>
        <input
          v-model="credEmail"
          type="email"
          inputmode="email"
          autocomplete="email"
          class="mt-1 w-full rounded-xl border border-line-soft bg-sunken px-3 py-2.5 text-[14px] text-ink outline-none focus:border-brand"
          placeholder="you@example.com"
        />

        <label class="mt-3 block text-[12px] text-ink-soft">
          {{ emailBound ? '登录密码' : '设置登录密码' }}
        </label>
        <input
          v-model="credPassword"
          type="password"
          autocomplete="new-password"
          class="mt-1 w-full rounded-xl border border-line-soft bg-sunken px-3 py-2.5 text-[14px] text-ink outline-none focus:border-brand"
          placeholder="至少 8 位，用于网页登录"
        />

        <label class="mt-3 block text-[12px] text-ink-soft">确认登录密码</label>
        <input
          v-model="credPassword2"
          type="password"
          autocomplete="new-password"
          class="mt-1 w-full rounded-xl border border-line-soft bg-sunken px-3 py-2.5 text-[14px] text-ink outline-none focus:border-brand"
          placeholder="再次输入密码"
        />

        <template v-if="emailBound">
          <label class="mt-3 block text-[12px] text-ink-soft">当前登录密码（确认身份）</label>
          <input
            v-model="credCurrent"
            type="password"
            autocomplete="current-password"
            class="mt-1 w-full rounded-xl border border-line-soft bg-sunken px-3 py-2.5 text-[14px] text-ink outline-none focus:border-brand"
            placeholder="已设置的登录密码"
          />
        </template>

        <p v-if="credError" class="mt-3 rounded-lg bg-danger/10 px-3 py-2 text-[12px] text-danger">
          {{ credError }}
        </p>
        <p v-if="credDone" class="mt-3 rounded-lg bg-brand/10 px-3 py-2 text-[12px] text-brand">
          绑定成功，现在可用该邮箱 + 密码在网页登录了
        </p>

        <div class="mt-5 flex gap-3">
          <button
            type="button"
            class="flex-1 rounded-xl border border-line-soft py-2.5 text-[14px] text-ink transition active:scale-[0.99]"
            @click="credOpen = false"
          >
            取消
          </button>
          <button
            type="button"
            class="flex-1 rounded-xl bg-brand py-2.5 text-[14px] font-medium text-white transition active:scale-[0.99] disabled:opacity-50"
            :disabled="credBusy || credDone"
            @click="submitCredentials"
          >
            {{ credBusy ? '保存中…' : '保存' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 注销账号确认弹窗 -->
    <div
      v-if="deleteOpen"
      class="fixed inset-0 z-50 flex items-end justify-center bg-black/50 px-4 pb-[calc(1rem+env(safe-area-inset-bottom,0px))] pt-8 sm:items-center"
      @click.self="deleteOpen = false"
    >
      <div class="w-full max-w-md rounded-2xl bg-card p-5 shadow-xl">
        <div class="flex items-center gap-2 text-danger">
          <AppIcon name="trash" class="h-5 w-5" />
          <h3 class="text-[16px] font-semibold">注销账号</h3>
        </div>
        <p class="mt-3 text-[13px] leading-relaxed text-ink-soft">
          注销后将立即退出登录，账号及个人身份信息会被匿名化并停用，且无法恢复。会员权益将一并失效，剩余时长不予退还。
        </p>
        <label class="mt-4 flex items-start gap-2 text-[13px] text-ink-soft">
          <input v-model="deleteChecked" type="checkbox" class="mt-0.5 h-4 w-4" />
          <span>我已了解注销后数据不可恢复，确认注销该账号</span>
        </label>
        <p
          v-if="deleteError"
          class="mt-3 rounded-lg bg-danger/10 px-3 py-2 text-[12px] text-danger"
        >
          {{ deleteError }}
        </p>
        <div class="mt-5 flex gap-3">
          <button
            type="button"
            class="flex-1 rounded-xl border border-line-soft py-2.5 text-[14px] text-ink transition active:scale-[0.99]"
            @click="deleteOpen = false"
          >
            取消
          </button>
          <button
            type="button"
            class="flex-1 rounded-xl py-2.5 text-[14px] font-medium text-white transition active:scale-[0.99] disabled:opacity-50"
            style="background: #dc2626"
            :disabled="!deleteChecked || deleting"
            @click="confirmDeleteAccount"
          >
            {{ deleting ? '注销中…' : '确认注销' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
