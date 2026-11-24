export interface LanguageOption {
  code: string
  /** 本地语言名（中文） */
  label: string
  /** 该语言的母语写法 */
  native: string
  flag: string
}

/** 支持的语言目录（管理端可从中挑选开放给用户） */
export const LANGUAGE_CATALOG: Record<string, LanguageOption> = {
  en: { code: 'en', label: '英语', native: 'English', flag: '🇬🇧' },
  de: { code: 'de', label: '德语', native: 'Deutsch', flag: '🇩🇪' },
  fr: { code: 'fr', label: '法语', native: 'Français', flag: '🇫🇷' },
  ja: { code: 'ja', label: '日语', native: '日本語', flag: '🇯🇵' },
  ko: { code: 'ko', label: '韩语', native: '한국어', flag: '🇰🇷' },
  es: { code: 'es', label: '西班牙语', native: 'Español', flag: '🇪🇸' },
  pt: { code: 'pt', label: '葡萄牙语', native: 'Português', flag: '🇵🇹' },
}

export const TARGET_LANGUAGES: LanguageOption[] = Object.values(LANGUAGE_CATALOG)

export const NATIVE_LANGUAGES: LanguageOption[] = [
  { code: 'zh', label: '中文', native: '中文', flag: '🇨🇳' },
]

export function languageLabel(code?: string | null): string {
  return LANGUAGE_CATALOG[code || '']?.label || code || '英语'
}

export function targetLanguageLabel(code?: string | null): string {
  return LANGUAGE_CATALOG[code || '']?.label || '英语'
}
