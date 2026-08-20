import { computed, ref, watch, type MaybeRefOrGetter, toValue } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { setAuthorSubscribe } from '@/api/episodes'
import { useAuthStore } from '@/stores/auth'

export function useAuthorSubscribe(
  authorId: MaybeRefOrGetter<number | undefined>,
  initialSubscribed: MaybeRefOrGetter<boolean | undefined> = false,
  initialCount: MaybeRefOrGetter<number | undefined> = 0,
) {
  const auth = useAuthStore()
  const router = useRouter()
  const route = useRoute()
  const subscribed = ref(Boolean(toValue(initialSubscribed)))
  const subscriberCount = ref(Math.max(0, Number(toValue(initialCount) || 0)))
  const loading = ref(false)

  watch(
    () => [toValue(authorId), toValue(initialSubscribed), toValue(initialCount)] as const,
    ([, nextSubscribed, nextCount]) => {
      subscribed.value = Boolean(nextSubscribed)
      subscriberCount.value = Math.max(0, Number(nextCount || 0))
    },
  )

  async function toggle() {
    const id = Number(toValue(authorId) || 0)
    if (!id || loading.value) return false
    if (!auth.isLoggedIn) {
      router.push({ path: '/login', query: { next: route.fullPath } })
      return false
    }

    const next = !subscribed.value
    subscribed.value = next
    subscriberCount.value = Math.max(0, subscriberCount.value + (next ? 1 : -1))
    loading.value = true
    try {
      const res = await setAuthorSubscribe(id, next)
      subscribed.value = res.is_subscribed
      subscriberCount.value = res.subscriber_count
      return true
    } catch {
      subscribed.value = !next
      subscriberCount.value = Math.max(0, subscriberCount.value + (next ? -1 : 1))
      return false
    } finally {
      loading.value = false
    }
  }

  const label = computed(() => (subscribed.value ? '已关注' : '关注'))

  return { subscribed, subscriberCount, loading, toggle, label }
}
