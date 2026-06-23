<script setup lang="ts">
import { computed } from 'vue'
import type { EntryDetail } from '@/types'
import { posLabel } from '@/utils/posLabel'

const props = defineProps<{
  entry: EntryDetail | null
  loading?: boolean
  error?: string
}>()

defineEmits<{ close: [] }>()

const primaryPron = computed(() => {
  const list = props.entry?.pronunciations ?? []
  return list.find((p) => p.is_primary) ?? list[0] ?? null
})

function playAudio(url: string) {
  new Audio(url).play()
}
</script>

<template>
  <div
    class="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/35 p-0 sm:p-4"
    @click.self="$emit('close')"
  >
    <div
      class="relative w-full max-w-lg max-h-[88dvh] sm:max-h-[85dvh] flex flex-col rounded-t-[24px] sm:rounded-[24px] bg-[#FDF8F1] shadow-2xl overflow-hidden"
      role="dialog"
      aria-modal="true"
    >
      <div class="shrink-0 flex justify-center pt-3 pb-1 sm:hidden">
        <div class="w-10 h-1 rounded-full bg-neutral-300/80" />
      </div>

      <button
        type="button"
        class="absolute top-3 right-4 z-10 w-8 h-8 flex items-center justify-center rounded-full text-neutral-400 hover:text-neutral-700 hover:bg-black/5 transition-colors"
        aria-label="关闭"
        @click="$emit('close')"
      >
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M18 6L6 18M6 6l12 12" />
        </svg>
      </button>

      <!-- Loading -->
      <div v-if="loading" class="p-6 space-y-4">
        <div class="h-8 w-40 bg-neutral-200/70 rounded-lg animate-pulse" />
        <div class="h-5 w-32 bg-neutral-200/60 rounded animate-pulse" />
        <div class="bg-white rounded-2xl p-4 space-y-3">
          <div class="h-4 w-12 bg-neutral-100 rounded animate-pulse" />
          <div class="h-6 w-full bg-neutral-100 rounded animate-pulse" />
          <div class="h-4 w-4/5 bg-neutral-100 rounded animate-pulse" />
        </div>
      </div>

      <!-- Error -->
      <div v-else-if="error" class="p-8 text-center">
        <p class="text-neutral-600 mb-4">{{ error }}</p>
        <button
          type="button"
          class="px-4 py-2 rounded-full bg-neutral-900 text-white text-sm"
          @click="$emit('close')"
        >
          关闭
        </button>
      </div>

      <!-- Content -->
      <template v-else-if="entry">
        <header class="shrink-0 px-5 pt-2 pb-4 pr-12">
          <div class="flex items-start justify-between gap-3">
            <div class="flex items-center gap-2 min-w-0">
              <button
                type="button"
                class="shrink-0 text-neutral-300 hover:text-amber-400 transition-colors"
                aria-label="收藏"
              >
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                  <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
                </svg>
              </button>
              <h2 class="text-[1.75rem] leading-tight font-serif font-bold text-neutral-900 truncate">
                {{ entry.headword }}
              </h2>
            </div>
            <span class="shrink-0 px-2.5 py-0.5 rounded-md bg-[#E8A87C] text-white text-xs font-medium">
              {{ entry.category }}
            </span>
          </div>

          <div v-if="primaryPron" class="flex items-center gap-2 mt-3">
            <button
              type="button"
              class="inline-flex items-center gap-1.5 text-sm text-neutral-600 hover:text-neutral-900 transition-colors"
              @click="playAudio(primaryPron.audio_url)"
            >
              <span class="font-medium">{{ primaryPron.accent_type }}</span>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" class="text-neutral-500">
                <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02z" />
              </svg>
              <span class="font-serif text-neutral-700">{{ primaryPron.ipa }}</span>
            </button>
          </div>
        </header>

        <div class="flex-1 min-h-0 overflow-y-auto overscroll-contain px-4 pb-6 space-y-3">
          <article
            v-for="def in entry.definitions"
            :key="def.id"
            class="bg-white rounded-2xl p-4 shadow-[0_1px_3px_rgba(0,0,0,0.06)]"
          >
            <span
              v-if="def.pos"
              class="inline-block px-2 py-0.5 mb-2 rounded text-xs font-medium bg-[#F5E6D8] text-[#B45309]"
            >
              {{ posLabel(def.pos) }}
            </span>

            <p class="text-lg font-semibold text-neutral-900 leading-snug mb-1">
              {{ def.definition_cn }}
            </p>
            <p class="text-sm text-neutral-600 leading-relaxed mb-3">
              {{ def.definition_en }}
            </p>

            <div v-if="def.usage_pattern" class="mb-3">
              <p class="text-xs text-neutral-400 mb-1">用法</p>
              <p class="text-sm text-neutral-700">{{ def.usage_pattern }}</p>
            </div>

            <div v-for="ex in def.examples" :key="ex.order" class="mt-3">
              <p class="text-xs text-neutral-400 mb-1">例句</p>
              <p class="text-sm text-neutral-800 leading-relaxed">{{ ex.example_en }}</p>
              <p class="text-sm text-neutral-500 mt-0.5 leading-relaxed">{{ ex.example_cn }}</p>
            </div>
          </article>
        </div>
      </template>
    </div>
  </div>
</template>
