# Brewfile - Homebrew Bundle
# Based on Mac Setup Guide (2025)
#
# Installation options:
#   brew bundle                    # Install everything
#   brew bundle --no-lock          # Install without creating Brewfile.lock
#
# Minimal install (CLI tools only):
#   brew bundle --file=- <<EOF
#   $(sed -n '/ESSENTIAL START/,/ESSENTIAL END/p' Brewfile)
#   EOF
#
# To skip GUI apps, comment out the "Applications (Casks)" section

# ========================================
# Taps
# ========================================

tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/cask-fonts"
tap "homebrew/core"

# ========================================
# ESSENTIAL START - Minimal CLI-only install
# ========================================

# ========================================
# Terminal & Shell
# ========================================

# Terminal
cask "iterm2"

# ZSH plugin manager
brew "antidote"

# Powerlevel10k prompt theme
brew "powerlevel10k"

# FZF fuzzy finder
brew "fzf"

# ========================================
# Modern CLI Tools
# ========================================

# Better cat
brew "bat"

# Better ls
brew "eza"

# Better grep
brew "ripgrep"

# Better find
brew "fd"

# Smart cd
brew "zoxide"

# Better top
brew "btop"

# Fast tldr
brew "tealdeer"

# Interactive cheatsheets
brew "navi"

# Better git diff
brew "git-delta"

# Git TUI
brew "lazygit"

# Disk usage analyzer
brew "gdu"

# JSON processor
brew "jq"

# YAML processor
brew "yq"

# Process viewer
brew "htop"

# Directory tree
brew "tree"

# ========================================
# Development Tools
# ========================================

# Git
brew "git"

# Neovim
brew "neovim"

# Programming languages
brew "python3"
brew "golang"
brew "node"

# Version managers
brew "nvm"
brew "pyenv"
brew "rbenv"

# ========================================
# Utilities
# ========================================

# Download tools
brew "wget"
brew "curl"

# Tmux
brew "tmux"

# Mac App Store CLI
brew "mas"

# GitHub CLI
brew "gh"

# ========================================
# ESSENTIAL END - Everything above is CLI tools only
# ========================================

# ========================================
# Applications (Casks) - OPTIONAL
# Comment out this entire section if you don't want GUI apps
# ========================================

# Browsers
cask "google-chrome"
cask "firefox"

# Security & Password Management
cask "1password"

# Development (comment out what you don't need)
cask "visual-studio-code"  # Code editor (optional if using Neovim)
cask "docker"              # Docker Desktop
cask "postman"             # API testing

# Communication (comment out what you don't need)
cask "slack"               # Team communication
cask "discord"             # Community chat

# Productivity Utilities
cask "rectangle"           # Window management (free)
cask "raycast"             # Spotlight replacement (free tier available)
# cask "alfred"            # Alternative to Raycast (paid)

# ========================================
# Fonts - REQUIRED for Powerlevel10k icons
# ========================================

# Nerd Fonts (required for terminal icons and Powerlevel10k)
# At minimum, install one of these:
cask "font-meslo-lg-nerd-font"       # Recommended by Powerlevel10k
cask "font-fira-code-nerd-font"      # Popular coding font
cask "font-hack-nerd-font"           # Clean monospace
cask "font-jetbrains-mono-nerd-font" # JetBrains official font

# ========================================
# Mac App Store Apps
# ========================================

# Install after: mas install <id>
# Find IDs: mas search "app name"

# Examples:
# mas "Xcode", id: 497799835

# ========================================
# Optional Tools
# ========================================

# Uncomment if needed:
# brew "vim"
# brew "tmux"
# brew "ansible"
# brew "terraform"
# brew "kubernetes-cli"
# cask "obsidian"
# cask "notion"
