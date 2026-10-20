/**
 * App 构建后处理：把 Tailwind v4 产物降级到旧 Android System WebView 可用。
 *
 * 主要处理：
 * 1. lightningcss 按 Chrome 69 目标把 oklch 等现代颜色转成 hex/rgb
 * 2. 展开 @layer（旧 WebView 不支持则整层样式丢失）
 * 3. 去掉 @property，并把其中的 --tw-* 初始值落到通用选择器（旧引擎无 @property）
 * 4. 把 color-mix(...% , transparent) 转成 rgba
 * 5. 为 dvh 补 100vh 回退
 */
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { transform } from 'lightningcss'
import { parse, converter, formatHex, formatRgb } from 'culori'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const wwwAssets = path.resolve(__dirname, '../../app/www/assets')

/** Chrome 69 ≈ 较老但仍能覆盖多数国产机升级后的 WebView 下限；颜色会尽量落到 sRGB */
const TARGETS = { chrome: 69 << 16 }

const toRgb = converter('rgb')

function findMatchingBrace(css, openIdx) {
  let depth = 0
  for (let i = openIdx; i < css.length; i++) {
    const ch = css[i]
    if (ch === '{') depth++
    else if (ch === '}') {
      depth--
      if (depth === 0) return i
    }
  }
  return -1
}

/** 展开 @layer name? { ... } → 内容；并去掉 @layer foo; 排序声明 */
function unwrapAtRule(css, atName) {
  let out = css
  // 无块声明：@layer theme, base, components, utilities; 或 @layer components;
  out = out.replace(new RegExp(`@${atName}\\b[^;{]*;`, 'g'), '')

  const re = new RegExp(`@${atName}\\b[^,{;]*\\{`, 'g')
  let guard = 0
  while (guard++ < 5000) {
    re.lastIndex = 0
    const m = re.exec(out)
    if (!m) break
    const openIdx = m.index + m[0].length - 1
    const closeIdx = findMatchingBrace(out, openIdx)
    if (closeIdx < 0) break
    const inner = out.slice(openIdx + 1, closeIdx)
    out = out.slice(0, m.index) + inner + out.slice(closeIdx + 1)
  }
  return out
}

/** 展开所有 @supports (...) { ... } → 内容（App 构建需要强制应用 --tw 回退） */
function unwrapSupports(css) {
  let out = css
  let guard = 0
  while (guard++ < 5000) {
    const idx = out.search(/@supports\b/)
    if (idx < 0) break
    const openIdx = out.indexOf('{', idx)
    if (openIdx < 0) break
    const closeIdx = findMatchingBrace(out, openIdx)
    if (closeIdx < 0) break
    const inner = out.slice(openIdx + 1, closeIdx)
    out = out.slice(0, idx) + inner + out.slice(closeIdx + 1)
  }
  return out
}

/** 删除 @property --name { ... } */
function stripPropertyRules(css) {
  let out = css
  let guard = 0
  while (guard++ < 5000) {
    const idx = out.search(/@property\b/)
    if (idx < 0) break
    const openIdx = out.indexOf('{', idx)
    if (openIdx < 0) {
      out = out.slice(0, idx)
      break
    }
    const closeIdx = findMatchingBrace(out, openIdx)
    if (closeIdx < 0) break
    out = out.slice(0, idx) + out.slice(closeIdx + 1)
  }
  return out
}

function parseCssColor(value) {
  if (!value) return null
  const v = value.trim()
  try {
    return parse(v)
  } catch {
    return null
  }
}

function colorToRgba(color, alpha) {
  const rgb = toRgb(color)
  if (!rgb) return null
  const r = Math.round((rgb.r ?? 0) * 255)
  const g = Math.round((rgb.g ?? 0) * 255)
  const b = Math.round((rgb.b ?? 0) * 255)
  const a = Math.round(alpha * 1000) / 1000
  if (a >= 1) return `rgb(${r} ${g} ${b})`
  if (a <= 0) return 'transparent'
  return `rgba(${r},${g},${b},${a})`
}

