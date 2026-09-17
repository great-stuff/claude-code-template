# Default Template Setup Guide
## GitHub + Claude Code (Web · CLI · VSCode) — From Scratch

**Audience:** someone building a new project template from scratch (meta).
For setting up an **already-cloned** project on a new machine, see [`../SETUP.md`](../SETUP.md) instead.

This guide builds a fully functional, reusable project template. No project-specific content.
Complete every phase in order. Skipping steps causes problems later.

---

## Prerequisites

Install all of these before starting. Verify each one.

### 1. Git
```powershell
# Windows — download from https://git-scm.com/download/win
# Verify
git --version
```

### 2. Git LFS
```powershell
# Download from https://git-lfs.com
# After installing:
git lfs install
# Verify
git lfs version
```

### 3. Node.js (LTS)
```powershell
# Download from https://nodejs.org (choose LTS)
# Verify
node --version
npm --version
```

### 4. Claude Code CLI

**Recommended — native installer (auto-updates):**
```bash
# macOS / Linux / WSL
curl -fsSL https://claude.ai/install.sh | bash
```
```powershell
# Windows PowerShell
irm https://claude.ai/install.ps1 | iex
```

**Alternative — npm (does not auto-update):**
```powershell
npm install -g @anthropic-ai/claude-code
```

```powershell
# Verify
claude --version
```

### 5. VSCode
```powershell
# Download from https://code.visualstudio.com
# Verify
code --version
```

### 6. GitHub account
- Go to https://github.com and sign in (or create an account)

### 7. Configure Git identity (one-time per machine)
```powershell
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
git config --global core.autocrlf true    # Windows: normalise line endings
```

### 8. Authenticate GitHub CLI (optional but recommended)
```powershell
# Install GitHub CLI from https://cli.github.com
gh auth login
# Choose: GitHub.com → HTTPS → Login with browser
```

---

## Phase 0 — Secure Your GitHub Account

> **Do this before anything else.** If your GitHub account is compromised, every repo, every secret, and every environment is compromised with it. These steps take less than five minutes.

### Step 0.1 — Enable 2FA or a Passkey (mandatory)

1. Go to https://github.com/settings/security
2. Under **Two-factor authentication**, click **Enable**
3. Choose one of:
   - **Authenticator app** (recommended) — use Microsoft Authenticator, Google Authenticator, or Authy. Scan the QR code shown, enter the 6-digit code to confirm.
   - **Passkey** (most secure, passwordless) — click **Add a passkey**, follow your browser/device prompt (Windows Hello, Face ID, etc.)
4. **Save your recovery codes** — GitHub shows these once. Store them in your password manager. These are the only way back in if you lose your 2FA device.
5. Click **Done**

Verify: your profile shows a green shield or "2FA enabled" badge.

### Step 0.2 — Enable Secret Scanning and Push Protection

These are free for all repos (public and private).

For each repository:
1. Go to your repo on GitHub
2. Settings → Code security
3. Enable **Secret scanning** — GitHub will scan commits for accidentally included tokens/keys and alert you
4. Enable **Push protection** — GitHub will **block** a push that contains a known secret pattern before it ever lands in the repo

> Push protection is the important one. It stops the mistake at the source rather than cleaning it up after.

### Step 0.3 — Enable Dependabot

Settings → Code security:
- Enable **Dependabot alerts** — notifies you when a dependency has a known vulnerability
- Enable **Dependabot security updates** — automatically opens PRs to fix vulnerable dependencies

### Step 0.4 — Review authorised OAuth apps (optional but recommended)

Settings → Applications → Authorized OAuth Apps

Check what has access to your account. Revoke anything you do not recognise or no longer use. When you connect Claude Code Web to GitHub, it will appear here — that is expected.

---

## Phase 1 — Create the GitHub Repository

### Step 1.1 — Create the repo on GitHub

1. Go to https://github.com/new
2. Fill in:
   - **Repository name:** `your-project-name` (lowercase, hyphens, no spaces)
   - **Description:** One sentence describing the project
   - **Visibility:** Private (change to Public only if intentional)
   - **Initialize this repository with:** check `Add a README file`
   - **Add .gitignore:** None (you will add a proper one manually)
   - **Choose a license:** as appropriate
3. Click **Create repository**

### Step 1.2 — Note the repository URL

After creation, copy the HTTPS URL shown — looks like:
```
https://github.com/YourUsername/your-project-name.git
```

---

## Phase 2 — Clone the Repository Locally

### Step 2.1 — Choose your projects folder

Pick one consistent location for all your projects and stick to it.

```powershell
# Example — create a projects folder if it does not exist
mkdir C:\Projects
cd C:\Projects
```

### Step 2.2 — Clone

```powershell
git clone https://github.com/YourUsername/your-project-name.git
cd your-project-name
```

You now have a local copy linked to GitHub.

