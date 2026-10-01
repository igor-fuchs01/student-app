export const PREPARATION_TARGET = 80;

export function formatPercent(value: number | null): string {
  return value === null ? "—" : `${Math.round(value)}%`;
}
