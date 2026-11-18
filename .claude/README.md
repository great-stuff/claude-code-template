# `.claude/` — Commands, Skills, Rules, Hooks

Index of everything Claude Code loads from this directory. **Keep in sync** when adding or removing entries.

## Commands (`.claude/commands/`)

Slash commands. Each `.md` file becomes `/<filename>` in a session.

| Command | Purpose |
|---|---|
| `/commit-message` | Drafts a commit message from current staged/unstaged changes |
| `/debug` | Systematic issue investigation — gather evidence, hypothesize, fix |
| `/explain` | Explains code, files, or architectural patterns in the project |
| `/pr` | Creates a pull request from the current branch with a drafted description |
| `/review-code` | Reviews current branch changes for correctness, security, and simplicity |
| `/security-audit` | Runs a security audit — config, secrets, dependencies, CI, OWASP patterns |
| `/task-add` | Appends a new task to `TASKS.md` |
| `/task-done` | Marks a task complete in `TASKS.md` |
| `/task-list` | Lists open tasks from `TASKS.md` |
| `/test` | Writes tests for new or changed code, matching the project's framework |
| `/write-docs` | Generates runbooks, ADRs, API references, or diagrams |

## Skills (`.claude/skills/`)

Newer format with YAML frontmatter, supporting files, and subagent execution. Each `<name>/SKILL.md` becomes `/<name>`.

| Skill | Purpose |
|---|---|
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
| `/template-update` | Brings merged template changes into a spin-off; `status` mode shows which spin-offs are behind |
| `/troubleshooting` | Evidence-based investigation — verify every entity's identity before building analysis on it |

## Optional upstream skill packs

Anthropic ships maintained skill packs for common document formats. Enable the ones you need — do not copy them into this template.

| Pack | What it does |
|---|---|
| `pdf` | Read, extract, and fill PDF files |
| `docx` | Create and edit Word documents |
| `xlsx` | Create and edit Excel spreadsheets |
| `pptx` | Create and edit PowerPoint presentations |

These auto-trigger by filename or user intent once enabled in your Claude Code installation. See the official skills catalog for installation details.

## Rules (`.claude/rules/`)

Topic-specific instructions. Claude reads all rule files at session start.

| File | Topic |
|---|---|
| `branch-audit.md` | Mandatory git+intent cross-checks before recommending branch deletion |
| `code-style.md` | Indentation, comments, abstractions, validation boundaries |
| `documentation.md` | Audience levels, doc types, templates, style rules |
| `goal-driven-execution.md` | Reframe imperative tasks as verifiable goals; plan with explicit verify steps |
| `harvest-flag.md` | Conversational flagging — bookmarks items for next `/harvest` audit |
| `mental-models.md` | Calibration framework — domain, context, intent, trust/handoff |
| `outbox-capture.md` | When and how to save reusable snippets to `_outbox/` |
| `session-start.md` | First-reply behavior — open tasks, branching prompt, template promotion |
| `troubleshooting-verification.md` | Verify entity identity before building on it; state what can't be verified; re-verify each finding |

## Hooks (`.claude/hooks/`)

Shell scripts the Claude Code harness invokes around tool calls and session events.

| File | Trigger | Purpose |
|---|---|---|
| `session-start.sh` | `SessionStart` | Prints git status, open tasks (`TASKS.md`), and warns when on `main` |
| `pre-tool-use.sh` | `PreToolUse` | Defense-in-depth: blocks secret reads, external fetches, and `rm -r*` |

> **Defense-in-depth note.** The deny rules in `settings.json` (curl, secret reads, `rm -rf`) are intentionally **mirrored** in `pre-tool-use.sh`. The `deny` list uses prefix-glob matching and misses edge cases like `rm -rfv`, `&&`-chained commands, and quoted variants — the hook catches those with regex. **If you remove a rule from one layer, remove it from the other.** JSON has no comment syntax, so this contract lives here rather than inline.

## Settings and loose files

| File | Committed? | Purpose |
|---|---|---|
| `settings.json` | Yes | Shared permissions, env vars, hook wiring |
| `settings.local.json` | No (gitignored) | Machine-specific MCP tokens |
| `settings.local.json.example` | Yes | Format reference for `settings.local.json` |
| `.gitignore` | Yes | Ignores local-only files inside `.claude/` (`settings.local.json`, `harvest-queue.md`, `.DS_Store`) |
| `docs-baseline.hash` | Yes | SHA-256 of the last-reviewed Claude Code changelog — set from the hash published by `claude-docs-watch` |
| `template-baseline.md` | Yes | Fork-time snapshot and sync state: fork commit, last synced commit, deferred and declined items, inherited files. Sync state is maintained by `/template-update` |
| `harvest-queue.md` | No (gitignored) | Transient queue populated by the harvest-flag rule — present only between flag and `/harvest` run |
