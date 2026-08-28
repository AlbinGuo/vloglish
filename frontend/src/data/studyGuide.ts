export interface StudyNeed {
  id: string
  need: string
  methodId: string
  methodLabel: string
  extra: string
}

export interface StudyMethod {
  id: string
  no: string
  name: string
  nameEn: string
  role: string
  fit: string
  time: string
  value: string
  stepsTitle: string
  steps: string[]
}

export interface StudyPlan {
  scene: string
  combo: string
  time: string
}

export const STUDY_PREMISE =
  '没有“最好”的方法，只有“最适合你当下状态”的方法。请根据自身水平、可用时间、学习目标和兴趣，自由组合、动态调整。'

export const STUDY_NEEDS: StudyNeed[] = [
  {
    id: 'pronunciation',
    need: '发音/语调差，说话像机器人',
    methodId: 'shadowing',
    methodLabel: '影子跟读 / 回音法',
    extra: '每日 10–20 分钟，二选一',
  },
  {
    id: 'cant-speak',
    need: '听懂了但说不出口',
    methodId: 'hundred-ls',
    methodLabel: '100LS / 尚雯婕法',
    extra: '每周精练 1–2 个短句或片段',
  },
  {
    id: 'listening',
    need: '听力反应慢，连读听不清',
    methodId: 'dictation',
    methodLabel: '听写训练 / 切片式输入',
    extra: '每周 3–4 次，每次 15 分钟',
  },
  {
    id: 'overall',
    need: '想综合提升听说能力',
    methodId: 'intensive',
    methodLabel: '精听-跟读-复述',
    extra: '每日 15 分钟，作为固定流程',
  },
  {
    id: 'beginner',
    need: '基础薄弱，怕跟不上',
    methodId: 'echoing',
    methodLabel: '回音法（0.5–0.8 倍速）',
    extra: '从单句开始，不贪多',
  },
]

