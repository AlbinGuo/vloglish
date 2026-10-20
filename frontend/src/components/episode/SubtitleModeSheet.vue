<script setup lang="ts">
import type { SubtitleDisplayMode } from '@/utils/subtitleHtml'

defineProps<{
  open: boolean
  subtitleMode: SubtitleDisplayMode
  contentView?: 'subtitles' | 'wordcards' | 'summary' | 'context' | 'audience'
  modeButtons: { key: SubtitleDisplayMode; label: string }[]
  /** @deprecated 汇总 Tab 始终显示 */
  showVocabSummary?: boolean
  showAudienceNotes?: boolean
}>()

const emit = defineEmits<{
  close: []
  'update:subtitleMode': [value: SubtitleDisplayMode]
  selectWordCards: []
  selectVocabSummary: []
  selectVideoContext: []
  selectAudienceNotes: []
}>()
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[280] flex items-end justify-center bg-black/40"
      @click.self="emit('close')"
    >
      <div
        class="w-full max-w-lg rounded-t-2xl bg-white dark:bg-neutral-900 shadow-2xl pb-[env(safe-area-inset-bottom)]"
        role="dialog"
        aria-modal="true"
        @click.stop
      >
        <div class="flex justify-center pt-3 pb-2">
          <div class="w-10 h-1 rounded-full bg-neutral-300 dark:bg-neutral-600" />
        </div>
        <div class="px-4 pb-4">
          <p class="text-sm font-medium mb-3">字幕模式</p>
          <div class="grid grid-cols-3 gap-2">
            <button
              v-for="m in modeButtons"
              :key="m.key"
              type="button"
              class="px-3 py-2.5 rounded-xl text-sm border transition-colors"
              :class="
                contentView === 'subtitles' && subtitleMode === m.key
                  ? 'bg-ink text-ink-inverse border-neutral-900 dark:border-neutral-100'
                  : 'border-line hover:bg-sunken'
              "
              @click="emit('update:subtitleMode', m.key)"
            >
              {{ m.label }}
            </button>
            <button
              type="button"
              class="px-3 py-2.5 rounded-xl text-sm border transition-colors"
              :class="
                contentView === 'wordcards'
                  ? 'bg-ink text-ink-inverse border-neutral-900 dark:border-neutral-100'
                  : 'border-line hover:bg-sunken'
              "
              @click="emit('selectWordCards')"
            >
              词卡
            </button>
            <button
              type="button"
              class="px-3 py-2.5 rounded-xl text-sm border transition-colors"
              :class="
                contentView === 'summary'
                  ? 'bg-ink text-ink-inverse border-neutral-900 dark:border-neutral-100'
                  : 'border-line hover:bg-sunken'
              "
              @click="emit('selectVocabSummary')"
            >
              汇总
            </button>
            <button
              type="button"
              class="relative col-span-3 flex items-center justify-between gap-2 px-3 py-2.5 rounded-xl text-sm border transition-colors text-left"
              :class="
                contentView === 'context'
                  ? 'bg-ink text-ink-inverse border-neutral-900 dark:border-neutral-100'
                  : 'border-line hover:bg-sunken'
              "
              @click="emit('selectVideoContext')"
            >
              <span class="inline-flex items-center gap-1.5 font-medium">
                视频语境
                <span class="px-1.5 py-0.5 rounded-md text-[10px] font-bold leading-none bg-red-500 text-white">
                  新
                </span>
              </span>
              <span
                class="text-[11px] font-medium leading-none px-1.5 py-0.5 rounded-full shrink-0"
                :class="
                  contentView === 'context'
                    ? 'bg-white/20 text-ink-inverse dark:bg-neutral-900/15'
                    : 'bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-200'
                "
              >
                看懂背景
              </span>
            </button>
            <button
              v-if="showAudienceNotes"
              type="button"
              class="relative col-span-3 flex items-center justify-between gap-2 px-3 py-2.5 rounded-xl text-sm border transition-colors text-left"
              :class="
                contentView === 'audience'
                  ? 'bg-ink text-ink-inverse border-neutral-900 dark:border-neutral-100'
                  : 'border-line hover:bg-sunken'
              "
              @click="emit('selectAudienceNotes')"
            >
              <span class="inline-flex items-center gap-1.5 font-medium">
                观众怎么说
                <span class="px-1.5 py-0.5 rounded-md text-[10px] font-bold leading-none bg-red-500 text-white">
                  新
                </span>
              </span>
              <span class="text-[11px] text-neutral-400">片后热议</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>
