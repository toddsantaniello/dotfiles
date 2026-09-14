---
name: review-pr-comments
description: Review PR comments and plan implementation. Use when the user wants to address PR feedback, review comments on a pull request, or plan changes based on code review.
allowed-tools: Bash(gh pr view:*), Bash(gh api:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Read, Grep, Glob, AskUserQuestion, TodoWrite
---

Follow the process in
[`../process/review-pr-comments.md`](../process/review-pr-comments.md)
exactly for the PR: $ARGUMENTS. This file only maps that process onto
Claude Code's tools.

- **Step 1 (fetch comments)** — use the GitHub CLI:
  ```
  gh api repos/{owner}/{repo}/pulls/{pr_number}/comments
  gh pr view {pr_number} --repo {owner}/{repo} --comments --json comments,reviews
  ```
- **Step 3 (open questions)** — use the `AskUserQuestion` tool.
- **Step 4 (implementation plan)** — use `TodoWrite` to track it.
