import type { Subtitle } from '@/types'

/** 当前时间点应展示的字幕：活跃句优先，间隙显示下一句，末尾之后保留最后一句。 */
export function resolveDisplaySub(subs: Subtitle[], t: number): Subtitle | null {
  if (!subs.length) return null
  const activeIdx = subs.findIndex((s) => t >= s.start && t < s.end)
  if (activeIdx >= 0) return subs[activeIdx]
  const nextIdx = subs.findIndex((s) => t < s.start)
  if (nextIdx >= 0) return subs[nextIdx]
  return subs[subs.length - 1]
}

export function stripSpeakerMarkers(text: string): string {
  if (!text) return ''
  return text.replace(/>>+/g, '').replace(/\s+/g, ' ').trim()
}

/** Preprocess english_html before v-html render. */
export function preprocessSubtitleHtml(html: string, options: { blank?: boolean } = {}): string {
  let result = html

  // 访谈类字幕里的说话人标记 >>
  result = result.replace(/(?:<span>\s*>+\s*<\/span>\s*)+/gi, '')
  result = result.replace(/>>+/g, '')

  // 短语 span（pid）保持整段不换行
  result = result.replace(/<span(\s[^>]*\bpid="[^"]+"[^>]*)>/gi, (_match, attrs: string) => {
    if (/class="/.test(attrs)) {
      return `<span${attrs.replace(/class="/, 'class="phrase-token ')}>`
    }
    return `<span class="phrase-token"${attrs}>`
  })

  if (options.blank) {
    result = result.replace(/class="([^"]*highlight[^"]*)"/g, 'class="$1 text-transparent"')
  }

  return result
}

export type SubtitleDisplayMode = 'both' | 'en' | 'zh' | 'blank' | 'dynamic' | 'ipa'

/** 全屏当前句字幕：中英 / 英语 / 盲听 */
export type FullscreenCaptionMode = 'both' | 'en' | 'blind'

export function modeShowsEnglish(mode: SubtitleDisplayMode): boolean {
  return mode === 'both' || mode === 'en' || mode === 'blank' || mode === 'dynamic' || mode === 'ipa'
}

export function modeShowsChinese(mode: SubtitleDisplayMode): boolean {
  return mode === 'both' || mode === 'zh'
}

export function modeShowsIpa(mode: SubtitleDisplayMode, showIpa: boolean): boolean {
  if (!showIpa) return false
  return mode === 'both' || mode === 'en' || mode === 'dynamic' || mode === 'ipa'
}

export function modeUsesBlank(mode: SubtitleDisplayMode): boolean {
  return mode === 'blank'
}

export function modeIsDynamicFocus(mode: SubtitleDisplayMode): boolean {
  return mode === 'dynamic'
}

export function modeIsChineseOnly(mode: SubtitleDisplayMode): boolean {
  return mode === 'zh'
}

export type SubtitleAlign = 'left' | 'center'
