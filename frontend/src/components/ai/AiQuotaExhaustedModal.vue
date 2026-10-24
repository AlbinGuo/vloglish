<script setup lang="ts">
import { watch } from 'vue'
import { useRouter } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useAiQuotaPromptStore } from '@/stores/aiQuotaPrompt'
import { useSiteConfigStore } from '@/stores/siteConfig'

const router = useRouter()
const store = useAiQuotaPromptStore()
const siteConfig = useSiteConfigStore()
const { open, detail } = storeToRefs(store)

watch(open, (v) => {
  if (typeof document === 'undefined') return
  document.body.style.overflow = v ? 'hidden' : ''
})

function dismiss() {
  store.close()
}

function goPricing() {
  store.close()
  const next = router.currentRoute.value.fullPath
  void router.push({
    path: '/pricing',
    query: next && next !== '/pricing' ? { next } : {},
  })
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[90] flex items-end sm:items-center justify-center bg-black/40 p-0 sm:p-4"
      @click.self="dismiss"
    >
      <div
        class="w-full sm:max-w-md rounded-t-2xl sm:rounded-2xl bg-card border border-line-soft shadow-xl p-5 sm:p-6"
        role="dialog"
        aria-modal="true"
        aria-labelledby="ai-quota-title"
      >
        <h2 id="ai-quota-title" class="text-base font-semibold text-neutral-900 dark:text-neutral-100">
          今日 AI 次数已用完
        </h2>
        <p class="mt-2 text-sm leading-relaxed text-neutral-600 dark:text-neutral-300">
          {{ detail }}
        </p>
        <div class="mt-5 flex flex-col-reverse sm:flex-row sm:justify-end gap-2">
          <button
            type="button"
            class="px-4 py-2 rounded-xl text-sm border border-line-strong text-neutral-700 dark:text-neutral-200 hover:bg-sunken"
            @click="dismiss"
          >
            稍后再说
          </button>
          <button
            v-if="siteConfig.isContentGated"
            type="button"
            class="px-4 py-2 rounded-xl text-sm font-medium bg-neutral-900 text-white dark:bg-amber-500 dark:text-neutral-900 hover:opacity-90"
            @click="goPricing"
          >
            开通会员
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
