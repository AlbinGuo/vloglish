<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import AppDownloadEntry from '@/components/AppDownloadEntry.vue'
import AppleSignInButton from '@/components/auth/AppleSignInButton.vue'
import AuthSplitShell from '@/components/auth/AuthSplitShell.vue'
import { authButtonClass, authInputClass, authLabelClass, authLinkClass, authPasswordClass } from '@/components/auth/authField'
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
  <AuthSplitShell>
    <h2 class="text-[1.75rem] font-semibold tracking-tight lg:text-[1.65rem]">创建账号</h2>
    <p class="mt-1.5 text-[13px] leading-relaxed text-neutral-500">
      <template v-if="hasInvite">检测到邀请激活码，注册后将直接开通会员。</template>
      <template v-else>免费注册，开始用真实 vlog 练听力与口语。</template>
    </p>

    <form class="mt-6 space-y-5 lg:mt-8" @submit.prevent="submit">
      <div>
        <label for="signup-email" :class="authLabelClass">邮箱</label>
        <input
          id="signup-email"
          v-model="email"
          type="email"
          autocomplete="email"
          required
          :class="authInputClass"
        />
      </div>
      <div>
        <label for="signup-password" :class="authLabelClass">密码</label>
        <PasswordInput
          id="signup-password"
          v-model="password"
          autocomplete="new-password"
          required
          :minlength="8"
          :input-class="authPasswordClass"
        />
      </div>
      <div>
        <label for="signup-confirm" :class="authLabelClass">确认密码</label>
        <PasswordInput
          id="signup-confirm"
          v-model="confirmPassword"
          autocomplete="new-password"
          required
          :minlength="8"
          :input-class="authPasswordClass"
        />
      </div>
      <div
        v-if="hasInvite"
        class="rounded-xl border border-black/10 bg-white px-3 py-2.5 text-sm text-neutral-800"
      >
        激活码：<span class="font-mono font-medium">{{ inviteCode }}</span>
      </div>

      <p v-if="formError" class="text-sm text-red-600 dark:text-red-400">{{ formError }}</p>

      <button type="submit" :class="authButtonClass" :disabled="loading">
        {{ loading ? '注册中...' : (hasInvite || activationCode.trim() ? '注册并开通会员' : '免费注册') }}
      </button>
    </form>

    <AppleSignInButton />

    <p class="mt-7 text-center text-[13px] text-neutral-500">
      已有账号？
      <RouterLink
        :to="{ path: '/login', query: route.query }"
        :class="authLinkClass"
      >
        登录
      </RouterLink>
    </p>

    <div class="mt-8 flex justify-center">
      <AppDownloadEntry variant="auth" />
    </div>
  </AuthSplitShell>
</template>
