# Session Start

## Current branch

**Always** show the current branch in the first reply. Use the branch name from the SessionStart hook's git status (the line starting with `##`).

- On a feature branch: `Branch: \`feature/some-task\`` (informational, no action needed)
- On main: show the branch and retain the branch rule for any later change request.

## Before changing files on main

When the user asks to edit files, commit, push, open a pull request, or otherwise change project state while on `main`, add a branching choice before taking action:

1. Continue work on an existing branch (list them if any exist)
2. Create a new feature branch (suggest a name once the task is known)
3. Proceed on `main` anyway (explicit override — rare)

For questions, reviews, explanations, and other read-only requests, do not present this choice.

## Open tasks prompt

When the SessionStart hook reports an "Open tasks (TASKS.md)" block, mention the open tasks when the user asks about project work or planning. If the user picks one to work on and is on main, derive a short branch name from it and offer that name as option 2 of the branching prompt.
If the hook does not include an open-tasks block, skip this step silently.

> Note: the exact heading the hook prints lives in `.claude/hooks/session-start.sh`. Match on intent ("there are open tasks listed"), not on the literal string, so the rule and the hook can evolve independently.

Note: tasks and memory are different. `TASKS.md` is a backlog of work to do in this project; memory (`MEMORY.md`) captures how to collaborate with the user. Do not conflate them.

## Template promotion prompt

When a useful rule, workflow, or convention emerges during a session — something the user confirms they want to apply going forward — ask whether it should be promoted into the template itself (a file under `.claude/rules/`, `.claude/commands/`, `CLAUDE.md`, or similar) rather than only saved to per-project memory.

The reasoning: memory is private to one project and one user. The template is the mechanism for spreading best practices to every new project cloned from it. If a rule is good enough to remember, it is usually good enough to encode in the repo.

Apply this whenever:

- The user corrects your behavior in a way that should persist
- The user confirms a non-obvious approach that others would benefit from
- A new tool, hook, or workflow step is introduced
- You are about to save a feedback or project memory that is not user-specific

One-line prompt is enough: "Should this go in the template as a rule, or keep it as project memory only?"

## Pull before branching

When creating a new branch mid-session — especially after a PR was just merged on GitHub — always
run `git switch main && git pull` before `git switch -c <new-branch>`. The merge commit is created
on the remote and the local main does not auto-update. Branching off stale main risks conflicts
later.

This is a mechanical step. Do not ask the user — just do it.

## Consistency check before opening a PR

If during this session you added, removed, or renamed anything under `.claude/commands/`,
`.claude/skills/`, `.claude/rules/`, or `.claude/hooks/` — or edited any file-tree block in
`CLAUDE.md`, `SETUP.md`, `README.md`, or `.claude/README.md` — run `/consistency-check-docs`
before opening the PR and fix any mismatches in the same branch.

Rationale: these four indices drift independently. `.claude/README.md` is usually updated first
because it is closest to the change, and the other three get missed. The audit takes seconds and
catches drift at the point where it matters most — right before it ships.

Skip the audit for edits that cannot cause drift (prose-only changes inside a rule file, typo
fixes in a command body, etc.).
