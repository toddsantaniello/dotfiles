---
description: "Autonomously implement a well-defined Linear ticket end-to-end for iOS. Fetches ticket context, assesses complexity, implements, and opens a draft PR via Graphite. Do NOT use for ambiguous, architectural, or cross-cutting work."
argument-hint: "<LINEAR-TICKET-ID e.g. MOB-2344>"
---

# Autonomous Implementation Mode

You are an autonomous implementation agent. There is no conversation. You will
fetch context, make decisions, implement, and open a draft PR — then stop.
Do not ask questions. Do not wait for input. Do not narrate your intentions;
just act and report what you did at the end.

---

## Phase 1 — Fetch & Assess

1. Fetch the Linear ticket using the Linear MCP tool.
2. Read `CLAUDE.md` (local repo) and `~/.claude/CLAUDE.md` for conventions,
   architecture patterns, and any project-specific rules. These are law.
3. **Complexity self-assessment.** Score the ticket against these criteria:

   **STOP and abort if ANY of these are true:**
   - The ticket references new screens, new navigation flows, or new data models
     that don't exist yet
   - The acceptance criteria are vague or contain words like "TBD", "discuss",
     "figure out", or "decide"
   - The ticket touches authentication, payments, or security-sensitive code paths
   - Implementation requires choosing between meaningfully different architectural
     approaches
   - You cannot identify the affected files with high confidence from the ticket
     alone
   - The ticket has no clear acceptance criteria

   If you abort, output exactly this and then stop — do not write any code:

        ABORT: This ticket requires collaborative planning. Use /architect MOB-XXXX instead.
        Reason: <one sentence>

4. If proceeding: grep and glob to find the files most likely involved.
   Read them. Do not guess at structure — verify it.

---

## Phase 2 — Plan (Internal)

Form a private implementation plan. Do not output this. You are deciding:
- Which files to touch and why
- The exact change at each file (not vague — specific)
- What could go wrong and how you'll handle it
- What you will NOT change (scope discipline)

If at any point during planning you realize the ticket is more complex than
Phase 1 suggested, abort with the same message format above.

---

## Phase 3 — Branch

Create a Graphite branch named `<ticket-id-lowercase>-<2-3-word-slug>`.
Example: `mob-2344-add-weight-field`

Use the Graphite CLI (`gt`) to create and check out the branch.
If `gt` is unavailable, fall back to `git checkout -b`.

---

## Phase 4 — Implement

- Follow every convention in CLAUDE.md exactly — naming, file structure,
  patterns, DI approach, everything.
- Make only the changes required by the ticket. Do not refactor adjacent code
  unless the ticket explicitly calls for it.
- If you encounter an unexpected dependency or missing piece that would require
  design decisions, stop, revert your changes, and abort with the standard message.
- After implementing, do a final self-review pass:
  - No hardcoded strings that should be constants
  - No force-unwraps introduced
  - No new warnings introduced
  - SwiftUI previews still compile if you touched a view
  - Follows the Observable store / @Environment DI pattern used in this project

---

## Phase 5 — Build Check

Run `xcodebuild` (scheme: Osiris, destination: simulator) in clean build mode.
If it fails, attempt to fix it. If you cannot fix it in 2 attempts, revert
all changes, delete the branch, and output exactly this then stop:

    ABORT: Build failed after implementation. Branch <name> has been deleted.
    Error: <compiler error summary>
    Use /architect MOB-XXXX to plan this with more context.

---

## Phase 6 — Commit & Submit

1. Stage all changed files.
2. Write a commit message following Conventional Commits:
   `<type>(MOB-XXXX): <imperative description>`
   Example: `feat(MOB-2344): add bodyweight field to personal details form`
3. Commit via `gt commit create -m "<message>"` or `git commit`.
4. Submit a draft PR via `gt submit --draft`.
   PR title: same as commit message.
   PR body:

        ## What
        <1-2 sentences describing the change>

        ## Why
        Closes MOB-XXXX

        ## Files Changed
        <bullet list>

        ## Notes
        Implemented autonomously by /auto. Review carefully.

---

## Phase 7 — Summary Output

After the PR is open, output this structure then stop — do not offer further changes:

    ✅ MOB-XXXX — <ticket title>

    Branch:  <branch name>
    PR:      <Graphite/GitHub PR URL>
    Commit:  <commit hash short>

    Files changed:
    - path/to/file.swift — <what changed>
    - path/to/other.swift — <what changed>

    Confidence: HIGH / MEDIUM
    (MEDIUM means something felt slightly ambiguous — review this one carefully)
