# Modern CLI Tools

> Replace traditional Unix tools with modern, faster alternatives

← [[2-ZSH-Configuration|ZSH Configuration]] | [[_Mac Setup|Mac Setup Hub]] | [[4-Neovim-Setup|Neovim Setup]] →

---

## Installation

Install all essential modern CLI tools at once:

```bash
brew install \
  bat \          # Better cat
  eza \          # Better ls (formerly exa)
  ripgrep \      # Better grep
  fd \           # Better find
  fzf \          # Fuzzy finder
  zoxide \       # Smart cd
  btop \         # Better top
  tealdeer \     # Fast tldr (simplified man pages)
  navi \         # Interactive cheatsheets
  git-delta \    # Better git diff
  lazygit \      # Git TUI
  gdu \          # Fast disk usage analyzer
  jq \           # JSON processor
  yq \           # YAML processor
  htop \         # Process viewer
  tree \         # Directory tree viewer
  wget \         # File downloader
  curl           # Transfer tool
```

---

## Tool Overview

### bat - Enhanced cat

**What it does:** Syntax highlighting, line numbers, git integration

```bash
# Basic usage
bat filename.py

# Compare with regular cat
cat script.sh      # Plain text
bat script.sh      # Syntax highlighting + line numbers

# Pipe support (auto-removes decorations when piped)
bat myfile.json | jq

# Show non-printable characters
bat -A file.txt

# Multiple files
bat file1.txt file2.txt

# With line range
bat --line-range 1:50 large-file.txt
```

**Configuration:**

Add to `~/.zshrc`:
```bash
# Set theme
export BAT_THEME="Dracula"
# or: "Monokai Extended", "OneHalfDark", "Solarized (dark)"

# Alias to replace cat
alias cat='bat'
```

---

### eza - Modern ls

**What it does:** Colorful file listing with icons, git status, tree view

```bash
# Basic listing with icons
eza

# Long format with all files
eza -la

# With git status
eza -la --git

# Tree view (2 levels)
eza --tree --level=2

# Tree view respecting .gitignore
eza --tree --git-ignore --level=3

# Sort by modification time
eza -la --sort=modified

# Sort by size
eza -la --sort=size

# Only directories
eza -D

# Only files
eza -f
```

**Recommended aliases:**

Add to `~/.zshrc`:
```bash
alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias la='eza -a --icons'
alias lt='eza --tree --level=2 --icons'
alias tree='eza --tree --level=3 --icons --git-ignore'
```

---

### ripgrep (rg) - Fast search

**What it does:** Lightning-fast code search, respects .gitignore

```bash
# Basic search
rg "search term"

# Case-insensitive
rg -i "search term"

# Search specific file types
rg -t py "def "           # Only Python files
rg -t js "function"       # Only JavaScript files
rg -t md "TODO"           # Only Markdown files

# Search with context (3 lines before/after)
rg -C 3 "search term"

# Only show filenames
rg -l "search term"

# Count matches per file
rg -c "search term"

# Include hidden files
rg --hidden "config"

# Include ignored files
rg --no-ignore "node_modules"

# Search only in specific directory
rg "term" src/

# List files that would be searched
rg --files

# List file types
rg --type-list
```

**Common patterns:**
```bash
# Find all TODOs
rg "TODO|FIXME|HACK"

# Find function definitions
rg "^def \w+"

# Find import statements
rg "^import|^from"

# Find console logs
rg "console\.log"
```

---

### fd - Better find

**What it does:** Fast file search, respects .gitignore

```bash
# Find files by name
fd filename

# Case-insensitive
fd -i readme

# Find by extension
fd -e py           # All .py files
fd -e md           # All .md files

# Find directories only
fd -t d dirname

# Find files only
fd -t f filename

# Include hidden files
fd -H pattern

# Search in specific directory
fd pattern /path/to/dir

# Execute command on results
fd -e jpg -x convert {} {.}.png

# Exclude patterns
fd --exclude node_modules pattern
```

**Combine with fzf:**
```bash
# Fuzzy find and edit file
nvim $(fd -t f | fzf)

# Find directory and cd
cd $(fd -t d | fzf)
```

