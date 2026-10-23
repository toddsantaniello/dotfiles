# Code Review Process

Tool-agnostic description of reviewing a set of changes for real bugs and
project-convention compliance, tuned hard against false positives. The
mechanism for "delegate to N independent reviewers" is left to the adapter
(parallel agent calls, separate model invocations, separate human
reviewers — whatever the executing tool provides); the method below is
what makes the output high-signal regardless of mechanism.

## Step 1: Check If Review Is Needed

Get the diff between the current change and its base. If any of these are
true, respond "No review needed" and stop:
- There are no changes to review.
- The changes are trivial and obviously correct (e.g. version bump, typo
  fix).
- The changes are automated/generated files only.

## Step 2: Find Relevant Project Conventions

Locate the project's own instruction files (CLAUDE.md/AGENTS.md or
equivalent) — the root one, plus any in directories containing modified
files.

## Step 3: Summarize the Changes

Produce: list of files modified, a brief description of what each change
does, and the overall intent.

## Step 4: Review the Changes

Review independently along these lines (in parallel if your tooling
supports it):

- **Convention compliance** (x2, independently): audit changes against
  the project's own instruction files. Only apply a rule from a file that
  shares a path with the changed file or its parents.
- **Bugs, pass 1**: scan for obvious bugs, working only from the diff
  itself without extra context. Flag only significant bugs; ignore
  nitpicks and likely false positives. Don't flag anything you can't
  validate without looking at surrounding context outside the diff.
- **Bugs, pass 2**: look for problems introduced by the new code
  specifically — security issues, incorrect logic, etc. — scoped only to
  changed lines.

Each pass returns: file path + line number(s), description, why it was
flagged (bug / convention violation / security), and severity
(HIGH/MEDIUM/LOW).

## Step 5: Filter for High-Signal Issues Only

Keep only issues where:
- The code will fail to compile or parse.
- The code will definitely produce wrong results regardless of input.
- A project-convention violation you can quote the exact rule for.
- A security vulnerability (injection, XSS, etc.).

Drop:
- Style/quality concerns.
- Anything that depends on specific inputs or state you haven't verified.
- Subjective suggestions.
- Pre-existing issues not introduced by this diff.
- Anything a linter would catch.
- General quality concerns not explicitly required by project convention.

If you're not certain an issue is real, don't flag it. False positives
erode trust faster than missed issues do.

## Step 6: Validate Flagged Issues

For every issue surfaced in Step 4, independently verify it against the
actual code before it's allowed into the final list — e.g. if "variable
undefined" was flagged, confirm it's actually undefined; if a convention
violation was flagged, confirm the rule is scoped to this file and
actually violated.

## Step 7: Compile Final Issues

Drop anything that didn't survive Step 6 validation.

## Step 8: Output

If issues remain:

```
## Code Review Summary

**Branch:** [current branch]
**Base:** [base branch]
**Files Changed:** [count]

### Changes Overview
[Summary from Step 3]

### Issues Found

#### Issue 1: [Title]
- **File:** `path/to/file:123`
- **Severity:** HIGH/MEDIUM/LOW
- **Type:** Bug/Convention violation/Security
- **Description:** [What's wrong]
- **Suggested Fix:** [How to fix it, if applicable]

### Conclusion
[Total issues found, recommendation to merge or not]
```

If none:

```
## Code Review Summary

**Branch:** [current branch]
**Base:** [base branch]
**Files Changed:** [count]

### Changes Overview
[Summary from Step 3]

### Issues Found
No issues found. Checked for bugs and convention compliance.

### Conclusion
Changes look good to merge.
```

## False Positives to Avoid

- Pre-existing issues not introduced in this diff.
- Something that looks like a bug but is actually correct.
- Pedantic nitpicks a senior engineer wouldn't flag.
- Issues a linter would catch (don't run the linter just to verify this).
- General quality concerns not explicitly required by project convention.
- Issues named in a convention file but explicitly silenced in the code
  (e.g. a lint-ignore comment).

## Notes

- Cite and link each issue (e.g. quote the exact instruction-file rule).
- Focus on the diff content, not the entire file, unless necessary to
  validate an issue.
