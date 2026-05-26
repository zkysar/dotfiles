# =============================================================================
# Portable zsh config — sourced on macOS AND the NAS toolbox container.
# KEEP THIS PORTABLE: no Homebrew paths, no macOS-only binaries (security,
# pbcopy, …), no hardcoded /Users/…. macOS-only config lives in macos.zsh.
# Consumed by homelab/toolbox (Dockerfile clones this repo and links it).
# =============================================================================

# dotfiles bin on PATH (repo lives at ~/projects/dotfiles on Mac and toolbox)
export PATH="$HOME/projects/dotfiles/bin:$PATH"

# Shell functions — shell/functions/*.zsh, one file per function
for _f in "$HOME/projects/dotfiles/shell/functions/"*.zsh(N); do
  source "$_f"
done
unset _f

# Aliases (guarded so an absent tool doesn't break the shell)
command -v nvim >/dev/null && alias vim='nvim'

# Environment
export EDITOR="vim"
export DO_NOT_TRACK=1
export CRUSH_DISABLE_METRICS=1

# Vi mode
set -o vi
export KEYTIMEOUT=1

# fzf — Homebrew (macOS) and apt (Debian/toolbox) integration paths
if command -v fzf &>/dev/null; then
  for _fzf in \
    /opt/homebrew/opt/fzf/shell/key-bindings.zsh \
    /opt/homebrew/opt/fzf/shell/completion.zsh \
    /usr/share/doc/fzf/examples/key-bindings.zsh \
    /usr/share/doc/fzf/examples/completion.zsh; do
    [[ -f $_fzf ]] && zsh-defer source "$_fzf"
  done
  unset _fzf
fi

# Completion framework
_ensure_completion() {
  local cmd=$1 file=$2; shift 2
  [[ -x ${commands[$cmd]} ]] || return
  [[ -f $file && $file -nt ${commands[$cmd]} ]] && return
  mkdir -p "${file:h}"
  $cmd "$@" >| $file
}
_ensure_completion kubectl "$HOME/.cache/zsh/completions/_kubectl" completion zsh
_ensure_completion gh      "$HOME/.cache/zsh/completions/_gh"      completion -s zsh

fpath=("$HOME/.zsh/completions" "$HOME/.zsh/external-completions" "$HOME/.cache/zsh/completions" $fpath)
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# Prompt
PROMPT='%F{#9d7cd8}❯%f %F{#6b9fe4}%~%f '
RPROMPT=''
PROMPT_EOL_MARK=''
