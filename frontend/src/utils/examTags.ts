export const EXAM_TAG_LABELS: Record<string, string> = {
  CET4: '四级',
  CET6: '六级',
  TEM4: '专四',
  TEM8: '专八',
  TOEFL: '托福',
  IELTS: '雅思',
  GRE: 'GRE',
}

export function asExamTagList(tags: unknown): string[] {
  if (!Array.isArray(tags)) return []
  return tags.filter((tag): tag is string => typeof tag === 'string' && tag.trim().length > 0)
}

export function formatExamTags(tags: unknown): { key: string; label: string }[] {
  return asExamTagList(tags)
    .map((tag) => {
      const key = tag.toUpperCase().replace(/-/g, '')
      return { key, label: EXAM_TAG_LABELS[key] ?? tag }
    })
    .filter((item) => item.label.length > 0)
}
