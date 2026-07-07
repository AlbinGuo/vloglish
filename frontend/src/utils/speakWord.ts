/** 浏览器即时朗读单词/短语（speechSynthesis 兜底） */

export function speechSynthesisSupported(): boolean {
  return typeof window !== 'undefined' && 'speechSynthesis' in window
}

export function stopSpeaking() {
  if (!speechSynthesisSupported()) return
  window.speechSynthesis.cancel()
}

export function speakText(text: string, options?: { rate?: number; lang?: string }): boolean {
  if (!speechSynthesisSupported()) return false
  const trimmed = text.trim()
  if (!trimmed) return false

  stopSpeaking()
  const utter = new SpeechSynthesisUtterance(trimmed)
  utter.lang = options?.lang ?? 'en-US'
  utter.rate = options?.rate ?? 0.92
  window.speechSynthesis.speak(utter)
  return true
}

/** 优先播放 URL，无 URL 时用 speechSynthesis */
export function playWordPronunciation(word: string, audioUrl?: string | null, rate = 0.92): boolean {
  const url = audioUrl?.trim()
  if (url) {
    stopSpeaking()
    const audio = new Audio(url)
    audio.playbackRate = rate
    void audio.play()
    return true
  }
  return speakText(word, { rate })
}
