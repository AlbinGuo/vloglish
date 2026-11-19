<script setup lang="ts">
import { computed, ref } from 'vue'
import { useAuthStore } from '@/stores/auth'
import LanguageSelect from '@/components/LanguageSelect.vue'

const auth = useAuthStore()
const submitting = ref(false)
const error = ref('')

const visible = computed(() => auth.ready && auth.isLoggedIn && !auth.user?.language_selected)

async function onConfirm(payload: { target_language: string; native_language: string }) {
  if (submitting.value) return
  submitting.value = true
  error.value = ''
  try {
    await auth.updateLanguage(payload.target_language, payload.native_language)
    // 重新加载以让首页/列表按新语言拉取（避免缓存旧语言数据）
    window.location.reload()
  } catch {
    error.value = '保存失败，请重试'
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="visible"
      class="fixed inset-0 z-[300] flex items-end justify-center bg-canvas/95 backdrop-blur sm:items-center"
    >
      <div class="w-full max-w-md rounded-t-2xl bg-card p-5 shadow-2xl sm:rounded-2xl sm:p-6">
        <div class="mb-1 text-xl font-semibold text-ink">选择你想学习的语言</div>
        <p class="mb-5 text-sm text-ink-soft">
          选好后点「开始学习」进入首页。之后也可以在「我的」里随时切换。
        </p>
        <LanguageSelect disable-unavailable :submitting="submitting" confirm-text="开始学习" @confirm="onConfirm" />
        <p v-if="error" class="mt-3 text-center text-sm text-danger">{{ error }}</p>
      </div>
    </div>
  </Teleport>
</template>
