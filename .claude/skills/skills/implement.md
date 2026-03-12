---
description: >
  Implement the most recent plan end-to-end: create branch, write code, build,
  test, run code review, fix issues, commit, and open a draft PR. Designed to
  run autonomously after an /architect session.
argument-hint: "[optional: plan filename or Linear ticket ID]"
---

# Implementation Mode

You are now in autonomous implementation mode. Your job is to take a plan and
deliver a draft PR — no hand-holding, no unnecessary questions. Work through
every phase below in order. Do not skip phases.

## Phase 1: Load the Plan

1. If an argument was provided, use it to find the plan (filename or ticket ID).
   Otherwise, find the most recent file in `~/.claude/plans/`.
2. Read the plan thoroughly. Identify:
   - The Linear ticket ID (if referenced)
   - The files involved
   - The recommended approach and steps
3. If no plan exists, stop and tell the user:
   > No plan found. Run `/architect` first to create one.

## Phase 2: Implement

Follow the plan's recommended approach step by step.

**Principles:**
- Do the minimum correct thing. No over-engineering, no drive-by refactors.
- Respect existing patterns in the codebase. Read surrounding code before writing.
- Handle errors explicitly. Never silently swallow failures.
- Work incrementally — one logical change at a time.
- If the plan is unclear or conflicts with what you see in the code, make a
  reasonable judgment call and note it. Do not stop to ask unless it's a
  fundamental ambiguity that could waste significant effort.

## Phase 3: Build & Test

1. Read the project's `CLAUDE.md` for build, test, and lint commands.
2. **Build the project.** If it fails, fix the errors. Do not proceed with a broken build.
3. **Run unit tests.** Fix any regressions your changes caused. If a test was already
   failing before your changes, note it but don't block on it.
4. **Run linters/formatters** (e.g. swiftformat, prettier, biome). Fix any issues.
5. If build or tests still fail after 3 fix attempts, stop and report the failure
   clearly. Do not push broken code.

## Phase 4: Code Review Loop

Run `/eternal-code-review` to review your changes against the base branch.

- **If issues are found:** Fix them, rebuild and retest (Phase 3), then run
  `/eternal-code-review` again.
- **If no issues are found:** Proceed to Phase 5.
- **Cap at 3 review cycles.** If issues persist after 3 rounds, note the remaining
  concerns in the PR description and proceed rather than looping forever.

## Phase 5: Commit & PR

1. Determine the branch name:
   - If the plan references a Linear ticket, look it up via MCP to get the `gitBranchName`.
   - If no Linear ticket, derive a descriptive branch name from the plan title.
2. Stage the changed files:
   ```
   git add <specific files>
   ```
3. Create the branch and commit in one shot:
   ```
   gt create <branch-name> -m "[TICKET-ID] Descriptive title" --all
   ```
4. Submit as a draft PR:
   ```
   gt submit --draft --no-edit --ai
   ```
5. Verify the PR title matches `[TICKET-ID] Descriptive title`. If `--ai` overwrote
   it, fix with `gh pr edit <number> --title "..."`.

## Phase 6: Report

Output a summary:

```
## Done

**PR:** <link>
**Ticket:** <Linear ticket ID>
**What was implemented:** <1-2 sentence summary>

**Files changed:**
- `path/to/file` — <what and why>

**Build:** Passing
**Tests:** Passing (or note any pre-existing failures)

**Code review:** Clean (or note review cycles and any remaining concerns)
- <any concerns, judgment calls, or deviations from the plan>
```

## Rules

- **Do not ask the user questions** unless you've hit a fundamental ambiguity that
  would waste significant effort if you guessed wrong. Minor judgment calls are yours
  to make — note them in the summary.
- **Do not offer alternatives or ask for preferences.** Pick the approach from the plan
  and execute it.
- **Do not skip the build/test phase.** Ever. Broken code is worse than slow code.
- **Do not push to main/master.** Always work on a feature branch.
