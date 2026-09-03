import { request } from '../utils/request'

export type MembershipPricing = {
  subject: string
  amount_yuan: string
  amount_cent: number
  description: string
}

export function getMembershipPricing() {
  return request<MembershipPricing>({
    url: '/api/membership/pricing/',
    auth: false,
  })
}
