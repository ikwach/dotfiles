# Mac Setup Guide

> Complete macOS development environment setup (2025 Edition)

---

## 📚 Setup Guides

### Core Setup (Do in Order)
1. [[1-Initial-Setup|Initial Setup]] - Homebrew, iTerm2, fonts, essential apps
2. [[2-ZSH-Configuration|ZSH Configuration]] - Shell, Antidote, Powerlevel10k, plugins
3. [[3-CLI-Tools|CLI Tools]] - Modern replacements (bat, eza, ripgrep, fzf, etc.)
4. [[4-Neovim-Setup|Neovim Setup]] - IDE configuration with AstroNvim/LazyVim

### Quick Reference
- [[5-Mac Setup Quick Reference|Quick Reference]] - Commands, aliases, troubleshooting

---

## ⚡ Quick Commands

### System Maintenance
```bash
# Update everything (Homebrew + Mac App Store + macOS)
osup
```

### ZSH & Terminal
```bash
# Reconfigure Powerlevel10k prompt
p10k configure

# Update ZSH plugins
antidote update

# Reload shell config
source ~/.zshrc
# or
exec zsh

# Edit configs
zshconfig    # Opens ~/.zshrc in nvim
nvim ~/.zsh_plugins.txt
```

### Git
```bash
# Quick status
gs

# Lazy Git TUI
lg
```



---

## 📖 Related Guides

### Troubleshooting
See [[5-Mac Setup Quick Reference|Quick Reference]] for troubleshooting commands and common issues.

### Other Topics

- [[../Git/Git Workflows|Git Workflows]] - Squashing, rebasing, best practices
- [[../Networking/wireguard|WireGuard Setup]] - VPN configuration
- [[../Snippets|Code Snippets]] - Useful code snippets

---

## 🏷️ Tags

#mac-setup #terminal #development #zsh #homebrew #2025

---

**Last Updated:** 2025-10-21
**macOS Version:** Sequoia 15.0 (Apple Silicon)
**Maintained by:** Your Name
