<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import AppIcon from '@/components/AppIcon.vue'
import AppleSignInButton from '@/components/auth/AppleSignInButton.vue'
import AuthBrandMark from '@/components/auth/AuthBrandMark.vue'
import AuthScreen from '@/components/auth/AuthScreen.vue'
import PasswordInput from '@/components/PasswordInput.vue'
import { isAppleSignInAvailable } from '@/services/appleAuth'
import { useCatalogViewMode } from '@/composables/useCatalogViewMode'
import { useAuthStore } from '@/stores/auth'
import { useCatalogStore } from '@/stores/catalog'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()
const catalog = useCatalogStore()
const { setViewMode } = useCatalogViewMode()

const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const activationCode = ref('')
const formError = ref('')
const loading = ref(false)

const appleAvailable = computed(() => isAppleSignInAvailable())

function goBack() {
  if (window.history.length > 1) router.back()
  else router.replace({ path: '/login', query: route.query })
}

function normalizeCode(value: unknown) {
  if (typeof value !== 'string') return ''
  return value.trim().toUpperCase()
}

/** 邀请链接：/signup?code=XXXX */
const inviteCode = computed(() => {
  const fromCode = normalizeCode(route.query.code)
  if (fromCode) return fromCode
  return normalizeCode(route.query.activation_code)
})

const hasInvite = computed(() => Boolean(inviteCode.value))

async function submit() {
  formError.value = ''
  if (password.value !== confirmPassword.value) {
    formError.value = '两次输入的密码不一致'
    return
  }
  if (password.value.length < 8) {
    formError.value = '密码至少 8 位'
    return
  }

  const code = hasInvite.value ? inviteCode.value : activationCode.value.trim()

  loading.value = true
  try {
    await auth.register(email.value.trim(), password.value, code || undefined)
    // 新用户默认卡片视图（避免沿用本机曾选过的「列表」）
    setViewMode('card')
    catalog.setListViewMode('card')
    await catalog.loadEpisodes(true)
    const next = typeof route.query.next === 'string' ? route.query.next : '/english'
    await router.replace(next)
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    formError.value = msg || '注册失败，请重试'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <AuthScreen>
    <div class="flex flex-1 flex-col">
      <!-- 顶部：返回 + 品牌 -->
      <header class="flex items-center gap-2.5">
        <button
          type="button"
          class="-ml-2 grid h-9 w-9 place-items-center rounded-full text-ink-soft transition hover:bg-black/5 dark:hover:bg-white/10"
          aria-label="返回"
          @click="goBack"
        >
          <AppIcon name="chevron-left" class="h-5 w-5" />
        </button>
        <AuthBrandMark :size="36" />
        <span class="text-[1.08rem] font-bold tracking-tight text-ink">Vloglish</span>
      </header>

      <!-- 标题 -->
      <div class="mt-7">
        <h1 class="text-[1.75rem] font-extrabold tracking-tight text-ink">创建账号</h1>
        <p class="mt-2 text-[13px] leading-relaxed text-ink-faint">
          <template v-if="hasInvite">检测到邀请激活码，注册后将直接开通会员</template>
          <template v-else>免费注册，开启你的英语学习之旅</template>
        </p>
      </div>

      <!-- 注册表单 -->
      <form class="mt-7 space-y-3.5" @submit.prevent="submit">
        <div class="relative">
          <AppIcon name="envelope" class="auth-field-icon" />
          <input
            id="signup-email"
            v-model="email"
            type="email"
            autocomplete="email"
            required
            placeholder="邮箱地址"
            class="auth-input"
          />
        </div>

        <div class="relative">
          <AppIcon name="lock" class="auth-field-icon" />
          <PasswordInput
            id="signup-password"
            v-model="password"
            autocomplete="new-password"
            required
            :minlength="8"
            placeholder="设置密码（至少 8 位）"
            input-class="auth-input auth-input--pw"
          />
        </div>

        <div class="relative">
          <AppIcon name="lock" class="auth-field-icon" />
          <PasswordInput
            id="signup-confirm"
            v-model="confirmPassword"
            autocomplete="new-password"
            required
            :minlength="8"
            placeholder="确认密码"
            input-class="auth-input auth-input--pw"
          />
        </div>

        <div
          v-if="hasInvite"
          class="rounded-2xl bg-brand-soft px-4 py-2.5 text-[13px] text-brand-on-soft"
        >
          激活码：<span class="font-mono font-semibold">{{ inviteCode }}</span>
        </div>

        <p v-if="formError" class="text-[13px] text-danger">{{ formError }}</p>

        <button type="submit" class="auth-primary" :disabled="loading">
          <span>{{ loading ? '注册中…' : (hasInvite ? '注册并开通会员' : '注册') }}</span>
          <AppIcon name="chevron-right" class="h-4 w-4" />
        </button>
      </form>

      <template v-if="appleAvailable">
        <div class="my-5 flex items-center gap-3 text-[12px] text-ink-faint">
          <span class="h-px flex-1 bg-line" />
          <span class="shrink-0">或使用 Apple 继续</span>
          <span class="h-px flex-1 bg-line" />
        </div>
        <AppleSignInButton variant="outline" />
      </template>

      <p class="mt-auto pt-10 text-center text-[13px] text-ink-faint">
        已有账号？
        <RouterLink :to="{ path: '/login', query: route.query }" class="auth-link">
          登录
        </RouterLink>
      </p>
    </div>
  </AuthScreen>
</template>
