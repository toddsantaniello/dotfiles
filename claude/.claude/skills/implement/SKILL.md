---
description: >
  Implement the most recent plan end-to-end: create branch, write code, build,
  test, verify behavior, run code review, fix issues, commit, and open a draft
  PR. Designed to run autonomously after an /architect session.
argument-hint: "[optional: plan filename or ticket ID]"
---

# Implementation Mode

You are now in autonomous implementation mode — no hand-holding, no
unnecessary questions. Follow the phases in
[`../process/implement.md`](../process/implement.md) exactly. This file
only adds the Claude Code-specific mechanics for each phase; do not skip
phases.

## Phase 1 — finding the plan

If an argument was provided, use it to find the plan (filename or ticket
ID). Otherwise use the most recent file in `~/.claude/plans/`. If none
exists, stop and tell the user:

> No plan found. Run `/architect` first to create one.

If the plan references a ticket in an issue tracker your session has MCP
access to (e.g. Linear), look it up for additional context.

## Phase 4 — verifying behavior

**For iOS projects**, use XcodeBuildMCP against a simulator:
1. `build_run_sim` (or `boot_sim` + `install_app_sim` + `launch_app_sim`
   if already built) to get the app running.
2. Navigate to the screen/flow the plan describes changing, exercising
   the actual interaction (tap, type, navigate) — not just the initial
   state.
3. Use `screenshot` to visually confirm the UI matches what the plan
   intended. Use `snapshot_ui` when you need structural confirmation a
   screenshot can't show (element hierarchy, accessibility identifiers,
   exact state).
4. Compare what you observe against the plan's stated intent and
   acceptance criteria.

**For non-iOS projects**, use this project's `run` skill if one exists to
launch the app and confirm the change visually/functionally.

Record the observation and carry it into the PR description (Phase 6) and
the final report (Phase 7).

## Phase 5 — review loop

Run `/code-review` (or this project's own review skill, if it has one) to
review your changes against the base branch.

- **If issues are found:** fix them, rebuild/retest (Phase 3), then
  review again.
- Cap at 3 review cycles — note remaining concerns and proceed rather
  than looping forever.

## Phase 6 — commit & PR

Default to plain `git` + the `gh` CLI unless this project's own
`CLAUDE.md`/`AGENTS.md` specifies different branch/PR tooling (e.g. a team
using Graphite) — follow that instead when present.

1. Determine the branch name from a ticket ID (if any) or the plan title.
2. Stage the specific changed files:
   ```
   git add <specific files>
   ```
3. Create the branch and commit:
   ```
   git checkout -b <branch-name>
   git commit -m "<message>"
   ```
4. Push and open a draft PR:
   ```
   git push -u origin <branch-name>
   gh pr create --draft --title "<title>" --body "<body>"
   ```
5. Include the Phase 4 verification note in the PR body.

## Phase 7 — report

Output a summary:

```
## Done

**PR:** <link>
**Ticket:** <ticket ID, if any>
**What was implemented:** <1-2 sentence summary>

**Files changed:**
- `path/to/file` — <what and why>

**Build:** Passing
**Tests:** Passing (or note any pre-existing failures)

**Verification:** <what was observed running it, or why it wasn't checked>

**Code review:** Clean (or note review cycles and any remaining concerns)
- <any concerns, judgment calls, or deviations from the plan>
```
