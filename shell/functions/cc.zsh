cc() {
  local f=$(mktemp -t claude-prompt.XXXXXX.md)
  ${EDITOR:-vim} "$f" </dev/tty >/dev/tty
  [ -s "$f" ] && claude "$(cat "$f")" "$@"
  rm -f "$f"
}
