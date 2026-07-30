export type BlankPrintHintMode = 'en-only' | 'with-chinese'

export interface BlankPrintOptions {
  hintMode: BlankPrintHintMode
  includeAnswers: boolean
}

export const DEFAULT_BLANK_PRINT_OPTIONS: BlankPrintOptions = {
  hintMode: 'en-only',
  includeAnswers: false,
}
