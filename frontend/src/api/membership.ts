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
  membership_activated: boolean
  paid_at: string | null
  created_at: string
}

export async function getMembershipPricing() {
  const { data } = await api.get<MembershipPricing>('/api/membership/pricing/')
  return data
}

export async function createMembershipOrder(channel: 'page' | 'wap' = 'page') {
  const { data } = await api.post<MembershipOrder>('/api/membership/orders/', { channel })
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

export interface ApplePurchaseVerifyIn {
  product_id: string
  transaction_id: string
  receipt: string
}

export interface ApplePurchaseVerifyOut {
  is_member: boolean
  member_until: string | null
  member_plan: string | null
}

/** 把 Apple 内购收据提交后端校验并开通会员 */
export async function verifyApplePurchase(payload: ApplePurchaseVerifyIn) {
  const { data } = await api.post<ApplePurchaseVerifyOut>('/api/membership/apple/verify/', payload)
  return data
}
