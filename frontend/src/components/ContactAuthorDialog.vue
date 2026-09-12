<script setup lang="ts">
import { onMounted, onUnmounted } from 'vue'

const open = defineModel<boolean>('open', { default: false })

function close() {
  open.value = false
}

function onKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape' && open.value) close()
}

onMounted(() => window.addEventListener('keydown', onKeydown))
onUnmounted(() => window.removeEventListener('keydown', onKeydown))
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[80] flex items-center justify-center px-4"
      role="dialog"
      aria-modal="true"
      aria-labelledby="contact-author-title"
    >
      <button
        type="button"
        class="absolute inset-0 bg-black/45 backdrop-blur-[1px]"
        aria-label="关闭"
        @click="close"
      />
      <div
        class="relative w-full max-w-sm rounded-2xl bg-white dark:bg-neutral-900 p-5 shadow-xl border border-black/5 dark:border-white/10"
      >
        <div class="flex items-start justify-between gap-3">
          <div>
            <h2 id="contact-author-title" class="text-base font-semibold text-neutral-900 dark:text-white">
              联系作者
            </h2>
            <p class="mt-1 text-sm text-neutral-500 dark:text-neutral-400 leading-relaxed">
              微信扫码添加作者，咨询学习或开通会员
            </p>
          </div>
          <button
            type="button"
            class="w-8 h-8 rounded-full text-neutral-500 hover:bg-neutral-100 dark:hover:bg-neutral-800 shrink-0"
            aria-label="关闭"
            @click="close"
          >
            ×
          </button>
        </div>
        <div
          class="mt-4 flex justify-center items-center rounded-xl bg-neutral-50 dark:bg-neutral-950 border border-black/5 dark:border-white/10 p-4"
        >
          <img
            src="/author-wechat-qr.png"
            alt="作者微信二维码"
            class="w-48 h-48 object-contain bg-white rounded-lg"
          />
        </div>
        <p class="mt-3 text-center text-xs text-neutral-500 leading-relaxed">
          添加时请备注来意，方便作者通过
        </p>
      </div>
    </div>
  </Teleport>
</template>
