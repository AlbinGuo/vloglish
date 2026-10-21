/**
 * Apple 应用内购买（StoreKit）桥接。
 *
 * 依赖原生插件 cordova-plugin-purchase(v13+)：它会把全局对象 `CdvPurchase` 挂到 window。
 * 这里不直接 import 该包，而是通过 window 全局访问，保证 Web 构建不受影响；
 * 仅当运行在 iOS 原生 App 且插件已安装时可用。
 *
 * 原生侧准备（在 app/ 目录、Mac 上执行，详见 app/IOS_BUILD.md）：
 *   npm i cordova-plugin-purchase
 *   npx cap sync ios
 *   在 App Store Connect 配置好内购商品并使用与代码 APPLE_PRODUCT_IDS 一致的 product id。
 */
import { getNativePlatform, isNativePlatform } from '@/utils/platform'

export interface ApplePurchaseResult {
  productId: string
  transactionId: string
  /** 应用级收据（base64），用于后端 verifyReceipt 校验 */
  receipt: string
}

type CdvPurchase = any

function getCdv(): CdvPurchase | null {
  const w = window as unknown as { CdvPurchase?: CdvPurchase }
  return w.CdvPurchase ?? null
}

/** iOS 原生 App 且已安装内购插件时可用 */
export function isAppleIapAvailable(): boolean {
  return isNativePlatform() && getNativePlatform() === 'ios' && Boolean(getCdv())
}

let initPromise: Promise<void> | null = null
const registered = new Set<string>()
let pendingResolve: ((r: ApplePurchaseResult) => void) | null = null
let pendingReject: ((e: Error) => void) | null = null
let purchaseTimer: ReturnType<typeof setTimeout> | null = null

function isNonConsumable(productId: string): boolean {
  return /forever|permanent|lifetime/i.test(productId)
}

function getProduct(C: CdvPurchase, id: string): any | null {
  try {
    return C.store.get?.(id, C.Platform.APPLE_APPSTORE) ?? C.store.get?.(id) ?? null
  } catch {
    return null
  }
}

function loadedProductIds(C: CdvPurchase): string[] {
  try {
    return (C.store.products ?? []).map((p: any) => p?.id).filter(Boolean)
  } catch {
    return []
  }
}

function clearPending() {
  pendingResolve = null
  pendingReject = null
  if (purchaseTimer) {
    clearTimeout(purchaseTimer)
    purchaseTimer = null
  }
}

/** 从 v13 的 Transaction 中取出 base64 应用收据（parentReceipt 是对象，不是字符串） */
function extractAppReceipt(tx: any): string {
  const parent: any = tx?.parentReceipt
  // 1) Receipt 对象的 nativeData.appStoreReceipt（标准路径）
  const fromNative = parent?.nativeData?.appStoreReceipt
  if (typeof fromNative === 'string' && fromNative) return fromNative
  // 2) 某些版本在 Receipt 上直接挂 appStoreReceipt
  if (typeof parent?.appStoreReceipt === 'string' && parent.appStoreReceipt) return parent.appStoreReceipt
  // 3) 若 parent 本身就是字符串（旧版本）
  if (typeof parent === 'string' && parent) return parent
  // 4) tx.receipt 字符串
  if (typeof tx?.receipt === 'string' && tx.receipt) return tx.receipt
  // 5) StoreKit2 JWS 兜底
  const jws = tx?.nativePurchase?.jwsRepresentation ?? tx?.jwsRepresentation
  if (typeof jws === 'string' && jws) return jws
  return ''
}

async function ensureInitialized(productId: string): Promise<void> {
  const C = getCdv()
  if (!C) throw new Error('Apple 内购插件未安装，请更新到最新版本 App')
  const { store, ProductType, Platform } = C
  const apple = Platform.APPLE_APPSTORE

  let newlyRegistered = false
  if (!registered.has(productId)) {
    store.register([
      {
        id: productId,
        type: isNonConsumable(productId)
          ? ProductType.NON_CONSUMABLE
          : ProductType.PAID_SUBSCRIPTION,
        platform: apple,
      },
    ])
    registered.add(productId)
    newlyRegistered = true
  }

  if (!initPromise) {
    try {
      store.verbosity = C.LogLevel?.WARNING ?? 0
    } catch {
      /* ignore */
    }
    const when = store.when?.()
    when?.approved?.((tx: any) => {
      const pid = String(tx?.products?.[0]?.id ?? tx?.productId ?? '')
      const result: ApplePurchaseResult = {
        productId: pid,
        transactionId: String(tx?.transactionId ?? ''),
        receipt: extractAppReceipt(tx),
      }
      try {
        tx?.finish?.()
      } catch {
        /* ignore */
      }
      const resolve = pendingResolve
      clearPending()
      resolve?.(result)
    })
    when?.cancelled?.(() => {
      const reject = pendingReject
      clearPending()
      reject?.(new Error('已取消支付'))
    })
    when?.error?.((err: any) => {
      // 仅在“有进行中的购买”时，把错误判定为购买失败；加载商品阶段忽略
      const reject = pendingReject
      if (!reject) return
      clearPending()
      reject(new Error(err?.message || '支付失败'))
    })
    initPromise = Promise.resolve(store.initialize([apple]))
  }

  await initPromise
  if (newlyRegistered) {
    try {
      store.update?.()
    } catch {
      /* ignore */
    }
  }
}

