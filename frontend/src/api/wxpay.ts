import api from './client'

export type PcPayCreate = {
  token: string
  plan: string
  plan_name: string
  amount_cent: number
  expires_in: number
}

export type PcPayStatus = {
  status: string
  plan: string
  plan_name: string
  amount_cent: number
  paid: boolean
}

export async function createPcPaySession(plan: string) {
  const { data } = await api.post<PcPayCreate>('/api/wxpay/pc-sessions/', { plan })
  return data
}

export async function fetchPcPayStatus(token: string) {
  const { data } = await api.get<PcPayStatus>(
    `/api/wxpay/pc-sessions/${encodeURIComponent(token)}/`,
  )
  return data
}

export async function fetchPcPayQr(token: string) {
  const { data } = await api.get<Blob>(
    `/api/wxpay/pc-sessions/${encodeURIComponent(token)}/qrcode/`,
    { responseType: 'blob' },
  )
  return data
}
