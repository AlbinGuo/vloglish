<script setup lang="ts">
import { RouterLink } from 'vue-router'
import { useFavoriteToastStore } from '@/stores/favoriteToast'

const toast = useFavoriteToastStore()
</script>

<template>
  <Teleport to="body">
    <Transition name="fav-toast">
      <div
        v-if="toast.visible"
        class="fixed inset-x-0 z-[430] flex justify-center px-4 pointer-events-none"
        :class="'bottom-[max(5.5rem,calc(env(safe-area-inset-bottom)+4.5rem))] sm:bottom-10'"
        role="status"
      >
        <div
          class="pointer-events-auto relative overflow-hidden w-full max-w-sm rounded-2xl border border-amber-200/80 dark:border-amber-500/30 bg-[#FFF8EE]/95 dark:bg-neutral-900/95 shadow-[0_18px_50px_-12px_rgba(217,119,6,0.45)] backdrop-blur-md px-4 py-3.5"
        >
          <div
            v-if="toast.added"
            class="fav-toast-glow absolute -top-10 left-1/2 -translate-x-1/2 w-40 h-24 rounded-full bg-amber-300/40 blur-2xl pointer-events-none"
            aria-hidden="true"
          />
          <div class="relative flex items-start gap-3">
            <div
              class="relative shrink-0 w-11 h-11 rounded-full flex items-center justify-center"
              :class="toast.added ? 'bg-amber-500 text-white fav-star-pop' : 'bg-neutral-200 text-neutral-500 dark:bg-neutral-800 dark:text-neutral-400'"
            >
              <svg
                v-if="toast.added"
                viewBox="0 0 24 24"
                class="w-6 h-6"
                fill="currentColor"
                aria-hidden="true"
              >
                <path d="M12 2.5l2.7 6.3 6.8.6-5.2 4.5 1.6 6.6L12 16.9 6.1 20.5l1.6-6.6L2.5 9.4l6.8-.6L12 2.5z" />
              </svg>
              <svg
                v-else
                viewBox="0 0 24 24"
                class="w-5 h-5"
                fill="none"
                stroke="currentColor"
                stroke-width="1.8"
                aria-hidden="true"
              >
                <path d="M12 2.5l2.7 6.3 6.8.6-5.2 4.5 1.6 6.6L12 16.9 6.1 20.5l1.6-6.6L2.5 9.4l6.8-.6L12 2.5z" />
              </svg>
              <span v-if="toast.added" class="fav-sparkle fav-sparkle-a" aria-hidden="true" />
              <span v-if="toast.added" class="fav-sparkle fav-sparkle-b" aria-hidden="true" />
              <span v-if="toast.added" class="fav-sparkle fav-sparkle-c" aria-hidden="true" />
            </div>
            <div class="min-w-0 flex-1 pt-0.5">
              <p class="text-sm font-semibold text-neutral-900 dark:text-neutral-50 leading-snug">
                {{ toast.added ? '已进入我的语料库' : '已移出我的语料库' }}
              </p>
              <p class="mt-0.5 text-xs text-neutral-500 dark:text-neutral-400 leading-snug line-clamp-2">
                <template v-if="toast.added">
                  {{ toast.title ? `「${toast.title}」` : '收藏的视频' }}可在「我的语料库」随时回看
                </template>
                <template v-else>收藏列表已更新</template>
              </p>
              <RouterLink
                v-if="toast.added"
                to="/english/my-submissions?tab=favorites"
                class="inline-flex items-center gap-1 mt-2 text-xs font-semibold text-amber-700 dark:text-amber-300 hover:underline"
                @click="toast.hide()"
              >
                去我的语料库查看
                <span aria-hidden="true">→</span>
              </RouterLink>
            </div>
            <button
              type="button"
              class="shrink-0 w-7 h-7 rounded-full text-neutral-400 hover:text-neutral-700 hover:bg-black/5 dark:hover:text-neutral-200 dark:hover:bg-white/10"
              aria-label="关闭"
              @click="toast.hide()"
            >
              ×
            </button>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.fav-toast-enter-active,
.fav-toast-leave-active {
  transition: opacity 0.28s ease, transform 0.38s cubic-bezier(0.22, 1, 0.36, 1);
}
.fav-toast-enter-from,
.fav-toast-leave-to {
  opacity: 0;
  transform: translateY(18px) scale(0.96);
}

.fav-star-pop {
  animation: fav-star-pop 0.55s cubic-bezier(0.22, 1.4, 0.36, 1);
}

@keyframes fav-star-pop {
  0% {
    transform: scale(0.4) rotate(-20deg);
  }
  60% {
    transform: scale(1.18) rotate(8deg);
  }
  100% {
    transform: scale(1) rotate(0deg);
  }
}

.fav-sparkle {
  position: absolute;
  width: 5px;
  height: 5px;
  border-radius: 999px;
  background: #fbbf24;
  box-shadow: 0 0 8px #f59e0b;
  animation: fav-sparkle 0.7s ease-out both;
}

.fav-sparkle-a {
  top: -2px;
  right: 2px;
}
.fav-sparkle-b {
  top: 4px;
  left: -3px;
  animation-delay: 0.06s;
}
.fav-sparkle-c {
  bottom: 0;
  right: -2px;
  animation-delay: 0.1s;
}

@keyframes fav-sparkle {
  0% {
    opacity: 0;
    transform: scale(0.2) translateY(4px);
  }
  40% {
    opacity: 1;
  }
  100% {
    opacity: 0;
    transform: scale(0.6) translate(8px, -12px);
  }
}

.fav-toast-glow {
  animation: fav-glow 1.2s ease-out;
}

@keyframes fav-glow {
  0% {
    opacity: 0;
    transform: translate(-50%, 8px) scale(0.6);
  }
  40% {
    opacity: 1;
  }
  100% {
    opacity: 0.35;
  }
}
</style>
