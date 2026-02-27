---
name: code-review
description: Code review for the current branch changes against the base branch. Use when reviewing code changes, checking for bugs, or validating CLAUDE.md compliance.
argument-hint: '[base-branch]'
disable-model-invocation: true
allowed-tools: Bash(git *), Read, Glob, Grep, Task
---

Provide a code review for the current branch changes against the base branch.

The base branch to compare against is: $ARGUMENTS (default to "main" if not provided)

## Agent Assumptions

All tools are functional and will work without error. Do not test tools or make exploratory calls. Make sure this is clear to every subagent that is launched.
Only call a tool if it is required to complete the task. Every tool call should have a clear purpose.

## Steps

### Step 1: Get the diff and check if review is needed

Run `git diff <base-branch>...HEAD` to get all changes on this branch compared to the base branch. Use "main" as the base branch if no argument was provided.

Launch a sonnet agent to check if any of the following are true:

- There are no changes to review
- The changes are trivial and obviously correct (e.g., version bump, typo fix)
- The changes are automated/generated files only

If any condition is true, respond with "No review needed" and stop.

### Step 2: Find relevant CLAUDE.md files

Launch a sonnet agent to return a list of file paths (not their contents) for all relevant CLAUDE.md files including:

- The root CLAUDE.md file, if it exists
- Any CLAUDE.md files in directories containing files modified by the changes

### Step 3: Get a summary of changes

Launch a sonnet agent to view the diff and return a summary of the changes including:

- List of files modified
- Brief description of what each change does
- Overall intent of the changes

### Step 4: Review the changes

Launch 4 agents in parallel to independently review the changes. Each agent should return the list of issues, where each issue includes:

- File path and line number(s)
- Description of the issue
- Reason it was flagged (e.g., "CLAUDE.md adherence", "bug", "security")
- Severity: HIGH, MEDIUM, or LOW

The agents should do the following:

**Agents 1 + 2: Sonnet CLAUDE.md compliance agents**
Audit changes for CLAUDE.md compliance in parallel. Note: When evaluating CLAUDE.md compliance for a file, you should only consider CLAUDE.md files that share a file path with the file or parents.

**Agent 3: Opus bug agent (parallel with agent 4)**
Scan for obvious bugs. Focus only on the diff itself without reading extra context. Flag only significant bugs; ignore nitpicks and likely false positives. Do not flag issues that you cannot validate without looking at context outside of the git diff.

**Agent 4: Opus bug agent (parallel with agent 3)**
Look for problems that exist in the introduced code. This could be security issues, incorrect logic, etc. Only look for issues that fall within the changed code.

Agents 1+2 MUST use sonnet. Agents 3+4 MUST use opus.

### Step 5: Filter for HIGH SIGNAL issues only

CRITICAL: We only want HIGH SIGNAL issues. Flag issues where:

- The code will fail to compile or parse (syntax errors, type errors, missing imports, unresolved references)
- The code will definitely produce wrong results regardless of inputs (clear logic errors)
- Clear, unambiguous CLAUDE.md violations where you can quote the exact rule being broken
- Security vulnerabilities (SQL injection, XSS, command injection, etc.)

Do NOT flag:

- Code style or quality concerns
- Potential issues that depend on specific inputs or state
- Subjective suggestions or improvements
- Pre-existing issues not introduced in this diff
- Issues a linter will catch
- General code quality concerns unless explicitly required in CLAUDE.md

If you are not certain an issue is real, do not flag it. False positives erode trust and waste reviewer time.

### Step 6: Validate flagged issues

For each issue found in step 4 by agents 3 and 4, launch parallel subagents to validate the issue. These subagents should get the change summary along with a description of the issue. The agent's job is to review the issue to validate that the stated issue is truly an issue with high confidence.

For example:

- If "variable is not defined" was flagged, validate it's actually undefined in the code
- If a CLAUDE.md violation was flagged, validate the rule is scoped for this file and is actually violated

Use Opus subagents for bugs and logic issues, and Sonnet subagents for CLAUDE.md violations.

### Step 7: Filter and compile final issues

Filter out any issues that were not validated in step 6. This gives us our list of high signal issues for the review.

### Step 8: Output the review

Format the review output as follows:

```
## Code Review Summary

**Branch:** [current branch]
**Base:** [base branch]
**Files Changed:** [count]

### Changes Overview
[Summary from step 3]

### Issues Found

#### Issue 1: [Title]
- **File:** `path/to/file.js:123`
- **Severity:** HIGH/MEDIUM/LOW
- **Type:** Bug/CLAUDE.md violation/Security
- **Description:** [What's wrong]
- **Suggested Fix:** [How to fix it, if applicable]

[Repeat for each issue]

### Conclusion
[Total issues found, recommendation to merge or not]
```

If NO issues were found, output:

```
## Code Review Summary

**Branch:** [current branch]
**Base:** [base branch]
**Files Changed:** [count]

### Changes Overview
[Summary from step 3]

### Issues Found
No issues found. Checked for bugs and CLAUDE.md compliance.

### Conclusion
Changes look good to merge.
```

## False Positives to Avoid

Do NOT flag these (these are false positives):

- Pre-existing issues not introduced in this diff
- Something that appears to be a bug but is actually correct
- Pedantic nitpicks that a senior engineer would not flag
- Issues that a linter will catch (do not run the linter to verify)
- General code quality concerns unless explicitly required in CLAUDE.md
- Issues mentioned in CLAUDE.md but explicitly silenced in the code (e.g., via a lint ignore comment)

## Notes

- Use `git diff` and `git log` commands to interact with the repository
- Create a todo list before starting
- You must cite and link each issue (e.g., if referring to a CLAUDE.md, include the file path)
- Focus on the diff content, not the entire file context unless necessary to validate an issue
