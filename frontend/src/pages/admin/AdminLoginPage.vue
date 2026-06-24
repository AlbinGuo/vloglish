<script setup lang="ts">
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAdminAuthStore } from '@/stores/adminAuth'

const router = useRouter()
const route = useRoute()
const auth = useAdminAuthStore()

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

async function submit() {
  error.value = ''
  loading.value = true
  try {
    await auth.login(email.value.trim(), password.value)
    const next = typeof route.query.next === 'string' ? route.query.next : '/gnadmin/dashboard'
    await router.replace(next)
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '登录失败'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-dvh bg-neutral-100 flex items-center justify-center px-4">
    <div class="w-full max-w-md rounded-2xl border border-black/5 bg-white p-8 shadow-sm">
      <h1 class="text-xl font-semibold mb-1">管理后台登录</h1>
      <p class="text-sm text-neutral-500 mb-6">Vloglish Admin</p>

      <form class="space-y-4" @submit.prevent="submit">
        <div>
          <label class="block text-sm text-neutral-600 mb-1.5">邮箱</label>
          <input
            v-model="email"
            type="email"
            required
            autocomplete="username"
            class="w-full rounded-lg border border-black/10 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-neutral-900/10"
          />
        </div>
        <div>
          <label class="block text-sm text-neutral-600 mb-1.5">密码</label>
          <input
            v-model="password"
            type="password"
            required
            autocomplete="current-password"
            class="w-full rounded-lg border border-black/10 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-neutral-900/10"
          />
        </div>
        <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
        <button
          type="submit"
          class="w-full rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium hover:bg-neutral-800 disabled:opacity-60"
          :disabled="loading"
        >
          {{ loading ? '登录中...' : '登录' }}
        </button>
      </form>
    </div>
  </div>
</template>
