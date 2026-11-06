<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue'
import AppIcon from '@/components/AppIcon.vue'
import { copyText } from '@/utils/clipboard'

const AUTHOR_WECHAT_ID = 'vloglish01'

const open = defineModel<boolean>('open', { default: false })

const copied = ref(false)
let copiedTimer: ReturnType<typeof setTimeout> | undefined

function close() {
  open.value = false
  copied.value = false
  if (copiedTimer) {
    clearTimeout(copiedTimer)
    copiedTimer = undefined
  }
}

async function copyWechat() {
  const ok = await copyText(AUTHOR_WECHAT_ID)
  copied.value = ok
  if (copiedTimer) clearTimeout(copiedTimer)
  copiedTimer = setTimeout(() => {
    copied.value = false
  }, 2000)
}

function onKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape' && open.value) close()
}

onMounted(() => window.addEventListener('keydown', onKeydown))
onUnmounted(() => {
  window.removeEventListener('keydown', onKeydown)
  if (copiedTimer) clearTimeout(copiedTimer)
})
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
        class="relative w-full max-w-sm rounded-2xl bg-card p-5 shadow-xl border border-line-soft"
      >
        <div class="flex items-start justify-between gap-3">
          <div>
            <h2 id="contact-author-title" class="text-base font-semibold text-neutral-900 dark:text-white">
              联系作者
            </h2>
            <p class="mt-1 text-sm text-neutral-500 dark:text-neutral-400 leading-relaxed">
              微信扫码或搜索微信号添加作者，咨询学习或开通会员
            </p>
          </div>
          <button
            type="button"
            class="w-8 h-8 rounded-full text-neutral-500 hover:bg-sunken shrink-0"
            aria-label="关闭"
            @click="close"
          >
            ×
          </button>
        </div>

        <div
          class="mt-4 flex items-center gap-2 rounded-xl border border-line-soft bg-canvas px-3 py-2.5"
        >
          <span class="text-[12px] text-neutral-500 dark:text-neutral-400 shrink-0">微信号</span>
          <span
            class="min-w-0 flex-1 truncate font-mono text-[14px] font-semibold tracking-wide text-neutral-900 dark:text-white"
          >
            {{ AUTHOR_WECHAT_ID }}
          </span>
          <button
            type="button"
            class="inline-flex shrink-0 items-center gap-1 rounded-lg bg-ink px-2.5 py-1.5 text-[12px] font-medium text-ink-inverse transition hover:opacity-90 active:scale-95"
            :aria-label="copied ? '已复制微信号' : '复制微信号'"
            @click="copyWechat"
          >
            <AppIcon :name="copied ? 'check-xs' : 'clipboard'" class="h-3.5 w-3.5" />
            {{ copied ? '已复制' : '复制' }}
          </button>
        </div>

        <div
          class="mt-3 flex justify-center items-center rounded-xl bg-canvas border border-line-soft p-4"
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
