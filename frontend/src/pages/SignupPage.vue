<script setup lang="ts">
import { nextTick, onUnmounted, ref, watch } from 'vue'
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
const activationCode = ref('')
const showActivationModal = ref(false)
const formError = ref('')
const modalError = ref('')
const loading = ref(false)
const codeInputRef = ref<HTMLInputElement | null>(null)

function normalizeCode(value: string) {
  return value.trim().toUpperCase()
}

function validateAccountForm() {
  formError.value = ''
  if (password.value !== confirmPassword.value) {
    formError.value = '两次输入的密码不一致'
    return false
  }
  if (password.value.length < 8) {
    formError.value = '密码至少 8 位'
    return false
  }
  return true
}

function openActivationModal() {
  if (!validateAccountForm()) return
  modalError.value = ''
  activationCode.value = ''
  showActivationModal.value = true
}

function closeActivationModal() {
  if (loading.value) return
  showActivationModal.value = false
  modalError.value = ''
}

async function completeRegistration() {
  const code = normalizeCode(activationCode.value)
  if (!code) {
    modalError.value = '请输入激活码'
    return
  }

  modalError.value = ''
  loading.value = true
  try {
    await auth.register(email.value.trim(), password.value, code)
    await catalog.loadEpisodes(true)
    const next = typeof route.query.next === 'string' ? route.query.next : '/english'
    await router.replace(next)
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    modalError.value = msg || '注册失败，请重试'
  } finally {
    loading.value = false
  }
}

watch(showActivationModal, async (open) => {
  document.body.style.overflow = open ? 'hidden' : ''
  if (open) {
    await nextTick()
    codeInputRef.value?.focus()
  }
})

onUnmounted(() => {
  document.body.style.overflow = ''
})
</script>

<template>
  <div class="min-h-dvh flex items-center justify-center px-4 py-12 bg-neutral-50 dark:bg-neutral-950">
    <div class="w-full max-w-md rounded-2xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-6 sm:p-8 shadow-sm">
      <h1 class="text-xl font-semibold mb-1">注册</h1>
      <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-6">
        注册需激活码，完成后即可学习全部视频内容
      </p>

      <form class="space-y-4" @submit.prevent="openActivationModal">
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
        >
          下一步
        </button>
      </form>

      <p class="text-sm text-neutral-500 dark:text-neutral-400 text-center mt-6">
        已有账号？
        <RouterLink to="/login" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">登录</RouterLink>
        <span class="mx-1">·</span>
        <RouterLink to="/english" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">先逛逛</RouterLink>
      </p>
    </div>

    <div
      v-if="showActivationModal"
      class="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/40 p-0 sm:p-4"
      @click.self="closeActivationModal"
    >
      <div
        class="w-full sm:max-w-md rounded-t-2xl sm:rounded-2xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-6 shadow-xl"
        role="dialog"
        aria-modal="true"
        aria-labelledby="activation-modal-title"
      >
        <h2 id="activation-modal-title" class="text-lg font-semibold mb-1">请输入激活码以完成注册</h2>
        <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-4">
          激活码由课程或社群提供，验证通过后将创建账号并开通会员
        </p>

        <form class="space-y-4" @submit.prevent="completeRegistration">
          <div>
            <label class="block text-sm text-neutral-600 dark:text-neutral-400 mb-1.5">激活码</label>
            <input
              ref="codeInputRef"
              v-model="activationCode"
              type="text"
              required
              autocomplete="off"
              placeholder="例如 AB3K"
              class="w-full rounded-lg border border-black/10 dark:border-white/10 dark:bg-neutral-800 dark:text-white px-3 py-2 text-sm uppercase focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:focus:ring-white/10"
              @input="activationCode = activationCode.toUpperCase()"
            />
          </div>

          <p v-if="modalError" class="text-sm text-red-600 dark:text-red-400">{{ modalError }}</p>

          <div class="flex flex-col-reverse sm:flex-row gap-2 sm:gap-3">
            <button
              type="button"
              class="w-full sm:flex-1 rounded-lg border border-black/10 dark:border-white/10 py-2.5 text-sm font-medium hover:bg-neutral-50 dark:hover:bg-neutral-800 disabled:opacity-60"
              :disabled="loading"
              @click="closeActivationModal"
            >
              返回修改
            </button>
            <button
              type="submit"
              class="w-full sm:flex-1 rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium hover:bg-neutral-800 dark:bg-neutral-100 dark:text-neutral-900 dark:hover:bg-white disabled:opacity-60"
              :disabled="loading"
            >
              {{ loading ? '注册中...' : '完成注册' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
