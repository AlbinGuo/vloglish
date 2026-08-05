/** 单词/短语朗读：优先词典音频 → 有道发音 → speechSynthesis */

let currentAudio: HTMLAudioElement | null = null

export function speechSynthesisSupported(): boolean {
  return typeof window !== 'undefined' && 'speechSynthesis' in window
}

function stopAudio() {
  if (!currentAudio) return
  try {
    currentAudio.pause()
    currentAudio.src = ''
  } catch {
    // ignore
  }
  currentAudio = null
}

export function stopSpeaking() {
  stopAudio()
  if (!speechSynthesisSupported()) return
  try {
    window.speechSynthesis.cancel()
  } catch {
    // ignore
  }
}

function pickEnglishVoice(): SpeechSynthesisVoice | null {
  if (!speechSynthesisSupported()) return null
  const voices = window.speechSynthesis.getVoices()
  if (!voices.length) return null
  return (
    voices.find((v) => v.lang === 'en-US' && /google|microsoft|samantha|jenny|aria/i.test(v.name)) ||
    voices.find((v) => v.lang === 'en-US') ||
    voices.find((v) => v.lang.toLowerCase().startsWith('en')) ||
    null
  )
}

/** 预热语音列表（Chrome / Android 异步加载） */
export function warmSpeechVoices() {
  if (!speechSynthesisSupported()) return
  try {
    window.speechSynthesis.getVoices()
    if (typeof window.speechSynthesis.addEventListener === 'function') {
      window.speechSynthesis.addEventListener('voiceschanged', () => {
        window.speechSynthesis.getVoices()
      }, { once: true })
    }
  } catch {
    // ignore
  }
}

if (typeof window !== 'undefined') {
  warmSpeechVoices()
}

export function speakText(text: string, options?: { rate?: number; lang?: string }): boolean {
  if (!speechSynthesisSupported()) return false
  const trimmed = text.trim()
  if (!trimmed) return false

  try {
    window.speechSynthesis.cancel()
  } catch {
    // ignore
  }

  const utter = new SpeechSynthesisUtterance(trimmed)
  utter.lang = options?.lang ?? 'en-US'
  utter.rate = Math.min(2, Math.max(0.5, options?.rate ?? 0.92))
  const voice = pickEnglishVoice()
  if (voice) {
    utter.voice = voice
    utter.lang = voice.lang || utter.lang
  }

  try {
    window.speechSynthesis.speak(utter)
    // Chrome：偶发 speak 后处于 paused，需 resume
    window.setTimeout(() => {
      try {
        if (window.speechSynthesis.paused) window.speechSynthesis.resume()
      } catch {
        // ignore
      }
    }, 0)
    return true
  } catch {
    return false
  }
}

function youdaoVoiceUrl(word: string) {
  // type=2 美音；音频元素播放不触发 CORS 读限制
  return `https://dict.youdao.com/dictvoice?audio=${encodeURIComponent(word)}&type=2`
}

function playRemoteAudio(url: string, rate: number, onFail?: () => void): boolean {
  const trimmed = url.trim()
  if (!trimmed) return false
  stopSpeaking()
  try {
    const audio = new Audio(trimmed)
    currentAudio = audio
    audio.playbackRate = Math.min(2, Math.max(0.5, rate))
    const playPromise = audio.play()
    if (playPromise && typeof playPromise.catch === 'function') {
      void playPromise.catch(() => {
        if (currentAudio === audio) currentAudio = null
        onFail?.()
      })
    }
    audio.onended = () => {
      if (currentAudio === audio) currentAudio = null
    }
    audio.onerror = () => {
      if (currentAudio === audio) currentAudio = null
      onFail?.()
    }
    return true
  } catch {
    onFail?.()
    return false
  }
}

/** 优先播放 URL，否则有道发音，再不行用 speechSynthesis */
export function playWordPronunciation(word: string, audioUrl?: string | null, rate = 0.92): boolean {
  const text = word.trim()
  if (!text && !audioUrl?.trim()) return false

  const fallbackTts = () => {
    if (text) speakText(text, { rate })
  }

  const custom = audioUrl?.trim()
  if (custom) {
    return playRemoteAudio(custom, rate, () => {
      if (text) {
        if (!playRemoteAudio(youdaoVoiceUrl(text), rate, fallbackTts)) fallbackTts()
      }
    })
  }

  if (!text) return false

  // 移动端 speechSynthesis 常无声，优先有道
  return playRemoteAudio(youdaoVoiceUrl(text), rate, fallbackTts)
}
