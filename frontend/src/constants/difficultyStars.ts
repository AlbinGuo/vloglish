export interface DifficultyLevel {
  stars: number
  label: string
  traits: string[]
}

/** 难度星级说明（与 DeepSeek 评估标准一致，供 UI 提示与文档参考） */
export const difficultyLevels: DifficultyLevel[] = [
  {
    stars: 1,
    label: '入门',
    traits: ['短句、慢速', '高频基础词', '主题生活化', '发音清晰、连读少'],
  },
  {
    stars: 2,
    label: '初级',
    traits: ['日常口语为主', '少量短语搭配', '语速中等', '句子结构简单'],
  },
  {
    stars: 3,
    label: '中级',
    traits: ['正常 Vlog 语速', '有搭配与习语', '句子略长', '偶有从句或话题切换'],
  },
  {
    stars: 4,
    label: '中高级',
    traits: ['语速较快', '抽象词或领域词增多', '从句与信息密度高', '听辨有挑战'],
  },
  {
    stars: 5,
    label: '高级',
    traits: ['快而密、口语省略多', '习语俚语密集', '需背景知识', '口音或表达风格强'],
  },
]

export function difficultyLevel(stars: number): DifficultyLevel | undefined {
  return difficultyLevels.find((l) => l.stars === stars)
}
