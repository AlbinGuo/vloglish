<script setup lang="ts">
defineEmits<{ close: [] }>()

const shortcuts = [
  ['空格', '播放 / 暂停'],
  ['← / →', '上一句 / 下一句'],
  ['↑ / ↓', '加快 / 减慢倍速'],
  ['L', '切换单句循环'],
  ['R', '重播当前句'],
  ['[ / ]', '设置 A / B 循环点'],
  ['Esc', '清除 A-B 循环 / 关闭帮助'],
  ['?', '显示快捷键帮助'],
]
</script>

<template>
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="$emit('close')">
    <div class="bg-white rounded-2xl shadow-xl w-full max-w-md p-6">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-semibold">键盘快捷键</h3>
        <button class="text-neutral-400 hover:text-black text-xl" @click="$emit('close')">×</button>
      </div>
      <dl class="space-y-2">
        <div v-for="[key, desc] in shortcuts" :key="key" class="flex justify-between gap-4 text-sm">
          <dt class="font-mono bg-neutral-100 px-2 py-0.5 rounded shrink-0">{{ key }}</dt>
          <dd class="text-neutral-600 text-right">{{ desc }}</dd>
        </div>
      </dl>
    </div>
  </div>
</template>
