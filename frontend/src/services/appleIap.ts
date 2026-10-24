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
  /**
   * 后端校验凭证：StoreKit2 为 Apple 签名的交易 JWS（较长，形如 a.b.c）；
   * 旧版 StoreKit1 为 base64 应用收据。后端两种都能识别。
   */
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

let storeReady: Promise<void> | null = null
const catalog = new Set<string>()
let pendingResolve: ((r: ApplePurchaseResult) => void) | null = null
let pendingReject: ((e: Error) => void) | null = null
let purchaseTimer: ReturnType<typeof setTimeout> | null = null
/** 最近一次 StoreKit 原生错误（插件会把 transaction 失败的真实原因吞掉，这里尽量兜住 error 事件） */
let lastStoreError = ''

function isNonConsumable(productId: string): boolean {
  return /forever|permanent|lifetime/i.test(productId)
}

function productType(C: CdvPurchase, id: string) {
  return isNonConsumable(id) ? C.ProductType.NON_CONSUMABLE : C.ProductType.PAID_SUBSCRIPTION
}

/** 注册商品后再初始化：必须在 initialize 之前把所有商品 register，原生才会加载它们。 */
function registerProducts(C: CdvPurchase, ids: string[]): boolean {
  const toAdd = ids.filter((id) => id && !catalog.has(id))
  if (!toAdd.length) return false
  C.store.register(
    toAdd.map((id) => ({ id, type: productType(C, id), platform: C.Platform.APPLE_APPSTORE })),
  )
  toAdd.forEach((id) => catalog.add(id))
  return true
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

/** 判断字符串是否形似 StoreKit2 交易 JWS（header.payload.signature，恰有两个点） */
function looksLikeJws(s: unknown): s is string {
  return typeof s === 'string' && s.length > 100 && s.split('.').length === 3
}

/** 从 v13 的 Transaction 中取出用于后端校验的凭证。
 *
 * 优先返回 StoreKit2 交易 JWS：它与本次交易一一对应、后端可离线验签（无需共享密钥），
 * 不会出现「按产品在整张 App Receipt 里找不到本笔交易」的问题。
 * 仅当拿不到 JWS 时，才回退旧版 base64 App Receipt。
 */
function extractAppReceipt(tx: any): string {
  // 1) 优先 StoreKit2 交易 JWS（v13 中可能出现于多个位置）
  const jwsCandidates = [
    tx?.nativePurchase?.jwsRepresentation,
    tx?.nativePurchase?.jws,
    tx?.nativePurchase?.transaction?.jwsRepresentation,
    tx?.jwsRepresentation,
  ]
  for (const c of jwsCandidates) {
    if (looksLikeJws(c)) return c
  }

  // 2) 旧版 App Receipt 兜底
  const parent: any = tx?.parentReceipt
  const fromNative = parent?.nativeData?.appStoreReceipt
  if (typeof fromNative === 'string' && fromNative) return fromNative
  if (typeof parent?.appStoreReceipt === 'string' && parent.appStoreReceipt) return parent.appStoreReceipt
  if (typeof parent === 'string' && parent) return parent
  if (typeof tx?.receipt === 'string' && tx.receipt) return tx.receipt

  // 3) 其它可能的 JWS 字段兜底
  const jws = tx?.nativePurchase?.jwsRepresentation ?? tx?.jwsRepresentation
  if (typeof jws === 'string' && jws) return jws
  return ''
}

/** 取一份「新鲜」的凭证用于后端校验。
 *
 * 关键：StoreKit 1 下交易本身不带 JWS，只能用整张 App Receipt；而插件缓存的
 * `parentReceipt.nativeData.appStoreReceipt` 往往是 App 启动时抓取的旧收据，
 * **不包含刚刚完成的这笔交易**，会导致后端按产品/交易号查不到记录（“未找到对应
 * 的购买记录”）。因此这里优先刷新一次收据，拿到包含本次交易的最新 App Receipt。
 */
async function getFreshReceipt(C: CdvPurchase, tx: any): Promise<string> {
  // StoreKit2 交易 JWS 直接可用，无需刷新
  const jws = [
    tx?.nativePurchase?.jwsRepresentation,
    tx?.jwsRepresentation,
  ].find(looksLikeJws)
  if (jws) return jws

  // StoreKit1：调用原生刷新收据，确保包含本次交易；失败/超时再回退到缓存收据
  const adapter: any = (() => {
    try {
      return C.store.getAdapter?.(C.Platform.APPLE_APPSTORE)
    } catch {
      return null
    }
  })()
  if (adapter && typeof adapter.refreshReceipt === 'function') {
    // 最多重试两次（首次刷新偶发拿不到最新交易）
    for (let attempt = 0; attempt < 2; attempt++) {
      try {
        const fresh = await Promise.race([
          adapter.refreshReceipt(),
          new Promise((resolve) => setTimeout(() => resolve(null), 8000)),
        ])
        const receipt = (fresh as any)?.appStoreReceipt
        if (typeof receipt === 'string' && receipt.length > 20) return receipt
      } catch {
        /* 刷新失败，尝试下一次或回退 */
      }
      if (attempt === 0) await new Promise((r) => setTimeout(r, 1200))
    }
  }

  return extractAppReceipt(tx)
}

function attachHandlers(C: CdvPurchase) {
  try {
    C.store.verbosity = C.LogLevel?.DEBUG ?? 0
  } catch {
    /* ignore */
  }
  const when = C.store.when?.()
  when?.approved?.((tx: any) => {
    void (async () => {
      const pid = String(tx?.products?.[0]?.id ?? tx?.productId ?? '')
      // 先拿到包含本次交易的新鲜凭证，再 finish 交易（finish 后交易会从收据队列移除）
      const receipt = await getFreshReceipt(C, tx)
      const result: ApplePurchaseResult = {
        productId: pid,
        transactionId: String(tx?.transactionId ?? ''),
        receipt,
      }
      try {
        await tx?.finish?.()
      } catch {
        /* ignore */
      }
      const resolve = pendingResolve
      clearPending()
      resolve?.(result)
    })()
  })
  when?.cancelled?.(() => {
    const reject = pendingReject
    clearPending()
    reject?.(new Error('已取消支付'))
  })
  when?.error?.((err: any) => {
    const msg = typeof err?.message === 'string' && err.message ? err.message : '支付失败'
    lastStoreError = err?.code ? `${msg} (${err.code})` : msg
    try {
      console.warn('[AppleIAP] store error:', lastStoreError)
    } catch {
      /* ignore */
    }
    // 仅在“有进行中的购买”时，把错误判定为购买失败；加载商品阶段忽略
    const reject = pendingReject
    if (!reject) return
    clearPending()
    reject(new Error(lastStoreError))
  })
}

/** 注册（调用方已登记商品）后只初始化一次；initialize 必须在 register 之后调用。 */
function ensureStoreReady(): Promise<void> {
  const C = getCdv()
  if (!C) return Promise.reject(new Error('Apple 内购插件未安装，请更新到最新版本 App'))
  if (!storeReady) {
    attachHandlers(C)
    storeReady = Promise.resolve(C.store.initialize([C.Platform.APPLE_APPSTORE]))
  }
  return storeReady
}

function isProductLoaded(p: any): boolean {
  if (!p) return false
  try {
    return Array.isArray(p.offers) && p.offers.length > 0
  } catch {
    return false
  }
}

/** 等待商品「真正加载完成」（含可购买 offer）；仅注册未加载的占位商品不算就绪 */
async function waitForProduct(
  C: CdvPurchase,
  id: string,
  timeoutMs = 15000,
): Promise<any | null> {
  const ready = (): any | null => {
    const p = getProduct(C, id)
    return isProductLoaded(p) ? p : null
  }
  const found = ready()
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
    let ticks = 0
    const finish = (p: any | null) => {
      if (settled) return
      settled = true
      if (iv) clearInterval(iv)
      if (to) clearTimeout(to)
      resolve(isProductLoaded(p) ? p : ready())
    }
    to = setTimeout(() => finish(ready()), timeoutMs)
    try {
      const when = C.store.when?.()
      when?.productUpdated?.((p: any) => {
        if (p?.id === id && isProductLoaded(p)) finish(p)
      })
      when?.productList?.(() => finish(ready()))
    } catch {
      /* ignore */
    }
    iv = setInterval(() => {
      ticks += 1
      if (ticks % 4 === 0) {
        try {
          C.store.update?.()
        } catch {
          /* ignore */
        }
      }
      const p = ready()
      if (p) finish(p)
    }, 600)
  })
}

