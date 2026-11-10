#!/bin/bash
# Prints Claude and Codex quota remaining for the tmux status bar, e.g. "claude 71% · codex 98%".
# tmux redraws every second, so the line is cached for 60s, and quota-axi itself reuses
# a vendor reading for up to 5 minutes.
cache="${TMPDIR:-/tmp}/tmux-quota-status"

if [[ -f "$cache" && -n "$(find "$cache" -mtime -60s 2>/dev/null)" ]]; then
  cat "$cache"
  exit 0
fi

line=$(quota-axi --provider claude,codex --max-age 5m --no-credential-refresh --json 2>/dev/null |
  jq -r '[.providers[]
    | (.quotaSemantics.effectiveAvailability // [] | map(select(.scope == "all_models"))[0].effectivePercentRemaining) as $p
    | "\(.provider) \(if $p == null then "?" else "\($p)%" end)"]
    | join(" · ")' 2>/dev/null)

if [[ -n "$line" ]]; then
  printf '%s' "$line" >"$cache"
  printf '%s' "$line"
elif [[ -f "$cache" ]]; then
  cat "$cache"
fi