### Step 2.3 — Verify the link

```powershell
git remote -v
# Should show:
# origin  https://github.com/YourUsername/your-project-name.git (fetch)
# origin  https://github.com/YourUsername/your-project-name.git (push)
```

---

## Phase 3 — Create the Core File Structure

Run these commands from inside your project folder.

### Step 3.1 — Create the folder structure

```powershell
# Create directories
New-Item -ItemType Directory -Force -Path ".claude\commands"
New-Item -ItemType Directory -Force -Path ".claude\skills"
New-Item -ItemType Directory -Force -Path ".claude\rules"
New-Item -ItemType Directory -Force -Path ".claude\hooks"
New-Item -ItemType Directory -Force -Path ".github\workflows"
New-Item -ItemType Directory -Force -Path ".vscode"
New-Item -ItemType Directory -Force -Path "assets\screenshots"
New-Item -ItemType Directory -Force -Path "docs"
```

### Step 3.2 — Create .editorconfig

Create `.editorconfig` at the project root. This enforces consistent formatting for any editor (VS Code, JetBrains, Neovim, etc.) without requiring editor-specific plugins:

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
trim_trailing_whitespace = true
insert_final_newline = true

[*.md]
trim_trailing_whitespace = false

[*.{ps1,psm1,psd1,bat,cmd}]
end_of_line = crlf

[Makefile]
indent_style = tab
```

> For VS Code, install the EditorConfig extension — add `"editorconfig.editorconfig"` to `.vscode/extensions.json`.

### Step 3.3 — Create .gitignore

Create a file named `.gitignore` at the project root with this content:

```
# Secrets and credentials — NEVER commit these
.env
.env.*
*.key
*.pem
secrets/

# OS files
.DS_Store
Thumbs.db
desktop.ini

# Editor files (machine-specific only — shared settings.json is committed)
.vscode/launch.json
.vscode/tasks.json
*.suo
*.user

# Build output
bin/
obj/
dist/
build/
out/

# Logs
*.log
logs/

# Dependency folders
node_modules/
packages/

# Temp files
*.tmp
*.temp
~$*
```

### Step 3.4 — Create .gitattributes

Create `.gitattributes` at the project root:

```
# Auto-detect text files and normalise line endings
* text=auto

# Force LF for scripts
*.sh text eol=lf
*.bash text eol=lf

# Windows scripts keep CRLF
*.ps1 text eol=crlf
*.psm1 text eol=crlf
*.psd1 text eol=crlf
*.bat text eol=crlf
*.cmd text eol=crlf

# Binary files — Git LFS
*.png filter=lfs diff=lfs merge=lfs -text
*.jpg filter=lfs diff=lfs merge=lfs -text
*.jpeg filter=lfs diff=lfs merge=lfs -text
*.gif filter=lfs diff=lfs merge=lfs -text
*.bmp filter=lfs diff=lfs merge=lfs -text
*.ico filter=lfs diff=lfs merge=lfs -text

*.pdf filter=lfs diff=lfs merge=lfs -text
*.zip filter=lfs diff=lfs merge=lfs -text
*.msi filter=lfs diff=lfs merge=lfs -text
*.exe filter=lfs diff=lfs merge=lfs -text
*.dll filter=lfs diff=lfs merge=lfs -text
*.mp4 filter=lfs diff=lfs merge=lfs -text
*.mov filter=lfs diff=lfs merge=lfs -text
```

### Step 3.5 — Create CLAUDE.md

Create `CLAUDE.md` at the project root. This is the AI constitution — edit the bracketed sections for each new project:

```markdown
# CLAUDE.md

Instructions for Claude Code in this repository.

## Project

[One paragraph: what this project is, what it does, its purpose.]

## Technology Stack

- [List the main languages, frameworks, tools used]

## Repository Structure

[Brief description of what lives where once the project has content]

## Git Workflow

### Branch Naming
- Feature branches: `feature/<short-description>`
- Bug fix branches: `fix/<short-description>`
- AI-assisted branches: `claude/<task-id>-<description>`
- Never push directly to `main`

### Commit Messages
- First line: imperative, 50 characters or less
- Reference issues when applicable: `Fixes #42`
- Examples: `Add user authentication`, `Fix null pointer in parser`

## Claude Behaviour

### Do
- Read files before editing them
- Keep changes minimal and focused
- Prefer editing existing files over creating new ones
- Run tests before committing if a test suite exists
- Update CLAUDE.md when a new pattern or tool is introduced

### Do Not
- Add comments, docstrings, or type annotations to unchanged code
- Add error handling for scenarios that cannot happen
- Add features beyond what was explicitly requested
- Push to any branch other than the designated feature branch
- Commit secrets, credentials, or API keys

