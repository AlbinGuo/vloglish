import { defineStore } from 'pinia'
import { reactive, ref } from 'vue'
import { getAuthorAccents, getEpisodeList, getEpisodeTags } from '@/api/episodes'
import type { EpisodeSummary, Tag } from '@/types'

export const useCatalogStore = defineStore('catalog', () => {
  const episodes = ref<EpisodeSummary[]>([])
  const total = ref(0)
  const loading = ref(false)
  const tags = ref<Tag[]>([])
  const accents = ref<string[]>([])

  const filters = reactive({
    page: 1,
    page_size: 12,
    stars: undefined as number | undefined,
    accent: undefined as string | undefined,
    gender: undefined as string | undefined,
    tag: undefined as number | undefined,
    ordering: 'index',
  })

  async function loadFilters() {
    const [t, a] = await Promise.all([getEpisodeTags(), getAuthorAccents()])
    tags.value = t
    accents.value = a
  }

  async function loadEpisodes(resetPage = false) {
    if (resetPage) filters.page = 1
    loading.value = true
    try {
      const params: Record<string, string | number> = {
        page: filters.page,
        page_size: filters.page_size,
        ordering: filters.ordering,
      }
      if (filters.stars) params.stars = filters.stars
      if (filters.accent) params.accent = filters.accent
      if (filters.gender) params.gender = filters.gender
      if (filters.tag) params.tag = filters.tag

      const data = await getEpisodeList(params)
      episodes.value = data.results
      total.value = data.count
    } finally {
      loading.value = false
    }
  }

  function clearFilters() {
    filters.stars = undefined
    filters.accent = undefined
    filters.gender = undefined
    filters.tag = undefined
    filters.ordering = 'index'
  }

  return { episodes, total, loading, tags, accents, filters, loadFilters, loadEpisodes, clearFilters }
})
