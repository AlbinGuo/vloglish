<script setup lang="ts">
import { ref } from 'vue'
import { NATIVE_LANGUAGES, TARGET_LANGUAGES } from '@/constants/languages'

const props = defineProps<{
  initialTarget?: string
  initialNative?: string
  submitting?: boolean
  confirmText?: string
}>()

const emit = defineEmits<{
  (e: 'confirm', payload: { target_language: string; native_language: string }): void
}>()

const target = ref(props.initialTarget || 'en')
const native = ref(props.initialNative || 'zh')

function onConfirm() {
  emit('confirm', { target_language: target.value, native_language: native.value })
}
</script>

<template>
  <div class="space-y-6">
    <section>
      <h2 class="mb-3 text-sm font-medium text-ink-soft">我想学（目标语言）</h2>
      <div class="grid grid-cols-3 gap-2">
        <button
          v-for="l in TARGET_LANGUAGES"
          :key="l.code"
          type="button"
          class="flex flex-col items-center gap-1 rounded-xl border px-2 py-3 text-sm transition"
          :class="
            target === l.code
              ? 'border-brand bg-brand-soft font-medium text-ink'
              : 'border-line-soft text-ink-soft hover:bg-sunken'
          "
          @click="target = l.code"
        >
          <span class="text-2xl leading-none">{{ l.flag }}</span>
          <span>{{ l.label }}</span>
          <span class="text-[11px] text-ink-faint">{{ l.native }}</span>
        </button>
      </div>
    </section>

    <section>
      <h2 class="mb-3 text-sm font-medium text-ink-soft">我的母语</h2>
      <div class="grid grid-cols-3 gap-2">
        <button
          v-for="l in NATIVE_LANGUAGES"
          :key="l.code"
          type="button"
          class="flex flex-col items-center gap-1 rounded-xl border px-2 py-3 text-sm transition"
          :class="
            native === l.code
              ? 'border-brand bg-brand-soft font-medium text-ink'
              : 'border-line-soft text-ink-soft hover:bg-sunken'
          "
          @click="native = l.code"
        >
          <span class="text-2xl leading-none">{{ l.flag }}</span>
          <span>{{ l.label }}</span>
        </button>
      </div>
    </section>

    <button
      type="button"
      class="w-full rounded-xl bg-brand px-4 py-3 text-base font-semibold text-white transition hover:opacity-90 disabled:opacity-60"
      :disabled="submitting"
      @click="onConfirm"
    >
      {{ submitting ? '保存中…' : confirmText || '开始学习' }}
    </button>
  </div>
</template>
