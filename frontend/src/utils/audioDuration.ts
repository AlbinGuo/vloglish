/** 音频时长展示：短音频用 5″，满分钟用 1′05″ */

export function formatAudioClock(seconds: number): string {
  if (!Number.isFinite(seconds) || seconds < 0) return '0″'
  const total = Math.max(0, Math.floor(seconds + 0.5))
  const m = Math.floor(total / 60)
  const s = total % 60
  if (m <= 0) return `${s}″`
  return `${m}′${String(s).padStart(2, '0')}″`
}

/** 从 Audio 元数据读取时长（秒）；失败返回 null */
export function probeAudioDuration(url: string): Promise<number | null> {
  const src = (url || '').trim()
  if (!src) return Promise.resolve(null)

  return new Promise((resolve) => {
    const audio = new Audio()
    let settled = false
    const done = (value: number | null) => {
      if (settled) return
      settled = true
      audio.onloadedmetadata = null
      audio.onerror = null
      try {
        audio.removeAttribute('src')
        audio.load()
      } catch {
        /* ignore */
      }
      resolve(value)
    }

    audio.preload = 'metadata'
    audio.onloadedmetadata = () => {
      const d = audio.duration
      if (Number.isFinite(d) && d > 0) done(d)
      else done(null)
    }
    audio.onerror = () => done(null)
    // 部分浏览器对 blob/跨域需设 crossOrigin；七牛直链一般可播
    try {
      audio.src = src
    } catch {
      done(null)
    }
  })
}
