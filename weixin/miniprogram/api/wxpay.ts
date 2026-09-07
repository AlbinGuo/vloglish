import { request } from '../utils/request'
import type { AuthUser } from '../utils/auth'

export type WxPayCreate = {
  out_trade_no: string
  plan: string
  plan_name: string
  amount_cent: number
  mode: string
  sign_data: string
  pay_sig: string
  signature: string
}

export type WxPayOrder = {
  out_trade_no: string
  status: string
  plan: string
  amount_cent: number
  paid: boolean
  user?: AuthUser | null
}

export function createWxPayOrder(plan: string, code: string, pcToken?: string) {
  return request<WxPayCreate>({
    url: '/api/wxpay/orders/',
    method: 'POST',
    data: { plan, code, pc_token: pcToken || undefined },
  })
}

export type PcPaySession = {
  status: string
  plan: string
  plan_name: string
  amount_cent: number
  paid: boolean
  user?: AuthUser | null
}

export function getPcPaySession(token: string) {
  return request<PcPaySession>({
    url: `/api/wxpay/pc-sessions/${encodeURIComponent(token)}/`,
  })
}

export type PcPayClaim = PcPaySession & {
  access: string
  refresh: string
  user: AuthUser
}

export function claimPcPaySession(token: string) {
  return request<PcPayClaim>({
    url: `/api/wxpay/pc-sessions/${encodeURIComponent(token)}/claim/`,
    method: 'POST',
  })
}

export function getWxPayOrder(outTradeNo: string) {
  return request<WxPayOrder>({
    url: `/api/wxpay/orders/${encodeURIComponent(outTradeNo)}/`,
  })
}

export function queryWxPayOrder(outTradeNo: string) {
  return request<WxPayOrder>({
    url: `/api/wxpay/orders/${encodeURIComponent(outTradeNo)}/query/`,
    method: 'POST',
  })
}
