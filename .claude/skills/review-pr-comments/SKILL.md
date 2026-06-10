---
name: review-pr-comments
description: Review PR comments and plan implementation. Use when the user wants to address PR feedback, review comments on a pull request, or plan changes based on code review.
allowed-tools: Bash(gh pr view:*), Bash(gh api:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*), Read, Grep, Glob, AskUserQuestion, TodoWrite
---

## Context

You are reviewing comments on a Pull Request to understand what changes need to be made. Your goal is to:
1. Fetch and analyze all review comments on the PR
2. Categorize comments by status (addressed vs needs attention)
3. Identify any open questions that need clarification
4. Create an implementation plan for the required changes

## Your Task

Review all comments on this PR: $ARGUMENTS

### Step 1: Fetch PR Comments

Use the GitHub CLI to fetch all review comments:
```
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments
```

Also fetch the PR reviews for context:
```
gh pr view {pr_number} --repo {owner}/{repo} --comments --json comments,reviews
```

### Step 2: Analyze Comments

For each reviewer comment:
- Identify who made the comment
- Determine if it's been addressed (check for replies, resolved status)
- Categorize: question, suggestion, required change, or nitpick
- Note any code references (file paths, line numbers)

### Step 3: Identify Open Questions

Look for comments that:
- Ask questions without clear answers
- Suggest multiple approaches without a decision
- Require product/design decisions
- Need clarification on requirements

Use the `AskUserQuestion` tool to clarify these open questions with the user before proceeding.

### Step 4: Create Implementation Plan

After clarifying open questions, use `TodoWrite` to create a structured plan:
- List each change that needs to be made
- Reference the specific comment/feedback
- Order tasks by dependency and priority

### Step 5: Confirm Before Proceeding

Present the implementation plan to the user and ask for confirmation before making any code changes. Include:
- Summary of comments reviewed
- Decisions made from open questions
- Ordered list of changes to implement
- Any comments that were already addressed

Do NOT make any code changes until the user approves the plan.

### Step 6: Suggest Comment Responses

After the user approves the plan, provide brief and concise suggested responses for each reviewer comment. These should be:
- Short (1-2 sentences max)
- Professional and friendly
- Reference what was done (e.g., "Done!", "Good catch, fixed.", "Updated as suggested.")
- For questions: provide a brief answer
- For suggestions not implemented: brief explanation why

Format the responses as a list the user can copy-paste directly into GitHub:
```
**Comment by [reviewer] on [file]:[line]:**
> [brief quote of comment]

**Suggested response:** [your suggested response]
```
