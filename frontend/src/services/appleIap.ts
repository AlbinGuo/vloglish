/**
 * Apple 应用内购买（StoreKit）桥接。
 *
 * 依赖原生插件 cordova-plugin-purchase(v13+)：它会把全局对象 `CdvPurchase` 挂到 window。
 * 这里不直接 import 该包，而是通过 window 全局访问，保证 Web 构建不受影响；
 * 仅当运行在 iOS 原生 App 且插件已安装时可用。
 *
 * 原生侧准备（在 app/ 目录、Mac 上执行，详见交付说明）：
 *   npm i cordova-plugin-purchase
 *   npx cap sync ios
 *   在 App Store Connect 配置好内购商品并使用与 APPLE_IAP_PRODUCTS 一致的 product id。
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

function isNonConsumable(productId: string): boolean {
  return /forever|permanent|lifetime/i.test(productId)
}

async function ensureInitialized(productId: string): Promise<void> {
  const C = getCdv()
  if (!C) throw new Error('Apple 内购插件未安装，请更新到最新版本 App')
  const { store, ProductType, Platform } = C
  const apple = Platform.APPLE_APPSTORE

  if (!registered.has(productId)) {
    store.register([
      {
        id: productId,
        type: isNonConsumable(productId) ? ProductType.NON_CONSUMABLE : ProductType.PAID_SUBSCRIPTION,
        platform: apple,
      },
    ])
    registered.add(productId)
  }

  if (!initPromise) {
    try {
      store.verbosity = C.LogLevel?.WARNING ?? 0
    } catch {
      /* ignore */
    }
    const when = store.when?.()
    when?.approved?.((tx: any) => {
      const pid: string = tx?.products?.[0]?.id ?? tx?.productId ?? ''
      const receipt: string = tx?.parentReceipt ?? tx?.receipt ?? ''
      const result: ApplePurchaseResult = {
        productId: pid,
        transactionId: String(tx?.transactionId ?? ''),
        receipt,
      }
      try {
        tx?.finish?.()
      } catch {
        /* ignore */
      }
      const resolve = pendingResolve
      pendingResolve = null
      pendingReject = null
      resolve?.(result)
    })
    when?.error?.((err: any) => {
      const reject = pendingReject
      pendingResolve = null
      pendingReject = null
      reject?.(new Error(err?.message || '支付失败'))
    })
    initPromise = Promise.resolve(store.initialize([apple]))
  }

  await initPromise
}

/** 发起购买，成功（交易已批准）后 resolve；用户取消/失败 reject */
export async function applePurchase(productId: string): Promise<ApplePurchaseResult> {
  const C = getCdv()
  if (!C) throw new Error('Apple 内购插件未安装，请更新到最新版本 App')
  await ensureInitialized(productId)

  const apple = C.Platform.APPLE_APPSTORE
  try {
    C.store.update?.()
  } catch {
    /* ignore */
  }
  const product = C.store.get?.(productId, apple)
  if (!product) throw new Error('商品未就绪，请稍后重试或检查 App Store 配置')
  const offer = product.getOffer?.() ?? product.offers?.[0]
  if (!offer) throw new Error('该商品暂无可用购买选项')

  return await new Promise<ApplePurchaseResult>((resolve, reject) => {
    pendingResolve = resolve
    pendingReject = reject
    Promise.resolve(offer.order?.())
      .then((err: any) => {
        if (err) {
          pendingResolve = null
          pendingReject = null
          reject(new Error(err?.message || '支付未完成'))
        }
      })
      .catch((e: unknown) => {
        pendingResolve = null
        pendingReject = null
        reject(e instanceof Error ? e : new Error('支付失败'))
      })
  })
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