### Risky Actions — Always Ask First
- Deleting files or directories
- Force-pushing
- Modifying CI/CD pipelines
- Creating or closing GitHub issues/PRs on behalf of the user

## Commands

[Update this section once tooling is configured]

\`\`\`bash
# Run tests
# (command here)

# Build
# (command here)

# Lint / format
# (command here)
\`\`\`
```

### Step 3.6 — Create .claude/settings.json

Create `.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(gh *)",
      "Bash(npm run *)",
      "Bash(npm install)",
      "Bash(npm test)",
      "Bash(node --version)",
      "Edit(TASKS.md)",
      "Write(TASKS.md)"
    ],
    "_comment_deny": "Mirrored by .claude/hooks/pre-tool-use.sh — both layers are intentional defense-in-depth. If you change one, change the other.",
    "deny": [
      "Bash(git push --force*)",
      "Bash(git push * --force*)",
      "Bash(git push --no-verify*)",
      "Bash(git push * --no-verify*)",
      "Bash(git reset --hard*)",
      "Bash(git rebase -i*)",
      "Bash(rm -rf *)",
      "Bash(curl *)",
      "Bash(wget *)",
      "Read(**/.env)",
      "Read(**/.env.*)",
      "Read(**/.ssh/*)",
      "Read(**/*.pem)",
      "Read(**/*.key)"
    ]
  },
  "env": {
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "80"
  },
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-start.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/pre-tool-use.sh"
          }
        ]
      }
    ],
    "ConfigChange": [
      {
        "matcher": "project_settings",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Project settings change blocked. Edit .claude/settings.json manually outside of a session.' && exit 2"
          }
        ]
      }
    ]
  }
}
```

Key settings:
- `allow` — tools Claude can use without asking. Keep it narrow: `Bash(npm run *)` rather than `Bash(npm *)`, so `npm publish` still prompts. Add your own stack's build and test commands here (see `SETUP.md` for per-stack suggestions).
- `deny` — destructive operations and secret reads Claude must never perform. The bash rules here are deliberately duplicated in `.claude/hooks/pre-tool-use.sh`: `deny` uses prefix-glob matching, which misses `rm -rfv` and `&&`-chained variants, and the hook catches those with regex. **Change one layer, change the other.**
- `env.CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` — triggers context compaction at 80% usage (default is 95%), leaving more headroom before a session is interrupted.
- `hooks.SessionStart` — runs `.claude/hooks/session-start.sh` at the start of every session to print git status, open tasks, and a branch warning.
- `hooks.PreToolUse` — runs the guardrail script before every tool call.
- `hooks.ConfigChange` — blocks in-session edits to the project settings file, so permission changes are a deliberate act outside a session.

See `docs/concepts.md` section 12 for the full list of hook events and types, and section 13 for sandboxing — an OS-level layer beneath permissions.

> **Note:** MCP server configuration belongs in `.mcp.json` at the repo root (Phase 7), not here. Keep this file to permissions, env vars, and hooks only.

### Step 3.7 — Create .claude/.gitignore

This keeps personal/local Claude files out of the repo:

```
# Personal / machine-specific — do not commit
settings.local.json
*.local.md
.DS_Store
```

### Step 3.7b — Create .claude/settings.local.json.example

This file documents the format for the machine-specific MCP config. It is committed to the repo so every developer knows what to create — but the real `settings.local.json` (which contains tokens) is gitignored.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/path/to/this/repo"
      ]
    },
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your-fine-grained-token-here"
      }
    }
  }
}
```

Each developer copies this file and fills in their own values:

```bash
cp .claude/settings.local.json.example .claude/settings.local.json
```

### Step 3.8 — Create custom commands

Custom commands are Markdown files in `.claude/commands/` that become `/slash-commands` in Claude Code. They are prompt templates shared with everyone on the project.

Create `.claude/commands/review-code.md`:

```markdown
Review the code changes on the current branch compared to main.

Focus on:
1. Correctness — does the code do what it claims?
2. Security — any OWASP top 10 issues (injection, XSS, secrets, etc.)?
3. Simplicity — is the code unnecessarily complex?
4. Naming — are variables, functions, and files named clearly?

For each issue found, state:
- **File and line**
- **Severity** (critical / warning / suggestion)
- **What** is wrong
- **Why** it matters
- **Fix** — concrete suggestion

If everything looks good, say so briefly. Do not invent issues.
```

Create `.claude/commands/commit-message.md`:

```markdown
Look at the current staged and unstaged changes (run `git diff` and `git diff --cached`).

Draft a commit message following these rules:
- First line: imperative mood, 50 characters or less
- If needed, add a blank line then a body explaining *why*, not *what*
- Reference issue numbers if applicable

