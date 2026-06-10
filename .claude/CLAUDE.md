## Linear Integration

Use the Linear MCP tools freely for creating/updating issues, adding comments, etc.

### Formatting conventions

- **Use real newlines in markdown content** — never use `\n` escape sequences in `description` or `body` fields. The MCP tool will double-escape them into literal `\n` text.
- Use standard markdown: `###` headings, `**bold**`, `- ` bullet lists.
- Keep descriptions concise with a summary paragraph up top, then a bulleted "Key Changes" or similar section if needed.

## Development Workflow

When the user approves a plan (says "implement", "go for it", "yes please", etc.), run `/implement`. It handles everything: reading the plan, creating the branch, writing code, building, testing, self-reviewing, and opening a draft PR.

Plans from `/architect` are saved to `~/.claude/plans/`. Always use the most recent plan file — never rely on conversation context.

### Rules

- **No worktrees.** Always work directly on the current branch in the main working directory.
- **No broken code.** Never commit or PR code that doesn't compile and pass tests.

## Graphite (git)

This project uses **Graphite** (`gt`) for branch and PR management. Never use raw `git commit` or `git push`.

- `gt create <branch> -m "<message>" --all` — Create a new branch with initial commit
- `git add <files>` then `gt modify --all` — Amend the current commit with staged changes
- `gt submit --draft --no-edit --ai` — Push and create/update draft PR with AI-generated description

## Cross-repo Reference

The athletes-api OpenAPI spec is always available at `../athletes-api/openapi.yaml` for looking up backend API contracts, endpoint shapes, and field names.
