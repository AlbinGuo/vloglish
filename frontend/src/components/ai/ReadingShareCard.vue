<script setup lang="ts">
import { computed, ref } from 'vue'

const props = defineProps<{
  open: boolean
  title: string
  english?: string
  chinese?: string
}>()

defineEmits<{ close: [] }>()

const copied = ref(false)

const shareText = computed(() => {
  const parts = [
    `【Vloglish 读报】${props.title}`,
    props.english?.trim() || '',
    props.chinese?.trim() || '',
    '—— 用真实语料学英语 · vloglish',
  ].filter(Boolean)
  return parts.join('\n\n')
})

async function copyShare() {
  try {
    await navigator.clipboard.writeText(shareText.value)
    copied.value = true
    setTimeout(() => {
      copied.value = false
    }, 2000)
  } catch {
    copied.value = false
  }
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[80] flex items-end sm:items-center justify-center bg-black/40 p-0 sm:p-4"
      @click.self="$emit('close')"
    >
      <div
        class="w-full sm:max-w-md rounded-t-2xl sm:rounded-2xl bg-white dark:bg-neutral-900 border border-black/5 dark:border-white/10 shadow-xl p-5 sm:p-6 space-y-4"
      >
        <div class="flex items-start justify-between gap-3">
          <h2 class="text-base font-semibold">分享卡片</h2>
          <button type="button" class="text-sm text-neutral-500" @click="$emit('close')">关闭</button>
        </div>

        <div
          class="rounded-2xl overflow-hidden border border-amber-200/80 dark:border-amber-900 bg-gradient-to-br from-amber-50 via-white to-neutral-50 dark:from-amber-950/40 dark:via-neutral-900 dark:to-neutral-950 p-5 space-y-3"
        >
          <p class="text-[11px] tracking-wide text-amber-700 dark:text-amber-300 font-medium">
            VLOGLISH · REAL ENGLISH
          </p>
          <h3 class="text-lg font-semibold leading-snug">{{ title }}</h3>
          <p v-if="english" class="text-sm leading-relaxed text-neutral-800 dark:text-neutral-200">
            {{ english }}
          </p>
          <p v-if="chinese" class="text-sm text-neutral-500 leading-relaxed">{{ chinese }}</p>
        </div>

        <button
          type="button"
          class="w-full rounded-lg bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900 py-2.5 text-sm font-medium"
          @click="copyShare"
        >
          {{ copied ? '已复制文案' : '复制分享文案' }}
        </button>
      </div>
    </div>
  </Teleport>
</template>
