export function normalizeAnswerText(text: string): string {
  return text.trim().toLowerCase().replace(/\s+/g, " ");
}
