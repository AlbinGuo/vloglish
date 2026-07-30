/** 将 DataV 中国 geoJSON 的全称规范为短省名，便于与后端 map_name 对齐 */
const FULL_TO_SHORT: Record<string, string> = {
  北京市: '北京',
  天津市: '天津',
  上海市: '上海',
  重庆市: '重庆',
  河北省: '河北',
  山西省: '山西',
  辽宁省: '辽宁',
  吉林省: '吉林',
  黑龙江省: '黑龙江',
  江苏省: '江苏',
  浙江省: '浙江',
  安徽省: '安徽',
  福建省: '福建',
  江西省: '江西',
  山东省: '山东',
  河南省: '河南',
  湖北省: '湖北',
  湖南省: '湖南',
  广东省: '广东',
  海南省: '海南',
  四川省: '四川',
  贵州省: '贵州',
  云南省: '云南',
  陕西省: '陕西',
  甘肃省: '甘肃',
  青海省: '青海',
  台湾省: '台湾',
  内蒙古自治区: '内蒙古',
  广西壮族自治区: '广西',
  西藏自治区: '西藏',
  宁夏回族自治区: '宁夏',
  新疆维吾尔自治区: '新疆',
  香港特别行政区: '香港',
  澳门特别行政区: '澳门',
}

export type GeoJson = {
  type: string
  features: Array<{
    type: string
    properties: Record<string, unknown> & { name?: string }
    geometry: unknown
  }>
}

export function shortenChinaGeoJson(geo: GeoJson): GeoJson {
  return {
    ...geo,
    features: geo.features
      .filter((f) => f.properties?.name)
      .map((f) => {
        const full = String(f.properties.name)
        const short = FULL_TO_SHORT[full] || full
        return {
          ...f,
          properties: { ...f.properties, name: short },
        }
      }),
  }
}

const geoCache = new Map<string, GeoJson>()

export async function loadGeoJson(path: string): Promise<GeoJson> {
  const cached = geoCache.get(path)
  if (cached) return cached
  const res = await fetch(path)
  if (!res.ok) throw new Error(`加载地图失败: ${path}`)
  const data = (await res.json()) as GeoJson
  geoCache.set(path, data)
  return data
}
