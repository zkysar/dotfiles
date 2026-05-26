cc() {
  command -v claude >/dev/null 2>&1 || { echo "cc: claude not found" >&2; return 1; }
  local f=$(mktemp -t claude-prompt.XXXXXX.md)
  ${EDITOR:-vim} "$f" </dev/tty >/dev/tty
  [ -s "$f" ] && claude "$(cat "$f")" "$@"
  rm -f "$f"
}