/** 从已降级 CSS 中收集 --color-*: <solid> */
function collectColorVars(css) {
  const map = new Map()
  const re = /--color-([\w-]+)\s*:\s*([^;}{]+)/g
  let m
  while ((m = re.exec(css))) {
    const name = `--color-${m[1]}`
    const raw = m[2].trim()
    if (/color-mix\(/i.test(raw) || /oklch\(/i.test(raw) || /lab\(/i.test(raw)) continue
    const color = parseCssColor(raw)
    if (color) map.set(name, color)
  }
  // 兜底
  if (!map.has('--color-black')) map.set('--color-black', parse('black'))
  if (!map.has('--color-white')) map.set('--color-white', parse('white'))
  return map
}

function rewriteColorMix(css, colorVars, unresolved) {
  let out = css

  // @property 占位：color-mix(in lab, red, red)
  out = out.replace(/color-mix\(\s*in\s+lab\s*,\s*red\s*,\s*red\s*\)/gi, 'transparent')

  // color-mix(in oklab|lab, var(--color-x) N%, transparent)
  out = out.replace(
    /color-mix\(\s*in\s+(?:oklab|lab)\s*,\s*var\(\s*(--color-[\w-]+)\s*\)\s*([\d.]+)%\s*,\s*transparent\s*\)/gi,
    (_, varName, pct) => {
      const color = colorVars.get(varName)
      const alpha = Number(pct) / 100
      if (!color || Number.isNaN(alpha)) {
        // 解析不了就只能降级成 transparent —— 视觉会静默丢失，必须报出来
        unresolved.push(`${varName} @ ${pct}%`)
        return 'transparent'
      }
      return colorToRgba(color, alpha) || 'transparent'
    },
  )

  // color-mix(in oklab, currentcolor N%, transparent) → 近似半透明黑（极少出现）
  out = out.replace(
    /color-mix\(\s*in\s+(?:oklab|lab)\s*,\s*currentcolor\s*([\d.]+)%\s*,\s*transparent\s*\)/gi,
    (_, pct) => {
      const alpha = Number(pct) / 100
      if (Number.isNaN(alpha)) return 'transparent'
      return `rgba(0,0,0,${Math.round(alpha * 1000) / 1000})`
    },
  )

  // 其它残留 color-mix：尽量用 culori；失败则 transparent，避免整条声明失效
  out = out.replace(/color-mix\((?:[^()]|\([^()]*\))*\)/gi, (expr) => {
    try {
      const c = parse(expr)
      if (!c) return 'transparent'
      const hex = formatHex(c)
      return hex || formatRgb(c) || 'transparent'
    } catch {
      return 'transparent'
    }
  })

  return out
}

function addDvhFallbacks(css) {
  // min-height: 100dvh → 先 100vh 再 100dvh
  return css
    .replace(/(^|[{;\s])(min-height\s*:\s*100dvh)\b/g, '$1min-height:100vh;$2')
    .replace(/(^|[{;\s])(height\s*:\s*100dvh)\b/g, '$1height:100vh;$2')
    .replace(/(^|[{;\s])(max-height\s*:\s*100dvh)\b/g, '$1max-height:100vh;$2')
}

function compatOneFile(filePath) {
  const input = fs.readFileSync(filePath)
  let css = transform({
    filename: path.basename(filePath),
    code: input,
    minify: true,
    targets: TARGETS,
  }).code.toString()

  css = unwrapAtRule(css, 'layer')
  css = stripPropertyRules(css)
  css = unwrapSupports(css)

  const colorVars = collectColorVars(css)
  const unresolved = []
  css = rewriteColorMix(css, colorVars, unresolved)
  css = addDvhFallbacks(css)

  // 再过一遍 lightningcss，清理无效残留并压缩
  css = transform({
    filename: path.basename(filePath),
    code: Buffer.from(css),
    minify: true,
    targets: TARGETS,
  }).code.toString()

  fs.writeFileSync(filePath, css)
  return {
    file: path.basename(filePath),
    oklch: (css.match(/oklch/gi) || []).length,
    colorMix: (css.match(/color-mix/gi) || []).length,
    layer: (css.match(/@layer\b/g) || []).length,
    property: (css.match(/@property\b/g) || []).length,
    bytes: Buffer.byteLength(css),
    unresolved,
  }
}

function main() {
  if (!fs.existsSync(wwwAssets)) {
    console.error(`[compatWebViewCss] missing ${wwwAssets} — run vite app build first`)
    process.exit(1)
  }
  const files = fs.readdirSync(wwwAssets).filter((f) => f.endsWith('.css'))
  if (!files.length) {
    console.warn('[compatWebViewCss] no css files')
    return
  }
  const stats = []
  for (const f of files) {
    stats.push(compatOneFile(path.join(wwwAssets, f)))
  }
  const sum = stats.reduce(
    (a, s) => ({
      oklch: a.oklch + s.oklch,
      colorMix: a.colorMix + s.colorMix,
      layer: a.layer + s.layer,
      property: a.property + s.property,
    }),
    { oklch: 0, colorMix: 0, layer: 0, property: 0 },
  )
  console.log('[compatWebViewCss] processed', stats.length, 'css files')
  for (const s of stats) {
    console.log(
      `  - ${s.file}: ${s.bytes}B (oklch=${s.oklch} color-mix=${s.colorMix} @layer=${s.layer} @property=${s.property})`,
    )
  }

  // 解析不了的 color-mix 会被降级成 transparent —— 视觉静默丢失，必须让构建失败
  const unresolved = stats.flatMap((s) => s.unresolved.map((u) => `${s.file}: ${u}`))
  if (unresolved.length) {
    console.error('[compatWebViewCss] error: 以下 color-mix 无法解析，已降级为 transparent（视觉会丢失）：')
    for (const u of unresolved) console.error(`   - ${u}`)
    console.error('   原因通常是该 --color-* 变量用了间接引用（如 var(--neutral-50)），')
    console.error('   culori 无法解析。请在 src/styles/tokens.css 里改写成具体色值。')
    process.exit(1)
  }

  if (sum.oklch || sum.colorMix || sum.layer || sum.property) {
    console.warn('[compatWebViewCss] warning: some modern features remain', sum)
  } else {
    console.log('[compatWebViewCss] ok: no oklch / color-mix / @layer / @property left')
  }
}

main()
