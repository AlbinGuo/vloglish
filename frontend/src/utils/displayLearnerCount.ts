/** 前端展示用学习人数（与后端无关，仅让列表数字更饱满）。 */

const DISPLAY_LEARNER_OFFSET_MIN = 80
const DISPLAY_LEARNER_OFFSET_SPAN = 20 // → 80..100

/** 从此日期起按天累计增长（本地日历日）。今天为第 0 天，明天起开始累加。 */
const GROWTH_START = new Date(2026, 6, 26) // 2026-07-26

function stableHash(input: string): number {
  let h = 2166136261
  for (let i = 0; i < input.length; i++) {
    h ^= input.charCodeAt(i)
    h = Math.imul(h, 16777619)
  }
  return h >>> 0
}

function startOfLocalDay(d: Date): number {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime()
}

/** 相对 GROWTH_START 过了多少个完整本地日（未开始则为 0）。 */
function daysSinceGrowthStart(now = new Date()): number {
  const diff = startOfLocalDay(now) - startOfLocalDay(GROWTH_START)
  if (diff <= 0) return 0
  return Math.floor(diff / 86_400_000)
}

/** 同一 video_id 永远得到相同基础偏移。 */
export function displayLearnerOffset(videoId: string): number {
  if (!videoId) return DISPLAY_LEARNER_OFFSET_MIN
  return DISPLAY_LEARNER_OFFSET_MIN + (stableHash(videoId) % (DISPLAY_LEARNER_OFFSET_SPAN + 1))
}

/** 每天额外增长量（按视频固定为 20～30）。 */
function dailyGrowthStep(videoId: string): number {
  return 20 + (stableHash(`${videoId}:daily`) % 11)
}

/**
 * 展示人数 = 真实人数 + 基础偏移(80～100) + 按天累计增长。
 * 同一天内刷新不变；跨天后自动变大。
 */
export function displayLearnerCount(realCount: number | undefined | null, videoId: string): number {
  const real = Math.max(0, Number(realCount) || 0)
  const base = displayLearnerOffset(videoId)
  const growth = daysSinceGrowthStart() * dailyGrowthStep(videoId)
  return real + base + growth
}
