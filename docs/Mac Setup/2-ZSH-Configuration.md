# ZSH Configuration

> Modern ZSH setup with Antidote plugin manager, Powerlevel10k theme, and essential plugins

← [[1-Initial-Setup|Initial Setup]] | [[_Mac Setup|Mac Setup Hub]] | [[3-CLI-Tools|CLI Tools]] →

---

## Table of Contents
- [Why ZSH?](#why-zsh)
- [Prerequisites](#prerequisites)
- [Core Setup](#core-setup)
- [Plugin Manager (Antidote)](#plugin-manager-antidote)
- [Powerlevel10k Theme](#powerlevel10k-theme)
- [Essential Plugins](#essential-plugins)
- [FZF Integration](#fzf-integration)
- [Useful Aliases](#useful-aliases)
- [Troubleshooting](#troubleshooting)

---

## Why ZSH?

macOS has used ZSH as the default shell since Catalina (2019). ZSH offers:
- **Better tab completion** - More intelligent and context-aware
- **Spelling correction** - Suggests corrections for typos
- **Plugin ecosystem** - Extensive community plugins
- **Theming support** - Beautiful, informative prompts
- **Backward compatibility** - Works with most Bash scripts

**Check your current shell:**
```bash
echo $0
# or
ps -p $$
```

---

## Prerequisites

```bash
# Install Homebrew first (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install antidote lazygit ripgrep fzf
```

---

## Core Setup

### Backup Existing Configuration

**IMPORTANT:** Always backup before making changes!

```bash
# Backup ZSH config
cp ~/.zshrc ~/.zshrc.bak

# Backup Oh-My-Zsh if you have it (we'll replace it)
mv ~/.oh-my-zsh ~/.oh-my-zsh_backup
```

### Create Fresh .zshrc

Create a new `~/.zshrc` file:

```bash
cat > ~/.zshrc << 'EOF'
# Enable completion system
autoload -Uz compinit
compinit

# Source antidote
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh

# Initialize plugins from ~/.zsh_plugins.txt
antidote load

# Enable FZF integration for CTRL-R and other features
source <(fzf --zsh)
EOF
```

---

## Plugin Manager (Antidote)

### Why Antidote?

- **Fast** - Written natively in ZSH, concurrent plugin loading
- **Simple** - Single text file for plugin management
- **Modern** - Successor to Antibody, actively maintained
- **Compatible** - Works with Oh-My-Zsh plugins
- **Static** - Generates fast static plugin file

### Install Antidote

```bash
brew install antidote
```

### Create Plugin File

Create `~/.zsh_plugins.txt`:

```bash
cat > ~/.zsh_plugins.txt << 'EOF'
# ~/.zsh_plugins.txt

# Comments are supported like this
# Empty lines are skipped

# Completions
zsh-users/zsh-completions

# Annotations are supported:
romkatv/zsh-bench kind:path
olets/zsh-abbr kind:defer

# Oh-My-Zsh framework support
ohmyzsh/ohmyzsh path:lib
ohmyzsh/ohmyzsh path:plugins/colored-man-pages

# Essential Fish-like plugins
zsh-users/zsh-autosuggestions
zdharma-continuum/fast-syntax-highlighting kind:defer
EOF
```

### Plugin Descriptions

- **zsh-completions** - Additional completion definitions
- **zsh-bench** - Benchmark your ZSH startup time
- **zsh-abbr** - Manage command abbreviations
- **colored-man-pages** - Colorize man pages for better readability
- **zsh-autosuggestions** - Fish-like autosuggestions as you type
- **fast-syntax-highlighting** - Syntax highlighting for commands

---

## Powerlevel10k Theme

### Why Powerlevel10k?

- **Fast** - 100x faster than Powerlevel9k
- **Beautiful** - Clean, informative prompt
- **Git integration** - Shows branch, status, ahead/behind
- **Configurable** - Interactive setup wizard
- **Async** - Non-blocking prompt rendering

### Install Powerlevel10k

```bash
brew install powerlevel10k
```

### Add to .zshrc

Add these lines to the **TOP** of your `~/.zshrc` (before everything else):

```bash
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source Powerlevel10k theme
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

### Run Configuration Wizard

Close and reopen iTerm2. The p10k configuration wizard will start automatically.

If it doesn't start automatically:
```bash
p10k configure
```

**Configuration Wizard Options:**
1. **Diamond** - Does this look like a diamond? (Tests font rendering)
2. **Lock** - Does this look like a lock? (Tests icon rendering)
3. **Prompt Style** - Choose: Rainbow, Pure, Lean (Lean recommended)
4. **Character Set** - Unicode
5. **Prompt Colors** - 256 colors
6. **Show current time?** - 24-hour format recommended
7. **Prompt Separators** - Angled
8. **Prompt Heads** - Sharp
9. **Prompt Tails** - Flat
10. **Prompt Height** - One line (cleaner) or Two lines (more space)
11. **Prompt Connection** - Disconnected
12. **Prompt Frame** - No frame
13. **Prompt Spacing** - Compact
14. **Icons** - Many icons
15. **Prompt Flow** - Concise
16. **Enable Transient Prompt?** - Yes (saves screen space)
17. **Instant Prompt Mode** - Verbose (shows warnings)

### Reconfigure Anytime

```bash
p10k configure
```

### Prompt Features

Powerlevel10k shows:
- **Current directory** - With shortened path
- **Git branch** - Current branch name
- **Git status** - Modified files, staged changes, ahead/behind
- **Exit code** - Shows if last command failed
- **Execution time** - For long-running commands
- **Python virtualenv** - If activated
- **Node version** - If nvm is active
- **Background jobs** - If any running
- **Time** - Current time (optional)

---

## Essential Plugins

**Understanding the difference:**
- **zsh-completions** - Adds data for `TAB` completion (250+ commands)
- **zsh-autosuggestions** - Shows suggestions automatically as you type
- **They work together:** completions provides the data, autosuggestions uses it proactively

### zsh-completions

Adds completion definitions for 250+ commands not included in default ZSH.

**What it does:**
- Press `TAB` → dropdown menu appears with available options
- Adds support for modern tools: docker, npm, cargo, kubectl, etc.
- Makes tab-completion smarter for tools you use daily

**Example usage:**
```bash
# Git commands
git che<TAB>  # → git checkout

# Docker with intelligent options
docker run <TAB>  # Shows: --rm, --name, -p, -v, etc.

# NPM commands
npm in<TAB>  # → npm install

# Homebrew formulas
brew install <TAB>  # Lists available packages

# Kubectl resources
kubectl get <TAB>  # Shows: pods, services, deployments, etc.
```

**Why you need it:**
Default ZSH has basic completions. This adds 250+ modern CLI tools.

### zsh-autosuggestions

Proactively suggests commands as you type based on your history and available completions.

**How it works:**
- Type `doc` → automatically shows `docker ps` in gray (from your history)
- Press `→` (right arrow) to accept full suggestion
- Press `Ctrl+→` to accept one word at a time
- Press `Esc` to dismiss suggestion
- Keep typing to ignore it

**Visual example:**
```bash
$ git che█
$ git checkout main█  # ← appears automatically in gray
                      # Press → to accept
```

**Why you need it:**
- Speeds up typing repetitive commands
- Recalls commands you've used before
- Works with zsh-completions data for smarter suggestions

**Configuration:**
```bash
# Add to ~/.zshrc if you want custom settings
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'  # Gray color
ZSH_AUTOSUGGEST_STRATEGY=(history completion)  # Use both sources
```

### fast-syntax-highlighting

Highlights command syntax in real-time as you type.

**Color coding:**
- **Green** - Valid command (exists in PATH)
- **Red** - Invalid/unknown command (will fail)
- **Blue** - Existing file/directory
- **Yellow** - String/argument
- **Magenta** - Option/flag

**Why you need it:**
- Catch typos BEFORE pressing Enter
- See if files exist as you type paths
- Understand command structure visually

**Example:**
```bash
$ cd /usr/loca  # "loca" shows in RED (doesn't exist)
$ cd /usr/local # "local" shows in BLUE (exists!)
```

### Colored Man Pages

Makes man pages readable with syntax highlighting.

```bash
# Try it
man ls
man git
```

---

## FZF Integration

FZF (Fuzzy Finder) dramatically improves command-line productivity.

### Install FZF

```bash
brew install fzf
```

### Enable in ZSH

Add to `~/.zshrc`:
```bash
# Enable FZF integration for CTRL-R and other powerful features
source <(fzf --zsh)
```

### Key Bindings

- **Ctrl+R** - Search command history (fuzzy)
- **Ctrl+T** - Search files in current directory
- **Alt+C** - cd into subdirectory

### Usage Examples

**Search command history (Ctrl+R):**
```
# Type: Ctrl+R
# Start typing: "dock"
# See fuzzy-matched commands from history
# Select with arrow keys, Enter to execute
```

**Search files (Ctrl+T):**
```bash
nvim <Ctrl+T>
# Fuzzy search for file
# Press Enter to insert into command
```

**Change directory (Alt+C):**
```bash
# Press Alt+C
# Fuzzy search for directory
# Press Enter to cd into it
```

### FZF Customization

Add to `~/.zshrc`:
```bash
# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --preview "bat --color=always {}"
  --preview-window=right:60%
'
```

---

## Useful Aliases

### System Update Alias

Add to `~/.zshrc`:

```bash
# Update everything: Homebrew, Mac App Store, macOS
alias osup="echo 'Updating Homebrew...'; brew update; echo 'Upgrading outdated packages...'; brew upgrade; echo 'Cleaning up...'; brew cleanup; echo 'Done!'; echo 'Upgrading Mac App Store apps...'; mas upgrade; echo 'Done!'; echo 'Updating macOS...'; sudo softwareupdate -i --restart; echo 'Done!'"
```

**Usage:**
```bash
osup  # Updates everything and restarts if needed
```

### Modern CLI Aliases

```bash
# Modern replacements
alias cat='bat'
alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias tree='eza --tree --level=3 --icons'
alias cd='z'  # Using zoxide

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias lg='lazygit'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Shortcuts
alias reload='source ~/.zshrc'
alias zshconfig='nvim ~/.zshrc'
alias zshplugins='nvim ~/.zsh_plugins.txt'

# Networking
alias myip='curl ifconfig.me'
alias ports='lsof -i -P -n | grep LISTEN'

# Disk usage
alias du='gdu'
alias df='df -h'
```

### Apply Aliases

```bash
source ~/.zshrc
# or
exec zsh
```

---

## Complete .zshrc Example

Here's a complete, production-ready `.zshrc`:

```bash
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source Powerlevel10k theme
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Enable completion system
autoload -Uz compinit
compinit

# Source antidote
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh

# Initialize plugins from ~/.zsh_plugins.txt
antidote load

# Enable FZF integration
source <(fzf --zsh)

# ============================================
# Environment Variables
# ============================================

# BAT theme
export BAT_THEME="Dracula"

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# ============================================
# Aliases
# ============================================

# System update
alias osup="echo 'Updating Homebrew...'; brew update; echo 'Upgrading outdated packages...'; brew upgrade; echo 'Cleaning up...'; brew cleanup; echo 'Done!'; echo 'Upgrading Mac App Store apps...'; mas upgrade; echo 'Done!'; echo 'Updating macOS...'; sudo softwareupdate -i --restart; echo 'Done!'"

# Modern CLI tools
alias cat='bat'
alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias tree='eza --tree --level=3 --icons'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias lg='lazygit'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'

# Utilities
alias reload='source ~/.zshrc'
alias zshconfig='nvim ~/.zshrc'
alias myip='curl ifconfig.me'

# ============================================
# Zoxide (Smart cd)
# ============================================
eval "$(zoxide init zsh)"
alias cd='z'

# ============================================
# Additional Configurations
# ============================================

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
```

---

## Troubleshooting

### Plugins Not Loading

```bash
# Reload antidote
antidote load

# Or regenerate static file
rm -rf ~/.cache/antidote
antidote load
```

### Slow Shell Startup

```bash
# Benchmark your shell
zsh-bench

# Profile startup
zsh -xv 2>&1 | ts -i '%.s' > /tmp/zsh_profile.log

# Check which plugins are slow
for i in {1..10}; do /usr/bin/time zsh -i -c exit; done
```

### Powerlevel10k Not Showing Icons

1. Verify Nerd Font is installed:
```bash
fc-list | grep -i "nerd"
```

2. Check iTerm2 font settings:
   - Preferences → Profiles → Text → Font
   - Must be a Nerd Font (e.g., "MesloLGS NF")

3. Reconfigure p10k:
```bash
p10k configure
```

### FZF Not Working

```bash
# Reinstall FZF
brew reinstall fzf

# Verify installation
which fzf
fzf --version

# Check .zshrc has FZF source line
grep "fzf --zsh" ~/.zshrc
```

### Autosuggestions Not Appearing

```bash
# Check plugin is loaded
antidote list | grep autosuggestions

# Reload plugins
antidote update
source ~/.zshrc

# Test manually
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
```

### Reset Everything

```bash
# Restore backup
cp ~/.zshrc.bak ~/.zshrc

# Or start fresh
rm ~/.zshrc ~/.zsh_plugins.txt
rm -rf ~/.cache/antidote
# Then redo setup from beginning
```

---

## Performance Tips

### Lazy Load Heavy Tools

```bash
# Lazy load NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  nvm "$@"
}
```

### Use Static Plugin Loading

Antidote already does this by default - it generates a static file for fast loading.

### Minimize Plugins

Only use plugins you actually need. Each plugin adds startup time.

---

## Additional Resources

- [Antidote Documentation](https://getantidote.github.io/)
- [Powerlevel10k GitHub](https://github.com/romkatv/powerlevel10k)
- [ZSH Users Plugins](https://github.com/zsh-users)
- [Awesome ZSH Plugins](https://github.com/unixorn/awesome-zsh-plugins)
- [FZF GitHub](https://github.com/junegunn/fzf)
- [ZSH Documentation](https://zsh.sourceforge.io/Doc/)

---

**Last Updated:** 2025-10-21
**Tested on:** macOS Sequoia 15.0 with ZSH 5.9


---

← [[1-Initial-Setup|Initial Setup]] | [[_Mac Setup|Mac Setup Hub]] | [[3-CLI-Tools|CLI Tools]] →

**Last Updated:** 2025-10-21
