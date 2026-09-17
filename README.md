# Project Name

> Replace this line with a one-sentence description of your project.

---

## What's in this template

A production-ready scaffold for GitHub projects with Claude Code integration built in from day one.

| Area | What's included |
|---|---|
| **AI integration** | `CLAUDE.md` project constitution, standing rules, slash commands, skills, MCP config |
| **Git guardrails** | Pre-commit secret scanner, commit-msg length enforcer, branch naming conventions |
| **GitHub automation** | Configuration CI, weekly Claude Code docs monitor, Dependabot, CodeQL-ready workflow |
| **Security** | Secret scanning, push protection, vulnerability policy, `.gitignore` for credentials |
| **Documentation** | Concepts guide, setup walkthrough, ADR / runbook / API doc templates |
| **Binary files** | `.gitattributes` routes images, fonts, and videos through Git LFS automatically |
| **Editor config** | `.editorconfig` and `.vscode/settings.json` for consistent formatting across machines |
| **MCP ready** | `.mcp.json` for project-scoped servers; `settings.local.json` template for local tokens |

---

## Getting Started

See [SETUP.md](SETUP.md) for full setup instructions, including prerequisites, cloning, and tool configuration.

---

## AI-Assisted Development

This repository is configured for use with **Claude Code** across all three surfaces. Pick yours and follow the start guide:

| Surface | Start guide | Quick access |
|---|---|---|
| **Claude Code CLI** | [docs/start-cli.md](docs/start-cli.md) | Run `claude` from the project root |
| **Claude VS Code Extension** | [docs/start-vscode.md](docs/start-vscode.md) | Install `anthropic.claude-code`, open the project folder |
| **Claude Code on the Web** | [docs/start-web.md](docs/start-web.md) | Connect your repo at claude.ai — no install needed |

Claude reads [`CLAUDE.md`](CLAUDE.md) on every session start. That file contains project conventions, access restrictions, and coding guidelines. Update it as the project evolves.

---

## Repository Layout

```
your-project-name/
├── .claude/
│   ├── .gitignore             # Ignores local-only files inside .claude/ (settings.local.json, harvest-queue.md, .DS_Store)
│   ├── settings.json          # Shared Claude permissions, env vars, and hooks (committed)
│   ├── settings.local.json    # Machine-specific tokens and MCP servers (gitignored)
│   ├── settings.local.json.example  # Template for settings.local.json — copy and fill in
│   ├── docs-baseline.hash     # SHA-256 of last-reviewed Claude Code changelog
│   ├── commands/              # Slash commands: /review-code, /commit-message, /pr, /test, /explain, /debug, /security-audit, /write-docs, /task-add, /task-done, /task-list
│   ├── skills/                # Skills: /adr-new, /avoid-ai-writing, /brainstorm, /changelog, /consistency-check-docs, /diagram, /export-prompt, /harvest, /inbox-process, /release-notes, /sync-template, /troubleshooting
│   ├── rules/                 # Standing instructions: branch-audit, code-style, documentation, goal-driven-execution, harvest-flag, mental-models, outbox-capture, session-start, troubleshooting-verification
│   ├── template-baseline.md   # Fork-time snapshot — inherited files, commit SHA, template URL
│   ├── harvest-queue.md       # Transient harvest flag queue (gitignored)
│   ├── README.md              # Index of commands and skills (keep in sync when adding/removing)
│   └── hooks/
│       ├── pre-tool-use.sh    # Blocks reading secrets, external fetches, rm -r* (defense-in-depth)
│       └── session-start.sh   # Runs at the start of every Claude session
├── .github/
│   ├── workflows/
│   │   ├── ci.yml             # Configuration CI — add project checks as the codebase grows
│   │   ├── codeql.yml         # CodeQL-ready workflow — add languages to activate
│   │   ├── claude-docs-watch.yml  # Weekly check for Claude Code doc changes
│   │   └── shellcheck.yml     # Lints .claude/hooks/ and .githooks/ on every PR
│   ├── ISSUE_TEMPLATE/        # Bug report and feature request templates
│   ├── pull_request_template.md
│   └── dependabot.yml         # Automated dependency update PRs
├── .githooks/
│   ├── pre-commit             # Blocks commits with secret patterns
│   ├── commit-msg             # Enforces commit message format (≤ 50 chars, no period)
│   ├── post-checkout          # Git LFS shim (required when core.hooksPath = .githooks)
│   ├── post-commit            # Git LFS shim
│   ├── post-merge             # Git LFS shim
│   └── pre-push               # Git LFS shim
├── .vscode/
│   ├── extensions.json        # Recommended VS Code extensions
│   └── settings.json          # Shared editor settings
├── _inbox/                    # Drop zone for unfiled material (gitignored except scaffolding)
├── _outbox/                   # Outbound drop zone for reusable snippets (tracked, harvested cross-project)
├── assets/
│   └── screenshots/           # Images and binary files (via Git LFS)
├── docs/
│   ├── adr/                   # Architecture Decision Records
│   ├── analysis/              # Investigations, trade-off studies, findings
│   ├── api/                   # API reference documentation
│   ├── current-state/         # How things work today (baseline)
│   ├── deliverables/          # Finished artifacts for external audiences
│   │   └── presentations/     #   Slide decks and talking points
│   ├── design/                # Design documents — plans, architecture sketches, mechanism designs
│   ├── future-state/          # Target design
│   ├── roadmap/               # Sequencing, phases, milestones
│   ├── runbooks/              # Operational runbooks
│   ├── concepts.md            # How repos, branches, environments and Claude Code work
│   ├── setup-guide.md         # How to create a new project from scratch using this template
│   ├── start-cli.md           # Getting started: Claude Code CLI
│   ├── start-vscode.md        # Getting started: Claude Code VS Code Extension
│   └── start-web.md           # Getting started: Claude Code on the Web
├── references/                # External knowledge: sources, tools, research, people, glossary, decisions-log
├── .editorconfig              # Editor-neutral formatting rules
├── .gitattributes             # Line ending rules and Git LFS routing
├── .gitignore                 # Files excluded from version control
├── .mcp.json                  # Project-scoped MCP servers — ships empty, add as needed (no secrets)
├── CLAUDE.md                  # AI assistant instructions and project conventions
├── CONTRIBUTING.md            # How to contribute
├── LICENSE                    # License — replace placeholder before publishing
├── README.md                  # This file
├── SECURITY.md                # Vulnerability reporting policy
├── SETUP.md                   # How to get started on a new machine
└── TASKS.md                   # Lightweight project backlog — surfaced at session start
```

