<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink } from 'vue-router'
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
  <div class="min-h-dvh flex items-center justify-center px-4 py-12 bg-neutral-50 dark:bg-neutral-950">
    <div class="w-full max-w-md rounded-2xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-6 sm:p-8 shadow-sm">
      <h1 class="text-xl font-semibold mb-1">忘记密码</h1>
      <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-6">输入注册邮箱并设置新密码</p>

      <form v-if="!success" class="space-y-4" @submit.prevent="submit">
        <div>
          <label class="block text-sm text-neutral-600 dark:text-neutral-400 mb-1.5">邮箱</label>
          <input
            v-model="email"
            type="email"
            autocomplete="email"
            required
            class="w-full rounded-lg border border-black/10 dark:border-white/10 dark:bg-neutral-800 dark:text-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:focus:ring-white/10"
          />
        </div>
        <div>
          <label class="block text-sm text-neutral-600 dark:text-neutral-400 mb-1.5">新密码</label>
          <PasswordInput
            v-model="password"
            autocomplete="new-password"
            required
            :minlength="8"
          />
        </div>
        <div>
          <label class="block text-sm text-neutral-600 dark:text-neutral-400 mb-1.5">确认新密码</label>
          <PasswordInput
            v-model="confirmPassword"
            autocomplete="new-password"
            required
            :minlength="8"
          />        </div>

        <p v-if="error" class="text-sm text-red-600 dark:text-red-400">{{ error }}</p>

        <button
          type="submit"
          class="w-full rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium hover:bg-neutral-800 dark:bg-neutral-100 dark:text-neutral-900 dark:hover:bg-white disabled:opacity-60"
          :disabled="loading"
        >
          {{ loading ? '保存中...' : '重置密码' }}
        </button>
      </form>

      <div v-else class="space-y-4">
        <p class="text-sm text-green-600 dark:text-green-400">密码已重置，请使用新密码登录。</p>
        <RouterLink
          to="/login"
          class="inline-block w-full text-center rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium hover:bg-neutral-800 dark:bg-neutral-100 dark:text-neutral-900 dark:hover:bg-white"
        >
          返回登录
        </RouterLink>
      </div>

      <p v-if="!success" class="text-sm text-neutral-500 dark:text-neutral-400 text-center mt-6">
        <RouterLink to="/login" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">返回登录</RouterLink>
      </p>
    </div>
  </div>
</template>
