<script setup lang="ts">
import AppIcon from '@/components/AppIcon.vue'
import type { AnnouncementItem } from '@/api/notifications'

defineProps<{ item: AnnouncementItem | null }>()
const emit = defineEmits<{ (e: 'close'): void }>()
</script>

<template>
  <Teleport to="body">
    <Transition name="announce-fade">
      <div
        v-if="item"
        class="fixed inset-0 z-[210] flex items-center justify-center bg-black/50 p-6"
        role="dialog"
        aria-modal="true"
        @click.self="emit('close')"
      >
        <div class="w-full max-w-sm rounded-2xl bg-card p-5 shadow-2xl">
          <div class="mb-2 flex items-start justify-between gap-3">
            <h2 class="text-lg font-semibold leading-snug text-ink">{{ item.title || '公告' }}</h2>
            <button type="button" class="shrink-0 text-ink-faint transition hover:text-ink" aria-label="关闭" @click="emit('close')">
              <AppIcon name="close" class="h-5 w-5" />
            </button>
          </div>
          <img
            v-if="item.image_url"
            :src="item.image_url"
            class="mb-3 max-h-[50vh] w-full rounded-lg object-contain"
            alt=""
          />
          <p v-if="item.body" class="whitespace-pre-wrap text-sm leading-relaxed text-ink-soft">
            {{ item.body }}
          </p>
          <div class="mt-5 text-right">
            <button
              type="button"
              class="rounded-lg bg-brand px-4 py-1.5 text-sm font-medium text-white transition hover:opacity-90"
              @click="emit('close')"
            >
              我知道了
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.announce-fade-enter-active,
.announce-fade-leave-active {
  transition: opacity 180ms ease;
}
.announce-fade-enter-from,
.announce-fade-leave-to {
  opacity: 0;
}
</style>
