<script setup lang="ts">
import { onUnmounted, ref, watch } from 'vue'
import { fetchBindWechatQr, fetchBindWechatStatus, prepareBindWechat } from '@/api/auth'
import { useAuthStore } from '@/stores/auth'
import { getErrorDetail } from '@/api/tokens'

const open = defineModel<boolean>('open', { default: false })
const auth = useAuthStore()
const loading = ref(false)
const error = ref('')
const qrUrl = ref('')
const hint = ref('微信扫码后，在小程序里确认绑定')
let timer: ReturnType<typeof setInterval> | undefined
let objectUrl = ''

function stop() {
  if (timer) {
    clearInterval(timer)
    timer = undefined
  }
  if (objectUrl) {
    URL.revokeObjectURL(objectUrl)
    objectUrl = ''
  }
  qrUrl.value = ''
}

async function start() {
  stop()
  error.value = ''
  loading.value = true
  try {
    const { token } = await prepareBindWechat()
    const blob = await fetchBindWechatQr(token)
    objectUrl = URL.createObjectURL(blob)
    qrUrl.value = objectUrl
    hint.value = '打开微信扫一扫，确认后网页会自动更新'
    timer = setInterval(async () => {
      try {
        const st = await fetchBindWechatStatus(token)
        if (st.status === 'bound') {
          if (st.user) auth.user = st.user
          else await auth.fetchMe()
          stop()
          open.value = false
        } else if (st.status === 'expired') {
          error.value = '二维码已过期，请关闭后重试'
          stop()
        }
      } catch {
        /* ignore poll errors */
      }
    }, 2000)
  } catch (e) {
    error.value = getErrorDetail(e) || '无法生成小程序码'
  } finally {
    loading.value = false
  }
}

watch(open, (v) => {
  if (v) void start()
  else stop()
})

onUnmounted(stop)
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[80] flex items-center justify-center bg-black/40 px-4"
      @click.self="open = false"
    >
      <div class="w-full max-w-sm rounded-2xl bg-white dark:bg-neutral-900 p-5 shadow-xl">
        <h2 class="text-base font-semibold text-neutral-900 dark:text-white">绑定微信</h2>
        <p class="mt-1 text-sm text-neutral-500 leading-relaxed">{{ hint }}</p>
        <div class="mt-4 flex justify-center min-h-[11rem] items-center">
          <p v-if="loading" class="text-sm text-neutral-400">正在生成小程序码…</p>
          <img v-else-if="qrUrl" :src="qrUrl" alt="绑定小程序码" class="w-44 h-44 rounded-lg bg-white" />
        </div>
        <p v-if="error" class="mt-2 text-sm text-red-600">{{ error }}</p>
        <button
          type="button"
          class="mt-4 w-full py-2 rounded-lg text-sm bg-neutral-100 dark:bg-neutral-800"
          @click="open = false"
        >
          关闭
        </button>
      </div>
    </div>
  </Teleport>
</template>
