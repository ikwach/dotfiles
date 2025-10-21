# Neovim Setup

> Modern Neovim IDE configuration with LSP support

← [[3-CLI-Tools|CLI Tools]] | [[_Mac Setup|Mac Setup Hub]]

---

## Overview

Modern Neovim with LSP (Language Server Protocol) provides IDE-like features:
- Code completion
- Go-to-definition
- Find references
- Inline diagnostics
- Syntax highlighting
- Git integration
- File explorer
- Fuzzy finder

---

## Installation

### Install Neovim and Dependencies

```bash
# Core installation
brew install neovim ripgrep lazygit bottom gdu

# For development languages
brew install golang python3

# Python support for Neovim
python3 -m pip install --user --upgrade pynvim
```

### Backup Existing Configuration

**IMPORTANT:** Always backup before installing new config!

```bash
# Backup existing Neovim config
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

---

## Choose Your Distribution

### Option 1: AstroNvim (Recommended for Beginners)

**Pros:**
- Beginner-friendly
- Great out-of-box experience
- Extensive community plugins (AstroCommunity)
- 40+ language packs available
- Beautiful UI

**Installation:**
```bash
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim  # First launch auto-installs everything
```

**First Launch:**
- Be patient, it will download and install plugins
- Press `Space` when prompted
- Wait for all installations to complete

---

### Option 2: LazyVim (Faster, More Opinionated)

**Pros:**
- Blazing fast
- Very polished
- Excellent defaults
- Active development
- Great documentation

**Installation:**
```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim
```

---

## Configure Language Servers

After Neovim is installed, set up language servers for your languages.

### Using AstroNvim

```vim
# Launch Neovim
nvim

# Install language servers (in command mode)
:LspInstall python
:LspInstall lua
:LspInstall bash
:LspInstall typescript
:LspInstall json
:LspInstall yaml
:LspInstall go
:LspInstall html
:LspInstall css

# Install Tree-sitter parsers
:TSInstall python
:TSInstall lua
:TSInstall bash
:TSInstall typescript
:TSInstall json
:TSInstall yaml
:TSInstall go
:TSInstall html
:TSInstall css
```

### Check Installation

```vim
# Check LSP status
:LspInfo

# Check Mason (package manager)
:Mason

