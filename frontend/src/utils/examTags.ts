export const EXAM_TAG_LABELS: Record<string, string> = {
  CET4: '四级',
  CET6: '六级',
  TEM4: '专四',
  TEM8: '专八',
  TOEFL: '托福',
  IELTS: '雅思',
  GRE: 'GRE',
}

/** 考试标签配色：浅底 + 深字（含 dark） */
export const EXAM_TAG_CLASSES: Record<string, string> = {
  CET4: 'bg-emerald-50 text-emerald-700 dark:bg-emerald-950/45 dark:text-emerald-300',
  CET6: 'bg-teal-50 text-teal-700 dark:bg-teal-950/45 dark:text-teal-300',
  TEM4: 'bg-amber-50 text-amber-700 dark:bg-amber-950/45 dark:text-amber-300',
  TEM8: 'bg-orange-50 text-orange-700 dark:bg-orange-950/45 dark:text-orange-300',
  IELTS: 'bg-sky-50 text-sky-700 dark:bg-sky-950/45 dark:text-sky-300',
  TOEFL: 'bg-indigo-50 text-indigo-700 dark:bg-indigo-950/45 dark:text-indigo-300',
  GRE: 'bg-rose-50 text-rose-700 dark:bg-rose-950/45 dark:text-rose-300',
}

const EXAM_TAG_FALLBACK_CLASS =
  'bg-blue-50 text-blue-700 dark:bg-blue-950/45 dark:text-blue-300'

export function examTagClass(keyOrLabel: string): string {
  const key = keyOrLabel.toUpperCase().replace(/-/g, '')
  if (EXAM_TAG_CLASSES[key]) return EXAM_TAG_CLASSES[key]
  // 也支持按中文展示名查找
  const byLabel = Object.entries(EXAM_TAG_LABELS).find(([, label]) => label === keyOrLabel)
  if (byLabel) return EXAM_TAG_CLASSES[byLabel[0]] ?? EXAM_TAG_FALLBACK_CLASS
  return EXAM_TAG_FALLBACK_CLASS
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
