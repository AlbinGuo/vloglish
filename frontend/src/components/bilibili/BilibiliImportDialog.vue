<script setup lang="ts">
import { computed } from 'vue'
import type { BilibiliResolved } from '@/api/bilibili'

const props = defineProps<{
  open: boolean
  data: BilibiliResolved | null
  resolving?: boolean
  importing?: boolean
  error?: string
}>()
const emit = defineEmits<{ confirm: []; close: [] }>()

const coverUrl = computed(() => props.data?.cover_proxy || props.data?.cover || '')
const durationText = computed(() => {
  const d = Math.max(0, Math.round(props.data?.duration || 0))
  const h = Math.floor(d / 3600)
  const m = Math.floor((d % 3600) / 60)
  const s = d % 60
  const mm = String(m).padStart(2, '0')
  const ss = String(s).padStart(2, '0')
  return h > 0 ? `${h}:${mm}:${ss}` : `${mm}:${ss}`
})
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[1000] flex items-end justify-center bg-black/50 px-4 pb-6 sm:items-center sm:pb-0"
      @click.self="emit('close')"
    >
      <div class="w-full max-w-md overflow-hidden rounded-2xl bg-card shadow-xl border border-line-soft">
        <div class="flex items-center justify-between border-b border-line-soft px-4 py-3">
          <span class="text-sm font-medium">发现 B 站视频</span>
          <button
            type="button"
            class="rounded-lg px-2 py-0.5 text-lg leading-none text-ink-faint hover:bg-sunken"
            aria-label="关闭"
            @click="emit('close')"
          >
            ×
          </button>
        </div>

        <div v-if="data" class="px-4 py-4">
          <div class="relative aspect-video w-full overflow-hidden rounded-xl bg-sunken">
            <img v-if="coverUrl" :src="coverUrl" alt="" class="h-full w-full object-cover" />
            <span
              v-if="data.duration"
              class="absolute bottom-2 right-2 rounded bg-black/70 px-1.5 py-0.5 text-[11px] tabular-nums text-white"
            >
              {{ durationText }}
            </span>
          </div>
          <p class="mt-3 line-clamp-2 text-[15px] font-medium leading-snug">{{ data.title }}</p>
          <p class="mt-1 text-xs text-ink-faint">{{ data.author_name || 'B站作者' }}</p>
          <p v-if="error" class="mt-2 text-xs text-red-600">{{ error }}</p>
          <div class="mt-4 flex gap-2">
            <button
              type="button"
              class="flex-1 rounded-lg border border-line-soft py-2 text-sm text-ink-soft hover:bg-sunken"
              @click="emit('close')"
            >
              取消
            </button>
            <button
              type="button"
              class="flex-1 rounded-lg bg-amber-500 py-2 text-sm font-medium text-white hover:bg-amber-600 disabled:opacity-60"
              :disabled="importing"
              @click="emit('confirm')"
            >
              {{ importing ? '导入中…' : '立即观看' }}
            </button>
          </div>
        </div>

        <div v-else-if="error" class="px-4 py-8 text-center">
          <p class="text-sm text-red-600">{{ error }}</p>
          <button
            type="button"
            class="mt-4 rounded-lg border border-line-soft px-4 py-2 text-sm text-ink-soft hover:bg-sunken"
            @click="emit('close')"
          >
            关闭
          </button>
        </div>

        <div v-else class="px-4 py-10 text-center">
          <div class="mx-auto h-6 w-6 animate-spin rounded-full border-2 border-amber-500 border-t-transparent" />
          <p class="mt-3 text-sm text-ink-faint">正在解析剪贴板中的 B 站视频…</p>
        </div>
      </div>
    </div>
  </Teleport>
</template>
