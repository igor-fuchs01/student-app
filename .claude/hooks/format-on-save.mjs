// PostToolUse hook (Edit|Write): formats edited files under src/ with the project's Prettier config.
import { readFileSync, writeFileSync } from "node:fs";
import path from "node:path";
import * as prettier from "prettier";

const input = JSON.parse(readFileSync(0, "utf8"));
const filePath = input?.tool_input?.file_path;
const projectDir = process.env.CLAUDE_PROJECT_DIR ?? input?.cwd ?? process.cwd();

if (!filePath) process.exit(0);

// Same scope as `npm run format` and the CI format check.
const absolutePath = path.resolve(projectDir, filePath);
const relativeToSrc = path.relative(path.join(projectDir, "src"), absolutePath);
if (relativeToSrc.startsWith("..") || path.isAbsolute(relativeToSrc)) process.exit(0);

try {
  const { ignored, inferredParser } = await prettier.getFileInfo(absolutePath);
  if (ignored || !inferredParser) process.exit(0);

  const source = readFileSync(absolutePath, "utf8");
  const options = (await prettier.resolveConfig(absolutePath)) ?? {};
  const formatted = await prettier.format(source, { ...options, filepath: absolutePath });
  if (formatted !== source) writeFileSync(absolutePath, formatted);
} catch {
  // Code that doesn't parse yet (mid-refactor) is left as is; build and lint report it.
}