---

## Branch Protection

This repository has the following branch protection rules configured on `main`:

- Require a pull request before merging (no direct pushes to `main`)
- Require at least 1 approving review
- Dismiss stale reviews when new commits are pushed
- Require status checks to pass before merging (CI must be green)
- Automatically delete head branches after a PR is merged

All AI-assisted branches follow the pattern `claude/<task-id>-<description>` and are submitted via pull request.

---

## Documentation

| File | Purpose |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | AI assistant instructions, conventions, and access rules |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | How to contribute — branch workflow, code standards, PR process |
| [`SECURITY.md`](SECURITY.md) | Vulnerability reporting policy |
| [`SETUP.md`](SETUP.md) | Machine setup guide — prerequisites, clone, MCP servers |
| [`docs/concepts.md`](docs/concepts.md) | How git, branches, environments, and Claude Code work together |
| [`docs/setup-guide.md`](docs/setup-guide.md) | Step-by-step guide for creating a new project from this template |
| [`docs/start-cli.md`](docs/start-cli.md) | Getting started with the Claude Code CLI surface |
| [`docs/start-vscode.md`](docs/start-vscode.md) | Getting started with the Claude Code VS Code Extension |
| [`docs/start-web.md`](docs/start-web.md) | Getting started with Claude Code on the Web |
| [`.claude/rules/documentation.md`](.claude/rules/documentation.md) | Documentation standards — audience levels, templates, style rules |

**Slash commands available in every session:**

| Command | What it does |
|---|---|
| `/review-code` | Reviews current branch changes for correctness, security, and simplicity |
| `/commit-message` | Drafts a commit message from staged/unstaged changes |
| `/pr` | Creates a pull request from the current branch with a drafted description |
| `/test` | Writes tests for new or changed code, matching the project's framework |
| `/explain` | Explains code, files, or architectural patterns in the project |
| `/debug` | Systematically investigates an issue — gather evidence, hypothesise, fix |
| `/security-audit` | Runs a security audit — config, secrets, dependencies, CI, OWASP patterns |
| `/write-docs` | Generates runbooks, ADRs, API references, or diagrams |
| `/task-add` | Appends a new task to `TASKS.md` |
| `/task-done` | Marks a task complete in `TASKS.md` |
| `/task-list` | Lists open tasks from `TASKS.md` |
| `/adr-new` | Scaffolds a new Architecture Decision Record in `docs/adr/` |
| `/avoid-ai-writing` | Audits and rewrites prose to remove AI writing tells |
| `/brainstorm` | Structured pre-planning conversation for vague or ambiguous tasks |
| `/changelog` | Generates or updates `CHANGELOG.md` from git history (Keep a Changelog format) |
| `/consistency-check-docs` | Audits documentation files against the actual file tree; reports mismatches |
| `/diagram` | Scaffolds a Mermaid diagram (sequence, flowchart, ER, state) into a Markdown file |
| `/export-prompt` | Exports a harvest paste-prompt, plan, or skill template to the cross-project library |
| `/harvest` | Audits spin-off project for template-worthy changes; generates paste-prompts for transfer |
| `/inbox-process` | Walks `_inbox/`, classifies items, and proposes filing destinations |
| `/release-notes` | Drafts human-facing release notes from git history, grouped by theme |
| `/sync-template` | Reviews Claude Code release notes and updates the template to stay current |
| `/troubleshooting` | Evidence-based investigation — verify every entity's identity before building analysis on it |

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full workflow, code standards, and documentation guidelines.
