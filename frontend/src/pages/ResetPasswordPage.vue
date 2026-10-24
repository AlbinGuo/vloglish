<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import AppIcon from '@/components/AppIcon.vue'
import AuthBrandMark from '@/components/auth/AuthBrandMark.vue'
import AuthScreen from '@/components/auth/AuthScreen.vue'
import PasswordInput from '@/components/PasswordInput.vue'
import { resetPassword } from '@/api/password'

const route = useRoute()
const router = useRouter()

const password = ref('')
const confirmPassword = ref('')
const loading = ref(false)
const error = ref('')
const success = ref(false)

const token = computed(() => {
  const value = route.query.token
  return typeof value === 'string' ? value : ''
})

async function submit() {
  error.value = ''
  if (!token.value) {
    error.value = '重置链接无效，请重新申请'
    return
  }
  if (password.value !== confirmPassword.value) {
    error.value = '两次输入的密码不一致'
    return
  }
  if (password.value.length < 8) {
    error.value = '密码至少 8 位'
    return
  }

  loading.value = true
  try {
    await resetPassword(token.value, password.value)
    success.value = true
    setTimeout(() => router.replace('/login'), 1200)
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '重置失败，请重试'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <AuthScreen>
    <div class="flex flex-1 flex-col">
      <header class="flex items-center gap-2.5">
        <RouterLink
          to="/login"
          class="-ml-2 grid h-9 w-9 place-items-center rounded-full text-ink-soft transition hover:bg-black/5 dark:hover:bg-white/10"
          aria-label="返回登录"
        >
          <AppIcon name="chevron-left" class="h-5 w-5" />
        </RouterLink>
        <AuthBrandMark :size="36" />
        <span class="text-[1.08rem] font-bold tracking-tight text-ink">Vloglish</span>
      </header>

      <div class="mt-7">
        <h1 class="text-[1.75rem] font-extrabold tracking-tight text-ink">重置密码</h1>
        <p class="mt-2 text-[13px] leading-relaxed text-ink-faint">请设置新的登录密码</p>
      </div>

      <div v-if="!token && !success" class="mt-7 space-y-4">
        <div class="rounded-2xl bg-danger-soft px-4 py-3 text-[13px] text-danger">
          重置链接无效或缺少 token。
        </div>
        <RouterLink to="/forgot-password" class="auth-link text-[13px]">重新申请重置</RouterLink>
      </div>

      <form v-else-if="!success" class="mt-7 space-y-3.5" @submit.prevent="submit">
        <div class="relative">
          <AppIcon name="lock" class="auth-field-icon" />
          <PasswordInput
            id="reset-new-password"
            v-model="password"
            autocomplete="new-password"
            required
            :minlength="8"
            placeholder="新密码（至少 8 位）"
            input-class="auth-input auth-input--pw"
          />
        </div>

        <div class="relative">
          <AppIcon name="lock" class="auth-field-icon" />
          <PasswordInput
            id="reset-new-confirm"
            v-model="confirmPassword"
            autocomplete="new-password"
            required
            :minlength="8"
            placeholder="确认新密码"
            input-class="auth-input auth-input--pw"
          />
        </div>

        <p v-if="error" class="text-[13px] text-danger">{{ error }}</p>

        <button type="submit" class="auth-primary" :disabled="loading">
          <span>{{ loading ? '保存中…' : '保存新密码' }}</span>
          <AppIcon name="chevron-right" class="h-4 w-4" />
        </button>
      </form>

      <template v-else>
        <div class="mt-7 rounded-2xl bg-brand-soft px-4 py-3 text-[13px] text-brand-on-soft">
          密码已重置，正在跳转登录页…
        </div>
        <RouterLink to="/login" class="auth-primary mt-4">立即登录</RouterLink>
      </template>
    </div>
  </AuthScreen>
</template>
