# =============================================================================
# macOS-only zsh config. Loader sources this only when $OSTYPE == darwin*, and
# BEFORE common.zsh (so Homebrew/tool PATHs are set before common's fzf/nvim/
# kubectl detection). Completions that need compinit/bashcompinit are zsh-defer'd
# so they run after common.zsh has initialized them.
# =============================================================================

# PATH
export PATH="$PATH:/opt/homebrew/bin"
export PATH="$PATH:/Users/zachkysar/.lmstudio/bin"
export PATH="$PATH:/Users/zachkysar/Library/Python/3.9/bin"
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Google Cloud SDK
source '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'
zsh-defer source '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'

# Aliases (Homebrew-versioned / macOS apps)
alias python='python3.11'
alias pip='pip3.11'
alias gyroflow="/Applications/Gyroflow.app/Contents/MacOS/gyroflow"
alias claude-mem='bun "/Users/zachkysar/.claude/plugins/cache/thedotmack/claude-mem/13.2.0/scripts/worker-service.cjs"'

# NAS toolbox entry (rides existing ssh zachnas + passwordless sudo).
# Full docker path: Container Manager's binary isn't on sudo's secure_path.
alias nas="ssh -t zachnas 'sudo /usr/local/bin/docker exec -it -u 1026:100 -w /volume1/homes/zachkysar toolbox zsh -l'"
alias nas-update="ssh -t zachnas 'sudo /usr/local/bin/docker exec -u 1026:100 toolbox sh -lc \"git -C \$HOME/projects/dotfiles pull --ff-only && \$HOME/projects/dotfiles/bin/link\"'"

# Environment
export FAKE_LMSTUDIO_KEY=123
export OLLAMA_MAX_LOADED_MODELS=2
export CLAUDE_MEM_MODEL=claude-haiku-4-5
export RCLONE_CONFIG_B2_TYPE=b2
export RCLONE_CONFIG_GDRIVE_TYPE=drive
export RCLONE_CONFIG_GDRIVE_SCOPE=drive.readonly

# Secrets — macOS Keychain (populated by `dots keys sync`)
_load_keychain_secrets() {
  local _name _val
  while IFS= read -r _name; do
    [ -z "$_name" ] && continue
    _val=$(security find-generic-password -s "$_name" -a "$USER" -w 2>/dev/null) || continue
    [ -n "$_val" ] && export "$_name=$_val"
  done < "$HOME/.dotfiles-keychain-names"
}
[ -f "$HOME/.dotfiles-keychain-names" ] && zsh-defer _load_keychain_secrets

# Terraform completion (needs bashcompinit from common.zsh — defer so it runs after)
zsh-defer complete -o nospace -C /opt/homebrew/bin/terraform terraform

# GitHub Issue Manager completion
if [ -f /Users/zachkysar/git/claude-tools/gh-issue-manager/completions/gh-issue-manager.zsh ]; then
  source /Users/zachkysar/git/claude-tools/gh-issue-manager/completions/gh-issue-manager.zsh
fi

# Dotfiles drift nag
[ -x "$HOME/projects/dotfiles/bin/doctor" ] && zsh-defer -1 -2 "$HOME/projects/dotfiles/bin/doctor" --quiet