Show the proposed message and ask for confirmation before committing.
```

Create `.claude/commands/write-docs.md` — generates technical documentation (runbooks, ADRs, API references, diagrams) following the standards in `.claude/rules/documentation.md`. Usage: `/write-docs runbook for the payment service` or just `/write-docs` to be prompted for subject and audience. See `.claude/rules/documentation.md` for the full template and audience-level conventions.

> Add more commands as your project needs them. Each `.md` file automatically becomes a `/command-name` slash command. You can also create personal commands in `~/.claude/commands/` — these are not committed and apply to all projects on your machine.

### Skills

Skills are the newer, more powerful format for slash commands. They live in `.claude/skills/<name>/SKILL.md` and support YAML frontmatter for auto-invocation and argument passing, plus supporting files in the same directory.

Create `.claude/skills/sync-template/SKILL.md` — the `/sync-template` command. It fetches the Claude Code release notes, compares them against the template files, guides you through applying updates, and updates `.claude/docs-baseline.hash` to reset the change-detection baseline. Run this whenever the `claude-docs-update` GitHub issue is opened (see Step 3.11).

### Step 3.9 — Create rules

Rules are topic-specific instruction files in `.claude/rules/`. They supplement `CLAUDE.md` with detailed standards.

Create `.claude/rules/code-style.md`:

```markdown
# Code Style

- Use 2-space indentation (configured in .vscode/settings.json)
- Prefer simple, readable code over clever code
- Do not add comments to self-explanatory code
- Do not add type annotations, docstrings, or comments to code you did not change
- Three similar lines of code is better than a premature abstraction
- Only validate at system boundaries (user input, external APIs) — trust internal code
```

Create `.claude/rules/documentation.md` — defines audience levels (Developer / Ops-L2 / L1 Support / Stakeholder), document templates (ADR, runbook, API reference, diagrams), style rules, and anti-patterns. Referenced by the `/write-docs` command. Copy the full file from the template repo or see `docs/concepts.md` for the structure.

> Add more rule files as needed (e.g., `security.md`, `testing.md`). Claude reads all files in `.claude/rules/` at session start.

### Step 3.10 — Create .vscode/settings.json

Create `.vscode/settings.json` with shared, project-level editor settings. These apply to everyone who opens the project in VS Code — no machine-specific paths or personal preferences here.

```json
{
  "editor.formatOnSave": true,
  "editor.insertSpaces": true,
  "editor.tabSize": 2,
  "editor.rulers": [100],
  "editor.trimAutoWhitespace": true,
  "files.eol": "\n",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true,
  "explorer.confirmDelete": true,
  "explorer.confirmDragAndDrop": false,
  "git.autofetch": true,
  "git.confirmSync": false,
  "git.pruneOnFetch": true,
  "terminal.integrated.scrollback": 5000
}
```

> This file is committed to the repo. Machine-specific VS Code files (`.vscode/launch.json`, `.vscode/tasks.json`) remain gitignored.

### Step 3.11 — Update README.md

Open `README.md` (created by GitHub) and replace its content:

```markdown
# Project Name

One sentence describing what this project does.

## Overview

[2-3 sentences about the project once content exists]

## Getting Started

See [docs/setup-guide.md](docs/setup-guide.md) for full setup instructions.

## Repository Structure

\`\`\`
.claude/           — Claude Code configuration (commands, rules, hooks)
.github/           — GitHub Actions workflows
assets/            — Images and binary files
docs/              — Documentation
\`\`\`

## Development

[Add commands and workflow notes here once tooling is in place]
```

### Step 3.12 — Create the CI workflow placeholder

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: ["**"]
  pull_request:
    branches: [main]

jobs:
  validate:
    name: Validate
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Check for secrets
        run: |
          echo "CI placeholder — add test/lint/build steps here"
          echo "Branch: ${{ github.ref_name }}"
          echo "Commit: ${{ github.sha }}"
```

> This placeholder ensures CI runs on every push from day one. Replace the `echo` lines with real test commands once the project has them.

Create `.github/workflows/claude-docs-watch.yml` — runs every Monday at 09:00 UTC. Fetches the raw Claude Code changelog (`raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md`), SHA-256 hashes it, and compares that against `.claude/docs-baseline.hash`. If it has changed and no open `claude-docs-update` issue exists, it opens one automatically and publishes the new hash in the issue body. Copy this file from the template repo; no configuration needed.

> Hash the **raw** changelog, not a docs-site page. Rendered HTML changes between requests, so hashing it reports a change every single run.

After creating this workflow, create the baseline seed file:

```bash
echo "none" > .claude/docs-baseline.hash
```

The first workflow run will detect a mismatch (since `none` is not a real hash), open a review issue, and prompt you to run `/sync-template`. Subsequent runs stay silent until the changelog actually changes.

**Responding to the review issue:** open a Claude Code session and run `/sync-template`. It will fetch the changelog, compare it against the template files — including `docs/setup-guide.md`, `SETUP.md`, and `README.md` — suggest specific updates, and apply what you approve. To close the loop, copy the hash from the issue's **New baseline hash** section into `.claude/docs-baseline.hash`, commit, and close the issue.

> The hash is published in the issue rather than computed locally because `Bash(curl *)` is denied in `.claude/settings.json` and blocked again by `pre-tool-use.sh` — a Claude session cannot fetch the changelog bytes itself.

### Step 3.13 — Create the pre-commit secret detection hook

This client-side hook blocks commits that contain common secret patterns (API keys, tokens, passwords) before they reach the repo. It complements GitHub's server-side push protection.

Create `.githooks/pre-commit`:

```bash
#!/usr/bin/env bash
# Pre-commit hook: detect common secret patterns before they reach the repo.
# Install once per machine: git config core.hooksPath .githooks
set -euo pipefail

