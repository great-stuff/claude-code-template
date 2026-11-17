---
description: Audit this spin-off project for concepts worth transferring back to the template. Produces paste-prompts for clean cross-repo transfer without git operations.
arguments: mode — "audit" (default, run full audit), or "flag <description>" (bookmark one item for next audit)
---

# Harvest — Transfer Spin-off Learnings to Template

Identify what this spin-off project has added or changed relative to the template it was forked from, and generate self-contained paste-prompts to transfer approved items back.

## Modes

### Mode 1: Audit (default — `/harvest` or `/harvest audit`)

1. **Read the baseline.** Open `.claude/template-baseline.md` and note the fork commit, fork date, **Last synced** commit, and inherited file list. The comparison point is **Last synced**, or the fork commit if this project has never run `/template-update`.

2. **Detect placeholder denylist.** If the keyword denylist below still contains `CompanyName, InternalToolA, SpaceKeyX`, stop and ask the user to customize it for this project before proceeding. Example prompt: "The denylist still has template placeholders — replace them with this project's company name, internal tools, and space keys."

3. **Diff against the template at the comparison point.** Read the template from a local clone (ask for its path if a sibling `../claude-code-template` does not exist). A project created with "Use this template" has unrelated history, so template SHAs exist only in the template clone, never in this repo. List the template's files with `git -C <template> ls-tree --name-only -r <comparison-point>`, then:
   - **New files** — not in the template at the comparison point
   - **Modified files** — in both, but `git rev-parse HEAD:<file>` differs from `git -C <template> rev-parse <comparison-point>:<file>`; show the difference with `git diff --no-index` on the two versions
   - **Deleted files** — in the template but removed here (rarely transferable, but note them)

   Comparing against the last sync, not the fork commit, keeps template changes already pulled in by `/template-update` from being offered back to the template.

4. **Consume the harvest queue.** Read `.claude/harvest-queue.md` if it exists. Include queued items alongside diff-discovered items. After audit completes, clear the queue file.

5. **Categorize each candidate:**
   - **Prose** — rules, CLAUDE.md sections, CONTRIBUTING.md, documentation
   - **Skill / command** — `.claude/skills/`, `.claude/commands/`
   - **Hook** — `.claude/hooks/`
   - **Structural** — file layout, directories, `.gitignore`, `.gitattributes`, config files

6. **Filter for template-worthiness.** Skip items that are:
   - Purely project-specific content (project docs in `docs/deliverables/`)
   - Data files (PDFs, images, inbox contents)
   - Already in the template (identical to the template at the comparison point)

7. **Denylist check.** For each candidate, scan its content for keywords from the denylist. Flag any matches: "⚠ Contains project-specific term: '<term>' — review and generalize before transfer."

8. **Present the audit.** Show a numbered list grouped by category:

   **Prose (3 items)**

   1. CONTRIBUTING.md — "Git basics for new contributors" section [NEW]
      ⚠ No denylist hits
   2. CLAUDE.md — new section [MODIFIED]
      ⚠ Contains: "CompanyName" — generalize before transfer

   **Skills (1 item)**

   3. .claude/skills/example-skill/ [NEW]
      ⚠ Contains: "InternalToolA" — generalize before transfer

9. **Generate paste-prompts on approval.** For each item the user approves, produce a self-contained paste-prompt. The prompt must specify:
   - What the change is and why it's template-worthy (context paragraph)
   - Exact target file path in the template repo
   - Exact section/heading placement (before/after what existing content)
   - Verbatim content to insert, replace, or append
   - Any instructions for the receiving session (e.g., "adapt the example to use placeholder names")

   Format with clear copy markers:

   🟢🟢🟢 COPY FROM THE LINE BELOW THIS ONE 🟢🟢🟢

   🟢🟢🟢 COPY UP TO THE LINE ABOVE THIS ONE 🟢🟢🟢

   The marker lines themselves are NOT part of the paste — only the content between them.

10. **Suggest export.** After generating paste-prompts, suggest: "Run `/export-prompt harvest` to save these paste-prompts to your library for future reuse."

### Mode 2: Flag (`/harvest flag <description>`)

1. If `.claude/harvest-queue.md` does not exist, create it with the header:
   ```markdown
   # Harvest queue
   ```

2. Append a line: `- [ ] <description> — flagged <today's date> — source: <current file or context if known>`
3. Confirm briefly: "Flagged for template harvest: <description>"

The queue is consumed and cleared by the next `/harvest audit`.

## Keyword denylist — customize for your project

Replace these placeholders on first `/harvest` run with terms specific to this project (company names, internal tool names, space keys, internal hostnames, etc.):

`CompanyName, InternalToolA, SpaceKeyX`

## What this skill does NOT do

- No automatic scrubbing — it flags project-specific terms but never rewrites content. The user reviews and generalizes manually.
- No cross-repo git operations — transfer happens via paste-prompts, not pushes or PRs.
- No session-start cost — this skill loads only when explicitly invoked.
- No template-side changes required — the receiving session interprets the paste-prompt using its own repo context.
