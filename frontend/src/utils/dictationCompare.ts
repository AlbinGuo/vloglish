/** 听写文本宽松归一化与比对 */

export function normalizeDictationText(input: string): string {
  return input
    .toLowerCase()
    .replace(/[\u2018\u2019\u201A\uFF07]/g, "'")
    .replace(/[\u201C\u201D\u201E]/g, '"')
    .replace(/[^\p{L}\p{N}'\s]/gu, ' ')
    .replace(/\s+/g, ' ')
    .trim()
}

/** 按空格拆成听写词槽（忽略标点） */
export function splitDictationSlots(english: string): string[] {
  return normalizeDictationText(english).split(' ').filter(Boolean)
}

export function dictationWordMatches(answer: string, expected: string): boolean {
  return normalizeDictationText(answer) === normalizeDictationText(expected)
}

export function dictationMatches(answer: string, expected: string): boolean {
  const a = normalizeDictationText(answer)
  const e = normalizeDictationText(expected)
  if (!e) return !a
  return a === e
}

export type DictationWordMark = {
  text: string
  ok: boolean
}

/** 按固定词槽对照用户填写 */
export function markDictationSlots(answers: string[], expectedWords: string[]): DictationWordMark[] {
  return expectedWords.map((word, i) => ({
    text: word,
    ok: dictationWordMatches(answers[i] ?? '', word),
  }))
}

/** 按词粗略对照：用户多写/少写时尽量对齐期望句 */
export function diffDictationWords(answer: string, expected: string): DictationWordMark[] {
  const aWords = normalizeDictationText(answer).split(' ').filter(Boolean)
  const eWords = normalizeDictationText(expected).split(' ').filter(Boolean)
  if (!eWords.length) return []

  const result: DictationWordMark[] = []
  let ai = 0
  for (const ew of eWords) {
    if (ai < aWords.length && aWords[ai] === ew) {
      result.push({ text: ew, ok: true })
      ai += 1
    } else if (ai < aWords.length) {
      let found = -1
      for (let j = ai; j < Math.min(ai + 3, aWords.length); j++) {
        if (aWords[j] === ew) {
          found = j
          break
        }
      }
      if (found >= 0) {
        ai = found + 1
        result.push({ text: ew, ok: true })
      } else {
        result.push({ text: ew, ok: false })
      }
    } else {
      result.push({ text: ew, ok: false })
    }
  }
  return result
}
