/** 阅读页段落块（含 data-reading-segment-id） */
export function resolveReadingSegmentBlock(target: HTMLElement): HTMLElement | null {
  return target.closest('[data-reading-segment-id]') as HTMLElement | null
}

/**
 * 查词上下文：优先取渲染后的英文正文（与点击查词一致），
 * 回退到 data-reading-context（segment.english）。
 */
export function resolveReadingContext(target: HTMLElement): string {
  const block = resolveReadingSegmentBlock(target)
  const fromDom = block?.querySelector('.subtitle-english')?.textContent?.trim()
  if (fromDom) return fromDom
  return block?.dataset.readingContext?.trim() ?? ''
}

export function resolveReadingSegmentId(target: HTMLElement): number | undefined {
  const block = resolveReadingSegmentBlock(target)
  const rawId = block?.dataset.readingSegmentId
  return rawId ? Number(rawId) : undefined
}
