#!/usr/bin/env bash
# PreToolUse hook — defense-in-depth guardrail.
# Fires before every tool call, including in --dangerously-skip-permissions mode.
#
# DEFENSE-IN-DEPTH CONTRACT:
#   The blocks below mirror the deny rules in .claude/settings.json. The deny list
#   uses prefix-glob matching and misses edge cases (rm -rfv, &&-chained commands,
#   quoted variants); this hook catches those with regex. If you change one layer,
#   change the other. See .claude/README.md for the full rationale.
set -euo pipefail

# The hook receives tool name and input as JSON on stdin.
INPUT=$(cat)

# Parse hook input with a tool that is normally present on every supported
# setup. jq is preferred; Python and Node.js keep the guard available on
# machines where jq is not installed. Do not fail open: without a parser the
# hook cannot identify a safe tool call.
if command -v jq >/dev/null 2>&1 && jq -n true >/dev/null 2>&1; then
  JSON_PARSER="jq"
elif command -v python3 >/dev/null 2>&1 && python3 -c 'import json' >/dev/null 2>&1; then
  JSON_PARSER="python3"
elif command -v python >/dev/null 2>&1 && python -c 'import json' >/dev/null 2>&1; then
  JSON_PARSER="python"
elif command -v node >/dev/null 2>&1 && node -e 'process.exit(0)' >/dev/null 2>&1; then
  JSON_PARSER="node"
elif command -v powershell.exe >/dev/null 2>&1 && powershell.exe -NoProfile -Command '$null = 1' >/dev/null 2>&1; then
  JSON_PARSER="powershell.exe"
else
  echo "BLOCKED: no JSON parser is available for the PreToolUse guard." >&2
  echo "Install jq, Python, or Node.js, then start a new Claude session." >&2
  exit 2
fi

json_field() {
  local field="$1"

  case "$JSON_PARSER" in
    jq)
      case "$field" in
        tool_name) printf '%s' "$INPUT" | jq -r '.tool_name // empty' ;;
        file_path) printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' ;;
        command) printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' ;;
      esac
      ;;
    python3|python)
      printf '%s' "$INPUT" | "$JSON_PARSER" -c '
import json
import sys

data = json.load(sys.stdin)
field = sys.argv[1]
if field == "tool_name":
    value = data.get("tool_name", "")
else:
    value = data.get("tool_input", {}).get(field, "")
print(value if isinstance(value, str) else "")
' "$field"
      ;;
    node)
      printf '%s' "$INPUT" | node -e '
const chunks = [];
process.stdin.on("data", chunk => chunks.push(chunk));
process.stdin.on("end", () => {
  const data = JSON.parse(Buffer.concat(chunks).toString());
  const field = process.argv[1];
  const value = field === "tool_name"
    ? data.tool_name
    : data.tool_input?.[field];
  process.stdout.write(typeof value === "string" ? value : "");
});
' "$field"
      ;;    powershell.exe)
      case "$field" in
        tool_name)
          printf '%s' "$INPUT" | powershell.exe -NoProfile -Command '$data = [Console]::In.ReadToEnd() | ConvertFrom-Json; [Console]::Write([string]$data.tool_name)'
          ;;
        file_path)
          printf '%s' "$INPUT" | powershell.exe -NoProfile -Command '$data = [Console]::In.ReadToEnd() | ConvertFrom-Json; [Console]::Write([string]$data.tool_input.file_path)'
          ;;
        command)
          printf '%s' "$INPUT" | powershell.exe -NoProfile -Command '$data = [Console]::In.ReadToEnd() | ConvertFrom-Json; [Console]::Write([string]$data.tool_input.command)'
          ;;
      esac
      ;;
  esac
}

TOOL_NAME=$(json_field tool_name)
# --- Block reading secrets and credentials ---
# Mirrors Read(**/.env), Read(**/.ssh/*), Read(**/*.pem), Read(**/*.key) in settings.json.
if [ "$TOOL_NAME" = "Read" ] || [ "$TOOL_NAME" = "read" ]; then
  FILE_PATH=$(json_field file_path)
  if echo "$FILE_PATH" | grep -qiE '(\.env($|\.)|\.ssh/|\.pem$|\.key$|\.pfx$|\.p12$|credentials|secrets)'; then
    echo "BLOCKED: Reading a sensitive file is not allowed." >&2
    exit 2
  fi
fi

# --- Bash command checks ---
if [ "$TOOL_NAME" = "Bash" ] || [ "$TOOL_NAME" = "bash" ]; then
  COMMAND=$(json_field command)

  # Block external fetches (prompt-injection vector).
  # Mirrors Bash(curl *) and Bash(wget *) in settings.json. Catches mid-pipeline
  # uses (e.g. `something | curl ...`) that the prefix glob misses.
  if echo "$COMMAND" | grep -qiE '(^|[ ;&|`(])(curl|wget|fetch)( |$)'; then
    echo "BLOCKED: External fetch command." >&2
    echo "Use WebFetch or ask the user to run this command manually." >&2
    exit 2
  fi

  # Block recursive rm — catches rm -rf, rm -fr, rm -rfv, rm -Rf, rm --recursive.
  # Mirrors Bash(rm -rf *) in settings.json. The deny rule only catches the literal
  # `rm -rf ` prefix; this regex catches every short-flag combination and the long
  # form. If you legitimately need to recursively delete, do it from a terminal,
  # not from Claude.
  if echo "$COMMAND" | grep -qE '(^|[ ;&|`(])rm[ ]+(-[a-zA-Z]*[rRfF]|--recursive|--force)'; then
    echo "BLOCKED: Recursive deletion command." >&2
    echo "Recursive deletes must be run by the user manually." >&2
    exit 2
  fi
fi
