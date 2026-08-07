<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import AppDownloadEntry from '@/components/AppDownloadEntry.vue'
import PasswordInput from '@/components/PasswordInput.vue'
import { useCatalogViewMode } from '@/composables/useCatalogViewMode'
import { useAuthStore } from '@/stores/auth'
import { useCatalogStore } from '@/stores/catalog'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()
const catalog = useCatalogStore()
const { setViewMode } = useCatalogViewMode()

const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const activationCode = ref('')
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
  if (password.value !== confirmPassword.value) {
    formError.value = '两次输入的密码不一致'
    return
  }
  if (password.value.length < 8) {
    formError.value = '密码至少 8 位'
    return
  }

  const code = hasInvite.value ? inviteCode.value : activationCode.value.trim()

  loading.value = true
  try {
    await auth.register(email.value.trim(), password.value, code || undefined)
    // 新用户默认卡片视图（避免沿用本机曾选过的「列表」）
    setViewMode('card')
    catalog.setListViewMode('card')
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
      <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-6 leading-relaxed">
        <template v-if="hasInvite">
          检测到邀请激活码，注册后将直接开通会员。
        </template>
<!--        <template v-else>-->
<!--          免费注册即可登录学习；未开通会员时首页仅展示部分视频，可随时在站内开通会员。-->
<!--        </template>-->
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
        <div v-if="!hasInvite">
<!--          <label class="block text-sm text-neutral-600 dark:text-neutral-400 mb-1.5">-->
<!--            激活码 <span class="text-neutral-400 font-normal">（可选，抖音/运营渠道）</span>-->
<!--          </label>-->
<!--          <input-->
<!--            v-model="activationCode"-->
<!--            type="text"-->
<!--            autocomplete="off"-->
<!--            placeholder="有激活码可填写，注册后直接成为会员"-->
<!--            class="w-full rounded-lg border border-black/10 dark:border-white/10 dark:bg-neutral-800 dark:text-white px-3 py-2 text-sm uppercase tracking-wider focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:focus:ring-white/10"-->
<!--            @input="activationCode = activationCode.toUpperCase()"-->
<!--          />-->
        </div>
        <div
          v-else
          class="rounded-lg border border-amber-200 dark:border-amber-900 bg-amber-50 dark:bg-amber-950/40 px-3 py-2 text-sm text-amber-900 dark:text-amber-200"
        >
          激活码：<span class="font-mono font-medium">{{ inviteCode }}</span>
        </div>

        <p v-if="formError" class="text-sm text-red-600 dark:text-red-400">{{ formError }}</p>

        <button
          type="submit"
          class="w-full rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium hover:bg-neutral-800 dark:bg-neutral-100 dark:text-neutral-900 dark:hover:bg-white disabled:opacity-60"
          :disabled="loading"
        >
          {{ loading ? '注册中...' : (hasInvite || activationCode.trim() ? '注册并开通会员' : '免费注册') }}
        </button>
      </form>

      <p class="text-sm text-neutral-500 dark:text-neutral-400 text-center mt-6">
        已有账号？
        <RouterLink to="/login" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">登录</RouterLink>
      </p>

      <div class="mt-5 pt-5 border-t border-black/5 dark:border-white/10 flex justify-center">
        <AppDownloadEntry variant="auth" />
      </div>
    </div>
  </div>
</template>
