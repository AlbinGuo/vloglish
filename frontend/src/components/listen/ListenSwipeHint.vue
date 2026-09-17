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
          viewBox="-70 -96 230 230"
          width="128"
          height="128"
          aria-hidden="true"
        >
          <path
            fill="#fff"
            d="M48.512001037597656,-41.6719970703125 C48.512001037597656,-41.6719970703125 48.512001037597656,41.6719970703125 48.512001037597656,41.6719970703125 C48.512001037597656,68.44577026367188 26.773773193359375,90.18399810791016 0,90.18399810791016 C0,90.18399810791016 0,90.18399810791016 0,90.18399810791016 C-26.773773193359375,90.18399810791016 -48.512001037597656,68.44577026367188 -48.512001037597656,41.6719970703125 C-48.512001037597656,41.6719970703125 -48.512001037597656,-41.6719970703125 -48.512001037597656,-41.6719970703125 C-48.512001037597656,-68.44577026367188 -26.773773193359375,-90.18399810791016 0,-90.18399810791016 C0,-90.18399810791016 0,-90.18399810791016 0,-90.18399810791016 C26.773773193359375,-90.18399810791016 48.512001037597656,-68.44577026367188 48.512001037597656,-41.6719970703125z"
          />
          <rect x="-3.5" y="-58" width="7" height="28" rx="3.5" fill="#c8c8cc" />
          <g class="listen-swipe-hint__hand">
            <g transform="translate(-36,-8) scale(0.56)">
              <g transform="matrix(1,0,0,1,84.54600524902344,114.55500030517578)">
                <path
                  fill="#fff"
                  d="M101.375,-82.75 C95.2020034790039,-81.04000091552734 91,-72.375 91.625,-67.75 C92.25,-63.125 121.25,27.625 119.75,29.25 C117.5,30.5 111.375,16 101.75,9.5 C92.25,3.0850000381469727 70.25,9 72.75,16.5 C74.72599792480469,22.429000854492188 122.25,92.375 126.75,98 C130.61700439453125,102.83300018310547 150.75,120.5 174.75,120.25 C198.75,120 224.86700439453125,106.12300109863281 236,85 C245.75,66.5 245.625,54.5 242.125,37.75 C240.22799682617188,28.66900062561035 227.375,-12.75 226.125,-16.25 C224.875,-19.75 219.77099609375,-25.989999771118164 212.625,-26.5 C203.875,-27.125 199.375,-20.5 198.125,-20.625 C196.10000610351562,-20.82699966430664 192.875,-28 182.625,-28 C174.11700439453125,-28 170.25,-20.125 168,-19.875 C165.75,-19.625 163.5,-29 152.875,-29.125 C140.7969970703125,-29.267000198364258 138.5,-21.75 136.25,-20.375 C134.875,-25.25 120.42900085449219,-70.88999938964844 119.375,-74.625 C118,-79.5 109.5,-85 101.375,-82.75z"
                />
              </g>
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
  transform-origin: 30% 80%;
  animation: listen-index-swipe 1.4s ease-in-out infinite;
}
@media (prefers-reduced-motion: reduce) {
  .listen-swipe-hint__hand {
    animation: none;
  }
}
@keyframes listen-index-swipe {
  0%,
  12% {
    transform: translateY(10px);
  }
  50% {
    transform: translateY(-16px);
  }
  100% {
    transform: translateY(10px);
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
