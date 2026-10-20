<script setup lang="ts">
import { useListenPlayerStore } from '@/stores/listenPlayer'
import { formatListenTime } from '@/utils/formatListenTime'

const listen = useListenPlayerStore()

const options = [
  { minutes: 15, label: '15 分钟' },
  { minutes: 30, label: '30 分钟' },
  { minutes: 45, label: '45 分钟' },
  { minutes: 60, label: '60 分钟' },
]

function close() {
  listen.sleepOpen = false
}

function pick(minutes: number | null) {
  listen.setSleepMinutes(minutes)
  close()
}

function pickAfterCurrent() {
  listen.setSleepAfterCurrent()
  close()
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="listen.sleepOpen"
      class="fixed inset-0 z-[80] flex flex-col justify-end bg-black/45"
      @click.self="close"
    >
      <div
        class="rounded-t-2xl bg-white dark:bg-neutral-900 pb-[max(0.75rem,env(safe-area-inset-bottom))]"
        @click.stop
      >
        <div class="flex justify-center pt-3 pb-1">
          <div class="w-10 h-1 rounded-full bg-neutral-300 dark:bg-neutral-600" />
        </div>
        <div class="px-5 py-2 flex items-center justify-between">
          <h2 class="text-base font-semibold">定时关闭</h2>
          <p v-if="listen.sleepEndsAt" class="text-sm text-amber-700 dark:text-amber-300 tabular-nums">
            剩余 {{ formatListenTime(listen.sleepLeftSec) }}
          </p>
        </div>
        <div class="px-3 pb-2">
          <button
            type="button"
            class="w-full text-left px-4 py-3.5 text-sm rounded-xl hover:bg-sunken"
            @click="pickAfterCurrent"
          >
            播完这一集
          </button>
          <button
            v-for="opt in options"
            :key="opt.minutes"
            type="button"
            class="w-full text-left px-4 py-3.5 text-sm rounded-xl hover:bg-sunken"
            @click="pick(opt.minutes)"
          >
            {{ opt.label }}
          </button>
          <button
            type="button"
            class="w-full text-left px-4 py-3.5 text-sm rounded-xl text-neutral-500 hover:bg-sunken"
            @click="pick(null)"
          >
            关闭定时
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
