# Implementation Process

Tool-agnostic description of taking an approved plan to a working, reviewed
change. Any agent can follow this — the concrete tool names (build systems,
PR tooling, review mechanics) are adapter details layered on top, not part
of this process.

Work through every phase in order. Do not skip phases.

## Phase 1: Load the Plan

1. Find the most recent plan document (or the one referenced explicitly).
2. Read it thoroughly. Identify:
   - Any ticket/issue reference
   - The files involved
   - The recommended approach and steps
3. If no plan exists, stop and say so rather than guessing at scope.

## Phase 2: Implement

Follow the plan's recommended approach step by step.

**Principles:**
- Do the minimum correct thing. No over-engineering, no drive-by refactors.
- Respect existing patterns in the codebase. Read surrounding code before
  writing.
- Handle errors explicitly. Never silently swallow failures.
- Work incrementally — one logical change at a time.
- If the plan is unclear or conflicts with what you see in the code, make
  a reasonable judgment call and note it. Do not stop to ask unless it's
  a fundamental ambiguity that could waste significant effort.

## Phase 3: Build & Test

1. Read the project's own instructions (its CLAUDE.md/AGENTS.md/README,
   whichever it uses) for build, test, and lint commands.
2. **Build the project.** If it fails, fix the errors. Do not proceed with
   a broken build.
3. **Run tests.** Fix any regressions your changes caused. If a test was
   already failing before your changes, note it but don't block on it.
4. **Run linters/formatters.** Fix any issues.
5. If build or tests still fail after 3 fix attempts, stop and report the
   failure clearly. Do not hand off broken code.

## Phase 4: Verify Behavior

Build and passing tests confirm the code compiles and existing logic isn't
broken — they don't confirm the change actually does what the plan
intended. Before review, drive the app directly and observe the result:

1. Launch/run the app using whatever tooling is available (simulator,
   local dev server, browser, CLI — whatever fits the project).
2. Exercise the actual flow the plan describes changing, not just the
   initial state — the real interaction (click, tap, request, command).
3. Confirm visually or structurally that the result matches the plan's
   stated intent and acceptance criteria.

This step is advisory, not a hard gate: attempt it whenever the change has
a runtime or user-visible surface, record what you observed (confirmed
matching intent / observed a mismatch / couldn't be verified and why), and
carry that note forward into the review and the final report. Fix obvious
mismatches; flag non-obvious ones for the human reviewer rather than
stalling.

## Phase 5: Review Loop

Run this project's code review process against your changes.

- **If issues are found:** Fix them, rebuild/retest (Phase 3), then review
  again.
- **If no issues are found:** Proceed to Phase 6.
- **Cap at 3 review cycles.** If issues persist after 3 rounds, note the
  remaining concerns in the handoff and proceed rather than looping
  forever.

## Phase 6: Commit & Hand Off

1. Determine a branch/change name from the ticket (if any) or the plan
   title.
2. Stage the specific changed files (not a blanket add).
3. Commit with a message describing what changed and why.
4. Open the change for review (a draft PR, a merge request, whatever this
   project's tooling uses) including the Phase 4 verification note so the
   human reviewer has it.

## Phase 7: Report

Summarize:
- What was implemented (1-2 sentences)
- Files changed and why
- Build/test status
- What Phase 4 verification observed
- Review outcome (clean, or remaining concerns)
- Any judgment calls or deviations from the plan

## Rules

- **Do not ask questions** unless you've hit a fundamental ambiguity that
  would waste significant effort if you guessed wrong. Minor judgment
  calls are yours to make — note them in the report.
- **Do not offer alternatives or ask for preferences.** Pick the approach
  from the plan and execute it.
- **Do not skip the build/test phase.** Ever. Broken code is worse than
  slow code.
- **Do not commit directly to the main/trunk branch.** Always work on a
  feature branch.
