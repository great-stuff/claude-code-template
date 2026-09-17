# Getting started: Claude Code on the Web

Audience: Developer

The web surface requires no installation. Connect a GitHub repository to claude.ai and Claude can read and write code, run commands via the session-start hook, and open pull requests — all from the browser. It is scoped to the connected repository and does not persist local state between sessions.

---

## Prerequisites

| Requirement | Notes |
|---|---|
| GitHub account | Connected to [claude.ai](https://claude.ai) |
| Claude account | [claude.ai](https://claude.ai) — free or Pro |

No local tools required.

---

## Common setup (all surfaces)

Follow [SETUP.md](../SETUP.md) for:

- **Phase 0** — Secure your GitHub account (2FA, secret scanning, push protection, Dependabot)
- **Phase 1** — Create the GitHub repository

You do not need to clone the repository locally for web-only use. Skip the Node.js, Claude Code CLI, and git hooks prerequisites.

---

## Web-specific setup

### Connect the repository

1. Go to [claude.ai](https://claude.ai)
2. Open or create a Project
3. Connect your GitHub repository under **Project settings → GitHub**

Claude gains read/write access to the connected repository.

### Session-start hook

`.claude/hooks/session-start.sh` runs automatically at the start of every web session. It prints the current date, runs `git fetch`, and shows `git status` to orient Claude.

To extend it for your stack, edit the file and uncomment the relevant block (Node, Python, etc.):

```bash
# The hook detects Claude Code Web (remote) sessions automatically:
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi
```

The hook runs on every surface to show repository context. Only the remote-only fetch and optional dependency setup run in web sessions.

### MCP servers on the web

Web sessions cannot use `settings.local.json` (it is a local file and is gitignored). Instead:

- Use `.mcp.json` at the repo root for project-scoped MCP config that contains no secrets
- Pass tokens via environment variables set in your claude.ai Project settings, then read them in `session-start.sh`

---

## Limitations

| Feature | Web | CLI / VS Code |
|---|---|---|
| File access | Connected repo only | Full local filesystem |
| `pre-commit` / `commit-msg` hooks | No — hooks run locally on commit | Yes |
| `settings.local.json` MCP config | No | Yes |
| `CLAUDE.local.md` overrides | No | Yes |
| Persistent local state between sessions | No — resets each session | Yes |
| Auto-memory | Yes | Yes |

Because git hooks do not run in the browser, commits made through the web session bypass the pre-commit secret scanner and commit-msg length check. Review commits made via web sessions before merging.

---

## Daily workflow on the web

1. Open a session in claude.ai — the session-start hook runs automatically
2. Claude reads `CLAUDE.md`, `.claude/rules/*.md`, and slash commands
3. Work in the session — Claude can read, write, and run git operations
4. Commit and push via Claude; the PR is opened on GitHub
5. Review the PR on GitHub before merging — hooks did not run, so verify manually
6. Session ends — no local state persists; all work is in git

---

## What Claude reads automatically

Every session, Claude loads:

| File | Purpose |
|---|---|
| `CLAUDE.md` | Project conventions, access rules, coding guidelines |
| `.claude/rules/*.md` | Code style, documentation standards |
| `.claude/commands/*.md` | Slash commands: `/review-code`, `/commit-message`, `/write-docs` |

Run `/memory` in any session to see all loaded instructions, including auto-saved notes from previous sessions.

---

## Slash commands

| Command | What it does |
|---|---|
| `/review-code` | Reviews current branch changes for correctness, security, and simplicity |
| `/commit-message` | Drafts a commit message from staged changes |
| `/pr` | Creates a pull request from the current branch with a drafted description |
| `/test` | Writes tests for new or changed code, matching the project's framework |
| `/explain` | Explains code, files, or architectural patterns in the project |
| `/debug` | Systematically investigates an issue — gather evidence, hypothesise, fix |
| `/security-audit` | Runs a security audit — config, secrets, dependencies, CI, OWASP patterns |
| `/write-docs` | Generates runbooks, ADRs, API references, or diagrams |
| `/sync-template` | Reviews Claude Code release notes and updates the template |
