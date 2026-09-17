<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue'

const HINT_KEY = 'vloglish_listen_swipe_hint_v3'

const visible = ref(false)
let showTimer: ReturnType<typeof setTimeout> | null = null

function dismiss() {
  visible.value = false
  if (showTimer) clearTimeout(showTimer)
  try {
    localStorage.setItem(HINT_KEY, '1')
  } catch {
    /* ignore */
  }
}

onMounted(() => {
  try {
    if (localStorage.getItem(HINT_KEY) === '1') return
  } catch {
    /* ignore */
  }
  showTimer = setTimeout(() => {
    visible.value = true
  }, 420)
})

onUnmounted(() => {
  if (showTimer) clearTimeout(showTimer)
})

defineExpose({ dismiss })
</script>

<template>
  <div
    v-if="visible"
    class="listen-swipe-hint absolute inset-0 z-30 flex items-center justify-center"
    role="dialog"
    aria-label="切集提示"
  >
    <button
      type="button"
      class="absolute inset-0 bg-black/50 md:bg-black/55"
      aria-label="关闭提示"
      @click="dismiss"
    />

    <div class="relative z-10 flex flex-col items-center px-6 text-center text-white">
      <div class="hidden md:flex flex-col items-center">
        <svg
          class="listen-swipe-hint__mouse"
          viewBox="0 0 72 96"
          width="58"
          height="78"
          aria-hidden="true"
        >
          <rect x="16" y="4" width="40" height="88" rx="20" fill="#fff" />
          <rect x="33" y="18" width="6" height="20" rx="3" fill="#d4d4d8" />
        </svg>

        <svg
          class="mt-3 listen-swipe-hint__hand"
          viewBox="0 0 88 108"
          width="70"
          height="86"
          aria-hidden="true"
        >
          <path
            fill="#fff"
            d="M19 62.5c-6.8-3.6-15.2.2-16.4 8-.9 5.8 3.2 11 9 12.6 6.4 1.8 16.8 3.4 27.4 3.4h9.6c11.4 0 20.4-8 20.4-18.6V52c0-5.8-4.6-10.6-10.4-10.6-1.6 0-3.1.4-4.4 1V36.8c0-5.7-4.5-10.4-10.2-10.4h-1.2c-.4-5.8-5.2-10.4-11.2-10.4S21.6 20.6 21.2 26.4h-.8C14.6 26.4 10 31.2 10 37.2v21.6c2.4-2.8 5.6-4.8 9-5.3z"
          />
          <g class="listen-swipe-hint__index">
            <rect x="37.5" y="4" width="14.5" height="48" rx="7.25" fill="#fff" />
          </g>
        </svg>
      </div>

      <div class="flex md:hidden flex-col items-center">
        <span class="listen-swipe-hint__stage" aria-hidden="true">
          <span class="listen-swipe-hint__page listen-swipe-hint__page--next" />
          <span class="listen-swipe-hint__page listen-swipe-hint__page--current">
            <span class="listen-swipe-hint__finger" />
          </span>
        </span>
      </div>

      <p class="mt-5 max-w-[18rem] text-sm leading-relaxed text-white/95 md:max-w-[22rem] md:text-[15px]">
        <span class="hidden md:inline">滚动「鼠标」或点按「键盘上下键」<br />查看更多视频</span>
        <span class="md:hidden">上滑切换下一集</span>
      </p>

      <button
        type="button"
        class="mt-5 rounded-full bg-pink-500 px-5 py-1.5 text-sm font-medium text-white shadow-lg shadow-pink-500/25 hover:bg-pink-400"
        @click="dismiss"
      >
        我知道了
      </button>
    </div>
  </div>
</template>

<style scoped>
.listen-swipe-hint__mouse,
.listen-swipe-hint__hand {
  filter: drop-shadow(0 10px 18px rgb(0 0 0 / 0.28));
}
.listen-swipe-hint__index {
  transform-box: fill-box;
  transform-origin: 50% 100%;
  animation: listen-index-swipe 1.35s ease-in-out infinite;
}
@media (prefers-reduced-motion: reduce) {
  .listen-swipe-hint__index {
    animation: none;
  }
}
@keyframes listen-index-swipe {
  0%,
  14% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-16px);
  }
  100% {
    transform: translateY(0);
  }
}
.listen-swipe-hint__stage {
  position: relative;
  width: 4.6rem;
  height: 5.6rem;
  filter: drop-shadow(0 8px 16px rgba(0, 0, 0, 0.35));
}
.listen-swipe-hint__page {
  position: absolute;
  inset: 0;
  border-radius: 0.7rem;
  border: 1px solid rgba(255, 255, 255, 0.35);
}
.listen-swipe-hint__page--next {
  background: rgba(255, 255, 255, 0.16);
  transform: translateY(18%);
}
.listen-swipe-hint__page--current {
  background: rgba(255, 255, 255, 0.92);
  animation: listen-swipe-page 1.35s ease-in-out infinite;
}
.listen-swipe-hint__finger {
  position: absolute;
  left: 50%;
  bottom: 18%;
  width: 0.7rem;
  height: 0.7rem;
  margin-left: -0.35rem;
  border-radius: 999px;
  background: #2563eb;
  box-shadow: 0 0 0 6px rgba(37, 99, 235, 0.22);
  animation: listen-swipe-finger 1.35s ease-in-out infinite;
}
@keyframes listen-swipe-page {
  0%,
  12% {
    transform: translateY(0);
    opacity: 1;
  }
  55% {
    transform: translateY(-58%);
    opacity: 0.35;
  }
  100% {
    transform: translateY(0);
    opacity: 1;
  }
}
@keyframes listen-swipe-finger {
  0%,
  12% {
    transform: translateY(0);
    opacity: 1;
  }
  55% {
    transform: translateY(-1.7rem);
    opacity: 0.15;
  }
  100% {
    transform: translateY(0);
    opacity: 1;
  }
}
</style>
