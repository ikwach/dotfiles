# Initial Setup - macOS Developer Environment

> First steps for setting up a fresh macOS installation

← Back to [[_Mac Setup]]

---

## Prerequisites

**Before You Start:**
```bash
# Check your macOS version
sw_vers

# Install Xcode Command Line Tools (if not already installed)
xcode-select --install
```

**Supported Systems:**
- macOS 12 (Monterey) or later
- Works on both Intel and Apple Silicon Macs

---

## Homebrew Package Manager

Homebrew is the foundation - install it first.

### Installation

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Apple Silicon Setup

If you're on an M1/M2/M3 Mac, add Homebrew to your PATH:

```bash
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Verify Installation

```bash
brew --version
brew doctor
```

### Essential Homebrew Commands

```bash
# Update package list
brew update

# Upgrade installed packages
brew upgrade

# Search for packages
brew search <package>

# Install GUI applications
brew install --cask <app-name>

# Install CLI tools
brew install <tool-name>

# Clean up old versions
brew cleanup

# List installed packages
brew list

# Get info about a package
brew info <package>
```

---

## iTerm2 Terminal

iTerm2 is a powerful terminal replacement with advanced features.

### Install iTerm2

```bash
brew install --cask iterm2
```

### Key Features
- **Split Panes**: `Cmd+D` (vertical), `Cmd+Shift+D` (horizontal)
- **Full shell integration**: Command history, current directory tracking
- **Slow paste mode**: Essential for network device console configuration
- **Profiles**: Save different configurations for different workflows
- **Hotkey window**: Instant dropdown terminal with configurable hotkey
- **Search**: `Cmd+F` to search terminal output
- **Instant Replay**: View terminal history like a video

### Font Installation (Nerd Fonts)

Install Nerd Fonts for proper icon support in terminal prompts:

```bash
# Install specific popular fonts (recommended)
brew install --cask font-meslo-lg-nerd-font
brew install --cask font-fira-code-nerd-font
brew install --cask font-hack-nerd-font
brew install --cask font-jetbrains-mono-nerd-font

# Or install ALL Nerd Fonts (large download)
brew search '/font-.*-nerd-font/' | awk '{ print $1 }' | xargs -I{} brew install --cask {} || true
```

### Configure Font in iTerm2

1. Open iTerm2 → Preferences (⌘+,)
2. Profiles → Text tab
3. Change Font to a Nerd Font (e.g., "MesloLGS NF")
4. Set size to 13-14pt for optimal readability
5. Enable "Anti-aliased" and "Use ligatures" (optional)

### Color Schemes

**Recommended themes:**
- **Dark**: Monokai Pro Spectrum, Dracula, Material Design Colors, Andromeda
- **Light**: Monokai Pro Light Sun, Material Light, One Light, Pro Light

**Install themes:**
1. Download from [iTerm2 Color Schemes](https://iterm2colorschemes.com/)
2. iTerm2 → Preferences → Profiles → Colors
3. Color Presets → Import
4. Select downloaded `.itermcolors` file

### Recommended iTerm2 Settings

**General:**
- Preferences → General → Closing → Confirm "Quit iTerm2" → Uncheck (optional)

**Profiles → Terminal:**
- Scrollback lines → 10000 (or "Unlimited")

**Profiles → Keys:**
- Key Mappings → Presets → Natural Text Editing

---

## Essential Applications

### Core Development Tools

```bash
# Browsers
brew install --cask google-chrome
brew install --cask firefox

# Security
brew install --cask 1password

# Communication
brew install --cask slack
brew install --cask discord

# Development
brew install --cask visual-studio-code  # Optional, if you use VSCode
brew install --cask docker              # Docker Desktop
brew install --cask postman             # API testing

# Utilities
brew install --cask rectangle           # Window management
brew install --cask raycast             # Modern launcher (Spotlight replacement)
brew install --cask Alfred              # Alternative launcher

# Mac App Store CLI
brew install mas
```

### Version Managers

```bash
# Node version manager
brew install nvm

# Python version manager
brew install pyenv

# Ruby version manager
brew install rbenv
```

### Install Mac App Store Apps

```bash
# Login first
mas signin your.email@example.com

# Search for apps
mas search "Xcode"

# Install by ID
mas install 497799835  # Xcode (example)

# List installed apps
mas list
```

---

## Git Configuration

```bash
# Configure git identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Use rebase instead of merge on pull
git config --global pull.rebase true

# Set default editor
git config --global core.editor "nvim"

# View your config
git config --list
```

Better git diff with delta (install after setting up CLI tools):
```bash
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.light false
git config --global delta.side-by-side true
```

---

## Next Steps

1. ✅ Homebrew installed
2. ✅ iTerm2 configured with Nerd Fonts
3. ✅ Essential apps installed
4. ✅ Git configured

**Continue to:** [[2-ZSH-Configuration|ZSH Configuration]] →

---

## Troubleshooting

### Homebrew Issues

```bash
# Fix permissions (Apple Silicon)
sudo chown -R $(whoami) /opt/homebrew

# Fix permissions (Intel)
sudo chown -R $(whoami) /usr/local

# Reinstall if corrupted
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
# Then reinstall
```

### iTerm2 Font Issues

```bash
# Check if fonts are installed
fc-list | grep -i "nerd"

# If empty, reinstall fonts
brew reinstall font-meslo-lg-nerd-font
```

---

← Back to [[_Mac Setup]] | Next: [[2-ZSH-Configuration|ZSH Configuration]] →

**Last Updated:** 2025-10-21
