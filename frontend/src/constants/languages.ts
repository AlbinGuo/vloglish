export interface LanguageOption {
  code: string
  /** 本地语言名（中文） */
  label: string
  /** 该语言的母语写法 */
  native: string
  flag: string
}

export const TARGET_LANGUAGES: LanguageOption[] = [
  { code: 'en', label: '英语', native: 'English', flag: '🇬🇧' },
  { code: 'de', label: '德语', native: 'Deutsch', flag: '🇩🇪' },
  { code: 'fr', label: '法语', native: 'Français', flag: '🇫🇷' },
]

export const NATIVE_LANGUAGES: LanguageOption[] = [
  { code: 'zh', label: '中文', native: '中文', flag: '🇨🇳' },
]

export function targetLanguageLabel(code?: string | null): string {
  return TARGET_LANGUAGES.find((l) => l.code === code)?.label || '英语'
}