export const STUDY_METHODS: StudyMethod[] = [
  {
    id: 'shadowing',
    no: '01',
    name: '影子跟读法',
    nameEn: 'Shadowing',
    role: '高强度口语肌肉训练',
    fit: '中高阶（基础弱可先降速）',
    time: '每日 10–20 分钟',
    value: '强行训练发音肌肉、语调、语流节奏，不经过大脑翻译',
    stepsTitle: '五步进阶',
    steps: [
      '盲听复述：不开字幕，只听，尽力复述能捕捉到的词（不说完整都行）。',
      '盲听同步跟读：不暂停，不思考，听到什么就立刻跟着说，不求完美，只求开口。',
      '看字幕跟读：打开字幕，一边看一边跟着原声念，刻意模仿节奏、语调和情绪。',
      '脱稿同步跟读：关掉字幕，调到适合自己的倍速（0.6–1.0），尽量做到完美模仿。',
      '日常循环：每天坚持，逐步形成英语发声肌肉记忆。',
    ],
  },
  {
    id: 'echoing',
    no: '02',
    name: '回音法',
    nameEn: 'Echoing',
    role: '精准雕琢发音与语调',
    fit: '所有阶段（尤其初中级）',
    time: '每日 10–20 分钟',
    value: '利用大脑“听觉记忆”回放，比单纯跟读更精细',
    stepsTitle: '六步循环',
    steps: [
      '整体预习：开双语字幕看 1–2 遍视频，熟悉语境、声音、语速。',
      '理解内容：如有不懂，停下来阅读字幕，查清表达，确保完全理解。',
      '单句循环暂停：设置单句循环 2–5 遍，并开启“播放完自动暂停”。',
      '心中回放：暂停后，不急着张嘴，先在脑子里回放刚才听到的声音。',
      '模仿记忆：模仿脑子里的那个“回音”，而非机械复读，一字一字清楚地说出来。',
      '反复迭代：同一句话反复练习，直到能说得自然流畅（可先 0.5–0.8 倍速，再原速）。',
    ],
  },
  {
    id: 'hundred-ls',
    no: '03',
    name: '100LS 法',
    nameEn: 'Listen 100 · Speak 100',
    role: '极致重复，打通听说回路',
    fit: '所有阶段',
    time: '按单句投入',
    value: '用“量”强制突破听力边界和口语流利度',
    stepsTitle: '单句循环',
    steps: [
      '选材：选一句略高于自己水平、带字幕的句子。',
      '听 100 遍（L）：单句循环播放，专注发音、连读、节奏、语调。',
      '说 100 遍（S）：模仿跟读 100 遍，过程中可随时再回听校准。',
      '自我检视：在第 10、50、100 遍时分别录音，回听对比进步。',
    ],
  },
  {
    id: 'shangwenjie',
    no: '04',
    name: '尚雯婕外语学习法',
    nameEn: 'Intensive dictation + recitation',
    role: '高强度精听 + 主动输出转化',
    fit: '中高阶，有整块时间者',
    time: '按篇投入',
    value: '从“被动听懂”到“主动说出”的质变训练',
    stepsTitle: '四步一循环',
    steps: [
      '选材：选一段视频（初期选 1–2 分钟短片段）。',
      '逐词听写：一句一句听写，不会的查字典或留空，力求接近原文。',
      '彻底理解：查生词、拆句式，吃透每个表达的语言结构和语境用法。',
      '语速同步背诵：背到能和原音频同一语速、同一节奏完整复述出来。',
      '循环多篇：建议练完 10 篇不同语料，听说能力会有显著提升。',
    ],
  },
  {
    id: 'intensive',
    no: '05',
    name: '精听-跟读-复述',
    nameEn: 'Listen · Shadow · Retell',
    role: '每日固定训练组合',
    fit: '所有阶段',
    time: '每日 15 分钟',
    value: '兼顾输入理解与输出表达',
    stepsTitle: '四遍法',
    steps: [
      '第 1 遍：只听，不看字幕，抓大意。',
      '第 2 遍：看字幕，精听每一句，查生词。',
      '第 3 遍：一句句跟读，模仿发音语调。',
      '第 4 遍：尝试复述内容（可用英语，也可用中文概括，锻炼转述能力）。',
    ],
  },
  {
    id: 'dictation',
    no: '06',
    name: '听写训练',
    nameEn: 'Dictation',
    role: '锻炼耳朵对连读和句子结构的敏感度',
    fit: '所有阶段',
    time: '每周 3–4 次',
    value: '听一句，暂停，写下来，对照原文校对',
    stepsTitle: '操作',
    steps: ['听一句，暂停，写下来，对照原文校对。'],
  },
  {
    id: 'chunk',
    no: '07',
    name: '切片式输入',
    nameEn: 'Chunk Listening',
    role: '微习惯，零碎时间可用',
    fit: '所有阶段，任何听力材料',
    time: '随时可做',
    value: '每次只攻克一小段，再连成整段',
    stepsTitle: '操作',
    steps: [
      '每次只听一小段（1–2 句），反复循环直到完全听清每个词，再连起来听整段。',
    ],
  },
]

export const STUDY_PLANS: StudyPlan[] = [
  {
    scene: '日常泛练（维持语感）',
    combo: '影子跟读（10 分钟）+ 切片式输入（随时）',
    time: '约 15 分钟',
  },
  {
    scene: '集中突破（1 个月专项）',
    combo: '尚雯婕法（每周 2 篇）+ 每日回音法（10 分钟）',
    time: '约 30 分钟',
  },
]

export const STUDY_TIPS = [
  '录音对比：无论哪种方法，每周至少录 1 次自己朗读/复述的声音，回听校准，这是进步最快的“照镜子”。',
  '降速起步：基础较弱时，所有跟读类方法均可从 0.5–0.8 倍速开始，熟练后再升速。',
  '材料复用：一段 1 分钟的材料，可以先用“切片式输入”攻克听力，再用“回音法”打磨发音，最后用“尚雯婕法”背下来——一份材料吃干榨净。',
  '不必完美：前几遍跟读漏词、卡顿完全正常，坚持 3–5 天会明显改善。',
]