PATTERNS=(
  'AKIA[0-9A-Z]{16}'
  'sk-[a-zA-Z0-9]{32,}'
  'ghp_[a-zA-Z0-9]{36}'
  'github_pat_[a-zA-Z0-9_]{82}'
  'xox[baprs]-[a-zA-Z0-9-]+'
  'AIza[0-9A-Za-z_-]{35}'
  'eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.'
  'password\s*=\s*["\x27][^"\x27]{8,}'
  'api[_-]?key\s*=\s*["\x27][^"\x27]{8,}'
  'secret\s*=\s*["\x27][^"\x27]{8,}'
)

STAGED=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)
[ -z "$STAGED" ] && exit 0

FOUND=0
DIFF=$(git diff --cached -U0 | grep '^+' | grep -v '^+++' || true)
[ -z "$DIFF" ] && exit 0

for pattern in "${PATTERNS[@]}"; do
  matches=$(echo "$DIFF" | grep -iE "$pattern" || true)
  if [ -n "$matches" ]; then
    echo "BLOCKED: Potential secret detected (pattern: $pattern)"
    echo "$matches"
    FOUND=1
  fi
done

if [ "$FOUND" -ne 0 ]; then
  echo ""
  echo "Commit blocked. To bypass a confirmed false positive: git commit --no-verify"
  exit 1
fi
```

Make it executable and activate it:

```bash
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
```

> `git config core.hooksPath .githooks` is a local setting — each developer must run it once after cloning. Add it to the clone instructions in `SETUP.md` (already done in this template).

### Step 3.14 — Create GitHub issue templates

Create `.github/ISSUE_TEMPLATE/bug_report.md`:

```markdown
---
name: Bug report
about: Something is not working as expected
labels: bug
---

## Description

## Steps to reproduce

1.
2.
3.

## Expected behaviour

## Actual behaviour

## Environment

- OS:
- Relevant tool / library versions:

## Additional context
```

Create `.github/ISSUE_TEMPLATE/feature_request.md`:

```markdown
---
name: Feature request
about: Propose a new feature or improvement
labels: enhancement
---

## Problem

## Proposed solution

## Alternatives considered

## Additional context
```

### Step 3.15 — Create the CodeQL security analysis workflow

Create `.github/workflows/codeql.yml`. This workflow runs GitHub's static analysis on every PR and weekly on main. Add languages to the matrix as the project acquires code — until then it runs but performs no analysis.

```yaml
name: CodeQL

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 9 * * 1'

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write

    strategy:
      fail-fast: false
      matrix:
        # Add languages here as the project grows.
        # Supported: javascript, typescript, python, java, go, ruby, csharp, cpp
        language: []

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Initialize CodeQL
        uses: github/codeql-action/init@v4
        with:
          languages: ${{ matrix.language }}

      - name: Autobuild
        uses: github/codeql-action/autobuild@v4

      - name: Perform CodeQL analysis
        uses: github/codeql-action/analyze@v4
        with:
          category: '/language:${{ matrix.language }}'
```

> To activate: add your language(s) to the `language` array and push. GitHub will start reporting security findings under Security → Code scanning.

### Step 3.16 — Initial commit

```powershell
git add .editorconfig .gitignore .gitattributes CLAUDE.md README.md
git add .claude/settings.json .claude/.gitignore .claude/docs-baseline.hash
git add .claude/settings.local.json.example
git add .claude/commands/ .claude/rules/ .claude/skills/
git add .github/workflows/ci.yml .github/workflows/codeql.yml .github/workflows/claude-docs-watch.yml
git add .github/ISSUE_TEMPLATE/
git add .githooks/
git add .vscode/extensions.json .vscode/settings.json
git add docs/
git add assets/

