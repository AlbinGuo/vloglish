<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { consumeRemoteLoginNotice } from '@/api/tokens'
import AppDownloadEntry from '@/components/AppDownloadEntry.vue'
import AppleSignInButton from '@/components/auth/AppleSignInButton.vue'
import AuthSplitShell from '@/components/auth/AuthSplitShell.vue'
import { authButtonClass, authInputClass, authLabelClass, authLinkClass, authPasswordClass } from '@/components/auth/authField'
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
  <AuthSplitShell>
    <h2 class="text-[1.75rem] font-semibold tracking-tight lg:text-[1.65rem]">欢迎回来</h2>
    <p class="mt-1.5 text-[13px] leading-relaxed text-neutral-500">用注册邮箱接着练。</p>

    <form class="mt-6 space-y-5 lg:mt-8" @submit.prevent="submit">
      <div>
        <label for="login-email" :class="authLabelClass">邮箱</label>
        <input
          id="login-email"
          v-model="email"
          type="email"
          autocomplete="email"
          required
          :class="authInputClass"
        />
      </div>
      <div>
        <div class="flex items-center justify-between mb-1.5">
          <label for="login-password" class="text-[13px] text-neutral-500">密码</label>
          <RouterLink
            :to="{ path: '/forgot-password', query: route.query }"
            class="cursor-pointer text-[13px] text-neutral-400 transition-colors duration-200 hover:text-neutral-900"
          >
            忘记密码？
          </RouterLink>
        </div>
        <PasswordInput
          id="login-password"
          v-model="password"
          autocomplete="current-password"
          required
          :input-class="authPasswordClass"
        />
      </div>

      <p v-if="error" class="text-sm text-red-600 dark:text-red-400">{{ error }}</p>

      <button type="submit" :class="authButtonClass" :disabled="loading">
        {{ loading ? '登录中...' : '登录' }}
      </button>
    </form>

    <AppleSignInButton />

    <p class="mt-7 text-center text-[13px] text-neutral-500">
      还没有账号？
      <RouterLink
        :to="{ path: '/signup', query: route.query }"
        :class="authLinkClass"
      >
        免费注册
      </RouterLink>
    </p>

    <div class="mt-8 flex justify-center">
      <AppDownloadEntry variant="auth" />
    </div>
  </AuthSplitShell>
</template>
