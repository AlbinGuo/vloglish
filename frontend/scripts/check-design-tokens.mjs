#!/usr/bin/env node
/**
 * 设计 token 守卫：检查构建产物里是否真的生成了语义 token 工具类。
 *
 * 背景：Tailwind v4 的 @theme 定义如果写错位置（例如放进不会被处理的文件），
 * 构建不会报错，只是工具类静默缺失 —— 页面会掉样式却没人发现。
 * 这个脚本把它变成一次明确的失败。
 *
 * 用法：
 *   node scripts/check-design-tokens.mjs [css所在目录]   # 默认 dist
 */

import { readdir, readFile } from 'node:fs/promises'
import { existsSync } from 'node:fs'
import { join, resolve } from 'node:path'

/** 必须存在的工具类（组件已在用，缺了说明 token 层断了） */
const REQUIRED_UTILS = [
  'bg-canvas',
  'bg-card',
  'text-ink',
  'text-ink-soft',
  'text-ink-faint',
  'text-ink-inverse',
  'border-line-soft',
  'text-brand-on-soft',
  'bg-brand-soft',
  'text-warning',
  'bg-warning-soft',
  'text-info',
  'bg-info-soft',
  'bg-danger',
]

/** 必须存在的 CSS 变量（语义层） */
const REQUIRED_VARS = ['--color-canvas', '--color-ink', '--color-line', '--color-brand']

async function collectCss(dir) {
  const files = []
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const full = join(dir, entry.name)
    if (entry.isDirectory()) files.push(...(await collectCss(full)))
    else if (entry.name.endsWith('.css')) files.push(full)
  }
  return files
}

async function main() {
  const target = resolve(process.argv[2] ?? 'dist')
  if (!existsSync(target)) {
    console.error(`✘ 找不到 CSS 目录: ${target}`)
    process.exit(1)
  }

  const files = await collectCss(target)
  if (files.length === 0) {
    console.error(`✘ ${target} 下没有找到任何 .css 文件`)
    process.exit(1)
  }

  const merged = (await Promise.all(files.map((f) => readFile(f, 'utf8')))).join('\n')

  const missingUtils = REQUIRED_UTILS.filter((u) => !merged.includes(u))
  const missingVars = REQUIRED_VARS.filter((v) => !merged.includes(v))

  const problems = []
  if (missingUtils.length) problems.push(`缺少工具类: ${missingUtils.join(', ')}`)
  if (missingVars.length) problems.push(`缺少 CSS 变量: ${missingVars.join(', ')}`)
  if (!merged.includes('.dark')) problems.push('缺少 .dark 主题覆盖（深色模式会失效）')

  if (problems.length) {
    console.error('✘ 设计 token 校验失败：')
    for (const p of problems) console.error(`   - ${p}`)
    console.error('   请检查 src/styles/tokens.css 是否被正确引入，以及 @theme inline 是否生效。')
    process.exit(1)
  }

  console.log(`✓ 设计 token 校验通过（${files.length} 个 CSS 文件，${REQUIRED_UTILS.length} 个工具类）`)
}

main().catch((err) => {
  console.error('✘ token 校验脚本异常:', err)
  process.exit(1)
})
