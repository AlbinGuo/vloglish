import { ref, watch } from 'vue'

const STORAGE_KEY = 'catalog_sidebar_collapsed'

function readStored(): boolean {
  return localStorage.getItem(STORAGE_KEY) === '1'
}

const collapsed = ref(readStored())

watch(collapsed, (value) => {
  localStorage.setItem(STORAGE_KEY, value ? '1' : '0')
})

export function useCatalogSidebar() {
  function setCollapsed(value: boolean) {
    collapsed.value = value
  }

  function toggle() {
    collapsed.value = !collapsed.value
  }

  return { collapsed, setCollapsed, toggle }
}