---

### fzf - Fuzzy Finder

**What it does:** Interactive fuzzy search for files, history, processes

**Key Bindings (already configured in [[2-ZSH-Configuration|ZSH setup]]):**
- **Ctrl+R** - Search command history
- **Ctrl+T** - Search files
- **Alt+C** - cd into directory

**Usage examples:**
```bash
# Search files
fzf

# Preview files while searching
fzf --preview 'bat --color=always {}'

# Search and edit
nvim $(fzf)

# Kill process
kill -9 $(ps aux | fzf | awk '{print $2}')

# Checkout git branch
git checkout $(git branch | fzf)

# SSH into host
ssh $(cat ~/.ssh/config | grep "Host " | awk '{print $2}' | fzf)
```

**Advanced configuration:**

Add to `~/.zshrc`:
```bash
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --preview "bat --color=always --line-range=:500 {}"
  --preview-window=right:60%
  --bind=ctrl-u:preview-page-up,ctrl-d:preview-page-down
'
```

---

### zoxide - Smart cd

**What it does:** Jump to frequently used directories

```bash
# Jump to directory (fuzzy match)
z documents
z proj          # Matches "projects" or "project"
z doc/cod       # Matches "Documents/Coding"

# Interactive selection if multiple matches
zi proj

# Add current directory to database
zoxide add .

# Remove directory from database
zoxide remove /path/to/dir

# Query database
zoxide query proj

# Edit database
zoxide edit
```

**Setup:**

Add to `~/.zshrc`:
```bash
eval "$(zoxide init zsh)"
alias cd='z'
```

**How it learns:**
- Tracks how often you visit directories
- Prioritizes frequently/recently used directories
- Works like a smart "cd" with memory

---

### btop - System Monitor

**What it does:** Beautiful resource monitor

```bash
# Launch
btop
```

**Navigation:**
- `q` - Quit
- `o` - Options menu
- `m` - Menu
- `↑↓←→` - Navigate
- `f` - Filter processes
- `t` - Tree view
- `k` - Kill process

**Features:**
- CPU usage per core
- Memory/Swap usage
- Disk I/O
- Network traffic
- Process list with filtering
- Multiple color themes

---

### lazygit - Git TUI

**What it does:** Terminal UI for Git operations

```bash
# Launch (must be in git repo)
lazygit

# Or use alias
lg
```

**Key Bindings:**
- `space` - Stage/unstage
- `c` - Commit
- `p` - Push
- `P` - Pull
- `a` - Amend commit
- `r` - Rebase
- `m` - Merge
- `s` - Squash
- `d` - Delete branch
- `?` - Show help

**Why use it:**
- Visual diff viewer
- Interactive rebasing
- Branch management
- Stash management
- Commit history
- Cherry-picking

---

### gdu - Disk Usage Analyzer

**What it does:** Fast disk usage analysis

```bash
# Analyze current directory
gdu

# Analyze specific path
gdu /Users/username

# Show apparent size
gdu -a

# Export results
gdu -o- /path > disk-usage.json
```

**Navigation:**
- `↑↓` - Navigate
- `Enter` - Enter directory
- `Backspace` - Go up
- `d` - Delete file/directory
- `n` - Sort by name
- `s` - Sort by size
- `c` - Show item count
- `q` - Quit

---

### git-delta - Better Git Diff

**What it does:** Syntax highlighting for git diffs

**Configuration:**

Add to `~/.gitconfig`:
```bash
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global delta.light false
git config --global delta.side-by-side true
git config --global delta.line-numbers true
```

**Usage:**
```bash
# Now all git diff commands use delta
git diff
git show
git log -p
git stash show -p
```

---

### Additional Useful Tools

#### jq - JSON processor
```bash
# Pretty print JSON
cat file.json | jq

# Extract field
cat file.json | jq '.user.name'

# Filter array
cat file.json | jq '.[] | select(.age > 18)'

# Combine with curl
curl https://api.github.com/users/github | jq '.name'
```

#### yq - YAML processor
```bash
# Pretty print YAML
cat file.yaml | yq

# Convert YAML to JSON
yq -o json file.yaml
```