/** 等待商品加载完成（initialize/update 是异步的，get 可能一开始拿不到） */
async function waitForProduct(
  C: CdvPurchase,
  id: string,
  timeoutMs = 10000,
): Promise<any | null> {
  const found = getProduct(C, id)
  if (found) return found
  try {
    C.store.update?.()
  } catch {
    /* ignore */
  }
  return await new Promise((resolve) => {
    let settled = false
    let iv: ReturnType<typeof setInterval> | undefined
    let to: ReturnType<typeof setTimeout> | undefined
    const finish = (p: any | null) => {
      if (settled) return
      settled = true
      if (iv) clearInterval(iv)
      if (to) clearTimeout(to)
      resolve(p || getProduct(C, id) || null)
    }
    to = setTimeout(() => finish(getProduct(C, id)), timeoutMs)
    try {
      const when = C.store.when?.()
      when?.productUpdated?.((p: any) => {
        if (p?.id === id) finish(p)
      })
      when?.productList?.(() => finish(getProduct(C, id)))
    } catch {
      /* ignore */
    }
    iv = setInterval(() => {
      const p = getProduct(C, id)
      if (p) finish(p)
    }, 600)
  })
}

/** 发起购买，成功（交易已批准）后 resolve；用户取消/失败 reject */
export async function applePurchase(productId: string): Promise<ApplePurchaseResult> {
  const C = getCdv()
  if (!C) throw new Error('Apple 内购插件未安装，请更新到最新版本 App')
  await ensureInitialized(productId)

  const product = await waitForProduct(C, productId, 10000)
  if (!product) {
    const ids = loadedProductIds(C)
    throw new Error(
      '商品未就绪（未能从 App Store 拉到该商品）。' +
        `已加载商品：${ids.length ? ids.join('、') : '无'}。` +
        '请检查：① App Store Connect 是否已签署「付费 App 协议」；' +
        '② 商品状态是否为「准备提交/已批准」且已填价格、本地化、审核截图；' +
        '③ 产品 ID 是否与后台完全一致（区分大小写）；' +
        '④ 是否为真机 + 沙盒环境测试。',
    )
  }

  const offer = product.getOffer?.() ?? product.offers?.[0]
  if (!offer) throw new Error('该商品暂无可用购买选项（检查商品价格档位是否已设置）')

  return await new Promise<ApplePurchaseResult>((resolve, reject) => {
    pendingResolve = resolve
    pendingReject = reject
    purchaseTimer = setTimeout(() => {
      const rej = pendingReject
      clearPending()
      rej?.(new Error('支付超时，请重试'))
    }, 180000)
    Promise.resolve(offer.order?.())
      .then((err: any) => {
        if (err) {
          const rej = pendingReject
          clearPending()
          rej?.(new Error(err?.message || '支付未完成'))
        }
      })
      .catch((e: unknown) => {
        const rej = pendingReject
        clearPending()
        rej?.(e instanceof Error ? e : new Error('支付失败'))
      })
  })
}

/** 预加载商品（页面进入时调用，减少点支付时的“商品未就绪”） */
export async function appleIapWarmup(productIds: string[]): Promise<void> {
  const C = getCdv()
  if (!C) return
  for (const id of productIds) {
    try {
      await ensureInitialized(id)
    } catch {
      /* ignore */
    }
  }
  try {
    C.store.update?.()
  } catch {
    /* ignore */
  }
}

/** 恢复购买（换机/重装后找回已购） */
export async function restoreApplePurchases(): Promise<void> {
  const C = getCdv()
  if (!C) return
  try {
    await C.store.restorePurchases?.()
  } catch {
    /* ignore */
  }
}

/** 调试用：返回当前 App Store 已加载的商品 id，便于排查“商品未就绪” */
export function appleIapDebugInfo(): { available: boolean; products: string[] } {
  const C = getCdv()
  if (!C) return { available: false, products: [] }
  try {
    C.store.update?.()
  } catch {
    /* ignore */
  }
  return { available: true, products: loadedProductIds(C) }
}
