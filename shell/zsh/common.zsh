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

# zsh's default viins bindings use vi-backward-delete-char / vi-backward-kill-word,
# which refuse to delete past the point where insert mode was last entered — so
# Esc, move, then i/a leaves backspace dead. Use the emacs widgets in viins only;
# normal-mode x/d/c are untouched. Must come after any other `set -o vi`/`bindkey -v`.
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^U' backward-kill-line

# @d — inline date abbreviation. Typing `@d` at the start of a word and then any
# key (or Enter) replaces it with today's YYYY-MM-DD, so `mkdir @d-zine-cover`
# becomes `mkdir 2026-09-10-zine-cover` right in the buffer. A global alias can't
# do this: zsh only expands aliases that match a whole word. Word-start only, so
# `me@domain.com` is left alone.
_expand_date_abbrev() {
  [[ $LBUFFER == (|*[[:space:]/=])@d ]] && LBUFFER="${LBUFFER%@d}$(date +%F)"
}
_date_abbrev_self_insert() { _expand_date_abbrev; zle .self-insert; }
_date_abbrev_accept_line() { _expand_date_abbrev; zle .accept-line; }
zle -N self-insert _date_abbrev_self_insert
zle -N accept-line _date_abbrev_accept_line

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
_ensure_completion kubectl   "$HOME/.cache/zsh/completions/_kubectl"   completion zsh
_ensure_completion gh        "$HOME/.cache/zsh/completions/_gh"        completion -s zsh
_ensure_completion runpodctl "$HOME/.cache/zsh/completions/_runpodctl" completion generate zsh

fpath=("$HOME/.zsh/completions" "$HOME/.zsh/external-completions" "$HOME/.cache/zsh/completions" $fpath)
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# zoxide replaces `cd`: real paths behave as usual, otherwise `cd <part of path>`
# jumps to a frecent dir; `cdi` picks with fzf. _ZO_ECHO prints where a fuzzy
# jump landed so a typo can't silently drop you somewhere. Must come after compinit.
export _ZO_ECHO=1
command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"

# Keep every ~/projects/* dir in zoxide so `cd` finds a project before you've
# visited it. Only adds missing ones: `zoxide add` on a known dir bumps its rank.
_zoxide_seed_projects() {
  local -a known=("${(@f)$(zoxide query -la --base-dir $HOME/projects)}")
  local -a dirs=($HOME/projects/*(N/))
  local -a missing=(${dirs:|known})
  (( $#missing )) && zoxide add $missing
}
command -v zoxide >/dev/null && zsh-defer _zoxide_seed_projects

# Prompt. An optional location tag is prepended when $TOOLBOX_HOST is set
# (the NAS toolbox container sets TOOLBOX_HOST=nas); on the Mac it's unset, so
# the prompt is unchanged.
_ctx_tag=""
[[ -n $TOOLBOX_HOST ]] && _ctx_tag="%F{#e0af68}${TOOLBOX_HOST}%f "
PROMPT="${_ctx_tag}%F{#9d7cd8}❯%f %F{#6b9fe4}%~%f "
unset _ctx_tag
RPROMPT=''
PROMPT_EOL_MARK=''