git commit -m "Initial project scaffold — template structure"
git push -u origin main
```

After pushing, activate the git hook on this machine:

```bash
git config core.hooksPath .githooks
```

---

## Phase 4 — Configure GitHub Repository Settings

All of these are done in the GitHub web UI. Navigate to your repo → **Settings**.

### Step 4.1 — General settings

Settings → General:
- **Default branch:** confirm it is `main`
- **Features:** disable Wiki and Projects unless you need them
- **Pull Requests:**
  - Check: `Allow squash merging`
  - Uncheck: `Allow merge commits` (keeps history clean)
  - Check: `Allow rebase merging`
  - Check: `Automatically delete head branches` ← important, cleans up merged branches

### Step 4.2 — Branch protection on main

Settings → Branches → **Add branch protection rule**:

- **Branch name pattern:** `main`
- Check: `Require a pull request before merging`
  - Check: `Require approvals` — set to 1 (or 0 for solo projects)
- Check: `Require status checks to pass before merging`
  - Search for and add: `validate` (the CI job name from ci.yml)
  - Check: `Require branches to be up to date before merging`
- Check: `Do not allow bypassing the above settings`
- Click **Save changes**

> This makes it physically impossible to push directly to `main` or merge a failing PR.

### Step 4.3 — Create Environments

Settings → Environments → **New environment** — create all three:

#### Development environment
- Name: `development`
- No protection rules needed
- Add any dev-specific secrets/variables if you have them

#### Staging environment
- Name: `staging`
- No protection rules needed
- Add staging-specific secrets/variables

#### Production environment
- Name: `production`
- Check: `Required reviewers` — add yourself
- Check: `Prevent self-review` — optional
- Add production-specific secrets/variables

### Step 4.4 — Add repository secrets (template placeholders)

Settings → Secrets and variables → Actions → **New repository secret**

Add these now as empty placeholders so you remember to fill them in:

| Secret name | Purpose |
|---|---|
| `GITHUB_TOKEN` | Auto-provided by GitHub — no action needed |

Add environment-specific secrets under each environment (Settings → Environments → select environment → Add secret).

### Step 4.5 — Enable CodeQL (Code scanning)

Settings → Code security → **Code scanning**:

1. Click **Set up** next to "CodeQL analysis"
2. Choose **Default** setup — GitHub selects languages automatically, or
3. Choose **Advanced** if you want to use the `.github/workflows/codeql.yml` already in the repo (recommended — keeps config in version control)

Once activated, CodeQL results appear under Security → Code scanning alerts.

> CodeQL is free for all public repos and for private repos on GitHub Team / Enterprise. On free private repos, activate it under Settings → Code security → Code scanning — it may prompt you to enable GitHub Advanced Security.

---

## Phase 5 — Set Up Claude Code Web

This connects claude.ai to your GitHub repository.

### Step 5.1 — Authorise GitHub access

1. Go to https://claude.ai
2. Start a new conversation or project
3. If using **Projects:** Create a new Project, then connect the GitHub repo:
   - Project Settings → Integrations → GitHub → Connect
   - Authorise Anthropic to access your GitHub account
   - Select the specific repository

### Step 5.2 — Verify CLAUDE.md is read

In a Claude Web session, simply ask:
```
What does this repository do and what are the branch naming conventions?
```
Claude should answer using the content of your `CLAUDE.md`. If it cannot, the repo connection is not active.

### Step 5.3 — Configure the Session Start hook (for Web)

The session-start hook ensures Claude has a working environment at the start of each Web session — particularly useful for running setup commands.

In your Claude Web session, use the `/session-start-hook` skill or ask Claude to set up a session-start hook. At minimum it should:
- Confirm the repo is cloned and up to date
- Confirm the branch structure
- Echo environment info

> Claude Code Web sessions run in an ephemeral environment. The hook re-establishes context each time.

---

## Phase 6 — Set Up Claude Code CLI (Local)

### Step 6.1 — Authenticate

```powershell
claude auth login
# Opens browser — log in with your Anthropic account
```

Verify:
```powershell
claude --version
claude auth status
```

### Step 6.2 — Start Claude in your project

```powershell
cd C:\Projects\your-project-name
claude
```

Claude starts, reads `CLAUDE.md` and `.claude/settings.json`, and is ready.

### Step 6.3 — Verify it reads your config

Type in the Claude CLI session:
```
What are the branch naming conventions for this project?
```
It should answer from your `CLAUDE.md`.

### Step 6.4 — Global CLI settings (optional)

For settings that apply to all projects on this machine (not committed to any repo):

```powershell
# Location: C:\Users\YourName\.claude\settings.json
# Or on the CLI:
claude config
```

---

## Phase 7 — Set Up MCP Servers

MCP servers extend Claude's reach beyond the codebase. Project-scoped MCP configuration belongs in `.mcp.json` at the repo root — this file is safe to commit as long as it contains no secrets. Personal config (including tokens) goes in `~/.claude.json` on your machine, which is never committed.

### Step 7.1 — Install MCP servers

```powershell
# Filesystem server — gives Claude access to local files/folders
npm install -g @modelcontextprotocol/server-filesystem

