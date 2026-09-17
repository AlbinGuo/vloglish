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
          class="listen-swipe-hint__combo"
          viewBox="0 0 160 176"
          width="124"
          height="136"
          aria-hidden="true"
        >
          <rect x="54" y="6" width="52" height="92" rx="26" fill="#fff" />
          <rect x="76" y="22" width="8" height="26" rx="4" fill="#c4c4c8" />
          <g class="listen-swipe-hint__hand">
            <ellipse cx="88" cy="128" rx="30" ry="22" fill="#fff" />
            <rect x="62" y="104" width="50" height="34" rx="17" fill="#fff" />
            <rect
              x="22"
              y="108"
              width="42"
              height="17"
              rx="8.5"
              fill="#fff"
              transform="rotate(-30 43 116.5)"
            />
            <rect x="94" y="98" width="18" height="34" rx="9" fill="#fff" />
            <rect x="106" y="104" width="16" height="30" rx="8" fill="#fff" />
            <g class="listen-swipe-hint__index">
              <rect x="70" y="38" width="18" height="74" rx="9" fill="#fff" />
            </g>
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
.listen-swipe-hint__combo {
  overflow: visible;
  filter: drop-shadow(0 8px 16px rgb(0 0 0 / 0.22));
}
.listen-swipe-hint__hand {
  transform-box: fill-box;
  transform-origin: 70% 80%;
}
.listen-swipe-hint__index {
  transform-box: fill-box;
  transform-origin: 50% 100%;
  animation: listen-index-swipe 1.4s ease-in-out infinite;
}
@media (prefers-reduced-motion: reduce) {
  .listen-swipe-hint__index {
    animation: none;
  }
}
@keyframes listen-index-swipe {
  0%,
  12% {
    transform: translateY(6px);
  }
  50% {
    transform: translateY(-18px);
  }
  100% {
    transform: translateY(6px);
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
