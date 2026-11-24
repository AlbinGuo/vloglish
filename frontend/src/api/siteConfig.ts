import api from '@/api/client'

export interface SiteConfig {
  membership_gate_enabled: boolean
  language_selection_enabled: boolean
  available_target_languages: string[]
}

export async function fetchSiteConfig() {
  const { data } = await api.get<SiteConfig>('/api/site-config/')
  return data
}
