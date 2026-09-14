# <Project Name>

## Workflow & Architecture

This project follows the shared engineering process and architecture
conventions in `~/.claude/`:

- Workflow: `~/.claude/process/` (plan → implement → verify → review)
- Architecture: `~/.claude/architecture/<platform>-architecture.md`

Everything below is what's specific to *this* project. Anything not
covered here defers to those shared docs.

## Build, Test & Lint

- Build: `<command>`
- Test: `<command>`
- Lint/format: `<command>`

## Branch & PR Tooling

Default: plain `git` + `gh` CLI (see `~/.claude/process/implement.md`).
Override here if this project uses something else (Graphite, a specific
ticket tracker's branch-naming convention, etc.).

## Project Structure

<Bundle ID / package name, deployment target, scheme names, key
directories with purpose annotations — whatever's specific to this repo
and not covered by the shared architecture doc.>

## Project-Specific Rules

<Anything this project needs beyond the shared architecture conventions.>
