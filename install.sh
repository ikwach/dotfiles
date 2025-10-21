#!/usr/bin/env bash

# ========================================
# Dotfiles Installation Script
# ========================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# ========================================
# Configuration
# ========================================

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# ========================================
# Welcome
# ========================================

echo ""
echo "╔════════════════════════════════════════╗"
echo "║   Dotfiles Installation (2025)         ║"
echo "╚════════════════════════════════════════╝"
echo ""
info "Installation directory: $DOTFILES_DIR"
info "Backup directory: $BACKUP_DIR"
echo ""

# ========================================
# Check OS
# ========================================

if [[ "$OSTYPE" != "darwin"* ]]; then
    error "This script is only supported on macOS"
    exit 1
fi

# ========================================
# Install Homebrew
# ========================================

info "Checking Homebrew..."
if ! command -v brew &> /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH (Apple Silicon)
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    success "Homebrew installed"
else
    success "Homebrew already installed"
fi

# ========================================
# Install Homebrew packages
# ========================================

if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    info "Installing Homebrew packages..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
    success "Homebrew packages installed"
else
    warning "Brewfile not found, skipping package installation"
fi

# ========================================
# Backup existing dotfiles
# ========================================

info "Backing up existing dotfiles..."
mkdir -p "$BACKUP_DIR"

backup_file() {
    local file=$1
    if [ -f "$file" ] || [ -d "$file" ]; then
        info "Backing up $file"
        cp -r "$file" "$BACKUP_DIR/"
    fi
}

backup_file "$HOME/.zshrc"
backup_file "$HOME/.zsh_plugins.txt"
backup_file "$HOME/.p10k.zsh"
backup_file "$HOME/.gitconfig"
backup_file "$HOME/.tmux.conf"
backup_file "$HOME/.config/nvim"

success "Backup complete: $BACKUP_DIR"

# ========================================
# Create symlinks
# ========================================

info "Creating symlinks..."

create_symlink() {
    local source=$1
    local target=$2

    # Remove existing file/link
    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -rf "$target"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"

    # Create symlink
    ln -sf "$source" "$target"
    success "Linked: $target -> $source"
}

# ZSH
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/zsh/.zsh_plugins.txt" "$HOME/.zsh_plugins.txt"

# Terminal
create_symlink "$DOTFILES_DIR/terminal/.p10k.zsh" "$HOME/.p10k.zsh"

# Git
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# Tmux
create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# tealdeer
create_symlink "$DOTFILES_DIR/tealdeer/config.toml" "$HOME/Library/Application Support/tealdeer/config.toml"

success "Symlinks created"

# ========================================
# Install ZSH plugins
# ========================================

info "Installing ZSH plugins with Antidote..."
if command -v antidote &> /dev/null; then
    # Source antidote and load plugins
    source "$(brew --prefix)/opt/antidote/share/antidote/antidote.zsh"
    antidote load
    success "ZSH plugins installed"
else
    warning "Antidote not found, skipping plugin installation"
fi

# ========================================
# Install Powerlevel10k
# ========================================

info "Configuring Powerlevel10k..."
success "Powerlevel10k installed (run 'p10k configure' to customize)"

# ========================================
# Install Tmux Plugin Manager
# ========================================

info "Installing Tmux Plugin Manager (TPM)..."
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    success "TPM installed (press prefix + I in tmux to install plugins)"
else
    success "TPM already installed"
fi

# ========================================
# Update tealdeer cache
# ========================================

info "Updating tealdeer cache..."
if command -v tldr &> /dev/null; then
    tldr --update
    success "tealdeer cache updated"
fi

# ========================================
# Set ZSH as default shell
# ========================================

if [ "$SHELL" != "$(which zsh)" ]; then
    info "Setting ZSH as default shell..."
    chsh -s "$(which zsh)"
    success "ZSH set as default shell"
fi

# ========================================
# Done!
# ========================================

echo ""
echo "╔════════════════════════════════════════╗"
echo "║   Installation Complete! 🎉            ║"
echo "╚════════════════════════════════════════╝"
echo ""
success "Dotfiles installed successfully!"
echo ""
info "Next steps:"
echo "  1. Restart your terminal"
echo "  2. Run 'p10k configure' to customize your prompt"
echo "  3. In tmux, press Ctrl+a then Shift+I to install plugins"
echo "  4. Check Mac Setup guide for additional configuration"
echo ""
info "Backup location: $BACKUP_DIR"
echo ""
