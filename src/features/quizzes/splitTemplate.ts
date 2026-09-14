export type TemplatePart = { kind: "text"; value: string } | { kind: "blank"; id: string };

export function splitTemplate(template: string): TemplatePart[] {
  const parts: TemplatePart[] = [];
  const regex = /\{\{(\w+)\}\}/g;
  let lastIndex = 0;
  let match: RegExpExecArray | null;
  while ((match = regex.exec(template))) {
    if (match.index > lastIndex) {
      parts.push({ kind: "text", value: template.slice(lastIndex, match.index) });
    }
    parts.push({ kind: "blank", id: match[1] });
    lastIndex = match.index + match[0].length;
  }
  if (lastIndex < template.length) {
    parts.push({ kind: "text", value: template.slice(lastIndex) });
  }
  return parts;
}
