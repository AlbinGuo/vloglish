<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { isAppleSignInAvailable, signInWithApple } from '@/services/appleAuth'
import { useAuthStore } from '@/stores/auth'

withDefaults(
  defineProps<{
    variant?: 'filled' | 'outline'
    label?: string
  }>(),
  { variant: 'filled', label: '通过 Apple 继续' },
)

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()

const available = computed(() => isAppleSignInAvailable())
const loading = ref(false)
const error = ref('')

async function onClick() {
  if (loading.value) return
  error.value = ''
  loading.value = true
  try {
    const profile = await signInWithApple()
    await auth.loginWithApple({
      identity_token: profile.identityToken,
      authorization_code: profile.authorizationCode || undefined,
      full_name: profile.fullName,
    })
    const next = typeof route.query.next === 'string' ? route.query.next : '/english'
    await router.replace(next)
  } catch (e: unknown) {
    const err = e as { response?: { data?: { detail?: string } }; message?: string }
    const detail = err.response?.data?.detail
    if (typeof detail === 'string' && detail.trim()) {
      error.value = detail
    } else if (err.message && /cancel|取消|canceled|cancelled/i.test(err.message)) {
      error.value = ''
    } else {
      error.value = 'Apple 登录失败，请重试'
    }
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div v-if="available">
    <button
      type="button"
      class="flex h-[3.2rem] w-full items-center justify-center gap-2 rounded-2xl px-4 text-[15px] font-semibold transition active:scale-[0.99] disabled:opacity-60"
      :class="
        variant === 'outline'
          ? 'bg-white text-neutral-900 ring-1 ring-black/10 dark:bg-white/5 dark:text-white dark:ring-white/15'
          : 'bg-neutral-900 text-white dark:bg-white/10 dark:text-white dark:ring-1 dark:ring-white/20'
      "
      :disabled="loading"
      @click="onClick"
    >
      <svg viewBox="0 0 384 512" class="h-4 w-4 shrink-0" fill="currentColor" aria-hidden="true">
        <path d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z" />
      </svg>
      <span>{{ loading ? '登录中…' : label }}</span>
    </button>
    <p v-if="error" class="mt-2 text-center text-[13px] text-danger">{{ error }}</p>
  </div>
</template>
