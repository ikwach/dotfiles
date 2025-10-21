# Documentation & Manual Setup Guides

## Choose Your Path 🛤️

This dotfiles repository offers **two approaches** to setting up your macOS development environment:

---

## 🚀 Fast Track: Automated Installation

**"I trust your dotfiles and want to get up and running quickly"**

Use the automated installer for a one-command setup:

```bash
cd ~/dotfiles
./install.sh
```

**What you get:**
- ✅ Pre-configured dotfiles (ZSH, tmux, git, tealdeer)
- ✅ Automated package installation via Brewfile
- ✅ Automatic backup of your existing config
- ✅ Everything set up in under 10 minutes

**Best for:** Quick setup, trying out a complete modern config, getting started fast

[→ Back to main README](../README.md)

---

## 🛠️ DIY Track: Manual Setup

**"I want to understand everything and customize it myself"**

Use the comprehensive step-by-step guides in the `Mac Setup/` folder:

### Manual Setup Guides

1. **[Initial Setup](Mac%20Setup/1-Initial-Setup.md)** - Homebrew, iTerm2, fonts
2. **[ZSH Configuration](Mac%20Setup/2-ZSH-Configuration.md)** - Shell setup, plugins, theme
3. **[Modern CLI Tools](Mac%20Setup/3-CLI-Tools.md)** - bat, eza, ripgrep, fzf, etc.
4. **[Neovim Setup](Mac%20Setup/4-Neovim-Setup.md)** - Modern text editor config
5. **[Quick Reference](Mac%20Setup/5-Mac%20Setup%20Quick%20Reference.md)** - Command cheatsheet

**What you get:**
- 📚 Learn exactly what each tool does and why
- 🎨 Customize every aspect to your preferences
- 🧠 Deep understanding of your development environment
- 🎯 Pick and choose only what you need

**Best for:** Learning, customization, specific workflows, experienced users

[→ Start with Initial Setup](Mac%20Setup/1-Initial-Setup.md)

---

## 🎯 Hybrid Approach: Best of Both Worlds

**"I want the automated setup but also want to understand it"**

1. **Read the guides first** to understand what's being configured
2. **Run the automated installer** for quick setup
3. **Refer back to guides** for customization and troubleshooting

This gives you speed **and** knowledge.

---

## 📦 Minimal Installation

**"I only want CLI tools, no GUI applications"**

Use the minimal Brewfile for CLI-only setup:

```bash
brew bundle --file=docs/Brewfile.minimal
```

Then follow [Manual Installation](../README.md#manual-installation) for dotfile symlinks.

**Includes:** All modern CLI tools, ZSH, Neovim, development tools
**Excludes:** VS Code, Docker Desktop, Chrome, Slack, etc.

---

## 🔍 What's the Difference?

| Aspect | Automated (`./install.sh`) | Manual (Guides) |
|--------|---------------------------|-----------------|
| **Time** | ~10 minutes | ~1-2 hours |
| **Learning** | Quick overview | Deep understanding |
| **Customization** | Use my preferences | Your preferences |
| **Difficulty** | Easy | Intermediate |
| **Best for** | Getting started | Learning & mastery |

---

## 📂 Additional Resources

### Configuration Files

- **[Brewfile](../Brewfile)** - All packages and applications
- **[Brewfile.minimal](Brewfile.minimal)** - CLI tools only
- **[.zshrc](../zsh/.zshrc)** - Shell configuration
- **[.tmux.conf](../tmux/.tmux.conf)** - Terminal multiplexer
- **[.gitconfig](../git/.gitconfig)** - Git with delta
- **[tealdeer config](../tealdeer/config.toml)** - Monokai Pro Spectrum theme

### Files You Can Safely Customize

After installation, these are meant to be personalized:
- `~/.zshrc` - Add your own aliases and functions
- `~/.gitconfig` - Update name, email, add aliases
- `~/.p10k.zsh` - Customize prompt (or run `p10k configure`)
- `~/.tmux.conf` - Adjust key bindings and plugins

---

## 💡 Tips

**New to macOS development?**
→ Start with [Initial Setup Guide](Mac%20Setup/1-Initial-Setup.md)

**Experienced developer in a hurry?**
→ Run `./install.sh` and customize later

**Want to cherry-pick tools?**
→ Use [Brewfile.minimal](Brewfile.minimal) as a base

**Need help troubleshooting?**
→ Check [Quick Reference](Mac%20Setup/5-Mac%20Setup%20Quick%20Reference.md)

---

**Last Updated:** 2025-10-21
**Tested on:** macOS Sequoia 15.0 (Apple Silicon)
