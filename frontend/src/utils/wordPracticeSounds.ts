/**
 * 练习台音效（Web Audio 合成，避免引入第三方音源版权问题）。
 * 手感对齐 Qwerty：按键咔哒、错误短促、完成清脆。
 */

let ctx: AudioContext | null = null

function getCtx(): AudioContext | null {
  if (typeof window === 'undefined') return null
  const AC = window.AudioContext || (window as unknown as { webkitAudioContext?: typeof AudioContext }).webkitAudioContext
  if (!AC) return null
  if (!ctx) ctx = new AC()
  if (ctx.state === 'suspended') void ctx.resume()
  return ctx
}

function beep(opts: {
  freq: number
  duration: number
  type?: OscillatorType
  gain?: number
  slideTo?: number
}) {
  const audio = getCtx()
  if (!audio) return
  const t0 = audio.currentTime
  const osc = audio.createOscillator()
  const gain = audio.createGain()
  osc.type = opts.type || 'square'
  osc.frequency.setValueAtTime(opts.freq, t0)
  if (opts.slideTo != null) {
    osc.frequency.exponentialRampToValueAtTime(Math.max(40, opts.slideTo), t0 + opts.duration)
  }
  const g = opts.gain ?? 0.04
  gain.gain.setValueAtTime(g, t0)
  gain.gain.exponentialRampToValueAtTime(0.0001, t0 + opts.duration)
  osc.connect(gain)
  gain.connect(audio.destination)
  osc.start(t0)
  osc.stop(t0 + opts.duration + 0.02)
}

export function playKeyClick() {
  beep({ freq: 920, duration: 0.035, type: 'square', gain: 0.03 })
}

export function playKeyError() {
  beep({ freq: 220, duration: 0.12, type: 'sawtooth', gain: 0.05, slideTo: 140 })
}

export function playWordCorrect() {
  beep({ freq: 660, duration: 0.06, type: 'triangle', gain: 0.045 })
  setTimeout(() => beep({ freq: 880, duration: 0.08, type: 'triangle', gain: 0.04 }), 50)
}

export function playSessionDone() {
  beep({ freq: 523, duration: 0.08, type: 'triangle', gain: 0.04 })
  setTimeout(() => beep({ freq: 659, duration: 0.08, type: 'triangle', gain: 0.04 }), 70)
  setTimeout(() => beep({ freq: 784, duration: 0.12, type: 'triangle', gain: 0.045 }), 140)
}
