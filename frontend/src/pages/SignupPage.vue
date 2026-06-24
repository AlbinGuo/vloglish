<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const auth = useAuthStore()

const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const loading = ref(false)
const error = ref('')

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
    await auth.register(email.value.trim(), password.value)
    await router.replace('/english')
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '注册失败，请重试'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-[70vh] flex items-center justify-center px-4 py-12">
    <div class="w-full max-w-md rounded-2xl border border-black/5 bg-white p-6 sm:p-8 shadow-sm">
      <h1 class="text-xl font-semibold mb-1">注册</h1>
      <p class="text-sm text-neutral-500 mb-6">使用邮箱注册，激活会员后可学习全量内容</p>

      <form class="space-y-4" @submit.prevent="submit">
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
        <div>
          <label class="block text-sm text-neutral-600 mb-1.5">密码</label>
          <input
            v-model="password"
            type="password"
            autocomplete="new-password"
            required
            minlength="8"
            class="w-full rounded-lg border border-black/10 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-neutral-900/10"
          />
        </div>
        <div>
          <label class="block text-sm text-neutral-600 mb-1.5">确认密码</label>
          <input
            v-model="confirmPassword"
            type="password"
            autocomplete="new-password"
            required
            minlength="8"
            class="w-full rounded-lg border border-black/10 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-neutral-900/10"
          />
        </div>

        <p v-if="error" class="text-sm text-red-600">{{ error }}</p>

        <button
          type="submit"
          class="w-full rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium hover:bg-neutral-800 disabled:opacity-60"
          :disabled="loading"
        >
          {{ loading ? '注册中...' : '注册' }}
        </button>
      </form>

      <p class="text-sm text-neutral-500 text-center mt-6">
        已有账号？
        <RouterLink to="/login" class="text-neutral-900 font-medium hover:underline">登录</RouterLink>
      </p>
    </div>
  </div>
</template>
