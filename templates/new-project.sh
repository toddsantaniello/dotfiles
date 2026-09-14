#!/bin/bash
# Scaffold CLAUDE.md (+ AGENTS.md symlink) into a project directory.
# Usage: templates/new-project.sh <target-dir>
set -euo pipefail

TARGET="${1:?Usage: new-project.sh <target-dir>}"
TEMPLATES_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ -e "$TARGET/CLAUDE.md" ]]; then
    echo "$TARGET/CLAUDE.md already exists — not overwriting." >&2
    exit 1
fi

cp "$TEMPLATES_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"
ln -s CLAUDE.md "$TARGET/AGENTS.md"

echo "Scaffolded CLAUDE.md in $TARGET (AGENTS.md -> CLAUDE.md)."
echo "Fill in the placeholders, then commit both."
