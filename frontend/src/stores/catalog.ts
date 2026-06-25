import { defineStore } from 'pinia'
import { computed, reactive, ref } from 'vue'
import { getAuthorAccents, getEpisodeList, getEpisodeTags } from '@/api/episodes'
import type { EpisodeSummary, Tag } from '@/types'

export type CatalogListViewMode = 'card' | 'list'

export const CARD_INITIAL_SIZE = 12
export const LIST_INITIAL_SIZE = 8
export const LOAD_MORE_SIZE = 8

export interface CatalogFilters {
  stars: number | undefined
  accents: string[]
  tagIds: number[]
  ordering: string
  date: string | undefined
  search: string
}

function defaultFilters(): CatalogFilters {
  return {
    stars: undefined,
    accents: [],
    tagIds: [],
    ordering: 'created_at',
    date: undefined,
    search: '',
  }
}

function initialSizeForMode(mode: CatalogListViewMode) {
  return mode === 'card' ? CARD_INITIAL_SIZE : LIST_INITIAL_SIZE
}

export const useCatalogStore = defineStore('catalog', () => {
  const episodes = ref<EpisodeSummary[]>([])
  const total = ref(0)
  const loading = ref(false)
  const loadingMore = ref(false)
  const tags = ref<Tag[]>([])
  const accents = ref<string[]>([])
  const listViewMode = ref<CatalogListViewMode>('card')

  const filters = reactive(defaultFilters())

  const hasMore = computed(() => episodes.value.length < total.value)

  async function loadFilters() {
    const [t, a] = await Promise.all([getEpisodeTags(), getAuthorAccents()])
    tags.value = t
    accents.value = a
  }

  function buildParams(
    f: CatalogFilters,
    options: { pageSize: number; offset: number },
  ): Record<string, string | number> {
    const params: Record<string, string | number> = {
      page_size: options.pageSize,
      offset: options.offset,
      page: 1,
      ordering: f.ordering,
    }
    if (f.stars) params.stars = f.stars
    if (f.accents.length) params.accents = f.accents.join(',')
    if (f.tagIds.length) params.tags = f.tagIds.join(',')
    if (f.date) params.date = f.date
    if (f.search) params.search = f.search
    return params
  }

  function setListViewMode(mode: CatalogListViewMode) {
    listViewMode.value = mode
  }

  async function loadEpisodes(reset = false) {
    if (reset) {
      episodes.value = []
      total.value = 0
    }
    loading.value = true
    try {
      const pageSize = initialSizeForMode(listViewMode.value)
      const data = await getEpisodeList(buildParams(filters, { pageSize, offset: 0 }))
      episodes.value = data.results
      total.value = data.count
    } finally {
      loading.value = false
    }
  }

  async function loadMoreEpisodes() {
    if (loading.value || loadingMore.value || !hasMore.value) return
    loadingMore.value = true
    try {
      const data = await getEpisodeList(
        buildParams(filters, {
          pageSize: LOAD_MORE_SIZE,
          offset: episodes.value.length,
        }),
      )
      total.value = data.count
      const seen = new Set(episodes.value.map((ep) => ep.video_id))
      const fresh = data.results.filter((ep) => !seen.has(ep.video_id))
      episodes.value = [...episodes.value, ...fresh]
    } finally {
      loadingMore.value = false
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
    filters.ordering = filters.ordering === 'created_at' ? '-created_at' : 'created_at'
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
    loadingMore,
    hasMore,
    tags,
    accents,
    filters,
    listViewMode,
    loadFilters,
    setListViewMode,
    loadEpisodes,
    loadMoreEpisodes,
    setDateFilter,
    toggleStars,
    toggleAccent,
    toggleTag,
    toggleOrdering,
    setSearch,
  }
})
