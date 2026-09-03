import { request } from '../utils/request'

export type AiQuota = {
  is_member: boolean
  limit: number | null
  used: number
  remaining: number | null
}

export function getAiQuota() {
  return request<AiQuota>({ url: '/api/ai/quota/' })
}
