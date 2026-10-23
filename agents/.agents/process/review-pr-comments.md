# PR Comment Triage Process

Tool-agnostic description of turning open PR review comments into an
approved implementation plan.

## Goal

1. Fetch and analyze all review comments on the PR.
2. Categorize comments by status (addressed vs. needs attention).
3. Identify open questions that need clarification.
4. Create an implementation plan for the required changes.

## Step 1: Fetch PR Comments

Pull every review comment on the PR, plus the PR's top-level reviews, from
whatever code host this project uses.

## Step 2: Analyze Comments

For each comment:
- Identify who made it.
- Determine if it's already been addressed (replies, resolved status).
- Categorize: question, suggestion, required change, or nitpick.
- Note any code references (file paths, line numbers).

## Step 3: Identify Open Questions

Flag comments that:
- Ask questions without a clear answer.
- Suggest multiple approaches without a decision.
- Require a product/design decision.
- Need clarification on requirements.

Ask the human to resolve these before proceeding — do not guess at
product decisions.

## Step 4: Create an Implementation Plan

After open questions are resolved, produce a structured task list:
- Each change that needs to be made.
- The specific comment/feedback it addresses.
- Ordered by dependency and priority.

## Step 5: Confirm Before Proceeding

Present the plan and ask for approval before making any code changes.
Include:
- Summary of comments reviewed.
- Decisions made from the open questions.
- Ordered list of changes to implement.
- Any comments already addressed.

Do NOT make code changes until the plan is approved.

## Step 6: Suggest Comment Responses

Once approved, draft a short, professional reply for each reviewer
comment:
- 1-2 sentences max.
- Reference what was done ("Done!", "Good catch, fixed.", "Updated as
  suggested.").
- For questions: a brief answer.
- For suggestions not implemented: a brief reason why.

Format as a copy-pasteable list:

```
**Comment by [reviewer] on [file]:[line]:**
> [brief quote of comment]

**Suggested response:** [your suggested response]
```
