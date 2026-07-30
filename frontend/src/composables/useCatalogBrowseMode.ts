import { ref, watch } from 'vue'

export type CatalogBrowseMode = 'all' | 'author'

const STORAGE_KEY = 'catalog_browse_mode'

function readStoredMode(): CatalogBrowseMode {
  return localStorage.getItem(STORAGE_KEY) === 'author' ? 'author' : 'all'
}

const browseMode = ref<CatalogBrowseMode>(readStoredMode())

watch(browseMode, (mode) => {
  localStorage.setItem(STORAGE_KEY, mode)
})

export function useCatalogBrowseMode() {
  function setBrowseMode(mode: CatalogBrowseMode) {
    browseMode.value = mode
  }

  return { browseMode, setBrowseMode }
}
