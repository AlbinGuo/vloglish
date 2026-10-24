<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { consumeRemoteLoginNotice } from '@/api/tokens'
import AppIcon from '@/components/AppIcon.vue'
import AppleSignInButton from '@/components/auth/AppleSignInButton.vue'
import AuthBrandMark from '@/components/auth/AuthBrandMark.vue'
import AuthScreen from '@/components/auth/AuthScreen.vue'
import PasswordInput from '@/components/PasswordInput.vue'
import { isAppleSignInAvailable } from '@/services/appleAuth'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

const appleAvailable = computed(() => isAppleSignInAvailable())

onMounted(() => {
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
    const err = e as {
      response?: { data?: { detail?: string }; status?: number }
      code?: string
      message?: string
    }
    const detail = err.response?.data?.detail
    if (typeof detail === 'string' && detail.trim()) {
      error.value = detail
    } else if (err.code === 'ERR_NETWORK' || err.message === 'Network Error') {
      error.value = '无法连接服务器，请检查网络后重试'
    } else {
      error.value = '登录失败，请重试'
    }
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <AuthScreen>
    <div class="flex flex-1 flex-col">
      <!-- 品牌 -->
      <header class="flex items-center gap-2.5">
        <AuthBrandMark :size="40" />
        <span class="text-[1.15rem] font-bold tracking-tight text-ink">Vloglish</span>
      </header>

      <!-- 标题 -->
      <div class="mt-10">
        <h1 class="text-[1.85rem] font-extrabold leading-[1.18] tracking-tight text-ink">
          Better Videos.<br />Better English.
        </h1>
        <p class="mt-3 text-[13px] leading-relaxed text-ink-faint">
          用视频，轻松提升你的英语听说能力
        </p>
      </div>

      <!-- Apple 一键登录（仅 iOS 原生壳内可用） -->
      <AppleSignInButton class="mt-8" />

      <div
        v-if="appleAvailable"
        class="my-5 flex items-center gap-3 text-[12px] text-ink-faint"
      >
        <span class="h-px flex-1 bg-line" />
        <span class="shrink-0">或使用邮箱登录</span>
        <span class="h-px flex-1 bg-line" />
      </div>

      <!-- 邮箱登录 -->
      <form class="mt-7 space-y-3.5" @submit.prevent="submit">
        <div class="relative">
          <AppIcon name="envelope" class="auth-field-icon" />
          <input
            id="login-email"
            v-model="email"
            type="email"
            autocomplete="email"
            required
            placeholder="邮箱地址"
            class="auth-input"
          />
        </div>

        <div class="relative">
          <AppIcon name="lock" class="auth-field-icon" />
          <PasswordInput
            id="login-password"
            v-model="password"
            autocomplete="current-password"
            required
            placeholder="密码"
            input-class="auth-input auth-input--pw"
          />
        </div>

        <div class="flex justify-end">
          <RouterLink
            :to="{ path: '/forgot-password', query: route.query }"
            class="text-[12.5px] text-ink-faint transition-colors hover:text-ink"
          >
            忘记密码？
          </RouterLink>
        </div>

        <p v-if="error" class="text-[13px] text-danger">{{ error }}</p>

        <button type="submit" class="auth-primary" :disabled="loading">
          <span>{{ loading ? '登录中…' : '登录' }}</span>
          <AppIcon name="chevron-right" class="h-4 w-4" />
        </button>
      </form>

      <p class="mt-auto pt-10 text-center text-[13px] text-ink-faint">
        还没有账号？
        <RouterLink :to="{ path: '/signup', query: route.query }" class="auth-link">
          免费注册
        </RouterLink>
      </p>
    </div>
  </AuthScreen>
</template>
