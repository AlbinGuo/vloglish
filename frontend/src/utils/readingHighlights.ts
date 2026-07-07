export interface HighlightToken {
  word: string
  type: 1 | 2
}

export function extractHighlightTokens(html: string): HighlightToken[] {
  if (!html?.trim()) return []

  const doc = new DOMParser().parseFromString(html, 'text/html')
  const spans = doc.querySelectorAll('span.highlight')
  const seen = new Set<string>()
  const result: HighlightToken[] = []

  spans.forEach((span) => {
    const word = span.textContent?.trim().replace(/\s+/g, ' ')
    if (!word) return

    const key = word.toLowerCase()
    if (seen.has(key)) return
    seen.add(key)

    const isPhrase = span.hasAttribute('pid') || span.classList.contains('phrase-token')
    result.push({ word, type: isPhrase ? 2 : 1 })
  })

  return result
}
