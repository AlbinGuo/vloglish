<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import AppIcon from '@/components/AppIcon.vue'
import UserAvatar from '@/components/UserAvatar.vue'
import BindWechatDialog from '@/components/BindWechatDialog.vue'
import ContactAuthorDialog from '@/components/ContactAuthorDialog.vue'
import FeedbackModal from '@/components/FeedbackModal.vue'
import { useTheme } from '@/composables/useTheme'
import { useAuthStore } from '@/stores/auth'
import { useClipsStore } from '@/stores/clips'
import { useMyCorpusBadgeStore } from '@/stores/myCorpusBadge'
import { useNotificationStore } from '@/stores/notifications'
import { useVocabularyStore } from '@/stores/vocabulary'
import { useVoiceCloneStore } from '@/stores/voiceClone'

const router = useRouter()
const auth = useAuthStore()
const notifications = useNotificationStore()
const corpusBadge = useMyCorpusBadgeStore()
const vocabulary = useVocabularyStore()
const clips = useClipsStore()
const voiceClone = useVoiceCloneStore()

const { themeMode, setThemeMode } = useTheme()

const bindWechatOpen = ref(false)
const contactAuthorOpen = ref(false)
const feedbackOpen = ref(false)
const cycling = ref(false)

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

const navLinks = [
  { to: '/english/study', icon: 'book-open', label: '怎么学', desc: '学习方法与路线' },
  { to: '/english/learning', icon: 'chart-bar', label: '学习统计', desc: '进度与打卡' },
  { to: '/english/clips', icon: 'clipboard-list', label: '我的摘录', desc: '收藏的句子' },
  { to: '/english/series', icon: 'text-lines', label: '全部系列', desc: '按系列浏览' },
  { to: '/english/wish-wall', icon: 'sparkles', label: '心愿墙', desc: '想看的内容' },
]

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

      <button
        v-if="!auth.user?.wx_bound"
        type="button"
        class="relative mt-4 flex w-full items-center gap-3 rounded-2xl border border-warning bg-warning-soft px-4 py-3 text-left transition hover:opacity-90"
        @click="bindWechatOpen = true"
      >
        <AppIcon name="chat-bubble" class="h-5 w-5 shrink-0 text-warning" />
        <span class="flex-1 text-[13px] font-medium text-warning">关联小程序</span>
        <span class="text-[11px] text-warning">扫一下即关联</span>
        <AppIcon name="chevron-right" class="h-4 w-4 text-warning" />
      </button>
      <p v-else class="relative mt-4 flex items-center gap-2 text-[12px] text-ink-faint">
        <AppIcon name="check" class="h-4 w-4 text-success" />
        已关联微信，小程序与网页为同一账号
      </p>
    </section>

    <!-- 快捷入口 -->
    <section class="mt-4 grid grid-cols-2 gap-3 sm:grid-cols-3">
      <RouterLink
        v-for="item in navLinks"
        :key="item.to"
        :to="item.to"
        class="group flex items-center gap-3 rounded-2xl border border-line-soft bg-card px-3.5 py-3 transition hover:border-brand hover:bg-sunken active:scale-[0.98]"
      >
        <span class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-brand-soft text-brand">
          <AppIcon :name="item.icon" class="h-5 w-5" />
        </span>
        <span class="min-w-0 flex-1">
          <span class="block truncate text-[13.5px] font-medium text-ink">{{ item.label }}</span>
          <span class="block truncate text-[11px] text-ink-faint">{{ item.desc }}</span>
        </span>
      </RouterLink>
    </section>

    <!-- 设置 -->
    <section class="mt-4 overflow-hidden rounded-2xl border border-line-soft bg-card">
      <div class="flex items-center gap-3 px-4 py-3.5">
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

    <BindWechatDialog v-model:open="bindWechatOpen" />
    <ContactAuthorDialog v-model:open="contactAuthorOpen" />
    <FeedbackModal v-model:open="feedbackOpen" />
  </div>
</template>
