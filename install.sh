#!/bin/bash

# macOS dotfiles installer
set -e

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This script is designed for macOS only. Current OS: $OSTYPE"
    exit 1
fi

# Check if running zsh
if [[ "$SHELL" != *"zsh"* ]]; then
    echo "This script requires zsh. Current shell: $SHELL"
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 Setting up dotfiles on macOS..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install via Homebrew
brew_install() {
    local package="$1"
    if ! brew list "$package" >/dev/null 2>&1; then
        echo "📦 Installing $package..."
        brew install "$package"
    else
        echo "✅ $package is already installed"
    fi
}

# Install Homebrew if not present
if ! command_exists brew; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew is already installed"
fi

# Update Homebrew
echo "🔄 Updating Homebrew..."
brew update

# Install required packages
brew_install "fzf"
brew_install "tmux" 
brew_install "neovim"
brew_install "git"
brew_install "charmbracelet/tap/crush"

# Create necessary directories
echo "📁 Creating config directories..."
mkdir -p "$HOME/.config/crush"

# Create symlinks
echo "🔗 Creating symlinks..."
ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
ln -sf "$DOTFILES_DIR/crush/crush.json" "$HOME/.config/crush/crush.json"
ln -sf "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"

echo "✅ Dotfiles setup complete!"
echo "🔄 Please restart your terminal or run: source ~/.zshrc"
