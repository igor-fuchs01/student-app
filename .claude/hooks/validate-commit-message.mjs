// PreToolUse hook (Bash|PowerShell): enforces the commit message rule from .claude/CLAUDE.md.
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

const RULE = 'the subject must start with "feat: " (no other type such as fix/chore/docs, no scope in parentheses)';

const input = JSON.parse(readFileSync(0, "utf8"));
const command = input?.tool_input?.command ?? "";
const cwd = input?.cwd ?? process.cwd();

// Options may sit between "git" and "commit" (git -C dir commit); "commit-tree" and similar are not commits.
if (!/\bgit(?:\s+-{1,2}[\w-]+(?:[=\s]\S+)?)*\s+commit(?![\w-])/.test(command)) process.exit(0);

function block(reason) {
  process.stderr.write(`Commit blocked by .claude/hooks/validate-commit-message.mjs: ${reason}\n`);
  process.exit(2);
}

function firstLine(message) {
  return message.split(/\r?\n/).find((line) => line.trim() !== "")?.trim() ?? "";
}

// Only an actual trailer ("Co-Authored-By: ..." or --trailer "Co-authored-by=...") counts, not prose mentioning it.
if (/co-authored-by\s*[:=]/i.test(command)) {
  block("remove the Co-Authored-By trailer; the project never adds it.");
}

const subjects = [];

for (const match of command.matchAll(/<<-?\s*(['"]?)(\w+)\1[^\n]*\n([\s\S]*?)\n\s*\2\b/g)) {
  subjects.push(firstLine(match[3]));
}
for (const match of command.matchAll(/@(['"])\r?\n([\s\S]*?)\r?\n\1@/g)) {
  subjects.push(firstLine(match[2]));
}

if (subjects.length === 0) {
  for (const match of command.matchAll(/(?:^|\s)(?:-F|--file)(?:=|\s+)(["']?)([^\s"']+)\1/g)) {
    const file = path.resolve(cwd, match[2]);
    if (existsSync(file)) subjects.push(firstLine(readFileSync(file, "utf8")));
  }
  for (const match of command.matchAll(/(?:^|\s)(?:-[a-zA-Z]*m|--message)(?:=|\s*)(["'])([\s\S]*?)\1/g)) {
    subjects.push(firstLine(match[2]));
  }
}

// No readable message (e.g. --amend --no-edit, -C <commit>): nothing to validate.
for (const subject of subjects) {
  if (!/^feat: \S/.test(subject)) block(`${RULE}. Got: "${subject}"`);
}
