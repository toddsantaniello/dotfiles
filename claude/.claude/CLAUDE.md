## Development Workflow

When the user approves a plan (says "implement", "go for it", "yes please", etc.), run `/implement`. It handles everything: reading the plan, creating the branch, writing code, building, testing, verifying behavior, self-reviewing, and opening a draft PR.

Plans from `/architect` are saved to `~/.claude/plans/`. Always use the most recent plan file — never rely on conversation context.

The `architect` → `implement` → `code-review` skills are thin Claude Code adapters over tool-agnostic process docs in `process/` — those docs are the actual method (usable by any agent, not just this one); the skills just map them onto Claude Code's tools, slash commands, and subagent model pinning (see `agents/`).

### Rules

- **No worktrees.** Always work directly on the current branch in the main working directory.
- **No broken code.** Never commit or PR code that doesn't compile and pass tests.

### Job/team-specific overrides

This file is intentionally generic — no specific issue tracker, branch/PR
tool, or company API is assumed here. A given project's own
`CLAUDE.md`/`AGENTS.md` is the right place to layer in team-specific
tooling (e.g. a non-`gh` PR tool, a specific ticket tracker's conventions,
cross-repo API contract references) — it combines with this file rather
than replacing it.

