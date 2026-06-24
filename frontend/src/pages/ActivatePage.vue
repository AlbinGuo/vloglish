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
  <div class="min-h-[70vh] flex items-center justify-center px-4 py-12">
    <div class="w-full max-w-md rounded-2xl border border-black/5 bg-white p-6 sm:p-8 shadow-sm">
      <h1 class="text-xl font-semibold mb-1">激活会员</h1>
      <p class="text-sm text-neutral-500 mb-6">输入一次性激活码，永久解锁全量语料</p>

      <form class="space-y-4" @submit.prevent="submit">
        <div>
          <label class="block text-sm text-neutral-600 mb-1.5">激活码</label>
          <input
            v-model="code"
            type="text"
            required
            placeholder="例如 AB3K"
            class="w-full rounded-lg border border-black/10 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-neutral-900/10"
          />
        </div>

        <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
        <p v-if="success" class="text-sm text-green-600">激活成功，正在跳转...</p>

        <button
          type="submit"
          class="w-full rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium hover:bg-neutral-800 disabled:opacity-60"
          :disabled="loading || success"
        >
          {{ loading ? '激活中...' : '激活' }}
        </button>
      </form>

      <p class="text-sm text-neutral-500 text-center mt-6">
        <RouterLink to="/english" class="text-neutral-900 font-medium hover:underline">返回目录</RouterLink>
      </p>
    </div>
  </div>
</template>
