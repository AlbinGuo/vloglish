<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { consumeRemoteLoginNotice } from '@/api/tokens'
import PasswordInput from '@/components/PasswordInput.vue'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

onMounted(() => {
  // 静默清除异地登录标记，不在页面展示提示文案
  consumeRemoteLoginNotice()
})

async function submit() {
  error.value = ''
  loading.value = true
  try {
    await auth.login(email.value.trim(), password.value)
    const next = typeof route.query.next === 'string' ? route.query.next : '/english'
    await router.replace(next)
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '登录失败，请重试'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-dvh flex items-center justify-center px-4 py-12 bg-neutral-50 dark:bg-neutral-950">
    <div class="w-full max-w-md rounded-2xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-6 sm:p-8 shadow-sm">
      <h1 class="text-xl font-semibold mb-1">登录</h1>
      <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-6">使用注册邮箱登录。普通用户可学习部分内容，开通会员后解锁全部。</p>

      <form class="space-y-4" @submit.prevent="submit">
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
          <div class="flex items-center justify-between mb-1.5">
            <label class="block text-sm text-neutral-600 dark:text-neutral-400">密码</label>
            <RouterLink to="/forgot-password" class="text-xs text-neutral-500 hover:text-neutral-900 dark:hover:text-white">
              忘记密码？
            </RouterLink>
          </div>
          <PasswordInput
            v-model="password"
            autocomplete="current-password"
            required
          />
        </div>

        <p v-if="error" class="text-sm text-red-600 dark:text-red-400">{{ error }}</p>

        <button
          type="submit"
          class="w-full rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium hover:bg-neutral-800 dark:bg-neutral-100 dark:text-neutral-900 dark:hover:bg-white disabled:opacity-60"
          :disabled="loading"
        >
          {{ loading ? '登录中...' : '登录' }}
        </button>
      </form>

      <p class="text-sm text-neutral-500 dark:text-neutral-400 text-center mt-6">
        还没有账号？
        <RouterLink to="/signup" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">免费注册</RouterLink>
      </p>
    </div>
  </div>
</template>
