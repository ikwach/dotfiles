# Mac Setup Quick Reference

> Quick commands and troubleshooting

← [[_Mac Setup|Mac Setup Hub]]

---

## System Maintenance

```bash
# Update everything (Homebrew + Mac App Store + macOS)
osup

# Just Homebrew
brew update && brew upgrade && brew cleanup

# Check Homebrew health
brew doctor

# List installed packages
brew list

# Search for package
brew search <package>

# Get package info
brew info <package>
```

---

## ZSH & Terminal

```bash
# Reconfigure Powerlevel10k
p10k configure

# Update plugins
antidote update

# Reload shell
source ~/.zshrc
# or
exec zsh

# Edit configs
nvim ~/.zshrc
nvim ~/.zsh_plugins.txt

# Benchmark shell startup
zsh-bench
```

---

## Git Commands

```bash
# Quick status
gs

# LazyGit TUI
lg

# Configure git
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

---

## File Operations

```bash
# Better cat
bat filename.py

# Better ls
ll                    # Long listing
tree                  # Tree view

# Search files
fd filename
fd -e py              # Python files only

# Search content
rg "search term"
rg -t py "def "       # Python files only

# Fuzzy find
fzf

# Smart cd
z project-name
zi                    # Interactive
```

---

## System Monitoring

```bash
# System monitor
btop

# Disk usage
gdu

# Process viewer
htop
```

---

## Neovim

```bash
# Launch
nvim

# Launch with file explorer
nvim .

# Key bindings (in Neovim)
<Space>e      # File explorer
<Space>ff     # Find files
<Space>fw     # Find word
<Space>gg     # LazyGit
K             # Documentation
gd            # Go to definition
```

---

## Troubleshooting

### Homebrew Issues

```bash
# Fix permissions (Apple Silicon)
sudo chown -R $(whoami) /opt/homebrew

# Fix permissions (Intel)
sudo chown -R $(whoami) /usr/local
```

### Terminal Rendering Issues

```bash
# Reset terminal
tput reset

# Check fonts
fc-list | grep -i "nerd"

# Reconfigure p10k
p10k configure
```

### ZSH Slow Startup

```bash
# Benchmark
zsh-bench

# Profile startup
for i in {1..10}; do /usr/bin/time zsh -i -c exit; done

# Check plugins
antidote list
```

### FZF Not Working

```bash
# Check installation
which fzf
fzf --version

# Reinstall
brew reinstall fzf

# Check .zshrc
grep "fzf --zsh" ~/.zshrc
```

### Neovim LSP Issues

```vim
:LspInfo          # Check status
:Mason            # Package manager
:checkhealth      # Health check
:LspLog           # View logs
```

---

## Configuration Files

```
~/.zshrc                    # ZSH config
~/.zsh_plugins.txt          # Plugins
~/.p10k.zsh                 # Prompt theme
~/.gitconfig                # Git config
~/.config/nvim/             # Neovim config
```

---

## Useful Aliases

From `~/.zshrc`:

```bash
osup              # Update everything
cat='bat'         # Better cat
ls='eza --icons'  # Better ls
ll='eza -lah...'  # Long listing
tree='eza --tree' # Tree view
cd='z'            # Smart cd
lg='lazygit'      # Git TUI
gs='git status'   # Git status
..='cd ..'        # Up one dir
...='cd ../..'    # Up two dirs
```

---

← [[_Mac Setup|Mac Setup Hub]]

**Last Updated:** 2025-10-21