# GitHub server — gives Claude access to GitHub API (issues, PRs, metadata)
npm install -g @modelcontextprotocol/server-github
```

### Step 7.2 — Create a GitHub Personal Access Token

Required for the GitHub MCP server. Use a **fine-grained token** — it is scoped to specific repos and permissions, so a leaked token has minimal blast radius compared to a classic token.

1. Go to https://github.com/settings/tokens?type=beta
2. Click **Generate new token**
3. Fill in:
   - **Token name:** `Claude MCP - your-project-name`
   - **Expiration:** 90 days (calendar reminder to renew)
   - **Resource owner:** your username
   - **Repository access:** select `Only select repositories` → choose your specific repo
4. Under **Permissions**, set:
   - **Contents:** Read and write
   - **Metadata:** Read-only (auto-selected)
   - **Pull requests:** Read and write
   - **Issues:** Read and write
5. Click **Generate token**
6. **Copy it immediately** — you cannot see it again

Store it securely in your password manager or Windows Credential Manager (`Control Panel → Credential Manager → Windows Credentials → Add a generic credential`). Never paste it into a file, chat, or terminal that might be logged.

### Step 7.3 — Configure .mcp.json (project-level, no secrets)

Create `.mcp.json` at the repo root with the filesystem server. This file is committed to Git — keep it secrets-free:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:\\Projects\\your-project-name"
      ]
    }
  }
}
```

The filesystem path above is machine-specific, so if the project is used on multiple machines you can either leave it as a placeholder for each developer to fill in locally, or omit the filesystem server from `.mcp.json` entirely and add it to your user-level config instead.

### Step 7.3b — Add the GitHub MCP server to your user-level config (with token)

The GitHub server requires a personal access token — a secret that must never be committed. Add it to your machine-level config (`~/.claude.json`) so it applies across all your projects without touching the repo:

