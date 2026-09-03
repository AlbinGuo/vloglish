import { queryWxPayOrder } from '../api/wxpay'

export function versionGte(cur: string, need: string): boolean {
  const a = cur.split('.').map((n) => parseInt(n, 10) || 0)
  const b = need.split('.').map((n) => parseInt(n, 10) || 0)
  for (let i = 0; i < Math.max(a.length, b.length); i += 1) {
    const x = a[i] || 0
    const y = b[i] || 0
    if (x > y) return true
    if (x < y) return false
  }
  return true
}

export function assertPayReady() {
  const info = wx.getSystemInfoSync()
  if (info.platform === 'ios' && !versionGte(info.version || '', '8.0.68')) {
    throw new Error('iOS 请升级微信到 8.0.68 及以上')
  }
}

function payFailMessage(err: { errMsg?: string; errCode?: number }): string {
  const raw = `${err.errMsg || ''} ${err.errCode || ''}`
  if (/尚未开启\s*IOS支付|尚未开启iOS支付|IOS支付/i.test(raw)) {
    return '苹果手机需先在微信后台开通 iOS 支付。可先用安卓测试。'
  }
  if (/IOS_ORDER_PRICE_TOO_LOW|PRICE_TOO_LOW/i.test(raw)) {
    return '苹果支付最低 1 元，请改用 1 元测试档或正式套餐'
  }
  if (/cancel|取消/i.test(raw)) return '已取消支付'
  const msg = (err.errMsg || '').replace(/^requestVirtualPayment:fail\s*/i, '').trim()
  return msg || '支付取消或失败'
}

export function requestVirtualPayment(pay: {
  sign_data: string
  pay_sig: string
  signature: string
  mode: string
}): Promise<void> {
  return new Promise((resolve, reject) => {
    const api = (wx as unknown as {
      requestVirtualPayment?: (opts: Record<string, unknown>) => void
    }).requestVirtualPayment
    if (!api) {
      reject(new Error('当前微信版本不支持虚拟支付'))
      return
    }
    api({
      signData: pay.sign_data,
      paySig: pay.pay_sig,
      signature: pay.signature,
      mode: pay.mode || 'short_series_goods',
      success: () => resolve(),
      fail: (err: { errMsg?: string; errCode?: number }) => reject(new Error(payFailMessage(err))),
    })
  })
}

function sleep(ms: number) {
  return new Promise((r) => setTimeout(r, ms))
}

export async function waitPaid(outTradeNo: string) {
  for (let i = 0; i < 8; i += 1) {
    try {
      const row = await queryWxPayOrder(outTradeNo)
      if (row.paid) return row
    } catch {
      /* continue */
    }
    await sleep(1500)
  }
  return null
}
