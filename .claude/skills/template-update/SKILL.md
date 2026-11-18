---
description: Bring template changes into this spin-off project. Lists the template PRs merged since the last sync, decides per file whether to sync, merge by intent or skip, applies what the user approves on a branch, and records the new sync state. Use when the user says "update from template", "template update", "sync from template", or "what changed in the template". Run in the spin-off; the status mode runs in the template.
arguments: mode — "sync" (default, run in a spin-off), or "status <spin-off path> [...]" (read-only overview, run in the template repo). Optional "--template <path>" for the local template clone.
---

# Template update — template changes into a spin-off

The downstream counterpart of `/harvest`. `/harvest` carries spin-off learnings up to the template; this skill
carries merged template changes down into a spin-off. The step-by-step manual for people is
`docs/runbooks/template-update.md`.

## Ground rules

- **Template history comes from the template clone only.** A spin-off created with "Use this template" or by copying
  files has unrelated history: template SHAs do not exist in it. Every template SHA is read with
  `git -C <template> …`.
- **Read the template, never write to it** — the one exception is `git -C <template> pull --ff-only` in step 2.
- **Git is the source of truth.** The PR's **Downstream (spinoffs)** section adds detail; a PR without one gets an
  inferred classification, labelled as inferred.
- **Never commit per-machine state** (git config, credentials, user-level Claude config).
- **Commit messages and PR bodies go through files** (`git commit -F <file>`, `gh pr create --body-file <file>`).
  The `pre-tool-use` hook blocks any command whose text contains `curl` or `wget`, heredocs included.

## Mode 1: sync (default — `/template-update`)

1. **Preconditions.** The working tree is clean. Create a branch per this project's `CLAUDE.md`, for example
   `feature/template-update-<YYYY-MM-DD>`, before changing anything.

2. **Find the template clone.** Use `--template <path>` if given, else a sibling folder `../claude-code-template`,
   else ask. Confirm it is the template: its `origin` URL matches **Template repo** in
   `.claude/template-baseline.md` (a renamed or transferred repo may differ; ask if unsure). If the clone is on
   `main` with a clean tree, run `git -C <template> pull --ff-only`; otherwise ask the user to update it. `git pull`
   is used instead of `git fetch` on purpose: a spin-off whose hook predates template PR #44 blocks `git fetch`.

3. **Find the base.** Read **Last synced**, **Deferred** and **Declined** from `.claude/template-baseline.md`.
   - **Base** = Last synced; if that is still a placeholder, the Fork commit.
   - If both are placeholders: propose a candidate with
     `git -C <template> log -1 --format='%H %ad' --date=short --before=<date of this repo's first commit> main`
     and **confirm it with the user**. Never guess silently.
   - Check it exists: `git -C <template> cat-file -e <base>^{commit}`.
   - **Target** = `git -C <template> rev-parse main`. If base equals target and Deferred is empty, report "up to
     date" and stop.

4. **List the template changes.**
   - `git -C <template> log --first-parent --format='%H %s' <base>..<target>`. A merge subject
     `Merge pull request #N …` names the PR.
   - For each PR: `gh pr view N --repo <owner/template-repo> --json title,body` and read the ticked labels in
     **Downstream (spinoffs)** — Template-only, Sync file, Merge by intent, One-time local action — and the
     `Action:` line. A wrong `gh` account shows as "not found"; see the manual.
   - Add every **Deferred** entry. Drop every **Declined** entry.

5. **Classify each changed file.** `git -C <template> diff --name-status -M <base> <target>`. For each path,
   compare three committed blob hashes (they are immune to CRLF differences in the working tree):

   - `base` = `git -C <template> rev-parse <base>:<path>`
   - `new`  = `git -C <template> rev-parse <target>:<path>`
   - `ours` = `git rev-parse HEAD:<path>` (in this spin-off; missing if the file does not exist here)

   | Condition | Category |
   |---|---|
   | path in the never-sync list below | **Skip** (report it) |
   | `ours` = `new` | **Already applied** — record only |
   | `ours` = `base`, or the file is new in the template and missing here | **Sync file** |
   | anything else | **Merge by intent** |
   | path is `.claude/settings.json` | **User applies** — whatever the hashes say |
   | path in the always-ask list | **Ask** — show the change, apply only on approval |
   | template deleted the file | **Delete?** — propose; delete only after the user confirms each file |
   | template renamed the file (`R` status) | as above, using the old path for `base` and `ours` |

   **Never sync:** `.claude/template-baseline.md` (sync fields only), `.claude/docs-baseline.hash`, `TASKS.md`,
   `CHANGELOG.md`, contents of `_inbox/`, `_outbox/`, `docs/deliverables/` and `references/`.
   **Always ask:** `CLAUDE.md`, `README.md`, `.github/pull_request_template.md` (never carry its **Downstream
   (spinoffs)** section into a spin-off).

   Attribute each file to its PR(s) with `git -C <template> log --first-parent --format=%h <base>..<target> -- <path>`.

6. **Present the plan** as one table per category, each row: path, PR(s), label from the PR or "inferred", one line
   on what changes. List **One-time local actions** from the PR bodies separately. The user approves, defers or
   declines per row.

7. **Apply what was approved.**
   - **Sync file:** `git -C <template> show <target>:<path> > <path>`. If the template stores it as `100755`, run
     `git add <path>` then `git update-index --chmod=+x <path>` — Windows does not carry the bit (template PR #43).
   - **Merge by intent:** write the three versions to scratch files and run
     `git merge-file -p <ours> <base> <new>` for a draft. Resolve conflicts by what the template change is for, keep
     the spin-off's own customisations, and show the user the result before staging it.
   - **User applies (`settings.json`):** print the exact diff. The `ConfigChange` hook blocks in-session edits.
     Remind the user that deny rules in `settings.json` are mirrored in `.claude/hooks/pre-tool-use.sh`.
   - **Delete:** only files the user confirmed, one by one.

8. **One-time local actions.** Show them as a checklist. Run only read-only checks yourself, for example
   `git ls-files -s .githooks .claude/hooks` or `git config --get-all credential.helper`. Anything that changes
   machine state or git config: describe it and let the user run it or confirm it.

9. **Record the sync state** in `.claude/template-baseline.md`, in the same commit as the applied changes:
   **Last synced** = target SHA, **Last sync date** = today, **Deferred** and **Declined** updated with
   `<SHA> PR #<n> \`<path>\`: <reason>` entries. This keeps the record from claiming a sync that never landed.

10. **Check and hand over.** Run this project's tests or checks if it has any. Commit (message from a file), push,
    and open a PR in this spin-off following its `CLAUDE.md`. The PR body lists the template PRs taken, deferred and
    declined.

## Mode 2: status (`/template-update status <spin-off path> [...]`, run in the template repo)

Read-only. For each spin-off path:

1. Read its `.claude/template-baseline.md`. Report a missing file or placeholder values as "baseline not set".
2. Base = Last synced, else Fork commit. Count and list the PRs in
   `git log --first-parent --format='%h %s' <base>..main` of this template repo, with their Downstream labels.
3. Add its Deferred entries.

Present one row per spin-off: path, last synced (short SHA and date), PRs behind, deferred count, and any
One-time local action PRs. Change nothing in the spin-offs.

## What this skill does NOT do

- No writes to the template clone, other than `pull --ff-only`.
- No edits to `.claude/settings.json` — the user applies those.
- No automatic deletes and no silent base guess.
- No per-machine state in commits.
- It does not feed changes back to the template; that is `/harvest`.
