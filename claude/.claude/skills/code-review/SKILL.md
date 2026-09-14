---
name: code-review
description: Code review for the current branch changes against the base branch. Use when reviewing code changes, checking for bugs, or validating project-convention compliance.
argument-hint: '[base-branch]'
allowed-tools: Bash(git *), Read, Glob, Grep, Agent
---

Review the current branch's changes against the base branch (default
`origin/main`, or `$ARGUMENTS` if given), following the method in
[`../process/code-review.md`](../process/code-review.md) exactly. This
file only maps that method onto Claude Code's `Agent` tool and pins which
model runs which step — edit the `model:` field in the referenced agent
files to change cost/quality tradeoffs; nothing else needs to change.

## Agent Assumptions

All tools are functional and will work without error. Do not test tools
or make exploratory calls. Make sure this is clear to every subagent that
is launched. Only call a tool if it is required to complete the task.

## Model mapping

- **Steps 1-3** (triviality check, locating convention files, summarizing
  the diff) are mechanical — use `subagent_type: quick-task` for each.
- **Step 4** (the four independent review passes) and **Step 6**
  (validating each flagged issue) need actual judgment — use
  `subagent_type: code-reviewer` for each, launched in parallel where the
  process doc says to.

First, run `git fetch origin` to ensure the latest remote state, then
`git diff <base-branch>...HEAD` to get the full diff. Then work through
Steps 1-8 of the process doc, using the model mapping above for each
`Agent` call the process describes.
