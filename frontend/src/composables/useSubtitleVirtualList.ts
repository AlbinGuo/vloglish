import { computed, nextTick, onUnmounted, ref, watch, type ComputedRef, type Ref } from 'vue'

/** 字幕列表虚拟滚动：只渲染可视区附近的句子，避免长视频上万节点卡顿。 */
export function useSubtitleVirtualList(opts: {
  containerRef: Ref<HTMLElement | null>
  count: ComputedRef<number>
  estimatePx?: number
  gapPx?: number
  overscan?: number
  remeasureKey?: ComputedRef<unknown>
}) {
  const estimatePx = opts.estimatePx ?? 104
  const gapPx = opts.gapPx ?? 8
  const overscan = opts.overscan ?? 8

  const scrollTop = ref(0)
  const viewportH = ref(0)
  const heights = ref<number[]>([])

  let scrollBound: HTMLElement | null = null
  let ro: ResizeObserver | null = null

  function rowStride(i: number) {
    return (heights.value[i] || estimatePx) + gapPx
  }

  function offsetOf(index: number) {
    const n = Math.max(0, Math.min(index, opts.count.value))
    let y = 0
    for (let i = 0; i < n; i++) y += rowStride(i)
    return y
  }

  function findStart(y: number) {
    const n = opts.count.value
    if (n <= 0) return 0
    let acc = 0
    for (let i = 0; i < n; i++) {
      const h = rowStride(i)
      if (acc + h > y) return i
      acc += h
    }
    return n - 1
  }

  const range = computed(() => {
    const n = opts.count.value
    if (n <= 0) return { start: 0, end: 0 }
    const start = Math.max(0, findStart(scrollTop.value) - overscan)
    const limit = scrollTop.value + Math.max(viewportH.value, 1)
    let acc = offsetOf(start)
    let end = start
    while (end < n && acc < limit) {
      acc += rowStride(end)
      end += 1
    }
    return { start, end: Math.min(n, end + overscan) }
  })

  const padTop = computed(() => offsetOf(range.value.start))
  const padBottom = computed(() => Math.max(0, offsetOf(opts.count.value) - offsetOf(range.value.end)))

  function onScroll() {
    const el = opts.containerRef.value
    if (!el) return
    scrollTop.value = el.scrollTop
    viewportH.value = el.clientHeight
  }

  function measure() {
    const el = opts.containerRef.value
    if (!el) return
    viewportH.value = el.clientHeight
    const nodes = el.querySelectorAll<HTMLElement>('[data-sub-index]')
    if (!nodes.length) return
    const next = heights.value.slice()
    let changed = false
    nodes.forEach((node) => {
      const i = Number(node.dataset.subIndex)
      if (!Number.isFinite(i) || i < 0) return
      const h = node.offsetHeight
      if (h > 0 && next[i] !== h) {
        next[i] = h
        changed = true
      }
    })
    if (changed) heights.value = next
  }

  function unbind() {
    if (scrollBound) {
      scrollBound.removeEventListener('scroll', onScroll)
      scrollBound = null
    }
    ro?.disconnect()
    ro = null
  }

  function bind() {
    unbind()
    const el = opts.containerRef.value
    if (!el) return
    scrollBound = el
    el.addEventListener('scroll', onScroll, { passive: true })
    viewportH.value = el.clientHeight
    scrollTop.value = el.scrollTop
    if (typeof ResizeObserver !== 'undefined') {
      ro = new ResizeObserver(() => {
        viewportH.value = el.clientHeight
        measure()
      })
      ro.observe(el)
    }
    nextTick(measure)
  }

  watch(
    () => opts.containerRef.value,
    () => bind(),
    { flush: 'post' },
  )

  watch(
    () => opts.count.value,
    (n) => {
      heights.value = new Array<number>(n).fill(0)
      nextTick(measure)
    },
  )

  watch(
    () => [range.value.start, range.value.end, opts.remeasureKey?.value] as const,
    () => nextTick(measure),
  )

  onUnmounted(unbind)

  return {
    range,
    padTop,
    padBottom,
    offsetOf,
    measure,
  }
}
