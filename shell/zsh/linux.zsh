# =============================================================================
# Linux-only zsh config. Loader sources this only when $OSTYPE == linux* and
# BEFORE common.zsh (so PATH is set before common's tool-detection). Mirrors the
# role of macos.zsh. Keep it portable across Linux hosts; WSL-specific bits are
# guarded by a /proc/version check.
# =============================================================================

# ~/.local/bin holds user-installed binaries (gh, gitleaks, …). It is added by
# ~/.profile / ~/.bashrc for bash, but a zsh login shell reads neither, so put
# it on PATH here. The GitHub credential helper in git/gitconfig.linux
# (`!gh auth git-credential`) depends on gh being found this way. Prepend so
# user-installed tools win, but guard against duplicating the entry when this
# file is re-sourced (new subshells, `exec zsh`).
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac

# WSL clipboard parity with macOS pbcopy/pbpaste.
if grep -qi microsoft /proc/version 2>/dev/null; then
  alias pbcopy='clip.exe'
  alias pbpaste='powershell.exe -NoProfile -Command Get-Clipboard'
fi

# No secrets layer here: there is no macOS Keychain on Linux. On WSL, secrets
# are out of scope (see README); the NAS toolbox injects them by other means.
