import { onUnmounted, ref } from 'vue'

/** 生词「回看」定位后的短暂高亮（默认约 5 秒后消退） */
export function useSourceFocusPulse(durationMs = 5000) {
  const focusId = ref<number | null>(null)
  const focusWord = ref('')
  let timer: ReturnType<typeof setTimeout> | null = null

  function clear() {
    if (timer != null) {
      clearTimeout(timer)
      timer = null
    }
    focusId.value = null
    focusWord.value = ''
  }

  function trigger(id: number, word = '') {
    clear()
    focusId.value = id
    focusWord.value = (word || '').trim()
    timer = setTimeout(() => {
      focusId.value = null
      focusWord.value = ''
      timer = null
    }, durationMs)
  }

  function isFocused(id: number | null | undefined) {
    return focusId.value != null && id != null && focusId.value === id
  }

  onUnmounted(clear)

  return { focusId, focusWord, trigger, clear, isFocused }
}
