<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import LanguageSelect from '@/components/LanguageSelect.vue'
import AppIcon from '@/components/AppIcon.vue'

defineOptions({ name: 'LanguageSettings' })

const auth = useAuthStore()
const router = useRouter()
const submitting = ref(false)
const error = ref('')
const saved = ref(false)

async function onConfirm(payload: { target_language: string; native_language: string }) {
  if (submitting.value) return
  submitting.value = true
  error.value = ''
  saved.value = false
  try {
    await auth.updateLanguage(payload.target_language, payload.native_language)
    saved.value = true
    setTimeout(() => window.location.reload(), 800)
  } catch {
    error.value = '保存失败，请重试'
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="page-container max-w-xl py-6">
    <button
      type="button"
      class="mb-4 inline-flex items-center gap-1 text-sm text-ink-soft hover:text-ink"
      @click="router.back()"
    >
      <AppIcon name="chevron-left" class="h-4 w-4" />
      返回
    </button>
    <h1 class="mb-1 text-lg font-semibold text-ink">学习语言</h1>
    <p class="mb-5 text-sm text-ink-soft">切换后，首页与视频列表会显示对应语言的视频。</p>

    <LanguageSelect
      :initial-target="auth.user?.target_language"
      :initial-native="auth.user?.native_language"
      :submitting="submitting"
      confirm-text="保存设置"
      @confirm="onConfirm"
    />

    <p v-if="saved" class="mt-3 text-center text-sm text-success">已保存，切换语言成功</p>
    <p v-if="error" class="mt-3 text-center text-sm text-danger">{{ error }}</p>
  </div>
</template>
