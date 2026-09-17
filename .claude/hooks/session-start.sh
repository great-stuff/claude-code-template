#!/bin/bash
# SessionStart hook — runs at the start of every Claude Code session.
#
# PURPOSE:
#   1. Surface git state (branch, status) so Claude can confirm the workspace.
#   2. Surface the main-branch rule before an edit is requested.
#   3. In remote (web) sessions only, install project dependencies.
#
# HOW TO EXTEND:
#   Uncomment the relevant dep-install block in the REMOTE-ONLY section below.

set -euo pipefail

# -------------------------------------------------------
# Always-run: git state and branch notice
# -------------------------------------------------------
echo "=== Session Start ==="
echo "Project dir : ${CLAUDE_PROJECT_DIR:-$(pwd)}"
echo "Date/time   : $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo ""

echo "--- Git status ---"
git status --short --branch 2>/dev/null || { echo "(not a git repo — skipping)"; exit 0; }
echo ""

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

if [ -f "TASKS.md" ]; then
  OPEN_TASKS=$(grep -E '^\s*-\s*\[ \]' TASKS.md || true)
  if [ -n "$OPEN_TASKS" ]; then
    # The "Open tasks" heading below is the source of truth — .claude/rules/session-start.md
    # tells Claude to look for this section. Do not rename without updating the rule.
    echo "--- Open tasks (TASKS.md) ---"
    echo "$OPEN_TASKS"
    echo ""
    echo "Claude: mention these only when the user asks about project work or planning."
    echo ""
  fi
fi

if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  echo "--- Branch notice ---"
  echo "Current branch: $CURRENT_BRANCH"
  echo "Claude: before a user-requested edit, commit, or PR action, propose a feature branch."
  echo ""
fi
# -------------------------------------------------------
# Remote-only: project dependency installation
# -------------------------------------------------------
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  echo "=== Session ready (local) ==="
  exit 0
fi

git fetch --quiet origin 2>/dev/null || echo "(fetch skipped — no network or credentials)"

# -------------------------------------------------------
# ADD PROJECT-SPECIFIC SETUP BELOW
# -------------------------------------------------------
# Uncomment the block that matches your project's stack.
# You can have multiple blocks if the project uses several ecosystems.

# --- Node.js / npm ---
# if [ -f "package.json" ]; then
#   echo "--- Installing npm dependencies ---"
#   npm install
#   echo "npm install complete"
# fi

# --- Node.js / pnpm ---
# if [ -f "pnpm-lock.yaml" ]; then
#   echo "--- Installing pnpm dependencies ---"
#   corepack enable pnpm
#   pnpm install
#   echo "pnpm install complete"
# fi

# --- Python / pip ---
# if [ -f "requirements.txt" ]; then
#   echo "--- Installing Python dependencies ---"
#   pip install -r requirements.txt --quiet
#   echo "pip install complete"
# fi

# --- Python / Poetry ---
# if [ -f "pyproject.toml" ]; then
#   echo "--- Installing Poetry dependencies ---"
#   pip install poetry --quiet
#   poetry install --no-interaction
#   echo "poetry install complete"
# fi

# --- Environment variables ---
# Persist any required env vars for the session using $CLAUDE_ENV_FILE:
# echo 'export MY_VAR="value"' >> "$CLAUDE_ENV_FILE"

echo "=== Session ready ==="
