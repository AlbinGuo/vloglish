<script setup lang="ts">
import { ref } from 'vue'
import { NATIVE_LANGUAGES, TARGET_LANGUAGES } from '@/constants/languages'
import CountryFlag from '@/components/CountryFlag.vue'

const props = defineProps<{
  initialTarget?: string
  initialNative?: string
  submitting?: boolean
  confirmText?: string
  /** 允许选择的目标语言代码；未在其中的语言会显示为「语料库完善中」且不可选 */
  availableLanguages?: string[]
}>()

const emit = defineEmits<{
  (e: 'confirm', payload: { target_language: string; native_language: string }): void
}>()

const target = ref(props.initialTarget || 'en')
const native = ref(props.initialNative || 'zh')

function isUnavailable(code: string) {
  if (!props.availableLanguages) return false
  return !props.availableLanguages.includes(code)
}

function pick(code: string) {
  if (isUnavailable(code)) return
  target.value = code
}

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
          class="flex flex-col items-center gap-1.5 rounded-xl border px-2 py-3 text-sm transition"
          :class="[
            target === l.code
              ? 'border-brand bg-brand-soft font-medium text-ink'
              : 'border-line-soft text-ink-soft hover:bg-sunken',
            isUnavailable(l.code) ? 'cursor-not-allowed opacity-50 hover:bg-transparent' : '',
          ]"
          :disabled="isUnavailable(l.code)"
          @click="pick(l.code)"
        >
          <CountryFlag :code="l.code" class="h-7 w-10 rounded-[3px] ring-1 ring-black/10" />
          <span>{{ l.label }}</span>
          <span v-if="isUnavailable(l.code)" class="text-center text-[10px] leading-tight text-ink-faint">
            语料库完善中
          </span>
          <span v-else class="text-[11px] text-ink-faint">{{ l.native }}</span>
        </button>
      </div>
      <p v-if="availableLanguages" class="mt-2 text-[11px] text-ink-faint">
        灰色语言正在完善语料库，敬请期待。
      </p>
    </section>

    <section>
      <h2 class="mb-3 text-sm font-medium text-ink-soft">我的母语</h2>
      <div class="grid grid-cols-3 gap-2">
        <button
          v-for="l in NATIVE_LANGUAGES"
          :key="l.code"
          type="button"
          class="flex flex-col items-center gap-1.5 rounded-xl border px-2 py-3 text-sm transition"
          :class="
            native === l.code
              ? 'border-brand bg-brand-soft font-medium text-ink'
              : 'border-line-soft text-ink-soft hover:bg-sunken'
          "
          @click="native = l.code"
        >
          <CountryFlag :code="l.code" class="h-7 w-10 rounded-[3px] ring-1 ring-black/10" />
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
