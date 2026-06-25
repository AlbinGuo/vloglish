<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { consumeRemoteLoginNotice } from '@/api/tokens'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')
const remoteNotice = ref('')

onMounted(() => {
  if (route.query.reason === 'remote' || consumeRemoteLoginNotice()) {
    remoteNotice.value = '您的账号已在其他设备登录，当前登录已失效，请重新登录'
  }
})

async function submit() {
  error.value = ''
  remoteNotice.value = ''
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
  <div class="min-h-[70vh] flex items-center justify-center px-4 py-12">
    <div class="w-full max-w-md rounded-2xl border border-black/5 bg-white p-6 sm:p-8 shadow-sm">
      <h1 class="text-xl font-semibold mb-1">登录</h1>
      <p class="text-sm text-neutral-500 mb-6">登录后可同步收藏，激活会员解锁全量语料</p>

      <p
        v-if="remoteNotice"
        class="mb-4 text-sm text-amber-900 rounded-lg border border-amber-200 bg-amber-50 px-3 py-2.5"
      >
        {{ remoteNotice }}
      </p>

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
          <div class="flex items-center justify-between mb-1.5">
            <label class="block text-sm text-neutral-600">密码</label>
            <RouterLink to="/forgot-password" class="text-xs text-neutral-500 hover:text-neutral-900">
              忘记密码？
            </RouterLink>
          </div>
          <input
            v-model="password"
            type="password"
            autocomplete="current-password"
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
          {{ loading ? '登录中...' : '登录' }}
        </button>
      </form>

      <p class="text-sm text-neutral-500 text-center mt-6">
        还没有账号？
        <RouterLink to="/signup" class="text-neutral-900 font-medium hover:underline">注册</RouterLink>
      </p>
    </div>
  </div>
</template>
