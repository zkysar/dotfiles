cc() {
  command -v claude >/dev/null 2>&1 || { echo "cc: claude not found" >&2; return 1; }
  local f=$(mktemp -t claude-prompt.XXXXXX.md)
  ${EDITOR:-vim} "$f" </dev/tty >/dev/tty
  if [ -s "$f" ]; then
    local p=$(cat "$f") flags=()
    # A prompt that mentions chrome gets the Claude in Chrome integration.
    grep -qiw chrome "$f" && flags+=(--chrome)
    claude "${flags[@]}" "$p" "$@"
  fi
  rm -f "$f"
}
