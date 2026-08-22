import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useFavoriteToastStore = defineStore('favoriteToast', () => {
  const visible = ref(false)
  const added = ref(true)
  const title = ref('')
  let timer: ReturnType<typeof setTimeout> | null = null

  function hide() {
    visible.value = false
    if (timer != null) {
      clearTimeout(timer)
      timer = null
    }
  }

  function show(nextAdded: boolean, episodeTitle = '') {
    added.value = nextAdded
    title.value = episodeTitle.trim()
    visible.value = false
    requestAnimationFrame(() => {
      visible.value = true
    })
    if (timer != null) clearTimeout(timer)
    timer = setTimeout(hide, nextAdded ? 4800 : 2600)
  }

  return { visible, added, title, show, hide }
})
