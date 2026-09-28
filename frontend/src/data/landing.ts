const LANDING_OSS = 'https://oss.sxakgs.com/vloglish'

export const LANDING_MOCKS = {
  phoneCatalog: `${LANDING_OSS}/git0.jpg`,
  tabletCatalog: `${LANDING_OSS}/1.png`,
  tabletDesk: `${LANDING_OSS}/2.png`,
  macCatalog: `${LANDING_OSS}/3.jpg`,
  macList: `${LANDING_OSS}/4.jpg`,
  macCues: `${LANDING_OSS}/5.jpg`,
  macContext: `${LANDING_OSS}/6.jpg`,
  macNotes: `${LANDING_OSS}/7.jpg`,
} as const

export const LANDING_DESK_VIEWS = [
  {
    id: 'cues',
    label: '字幕',
    hint: '左视频，右当前句',
    image: LANDING_MOCKS.macCues,
  },
  {
    id: 'list',
    label: '句单',
    hint: '按句往下听',
    image: LANDING_MOCKS.macList,
  },
  {
    id: 'context',
    label: '语境',
    hint: '讲解仍停在这一句',
    image: LANDING_MOCKS.macContext,
  },
  {
    id: 'notes',
    label: '背景',
    hint: '看懂这一集在讲什么',
    image: LANDING_MOCKS.macNotes,
  },
] as const

export const LANDING_FEATURES = [
  { title: '电脑目录', summary: '按真实 vlog 选片，封面就是这一集。', image: LANDING_MOCKS.macCatalog },
  { title: '字幕精听', summary: '左视频，右当前句，单句循环。', image: LANDING_MOCKS.macCues },
  { title: '句单', summary: '整集句子排下来，听到哪点到哪。', image: LANDING_MOCKS.macList },
  { title: '视频语境', summary: '讲解停在这一句，不用另开文档。', image: LANDING_MOCKS.macContext },
  { title: '背景', summary: '先看懂这一集在讲什么，再练耳朵。', image: LANDING_MOCKS.macNotes },
  { title: '平板精听', summary: '同一套书桌，拿到沙发上也能练。', image: LANDING_MOCKS.tabletDesk },
  { title: '平板目录', summary: '和大屏同一份片单，进度还在。', image: LANDING_MOCKS.tabletCatalog },
  { title: '手机选片', summary: '走路先收藏，坐下来再精听。', image: LANDING_MOCKS.phoneCatalog },
] as const

export const LANDING_PATH = [
  {
    id: 'pick',
    name: '选一集真实口语',
    summary: '不背词书。先找一集你愿意听完的生活视频。',
  },
  {
    id: 'stay',
    name: '听不清就停在这一句',
    summary: '精听、字幕、语境都围着当前句，不求一遍看完。',
  },
  {
    id: 'write',
    name: '写下来，再说出去',
    summary: '听写按词填，跟读对着原句开口，对照原文才算过。',
  },
  {
    id: 'replay',
    name: '拿去听模式复听',
    summary: '同一集改成随身听，进度还在这一句。',
  },
] as const

export const LANDING_METHODS = [
  {
    id: 'intensive',
    name: '精听',
    summary: '单句循环，听不清就停在这一句。',
  },
  {
    id: 'dictation',
    name: '听写',
    summary: '按词填写，对照原文才算听懂。',
  },
  {
    id: 'shadow',
    name: '跟读',
    summary: '对着原句开口，立刻看到反馈。',
  },
  {
    id: 'listen',
    name: '听',
    summary: '当播客听，走路也能接着练。',
  },
] as const
