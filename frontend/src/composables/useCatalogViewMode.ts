import { ref, watch } from 'vue'

export type CatalogViewMode = 'card' | 'list'

const STORAGE_KEY = 'catalog_view_mode'

function readStoredMode(): CatalogViewMode {
  const value = localStorage.getItem(STORAGE_KEY)
  return value === 'list' ? 'list' : 'card'
}

const viewMode = ref<CatalogViewMode>(readStoredMode())

watch(viewMode, (mode) => {
  localStorage.setItem(STORAGE_KEY, mode)
})

export function useCatalogViewMode() {
  function setViewMode(mode: CatalogViewMode) {
    viewMode.value = mode
  }

  return { viewMode, setViewMode }
}
