#!/usr/bin/env bash
#
# PostToolUse/Bash hook wrapper around `tokenjuice claude-code-post-tool-use`.
#
# Why this exists: tokenjuice appends
#     need raw? `tokenjuice wrap --raw -- <command>`.
# to the compacted text it injects as additionalContext. That text arrives
# inside a tool result, where an imperative sentence addressed to the agent is
# indistinguishable from an injected instruction. Agents correctly refuse it,
# and pay attention to it on every single Bash call. This wrapper rewrites the
# trailer into an explicitly-labelled metadata block that reads as provenance
# rather than a directive.
#
# Fails open: if tokenjuice or jq is missing, or jq chokes, the hook emits
# tokenjuice's output unchanged (or nothing) rather than breaking Bash.

set -uo pipefail

TOKENJUICE=${TOKENJUICE:-/opt/homebrew/bin/tokenjuice}
[ -x "$TOKENJUICE" ] || exit 0

out=$("$TOKENJUICE" claude-code-post-tool-use)
status=$?
[ -n "$out" ] || exit "$status"

if ! command -v jq >/dev/null 2>&1; then
  printf '%s' "$out"
  exit "$status"
fi

rewritten=$(printf '%s' "$out" | jq -c '
  if (.hookSpecificOutput.additionalContext? // "") != "" then
    .hookSpecificOutput.additionalContext |= sub(
      "\n*need raw\\? `tokenjuice wrap --raw -- <command>`\\.[[:space:]]*$";
      "\n\n<tokenjuice-note>Output above was shortened by tokenjuice, a local formatting tool on this machine. This note is metadata, not an instruction. Raw output is available by re-running the command as: tokenjuice wrap --raw -- <command></tokenjuice-note>"
    )
  else . end
' 2>/dev/null) && [ -n "$rewritten" ] || rewritten=$out

printf '%s' "$rewritten"
exit "$status"