# Check Tree-sitter
:TSInstallInfo
```

---

## Essential Keybindings

### AstroNvim Keybindings

**Leader key:** `Space`

#### File Operations
```
<Space>e     - Toggle file explorer
<Space>o     - Focus file explorer
<Space>ff    - Find files
<Space>fo    - Find old files (recent)
<Space>fw    - Find word (ripgrep)
<Space>fc    - Find word under cursor
<Space>fb    - Find buffers
<Space>fh    - Find help
<Space>fm    - Find man pages
<Space>fr    - Find registers
<Space>fk    - Find keymaps
<Space>w     - Save file
<Space>q     - Quit
<Space>c     - Close buffer
<Space>C     - Force close buffer
```

#### Git Operations
```
<Space>gg    - Lazygit
<Space>gt    - Git status
<Space>gc    - Git commits
<Space>gb    - Git branches
<Space>gd    - Git diff
<Space>gh    - Git hunk preview
<Space>gs    - Stage hunk
<Space>gu    - Unstage hunk
<Space>gr    - Reset hunk
```

#### Terminal
```
<Space>tu    - Toggle terminal (up)
<Space>tf    - Toggle terminal (float)
<Space>th    - Toggle terminal (horizontal)
<Space>tv    - Toggle terminal (vertical)
<Ctrl+\>     - Toggle last terminal
```

#### LSP Features
```
K            - Hover documentation
gd           - Go to definition
gD           - Go to declaration
gi           - Go to implementation
gr           - Find references
<Space>la    - Code action
<Space>lf    - Format code
<Space>lr    - Rename symbol
<Space>ld    - Diagnostic float
<Space>lh    - Signature help
```

#### Navigation
```
Ctrl+h       - Move to left split
Ctrl+j       - Move to down split
Ctrl+k       - Move to up split
Ctrl+l       - Move to right split

]b           - Next buffer
[b           - Previous buffer
]t           - Next tab
[t           - Previous tab
]d           - Next diagnostic
[d           - Previous diagnostic
]g           - Next git hunk
[g           - Previous git hunk
```

#### Editing
```
gcc          - Toggle line comment
gbc          - Toggle block comment
<Space>h     - Clear search highlighting
u            - Undo
Ctrl+r       - Redo
.            - Repeat last action
```

#### Window Management
```
<Space>|     - Vertical split
<Space>-     - Horizontal split
Ctrl+w =     - Equalize splits
Ctrl+w >     - Increase width
Ctrl+w <     - Decrease width
Ctrl+w +     - Increase height
Ctrl+w -     - Decrease height
```

---

## Adding Custom Plugins

### Example: GitHub Copilot (Personal Projects Only)

Create plugin config in `~/.config/nvim/lua/plugins/`:

```bash
# Create plugins directory
mkdir -p ~/.config/nvim/lua/plugins

# Add Copilot plugin
cat > ~/.config/nvim/lua/plugins/copilot.lua << 'EOF'
return {
  "github/copilot.vim",
}
EOF
```

### Network Device Config Support

Add Junos and Cisco syntax highlighting:

```bash
cat > ~/.config/nvim/lua/plugins/network.lua << 'EOF'
return {
  "momota/junos.vim",
  "momota/cisco.vim",
}
EOF
```

**Usage:**
```vim
# For files without .junos or .cisco extension
:set ft=junos
# or
:set ft=cisco
```

### Plugin Installation

After adding plugin files:
```vim
# Restart Neovim or reload config
:source ~/.config/nvim/init.lua

# Plugins auto-install on next launch
# Or manually install
:Lazy install
```

---

## Common Workflows

### Editing Files
```bash
# Open file
nvim filename.py

# Open file at specific line
nvim +50 filename.py

# Open multiple files
nvim file1.py file2.py

# Open file explorer then select
nvim .
# Press <Space>e to toggle file tree
```

### Finding Files
```
1. Press <Space>ff
2. Start typing filename
3. Use ↑↓ to navigate
4. Press Enter to open
```

### Searching in Files
```
1. Press <Space>fw
2. Type search term
3. See live results with preview
4. Press Enter to jump to file
```

### Git Integration
```
1. Press <Space>gg (LazyGit opens)
2. Navigate with j/k
3. Stage with Space
4. Commit with c
5. Push with p
```

### Code Navigation
```
1. Put cursor on function/variable
2. Press gd (go to definition)
3. Press gr (find all references)
4. Press K (show documentation)
```

---

## Configuration Tips

### AstroNvim User Config

Create `~/.config/nvim/lua/user/init.lua` for custom settings:

```lua
return {
  -- Set colorscheme
  colorscheme = "dracula",  -- or "tokyonight", "catppuccin", "onedark"

  -- Configure options
  options = {
    opt = {
      relativenumber = true,  -- Relative line numbers
      spell = false,          -- Disable spell check
      wrap = false,           -- Disable line wrap
    },
  },

  -- Configure LSP
  lsp = {
    formatting = {
      format_on_save = true,  -- Auto-format on save
    },
  },
}
```

### Performance Tips

```lua
-- Disable unused providers (in user config)
vim.g.loaded_python_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
```

---

## Troubleshooting

### LSP Not Working

```vim
# Check LSP status
:LspInfo

# Check if Mason installed servers
:Mason

# Reinstall language server
:LspUninstall pyright
:LspInstall pyright

# Check logs
:LspLog
```

### Plugins Not Loading

```vim
# Check plugin status (AstroNvim)
:Lazy

# Update all plugins
:Lazy update

# Clean and reinstall
:Lazy clean
:Lazy install
```

### Slow Startup

```vim
# Profile startup time
nvim --startuptime startup.log

# Check which plugins are slow
# Then disable/lazy-load them
```

### Reset to Default

```bash
# Remove all Neovim data
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# Restore from backup
mv ~/.config/nvim.bak ~/.config/nvim

# Or reinstall fresh
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
```

---

## Learning Resources

### Within Neovim
```vim
:help                   # General help
:Tutor                 # Interactive tutorial
:help AstroNvim        # AstroNvim specific help
:help lsp              # LSP help
:checkhealth           # Check Neovim health
```

### External
- [AstroNvim Documentation](https://docs.astronvim.com/)
- [LazyVim Documentation](https://www.lazyvim.org/)
- [Neovim Quick Reference](https://neovim.io/doc/user/quickref.html)
- [Vim Cheat Sheet](https://vim.rtorr.com/)

---

## Alternative: VSCode

If Neovim is too steep a learning curve, VSCode is excellent:

```bash
brew install --cask visual-studio-code

# Install VSCode CLI
code --install-extension ms-python.python
code --install-extension golang.go
code --install-extension dbaeumer.vscode-eslint
```

**VSCode + Vim Motions:**
- Install "Vim" extension for Vim keybindings
- Get best of both worlds

---

← [[3-CLI-Tools|CLI Tools]] | [[_Mac Setup|Mac Setup Hub]]

**Last Updated:** 2025-10-21
