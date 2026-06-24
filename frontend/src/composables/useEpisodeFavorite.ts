import { ref, watch, type Ref } from 'vue'
import { setEpisodeFavorite } from '@/api/episodes'
import type { EpisodeSummary } from '@/types'

export function useEpisodeFavorite(episode: Ref<EpisodeSummary>) {
  const favorited = ref(episode.value.is_favorite ?? false)
  const loading = ref(false)

  watch(
    () => episode.value.is_favorite,
    (value) => {
      favorited.value = value ?? false
    },
  )

  async function toggle(e?: Event) {
    e?.preventDefault()
    e?.stopPropagation()
    if (loading.value) return

    const next = !favorited.value
    favorited.value = next
    loading.value = true
    try {
      const res = await setEpisodeFavorite(episode.value.video_id, next)
      favorited.value = res.is_favorite
      episode.value.is_favorite = res.is_favorite
    } catch {
      favorited.value = !next
    } finally {
      loading.value = false
    }
  }

  return { favorited, loading, toggle }
}
