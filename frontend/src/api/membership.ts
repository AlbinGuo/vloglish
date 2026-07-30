import api from './client'

export interface MembershipPricing {
  subject: string
  amount_yuan: string
  amount_cent: number
  currency: string
  mock: boolean
  description: string
}

export interface MembershipOrder {
  order_no: string
  email: string
  amount_yuan: string
  amount_cent: number
  status: string
  mock: boolean
  pay_url: string | null
  return_url: string
  signup_url: string | null
  activation_code: string | null
  email_is_member: boolean
  paid_at: string | null
  created_at: string
}

export async function getMembershipPricing() {
  const { data } = await api.get<MembershipPricing>('/api/membership/pricing/')
  return data
}

export async function createMembershipOrder(email: string, channel: 'page' | 'wap' = 'page') {
  const { data } = await api.post<MembershipOrder>('/api/membership/orders/', { email, channel })
  return data
}

export async function getMembershipOrder(orderNo: string) {
  const { data } = await api.get<MembershipOrder>(
    `/api/membership/orders/${encodeURIComponent(orderNo)}/`,
  )
  return data
}

export async function mockPayMembershipOrder(orderNo: string) {
  const { data } = await api.post<MembershipOrder>(
    `/api/membership/orders/${encodeURIComponent(orderNo)}/mock-pay/`,
  )
  return data
}
