<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useCatalogStore } from '@/stores/catalog'

const router = useRouter()
const auth = useAuthStore()
const catalog = useCatalogStore()

const code = ref('')
const loading = ref(false)
const error = ref('')
const success = ref(false)

async function submit() {
  error.value = ''
  loading.value = true
  try {
    await auth.activate(code.value.trim())
    success.value = true
    await catalog.loadEpisodes()
    setTimeout(() => router.replace('/english'), 800)
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '激活失败，请检查激活码'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-dvh flex items-center justify-center px-4 py-12 bg-neutral-50 dark:bg-neutral-950">
    <div class="w-full max-w-md rounded-2xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-6 sm:p-8 shadow-sm">
      <h1 class="text-xl font-semibold mb-1">激活会员</h1>
      <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-6">输入一次性激活码，永久解锁全量语料</p>

      <form class="space-y-4" @submit.prevent="submit">
        <div>
          <label class="block text-sm text-neutral-600 dark:text-neutral-400 mb-1.5">激活码</label>
          <input
            v-model="code"
            type="text"
            required
            placeholder="例如 AB3K"
            class="w-full rounded-lg border border-black/10 dark:border-white/10 dark:bg-neutral-800 dark:text-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:focus:ring-white/10"
          />
        </div>

        <p v-if="error" class="text-sm text-red-600 dark:text-red-400">{{ error }}</p>
        <p v-if="success" class="text-sm text-green-600 dark:text-green-400">激活成功，正在跳转...</p>

        <button
          type="submit"
          class="w-full rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium hover:bg-neutral-800 dark:bg-neutral-100 dark:text-neutral-900 dark:hover:bg-white disabled:opacity-60"
          :disabled="loading || success"
        >
          {{ loading ? '激活中...' : '激活' }}
        </button>
      </form>

      <p class="text-sm text-neutral-500 dark:text-neutral-400 text-center mt-6">
        <RouterLink to="/english" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">返回目录</RouterLink>
      </p>
    </div>
  </div>
</template>
