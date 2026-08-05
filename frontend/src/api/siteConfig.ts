import api from '@/api/client'

export interface SiteConfig {
  membership_gate_enabled: boolean
}

export async function fetchSiteConfig() {
  const { data } = await api.get<SiteConfig>('/api/site-config/')
  return data
}
