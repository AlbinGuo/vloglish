import { defineStore } from 'pinia'
import { reactive, ref } from 'vue'
import { getAuthorAccents, getEpisodeList, getEpisodeTags } from '@/api/episodes'
import type { EpisodeSummary, Tag } from '@/types'

export interface CatalogFilters {
  page: number
  page_size: number
  stars: number | undefined
  accents: string[]
  tagIds: number[]
  ordering: string
  date: string | undefined
  search: string
}

function defaultFilters(): CatalogFilters {
  return {
    page: 1,
    page_size: 50,
    stars: undefined,
    accents: [],
    tagIds: [],
    ordering: 'index',
    date: undefined,
    search: '',
  }
}

export const useCatalogStore = defineStore('catalog', () => {
  const episodes = ref<EpisodeSummary[]>([])
  const total = ref(0)
  const loading = ref(false)
  const tags = ref<Tag[]>([])
  const accents = ref<string[]>([])

  const filters = reactive(defaultFilters())

  async function loadFilters() {
    const [t, a] = await Promise.all([getEpisodeTags(), getAuthorAccents()])
    tags.value = t
    accents.value = a
  }

  function buildParams(f: CatalogFilters): Record<string, string | number> {
    const params: Record<string, string | number> = {
      page: f.page,
      page_size: f.page_size,
      ordering: f.ordering,
    }
    if (f.stars) params.stars = f.stars
    if (f.accents.length) params.accents = f.accents.join(',')
    if (f.tagIds.length) params.tags = f.tagIds.join(',')
    if (f.date) params.date = f.date
    if (f.search) params.search = f.search
    return params
  }

  async function loadEpisodes(resetPage = false) {
    if (resetPage) filters.page = 1
    loading.value = true
    try {
      const data = await getEpisodeList(buildParams(filters))
      episodes.value = data.results
      total.value = data.count
    } finally {
      loading.value = false
    }
  }

  function setDateFilter(date: string | undefined) {
    filters.date = date
    return loadEpisodes(true)
  }

  function toggleStars(level: number) {
    filters.stars = filters.stars === level ? undefined : level
    return loadEpisodes(true)
  }

  function toggleAccent(accent: string) {
    const idx = filters.accents.indexOf(accent)
    if (idx >= 0) filters.accents.splice(idx, 1)
    else filters.accents.push(accent)
    return loadEpisodes(true)
  }

  function toggleTag(id: number) {
    const idx = filters.tagIds.indexOf(id)
    if (idx >= 0) filters.tagIds.splice(idx, 1)
    else filters.tagIds.push(id)
    return loadEpisodes(true)
  }

  function toggleOrdering() {
    filters.ordering = filters.ordering === 'index' ? '-index' : 'index'
    return loadEpisodes(true)
  }

  function setSearch(query: string) {
    filters.search = query
    return loadEpisodes(true)
  }

  return {
    episodes,
    total,
    loading,
    tags,
    accents,
    filters,
    loadFilters,
    loadEpisodes,
    setDateFilter,
    toggleStars,
    toggleAccent,
    toggleTag,
    toggleOrdering,
    setSearch,
  }
})
