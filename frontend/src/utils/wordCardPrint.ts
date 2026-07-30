export type WordCardPrintMode = 'full' | 'quiz'

export interface WordCardPrintOptions {
  /** full=完整词卡；quiz=默写（释义留空） */
  mode: WordCardPrintMode
  includeAnswers: boolean
}

export const DEFAULT_WORD_CARD_PRINT_OPTIONS: WordCardPrintOptions = {
  mode: 'full',
  includeAnswers: false,
}
