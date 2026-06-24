<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { requestPasswordReset } from '@/api/password'

const email = ref('')
const loading = ref(false)
const error = ref('')
const message = ref('')
const devResetUrl = ref('')

const devResetLink = computed(() => {
  if (!devResetUrl.value) return null
  try {
    const url = new URL(devResetUrl.value)
    const token = url.searchParams.get('token')
    if (!token) return null
    return { path: '/reset-password', query: { token } }
  } catch {
    return null
  }
})

async function submit() {
  error.value = ''
  message.value = ''
  devResetUrl.value = ''
  loading.value = true
  try {
    const res = await requestPasswordReset(email.value.trim())
    message.value = res.message
    if (res.reset_url) devResetUrl.value = res.reset_url
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '提交失败，请重试'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-[70vh] flex items-center justify-center px-4 py-12">
    <div class="w-full max-w-md rounded-2xl border border-black/5 bg-white p-6 sm:p-8 shadow-sm">
      <h1 class="text-xl font-semibold mb-1">忘记密码</h1>
      <p class="text-sm text-neutral-500 mb-6">输入注册邮箱，我们将发送密码重置说明</p>

      <form v-if="!message" class="space-y-4" @submit.prevent="submit">
        <div>
          <label class="block text-sm text-neutral-600 mb-1.5">邮箱</label>
          <input
            v-model="email"
            type="email"
            autocomplete="email"
            required
            class="w-full rounded-lg border border-black/10 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-neutral-900/10"
          />
        </div>

        <p v-if="error" class="text-sm text-red-600">{{ error }}</p>

        <button
          type="submit"
          class="w-full rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium hover:bg-neutral-800 disabled:opacity-60"
          :disabled="loading"
        >
          {{ loading ? '提交中...' : '发送重置说明' }}
        </button>
      </form>

      <div v-else class="space-y-4">
        <p class="text-sm text-neutral-700">{{ message }}</p>
        <div v-if="devResetLink" class="rounded-lg border border-amber-200 bg-amber-50 p-3 text-sm text-amber-900">
          <p class="mb-2">开发环境未配置邮件，可直接使用以下链接：</p>
          <RouterLink :to="devResetLink" class="font-medium underline">打开重置密码页</RouterLink>
        </div>
        <RouterLink to="/login" class="inline-block text-sm text-neutral-900 font-medium hover:underline">
          返回登录
        </RouterLink>
      </div>

      <p v-if="!message" class="text-sm text-neutral-500 text-center mt-6">
        <RouterLink to="/login" class="text-neutral-900 font-medium hover:underline">返回登录</RouterLink>
      </p>
    </div>
  </div>
</template>