#### tealdeer - Fast tldr (Simplified man pages)
```bash
# Quick examples instead of full manual (Rust implementation, much faster)
tldr tar
tldr curl
tldr git-commit

# Update cache
tldr --update

# List all pages
tldr --list

# Clear cache
tldr --clear-cache
```

**Why tealdeer over tldr:**
- 10x faster (written in Rust)
- Works offline after cache update
- Drop-in replacement (command is still `tldr`)
- Actively maintained

**Custom color theme (optional):**

Create `~/Library/Application Support/tealdeer/config.toml`:

```toml
# Monokai Pro Spectrum theme
[style.description]
foreground = { rgb = [252, 252, 250] }
underline = false
bold = false
italic = false

[style.command_name]
foreground = { rgb = [252, 145, 88] }   # Orange
underline = false
bold = true
italic = false

[style.example_text]
foreground = { rgb = [191, 199, 213] }  # Gray
underline = false
bold = false
italic = false

[style.example_code]
foreground = { rgb = [120, 220, 232] }  # Cyan
underline = false
bold = true
italic = false

[style.example_variable]
foreground = { rgb = [255, 97, 136] }   # Pink
underline = true
bold = false
italic = false
```

**Other popular themes:**

<details>
<summary>Dracula theme</summary>

```toml
[style.description]
foreground = { rgb = [248, 248, 242] }

[style.command_name]
foreground = { rgb = [255, 121, 198] }  # Pink
bold = true

[style.example_code]
foreground = { rgb = [139, 233, 253] }  # Cyan
bold = true

[style.example_variable]
foreground = { rgb = [241, 250, 140] }  # Yellow
underline = true
```
</details>

<details>
<summary>Nord theme</summary>

```toml
[style.description]
foreground = { rgb = [216, 222, 233] }

[style.command_name]
foreground = { rgb = [136, 192, 208] }  # Blue
bold = true

[style.example_code]
foreground = { rgb = [129, 161, 193] }  # Light blue
bold = true

[style.example_variable]
foreground = { rgb = [180, 142, 173] }  # Purple
underline = true
```
</details>

#### navi - Interactive cheatsheets
```bash
# Launch interactive browser
navi

# Fuzzy search for command
navi --query "extract tar"

# Execute command directly
navi --best-match

# Add custom cheatsheet repository
navi repo add <url>
```

**Usage tips:**
- Browse with arrow keys, select with Enter
- Tab to see variables you can customize
- Integrates with fzf for fuzzy finding
- Create your own cheatsheets in `~/.local/share/navi/cheats/`

#### htop - Interactive process viewer
```bash
# Better than top
htop

# Sort by CPU
htop -s PERCENT_CPU

# Sort by memory
htop -s PERCENT_MEM
```

---

## Aliases Summary

Add all these to your `~/.zshrc`:

```bash
# Modern replacements
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
alias gd='git diff'
alias gco='git checkout'
alias lg='lazygit'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Zoxide (smart cd)
eval "$(zoxide init zsh)"
alias cd='z'

# Utilities
alias du='gdu'
alias top='btop'
alias man='tldr'  # Use tldr (tealdeer) instead of man for quick help
```

---

## Next Steps

After setting up CLI tools:
- ✅ Modern replacements installed
- ✅ Aliases configured
- ✅ Git delta configured

**Continue to:** [[4-Neovim-Setup|Neovim Setup]] (optional) →

Or return to [[_Mac Setup|Mac Setup Hub]]

---

## Resources

- [Modern Unix Tools GitHub](https://github.com/ibraheemdev/modern-unix)
- [bat Documentation](https://github.com/sharkdp/bat)
- [eza Documentation](https://github.com/eza-community/eza)
- [ripgrep User Guide](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)
- [fzf GitHub](https://github.com/junegunn/fzf)

---

← [[2-ZSH-Configuration|ZSH Configuration]] | [[_Mac Setup|Mac Setup Hub]] | [[4-Neovim-Setup|Neovim Setup]] →

**Last Updated:** 2025-10-21
