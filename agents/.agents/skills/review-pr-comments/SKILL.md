---
name: review-pr-comments
description: Review PR comments and plan implementation. Use when the user wants to address PR feedback, review comments on a pull request, or plan changes based on code review.
allowed-tools: Bash(gh pr view:*), Bash(gh api:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Read, Grep, Glob, AskUserQuestion, TodoWrite, Skill
---

Follow the process in
[`~/.agents/process/review-pr-comments.md`](../../process/review-pr-comments.md)
exactly for the PR: $ARGUMENTS. This file only maps that process onto
Claude Code's tools.

- **Project override** - if this project has its own PR-comment skill
  (in town: `address-pr-comments`), invoke it with the `Skill` tool,
  passing $ARGUMENTS, and stop; do not run the steps below.
- **Step 1 (fetch comments)** - use the GitHub CLI:
  ```
  gh pr view {pr_number} --repo {owner}/{repo} --json comments,reviews
  gh api graphql -f query='
  query($owner:String!,$name:String!,$number:Int!){
    repository(owner:$owner,name:$name){
      pullRequest(number:$number){
        reviewThreads(first:100){
          nodes{ id isResolved
            comments(first:30){ nodes{ id databaseId body path line author{login} } }
          }
        }
      }
    }
  }' -F owner={owner} -F name={repo} -F number={pr_number}
  ```
- **Step 3 (open questions)** - use the `AskUserQuestion` tool.
- **Step 4 (implementation plan)** - use `TodoWrite` to track it.