/** 把插件返回的错误对象转成对用户有意义的提示 */
function describePurchaseError(err: any): string {
  const raw = typeof err?.message === 'string' ? err.message : ''
  const code = typeof err?.code === 'number' ? err.code : undefined
  if (code === 6777003) {
    // ErrorCode.PURCHASE：无法发起/完成购买
    return (
      '购买未能完成（商品未在 App Store 就绪、未登录沙盒账号或网络异常等）。' +
      '请在「设置 → App Store → 沙盒账户」用测试账号登录后重试；' +
      '若持续失败，确认商品已在 App Store Connect 配置为「准备提交/已批准」并填好价格。' +
      (raw ? `（原始错误：${raw}）` : '')
    )
  }
  const msg = raw || '支付未完成'
  return code ? `${msg} (${code})` : msg
}

/** 发起购买，成功（交易已批准）后 resolve；用户取消/失败 reject */
export async function applePurchase(productId: string): Promise<ApplePurchaseResult> {
  const C = getCdv()
  if (!C) throw new Error('Apple 内购插件未安装，请更新到最新版本 App')
  lastStoreError = ''
  const added = registerProducts(C, [productId])
  await ensureStoreReady()
  if (added) {
    try {
      C.store.update?.()
    } catch {
      /* ignore */
    }
  }

  const product = await waitForProduct(C, productId, 15000)
  if (!product) {
    const ids = (C.store.products ?? [])
      .filter(isProductLoaded)
      .map((p: any) => p?.id)
      .filter(Boolean)
    throw new Error(
      '商品未就绪（未能从 App Store 拉到该商品的可购买信息）。' +
        `已就绪商品：${ids.length ? ids.join('、') : '无'}。` +
        '请检查：① App Store Connect 是否已签署「付费 App 协议」；' +
        '② 商品状态是否为「准备提交/已批准」且已填价格、本地化、审核截图（订阅须在「订阅组」内）；' +
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
          let text = describePurchaseError(err)
          if (lastStoreError && !text.includes(lastStoreError)) {
            text += `（StoreKit：${lastStoreError}）`
          }
          rej?.(new Error(text))
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
  // 先把所有商品注册好，再初始化，确保原生一次性加载全部商品
  registerProducts(C, productIds)
  try {
    await ensureStoreReady()
  } catch {
    return
  }
  try {
    C.store.update?.()
  } catch {
    /* ignore */
  }
}

/** 恢复购买（换机/重装后找回已购）。返回刷新后的最新 App Receipt（StoreKit1）或空串，
 * 便于调用方把收据重新提交给后端核对（修复“已扣款但未开通”后可通过恢复购买自愈）。 */
export async function restoreApplePurchases(): Promise<string> {
  const C = getCdv()
  if (!C) return ''
  try {
    await C.store.restorePurchases?.()
  } catch {
    /* ignore */
  }
  // 恢复后再刷新一次收据，拿到包含历史交易的最新 App Receipt
  const adapter: any = (() => {
    try {
      return C.store.getAdapter?.(C.Platform.APPLE_APPSTORE)
    } catch {
      return null
    }
  })()
  if (adapter && typeof adapter.refreshReceipt === 'function') {
    try {
      const fresh = await Promise.race([
        adapter.refreshReceipt(),
        new Promise((resolve) => setTimeout(() => resolve(null), 8000)),
      ])
      const receipt = (fresh as any)?.appStoreReceipt
      if (typeof receipt === 'string' && receipt.length > 20) return receipt
    } catch {
      /* ignore */
    }
  }
  return ''
}

/**
 * 打开 App Store 的「管理订阅」页（Apple 3.1.2 要求订阅用户可随时管理/取消）。
 * 优先用插件原生 API；不可用时回退到系统订阅管理网页。
 */
export async function manageAppleSubscriptions(): Promise<void> {
  const C = getCdv()
  try {
    const fn = C?.store?.showManageSubscriptions
    if (typeof fn === 'function') {
      await fn.call(C.store)
      return
    }
  } catch {
    /* 回退到网页 */
  }
  window.open('https://apps.apple.com/account/subscriptions', '_blank', 'noopener')
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
