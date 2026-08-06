/** 练习点评口播文案（精简：分数 + 等级 + 点评 + 可选一句建议） */
export function buildPracticeFeedbackSpeech(r: {
  score?: number | null
  level?: string | null
  praise?: string | null
  tips?: string[] | null
}): string {
  const score = Math.max(0, Math.min(100, Number(r.score) || 0))
  const level = (r.level || '').trim() || '已完成'
  const praise = (r.praise || '').trim()
  const tip = (r.tips || []).map((t) => String(t || '').trim()).find(Boolean) || ''
  let text = `本次得分 ${score} 分，评价${level}。`
  if (praise) {
    text += praise
    if (!/[。！？]$/.test(praise)) text += '。'
  }
  if (tip) text += `建议：${tip}`
  return text.slice(0, 400)
}
