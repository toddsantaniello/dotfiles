---
description: >
  Start a collaborative planning session for reasoning through a problem before
  implementation. Use when you need to think through a bug, design a feature,
  evaluate tradeoffs, or decompose a complex task.
argument-hint: "<description of the problem or task>"
---

# Planning Mode

Follow the process in [`../process/plan.md`](../process/plan.md) exactly —
it covers the conversation rules, how to read code during planning, and
the plan document template. This file only adds the Claude Code-specific
mechanics.

## Claude Code specifics

- Write the plan file to `~/.claude/plans/YYYY-MM-DD-<slug>.md`.
- When the conversation concludes, after writing the file and outputting
  the plan, close with:

  > **Planning complete.** Want me to take it from here? I'll create a
  > branch, implement, review, and open a draft PR.

  If the user says yes, follow the **Development Workflow** in
  `~/.claude/CLAUDE.md`, which runs `/implement`.
