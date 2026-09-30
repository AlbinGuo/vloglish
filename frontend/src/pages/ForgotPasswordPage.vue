<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink } from 'vue-router'
import AuthSplitShell from '@/components/auth/AuthSplitShell.vue'
import { authButtonClass, authInputClass, authLabelClass, authLinkClass, authPasswordClass } from '@/components/auth/authField'
import PasswordInput from '@/components/PasswordInput.vue'
import { resetPasswordByEmail } from '@/api/password'

const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const loading = ref(false)
const error = ref('')
const success = ref(false)

async function submit() {
  error.value = ''
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
    await resetPasswordByEmail(email.value.trim(), password.value)
    success.value = true
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '重置失败，请重试'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <AuthSplitShell>
    <h2 class="text-[1.75rem] font-semibold tracking-tight lg:text-[1.65rem]">重置密码</h2>
    <p class="mt-1.5 text-[13px] leading-relaxed text-neutral-500">输入注册邮箱并设置新密码。</p>

    <form v-if="!success" class="mt-6 space-y-5 lg:mt-8" @submit.prevent="submit">
      <div>
        <label for="reset-email" :class="authLabelClass">邮箱</label>
        <input
          id="reset-email"
          v-model="email"
          type="email"
          autocomplete="email"
          required
          :class="authInputClass"
        />
      </div>
      <div>
        <label for="reset-password" :class="authLabelClass">新密码</label>
        <PasswordInput
          id="reset-password"
          v-model="password"
          autocomplete="new-password"
          required
          :minlength="8"
          :input-class="authPasswordClass"
        />
      </div>
      <div>
        <label for="reset-confirm" :class="authLabelClass">确认新密码</label>
        <PasswordInput
          id="reset-confirm"
          v-model="confirmPassword"
          autocomplete="new-password"
          required
          :minlength="8"
          :input-class="authPasswordClass"
        />
      </div>

      <p v-if="error" class="text-sm text-red-600 dark:text-red-400">{{ error }}</p>

      <button type="submit" :class="authButtonClass" :disabled="loading">
        {{ loading ? '保存中...' : '重置密码' }}
      </button>
    </form>

    <div v-else class="mt-7 space-y-4">
      <p class="text-sm text-emerald-600 dark:text-emerald-400">密码已重置，请使用新密码登录。</p>
      <RouterLink to="/login" :class="authButtonClass">返回登录</RouterLink>
    </div>

    <p v-if="!success" class="mt-7 text-center text-[13px] text-neutral-500">
      <RouterLink
        to="/login"
        :class="authLinkClass"
      >
        返回登录
      </RouterLink>
    </p>
  </AuthSplitShell>
</template>
