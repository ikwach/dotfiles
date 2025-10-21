# 🚀 Modern macOS Dotfiles (2025)

> My personal development environment configuration for macOS with modern tools and best practices.

[![macOS](https://img.shields.io/badge/macOS-Sequoia%2015.0-000000?style=flat&logo=apple)](https://www.apple.com/macos/)
[![Homebrew](https://img.shields.io/badge/Homebrew-4.x-FBB040?style=flat&logo=homebrew)](https://brew.sh/)
[![ZSH](https://img.shields.io/badge/Shell-ZSH-4E9A06?style=flat&logo=gnu-bash)](https://www.zsh.org/)

---

## ✨ Features

- **Modern shell setup** - ZSH with Antidote plugin manager & Powerlevel10k theme
- **Modern CLI tools** - bat, eza, ripgrep, fzf, zoxide, btop, lazygit, and more
- **Enhanced tmux** - Mouse support, sensible key bindings, plugin manager
- **Beautiful colors** - Monokai Pro Spectrum theme for tealdeer
- **One-command install** - Automated setup with backup
- **Version controlled** - Track and sync across machines

---

## 📦 What's Included

### Shell & Terminal
- **ZSH** with Antidote plugin manager (faster than Oh-My-Zsh)
- **Powerlevel10k** prompt theme
- **Autosuggestions** - Fish-like suggestions as you type
- **Syntax highlighting** - Real-time command validation
- **FZF integration** - Fuzzy finding for history, files, directories

### Modern CLI Tools
| Tool | Replaces | Purpose |
|------|----------|---------|
| **bat** | cat | Syntax highlighting, line numbers |
| **eza** | ls | Icons, git status, tree view |
| **ripgrep** | grep | Faster search, respects .gitignore |
| **fd** | find | Simpler syntax, faster |
| **fzf** | - | Fuzzy finder for everything |
| **zoxide** | cd | Smart directory jumping |
| **btop** | top | Beautiful system monitor |
| **tealdeer** | tldr | Fast command examples |
| **navi** | - | Interactive cheatsheets |
| **lazygit** | - | Git TUI |
| **gdu** | du | Fast disk usage analyzer |
| **git-delta** | diff | Better git diffs |

### Applications
- iTerm2, VS Code, Docker, Postman
- 1Password, Rectangle, Raycast
- Google Chrome, Firefox, Slack

### Development
- Neovim, Python, Go, Node.js
- Version managers: nvm, pyenv, rbenv
- Git with delta for beautiful diffs

---

## 🚀 Quick Start

### Prerequisites

- macOS 12 (Monterey) or later
- Command Line Tools: `xcode-select --install`

### Installation

```bash
# Clone the repository
git clone https://github.com/ikwach/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the installation script
./install.sh
```

The installer will:
1. ✅ Install Homebrew (if needed)
2. ✅ Install all packages from Brewfile
3. ✅ Backup your existing dotfiles
4. ✅ Create symlinks to new dotfiles
5. ✅ Install ZSH plugins
6. ✅ Set up tmux plugin manager
7. ✅ Configure tealdeer

### Post-Installation

```bash
# Restart your terminal
# Then configure Powerlevel10k
p10k configure

# In tmux, install plugins
# Press: Ctrl+a then Shift+I
```

---

## 📁 Structure

```
dotfiles/
├── install.sh              # Automated installation script
├── Brewfile                # Homebrew packages
│
├── zsh/
│   ├── .zshrc             # ZSH configuration
│   └── .zsh_plugins.txt   # Antidote plugin list
│
├── terminal/
│   └── .p10k.zsh          # Powerlevel10k theme
│
├── git/
│   └── .gitconfig         # Git configuration
│
├── tmux/
│   └── .tmux.conf         # Modern tmux setup
│
├── tealdeer/
│   └── config.toml        # Monokai Pro Spectrum theme
│
├── nvim/                   # Neovim config (optional)
├── bin/                    # Utility scripts
└── fonts/                  # Custom fonts
```

---

## ⚙️ Configuration

### ZSH

Main configuration: `zsh/.zshrc`

**Key aliases:**
```bash
osup               # Update everything (Homebrew + MAS + macOS)
cat='bat'          # Use bat instead of cat
ls='eza --icons'   # Use eza instead of ls
cd='z'             # Use zoxide for smart cd
lg='lazygit'       # Launch lazygit
```

**Plugins:**
- zsh-completions (250+ commands)
- zsh-autosuggestions (Fish-like suggestions)
- fast-syntax-highlighting (Real-time validation)
- colored-man-pages
- FZF integration (Ctrl+R for history)

### Git

Configuration: `git/.gitconfig`

Features:
- Git delta for beautiful diffs
- Rebase on pull by default
- Main as default branch
- Neovim as editor

### Tmux

Configuration: `tmux/.tmux.conf`

**Key bindings:**
- Prefix: `Ctrl+a` (instead of Ctrl+b)
- `Ctrl+a |` - Split vertically
- `Ctrl+a -` - Split horizontally
- `Ctrl+a h/j/k/l` - Navigate panes (Vim-style)
- `Alt+Arrows` - Navigate panes (no prefix)
- `Ctrl+a r` - Reload config

**Plugins (TPM):**
- tmux-sensible - Sensible defaults
- tmux-resurrect - Save/restore sessions
- tmux-continuum - Auto-save every 15 mins
- tmux-yank - Better copy/paste

### tealdeer

Configuration: `tealdeer/config.toml`

Monokai Pro Spectrum color theme with:
- Orange command names
- Cyan code examples
- Pink variables
- Gray descriptions

---

## 🎨 Customization

### Change tealdeer colors

Edit `tealdeer/config.toml` with RGB values:

```toml
[style.command_name]
foreground = { rgb = [252, 145, 88] }  # Orange
bold = true
```

See alternate themes (Dracula, Nord) in the config file comments.

### Add ZSH plugins

Edit `zsh/.zsh_plugins.txt`:

```bash
# Add a new plugin
username/plugin-name

# Reload
antidote update
```

### Customize prompt

```bash
p10k configure
```

---

## 🔄 Updating

```bash
cd ~/dotfiles

# Pull latest changes
git pull

# Reinstall (keeps your config)
./install.sh

# Update Homebrew packages
brew bundle

# Update ZSH plugins
antidote update
```

---

## 🛠️ Manual Installation

If you prefer not to use the install script:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install packages
brew bundle

# Create symlinks
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/zsh/.zsh_plugins.txt ~/.zsh_plugins.txt
ln -sf ~/dotfiles/terminal/.p10k.zsh ~/.p10k.zsh
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/tealdeer/config.toml ~/Library/Application\ Support/tealdeer/config.toml
```

---

## 💡 Quick Reference

### System Maintenance
```bash
osup  # Update everything
```

### Essential Commands
```bash
fd filename          # Find files
rg "term"            # Search content
Ctrl+R               # Fuzzy history
z project            # Jump to directory
btop                 # System monitor
gdu                  # Disk usage
lg                   # Git TUI
tldr tar             # Command examples
```

### Tmux
```bash
tmux new -s name     # Create session
tmux ls              # List sessions
tmux attach -t name  # Attach
Ctrl+a d             # Detach
```

---

## 🔧 Troubleshooting

### ZSH plugins not loading
```bash
antidote update
source ~/.zshrc
```

### Homebrew permissions
```bash
sudo chown -R $(whoami) /opt/homebrew
```

### Icons not showing
1. iTerm2 → Preferences → Profiles → Text
2. Set font to a Nerd Font (e.g., "MesloLGS NF")
3. Run: `p10k configure`

### tmux plugins not installing
```bash
# In tmux: Ctrl+a then Shift+I
```

---

## 📝 Credits

- [Antidote](https://getantidote.github.io/) - ZSH plugin manager
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - ZSH theme
- [Modern Unix](https://github.com/ibraheemdev/modern-unix) - CLI tools
- [TPM](https://github.com/tmux-plugins/tpm) - Tmux plugin manager

---

## 📄 License

MIT License - Feel free to use and modify!

---

**Last Updated:** 2025-10-21
**Tested on:** macOS Sequoia 15.0 (Apple Silicon)

⭐ Star this repo if you found it helpful!