```powershell
# Open (or create) C:\Users\YourName\.claude.json and add:
```

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your-token-here"
      }
    }
  }
}
```

Replace `your-token-here` with the fine-grained token you created in Step 7.2. This file lives only on your machine and is never committed.

### Step 7.4 — Commit .mcp.json

```powershell
git add .mcp.json
git commit -m "Add project MCP server configuration"
git push
```

---

## Phase 8 — Set Up VSCode + Claude Code Extension

### Step 8.1 — Install the extension

1. Open VSCode
2. Press `Ctrl+Shift+X` to open Extensions
3. Search: `Claude Code`
4. Install the official Anthropic extension
5. Reload VSCode

### Step 8.2 — Open your project

```powershell
code C:\Projects\your-project-name
```

Or: File → Open Folder → navigate to your project.

### Step 8.3 — Sign in to Claude

1. Click the Claude icon in the VSCode sidebar (or press `Ctrl+Shift+P` → type `Claude`)
2. Sign in with your Anthropic account
3. Claude reads `CLAUDE.md` and `.claude/settings.json` from the open workspace automatically

### Step 8.4 — Verify

In the Claude panel inside VSCode, ask:
```
What does this project do and what are the branch naming conventions?
```
It should answer from `CLAUDE.md`.

### Step 8.5 — VSCode workspace settings (optional)

Create `.vscode/extensions.json` to recommend the extension to anyone who opens the project:

```json
{
  "recommendations": [
    "anthropic.claude-code"
  ]
}
```

Both `.vscode/extensions.json` and `.vscode/settings.json` are committed to the repo — they contain project-level preferences (recommended extension + shared editor settings), not machine-specific config.

```powershell
git add .vscode/extensions.json .vscode/settings.json
git commit -m "Add VS Code extension recommendation and shared editor settings"
git push
```

> If you followed Phase 3, these files already exist and were included in the initial commit. Skip this if already done.

---

## Phase 9 — Verification Checklist

Run through every item before considering the setup complete.

### GitHub Account Security
- [ ] 2FA or passkey is enabled on your GitHub account
- [ ] Recovery codes are saved in your password manager
- [ ] Secret scanning is enabled on the repo
- [ ] Push protection is enabled on the repo
- [ ] Dependabot alerts are enabled on the repo

### Repository
- [ ] Repo exists on GitHub and is cloned locally
- [ ] Repo is set to **Private**
- [ ] `main` branch has protection rules — direct push is blocked
- [ ] Three environments exist: `development`, `staging`, `production`
- [ ] `CLAUDE.md` is at the repo root with real content
- [ ] `.gitignore` is in place and includes `.env`, `*.key`, `secrets/`
- [ ] `.gitattributes` is in place with LFS rules
- [ ] `.editorconfig` is at the repo root
- [ ] Pre-commit hook is active: `git config --get core.hooksPath` returns `.githooks`
- [ ] GitHub issue templates exist (bug report + feature request)
- [ ] CodeQL workflow is in `.github/workflows/codeql.yml`
- [ ] CI workflow runs on every push (check the Actions tab on GitHub)
- [ ] No secrets or tokens are present anywhere in the commit history

### Claude Code Web
- [ ] Repo is connected to Claude via GitHub OAuth
- [ ] Asking about branch conventions returns the correct answer from `CLAUDE.md`
- [ ] Session-start hook is configured

### Claude Code CLI
- [ ] `claude auth status` shows authenticated
- [ ] Running `claude` inside the project folder starts without errors
- [ ] Asking about branch conventions returns the correct answer from `CLAUDE.md`
- [ ] MCP servers load without errors (check output when Claude starts)
- [ ] Run `/memory` — confirm all expected instruction files are listed

### VSCode Extension
- [ ] Extension is installed and signed in
- [ ] Project opens in VSCode and Claude panel is visible
- [ ] Asking about branch conventions returns the correct answer from `CLAUDE.md`

### End-to-end test — run this once
1. In CLI or VSCode, ask Claude: `Create a test branch called feature/setup-verified, add a file called test.txt with the text "setup ok", commit it, and push`
2. Check GitHub — the branch and commit should appear
3. Open a PR on GitHub
4. Confirm CI runs and passes
5. Close/delete the PR and branch (no merge needed — this is just a test)

---

## Phase 10 — Final Commit and State Snapshot

```powershell
git add -A
git status    # Review — make sure nothing sensitive is staged
git commit -m "Complete default template setup"
git push
```

Your repository is now a fully functional, reusable template. To start a new project:
1. Create a new GitHub repo (Phase 1)
2. Clone it (Phase 2)
3. Copy the template files from this repo (Phase 3 files)
4. Update the bracketed sections in `CLAUDE.md` and `README.md`
5. Configure GitHub settings (Phase 4)
6. Connect Claude (Phases 5–8 are machine-level — done once, not per project)

**Keeping the template current:** the `claude-docs-watch` workflow runs automatically every Monday. When it detects that the Claude Code changelog has changed, it opens a GitHub issue containing the new baseline hash. Run `/sync-template` in a Claude Code session to review the changes, apply updates to template files and guides, and write the published hash to `.claude/docs-baseline.hash`. This keeps the template aligned with the latest Claude Code features and deprecations without any manual monitoring.

---

## Reference — File Summary

| File | Purpose | Commit to repo? |
|---|---|---|
| `.editorconfig` | Editor-neutral formatting rules (indentation, line endings) | Yes |
| `.gitignore` | Excludes unwanted files from Git | Yes |
| `.gitattributes` | Line ending rules + LFS routing | Yes |
| `.githooks/pre-commit` | Blocks commits containing common secret patterns | Yes |
| `CLAUDE.md` | Claude's standing instructions | Yes |
| `CLAUDE.local.md` | Personal Claude instructions | **No** (gitignored) |
| `.mcp.json` | Project MCP server configuration (no secrets) | Yes |
| `.claude/settings.json` | Permissions and hooks | Yes |
| `.claude/settings.local.json` | Personal MCP tokens and overrides | **No** (gitignored) |
| `.claude/settings.local.json.example` | Template for settings.local.json — copy and fill in | Yes |
| `.claude/.gitignore` | Excludes local files within `.claude/` | Yes |
| `.claude/commands/*.md` | Custom slash commands (`/review-code`, `/commit-message`, `/write-docs`) | Yes |
| `.claude/skills/<name>/SKILL.md` | Skills with YAML frontmatter and supporting files (`/sync-template`) | Yes |
| `.claude/rules/*.md` | Topic-specific Claude instructions (`code-style.md`, `documentation.md`) | Yes |
| `.claude/hooks/*.sh` | Hook scripts (session-start, etc.) | Yes |
| `.claude/docs-baseline.hash` | SHA-256 hash of the last-reviewed Claude Code changelog | Yes |
| `.github/workflows/ci.yml` | Automated CI on every push | Yes |
| `.github/workflows/codeql.yml` | Static security analysis — activate by adding languages to matrix | Yes |
| `.github/workflows/claude-docs-watch.yml` | Weekly check for Claude Code changelog changes; opens review issue with the new baseline hash | Yes |
| `.github/ISSUE_TEMPLATE/bug_report.md` | Bug report template | Yes |
| `.github/ISSUE_TEMPLATE/feature_request.md` | Feature request template | Yes |
| `README.md` | Human-readable project overview | Yes |
| `.vscode/extensions.json` | Recommended VS Code extensions | Yes |
| `.vscode/settings.json` | Shared project editor settings | Yes |
| `.env` / `*.key` | Secrets and credentials | **Never** |
| `~/.claude/settings.json` | Machine-level global Claude config | No (local only) |
| `~/.claude/commands/*.md` | Personal global commands | No (local only) |
