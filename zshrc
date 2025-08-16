# =============================================================================
# PATH Configuration
# =============================================================================
export PATH="$PATH:/opt/homebrew/bin"
export PATH="$PATH:/Users/zachkysar/.lmstudio/bin"
export PATH="$PATH:/Users/zachkysar/Library/Python/3.9/bin"

# =============================================================================
# Aliases
# =============================================================================
alias vim='nvim'

# =============================================================================
# Environment Variables
# =============================================================================
export FAKE_LMSTUDIO_KEY=123

# =============================================================================
# Terminal Session Management
# =============================================================================
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    tmux attach-session -t default || tmux new-session -s default
fi

# =============================================================================
# FZF Configuration
# =============================================================================
if command -v fzf &> /dev/null; then
    fzf_directory=$(brew --prefix)/Cellar/fzf/$(fzf --version | cut -d ' ' -f 1)
    [ -f "$fzf_directory/shell/key-bindings.zsh" ] && source "$fzf_directory/shell/key-bindings.zsh"
    [ -f "$fzf_directory/shell/completion.zsh" ] && source "$fzf_directory/shell/completion.zsh"
fi

# =============================================================================
# Keys
# =============================================================================
if [ -f ~/.keys ]; then
    source ~/.keys
else
    echo "Warning: ~/.keys file not found. Please create it from keys.sh.template if needed."
fi
