import type { EntryDetail } from '@/types'

export function primaryIpa(entry: EntryDetail): string {
  const pron = entry.pronunciations.find((p) => p.is_primary) ?? entry.pronunciations[0]
  const ipa = pron?.ipa?.trim() ?? ''
  if (!ipa) return ''
  if (ipa.startsWith('/') || ipa.startsWith('[')) return ipa
  return `/${ipa}/`
}

export function firstChineseDefinition(entry: EntryDetail): string {
  return entry.definitions[0]?.definition_cn?.trim() ?? ''
}
