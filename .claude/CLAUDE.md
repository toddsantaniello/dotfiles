## Development Workflow

When the user approves a plan (says "implement", "go for it", "yes please", etc.), run `/implement`. It handles everything: reading the plan, creating the branch, writing code, building, testing, self-reviewing, and opening a draft PR.

Plans from `/architect` are saved to `~/.claude/plans/`. Always use the most recent plan file — never rely on conversation context.

### Rules

- **No worktrees.** Always work directly on the current branch in the main working directory.
- **No broken code.** Never commit or PR code that doesn't compile and pass tests.

