<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import PasswordInput from '@/components/PasswordInput.vue'
import { useAuthStore } from '@/stores/auth'
import { useCatalogStore } from '@/stores/catalog'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()
const catalog = useCatalogStore()

const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const formError = ref('')
const loading = ref(false)

function normalizeCode(value: unknown) {
  if (typeof value !== 'string') return ''
  return value.trim().toUpperCase()
}

/** 邀请链接：/signup?code=XXXX */
const inviteCode = computed(() => {
  const fromCode = normalizeCode(route.query.code)
  if (fromCode) return fromCode
  return normalizeCode(route.query.activation_code)
})

const hasInvite = computed(() => Boolean(inviteCode.value))

async function submit() {
  formError.value = ''
  if (!inviteCode.value) {
    formError.value = '请使用邀请链接'
    return
  }
  if (password.value !== confirmPassword.value) {
    formError.value = '两次输入的密码不一致'
    return
  }
  if (password.value.length < 8) {
    formError.value = '密码至少 8 位'
    return
  }

  loading.value = true
  try {
    await auth.register(email.value.trim(), password.value, inviteCode.value)
    await catalog.loadEpisodes(true)
    const next = typeof route.query.next === 'string' ? route.query.next : '/english'
    await router.replace(next)
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    formError.value = msg || '注册失败，请重试'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-dvh flex items-center justify-center px-4 py-12 bg-neutral-50 dark:bg-neutral-950">
    <div class="w-full max-w-md rounded-2xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-6 sm:p-8 shadow-sm">
      <h1 class="text-xl font-semibold mb-1">注册</h1>

      <template v-if="!hasInvite">
        <p class="text-sm text-neutral-500 dark:text-neutral-400 mt-2 mb-6 leading-relaxed">
          请使用邀请链接
        </p>
        <p class="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed mb-6">
          注册需通过管理员发送的专属链接，或先
          <RouterLink to="/pricing" class="text-neutral-900 dark:text-neutral-100 font-medium underline underline-offset-2">支付宝自助开通</RouterLink>
          后再注册。若你已收到邀请，请打开邮件或消息中的完整链接。
        </p>
        <p class="text-sm text-neutral-500 dark:text-neutral-400 text-center">
          已有账号？
          <RouterLink to="/login" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">登录</RouterLink>
          <span class="mx-1">·</span>
          <RouterLink to="/pricing" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">开通会员</RouterLink>
          <span class="mx-1">·</span>
          <RouterLink to="/english" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">先逛逛</RouterLink>
        </p>
      </template>

      <template v-else>
        <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-6">
          填写邮箱与密码即可完成注册并开通会员
        </p>

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
            <label class="block text-sm text-neutral-600 dark:text-neutral-400 mb-1.5">密码</label>
            <PasswordInput
              v-model="password"
              autocomplete="new-password"
              required
              :minlength="8"
            />
          </div>
          <div>
            <label class="block text-sm text-neutral-600 dark:text-neutral-400 mb-1.5">确认密码</label>
            <PasswordInput
              v-model="confirmPassword"
              autocomplete="new-password"
              required
              :minlength="8"
            />
          </div>

          <p v-if="formError" class="text-sm text-red-600 dark:text-red-400">{{ formError }}</p>

          <button
            type="submit"
            class="w-full rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium hover:bg-neutral-800 dark:bg-neutral-100 dark:text-neutral-900 dark:hover:bg-white disabled:opacity-60"
            :disabled="loading"
          >
            {{ loading ? '注册中...' : '注册' }}
          </button>
        </form>

        <p class="text-sm text-neutral-500 dark:text-neutral-400 text-center mt-6">
          已有账号？
          <RouterLink to="/login" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">登录</RouterLink>
          <span class="mx-1">·</span>
          <RouterLink to="/english" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">先逛逛</RouterLink>
        </p>
      </template>
    </div>
  </div>
</template>
